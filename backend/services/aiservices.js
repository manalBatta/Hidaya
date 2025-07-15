const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

async function getLastSession(userId) {
  const { data, error } = await supabase
    .from("chat_sessions")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (error) {
    console.error("Error fetching last session:", error);
    return null;
  }

  return data; // session row (id, user_id, created_at, etc.)
}

async function createNewSupabaseSession(userId) {
  const { data, error } = await supabase
    .from("chat_sessions")
    .insert([{ user_id: userId }])
    .select()
    .single();

  if (error) {
    console.error("Error creating new session:", error);
    throw new Error("Failed to create session");
  }

  return data; // new session row with id
}

async function saveChatMessage(sessionId, sender, message) {
  await supabase
    .from("chat_messages")
    .insert([{ session_id: sessionId, sender, message }]);

  // For now, just log and resolve
  console.log(`[${sender}] (${sessionId}): ${message}`);
}

async function fetchRecentMessages(sessionId, limit = 10) {
  const { data, error } = await supabase
    .from("chat_messages")
    .select("sender, message")
    .eq("session_id", sessionId)
    .order("timestamp", { ascending: true })
    .limit(limit);

  if (error) {
    console.error("Error fetching messages:", error);
    return [];
  }

  return data; // [{ sender: 'user', message: '...' }, ...]
}

function buildPrompt(user, history, message) {
  const franc = require("franc");
  const userLang = franc.franc(message);

  const toISO639_1 = require("iso-639-3-to-1");
  const langCode2 = toISO639_1(userLang);
  const language = langCode2 || "en";

  const intro = `
  You are an Islamic assistant helping a user named ${
    user.name || "Guest"
  } from ${user.city}, ${user.country}.
  They speak ${language} and are identified as ${user.gender}.
  Only answer with short, warm, clear Islamic responses. Provide 2-3 recommendations and ask gentle follow-up questions.
  `;

  const historyText = history
    .map((h) => `${h.sender === "user" ? "User" : "AI"}: ${h.message}`)
    .join("\n");

  return `${intro}\n\nPrevious Conversation:\n${historyText}\n\nNew Message:\nUser: ${message} Please answer in ${language} only, with no translation or transliteration.`;
}

async function sendToGemini(promptText) {
  const apiKey = process.env.GEMINI_API_KEY || "YOUR_API_KEY";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: promptText }],
          },
        ],
      }),
    }
  );

  const result = await response.json();

  // Defensive fallback if result is empty or malformed
  return result?.candidates?.[0]?.content?.parts?.[0]?.text || "No reply";
}

module.exports = {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  buildPrompt,
  sendToGemini,
};

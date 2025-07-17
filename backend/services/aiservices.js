const { createClient } = require("@supabase/supabase-js");
const ISO6391 = require("iso-639-1");
const cld3 = require("cld3-asm");

let cldFactory = null;
let identifier = null;

async function initLanguageIdentifier() {
  cldFactory = await cld3.loadModule({ timeout: 5000 });
  identifier = cldFactory.create(0, 512);
}

// Call this once at server startup
initLanguageIdentifier();

function detectLanguage(message) {
  if (!identifier) return "en";
  const result = identifier.findLanguage(message);
  if (result && result.is_reliable && result.language) {
    return result.language; // ISO 639-1 code
  }
  return "en";
}

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
  console.log("created new sessionid:", data.id, "for the userid:", userId);
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
    .order("timestamp", { ascending: false })
    .limit(limit);

  if (error) {
    console.error("Error fetching messages:", error);
    return [];
  }
  console.log("History messages", data);
  return data || [];
}

async function sendToGemini(promptText) {
  const apiKey = process.env.GEMINI_API_KEY || "YOUR_API_KEY";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "gemini-2.5-flash",
        contents: promptText,
      }),
    }
  );

  const result = await response.json();

  // Defensive fallback if result is empty or malformed
  console.log("result from gemini ", result);
  return result?.candidates?.[0]?.content?.parts?.[0]?.text || "No reply";
}

function buildPrompt(user, history, message, isStartWithHistory = false) {
  const supportedLanguages = ["en", "ar", "fr", "ur"];
  let language = detectLanguage(message) || "en";
  if (!supportedLanguages.includes(language)) {
    language = "en";
  }

  console.log("detectedLang:", language);

  let systemPromptText;
  if (isStartWithHistory) {
    // Greet and remind user of last topic if possible
    const lastUserMsg =
      history && history.length > 0
        ? history.filter((h) => h.sender === "user").slice(-1)[0]?.message
        : "";
    console.log("last message was", lastUserMsg);
    systemPromptText = `
You are a kind and knowledgeable Islamic assistant.
You are helping a user named ${user.displayName || "Guest"} from ${
      user.country || "an unknown country"
    }.

Greet the user with "As-salamu alaykum" in their language (${language}).
If there is context from previous messages, remind the user of the last topic discussed: ${
      lastUserMsg ? `"${lastUserMsg}"` : "(no previous topic)"
    }.

Always respond with warm, short, and respectful Islamic answers.

Before ending, suggest 2–3 things the user might want to ask next. Use the format:
Suggestions:
- Option 1
- Option 2
- Option 3

Suggestions must be under 15 words, no full sentences, no external resources, it should be about what can the conversation be about or what is the subject that the user may ask about next.

Reply only in ${language}. No transliteration. No English explanation.
    `.trim();
  } else {
    // Middle of conversation (default behavior)
    systemPromptText = `
You are a kind and knowledgeable Islamic assistant.
You are helping a user named ${user.displayName || "Guest"} from ${
      user.country || "an unknown country"
    }.

Always respond with warm, short, and respectful Islamic answers.

Do NOT start your answers with a greeting like "As-salamu alaykum" since you are in the middle of a conversation.

Before ending, suggest 2–3 things the user might want to ask next. Use the format:
Suggestions:
- Option 1
- Option 2
- Option 3

Suggestions must be under 15 words, no full sentences, no external resources, it should be about what can the conversation be about or what is the subject that the user may ask about next.

Reply only in ${language}. No transliteration. No English explanation.
    `.trim();
  }

  // Create system prompt as a user message (Gemini doesn't support role="system")
  const systemPrompt = {
    role: "user",
    parts: [
      {
        text: systemPromptText,
      },
    ],
  };

  // Convert message history into Gemini format
  const formattedHistory = history.map((h) => ({
    role: h.sender === "user" ? "user" : "model",
    parts: [{ text: h.message }],
  }));

  // Add the new user message
  const userMessage = {
    role: "user",
    parts: [{ text: message }],
  };

  // Combine all into one contents[] array
  const contents = [systemPrompt, ...formattedHistory, userMessage];

  return contents;
}

function buildWelcomePrompt(user) {
  const name = user.displayName || "dear friend";
  const location = user.country ? `from ${user.country}` : "";
  const genderGreeting = user.gender === "female" ? "sister" : "brother";

  const prompt = `
  Greet the user warmly. Their name is ${name}, and they are ${location}.
  Start with "As-salamu alaykum, ${genderGreeting}!"
  
  Offer a helpful message about what they can ask (e.g., prayer, Quran, life in Islam).
  Be friendly, supportive, and informative.
  
  `;

  return [
    {
      role: "user",
      parts: [{ text: prompt }],
    },
  ];
}

function buildContextualWelcome(user, lastUserMessage, history) {
  const name = user.displayName || "dear friend";
  const country = user.country || "your country";
  const language = "en";
  const topicHint = lastUserMessage ? lastUserMessage.message : "";
  if (history == undefined) history = [];
  const formattedHistory = history.map((h) => ({
    role: h.sender === "user" ? "user" : "model",
    parts: [{ text: h.message }],
  }));

  const prompt = `
You are a friendly and respectful Islamic guide.

Welcome the user by name: ${name}. 
Greet them with: "As-salamu alaykum" in their language: ${language}.
the user is from ${country}

if there is context previous messages use them to remind the user of the last topic were talking about then use that to guide the message.


Give 2-3 helpful suggestions related to ${topicHint} using the format:
Suggestions:
- Option 1
- Option 2
- Option 3


Keep suggestions under 15 words each. Avoid full sentences.it should be about what can the conversation be about or what is the subject that the user may ask about next.


Respond in ${language}.
`;

  return [
    ...formattedHistory,
    {
      role: "user",
      parts: [{ text: prompt }],
    },
  ];
}

module.exports = {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  buildPrompt,
  sendToGemini,
  buildWelcomePrompt,
  buildContextualWelcome,
};

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

module.exports = {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  detectLanguage,
};

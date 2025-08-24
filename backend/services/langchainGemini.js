import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { HumanMessage, AIMessage } from "@langchain/core/messages";
import {
  fetchRecentMessages,
  saveChatMessage,
  saveLongTermMemory,
  getRelevantMemory,
  getLastSession,
  createNewSupabaseSession,
} from "./aiservices.js";

// Set up Gemini LLM
const model = new ChatGoogleGenerativeAI({
  model: "gemini-1.5-flash",
  temperature: 0.3,
  apiKey: process.env.GEMINI_API_KEY,
});

// Main call: formats prompt and calls Gemini via LangChain
async function askGeminiWithLangchain({
  user,
  history,
  message,
  language = "en",
  lastUserMessage,
}) {
  const isReturning = message === "__resume__";
  const name = user?.displayName || "Guest";
  const country = user?.country || "an unknown country";
  console.log("is returning", isReturning);
  let systemPrompt;
  if (isReturning) {
    systemPrompt = `
    You are a wise, very kind Islamic advisor helping ${name} from ${country}. 
    Guide users with sincere care, rooted in authentic Islamic teachings.
    
    Support each user based on their background, past questions, and spiritual needs. 
    This user is returning to continue a previous conversation. Their last message was: "${lastUserMessage}".
    
    Welcome them warmly, for example:
    "As-salamu alaykum, ${name}. I was waiting for you."
    
    Ask if they would like to continue where they left off. 
    If they had a personal goal (e.g., prayer, behavior, emotion), gently follow up with encouragement.
    
    At the end of your answer, follow these steps:
    1. Understand the user's previous concern.
    2. Predict 2–3 **Islamic questions** they might naturally ask next.
    3. Keep suggestions relevant to their situation — not general advice.
    
    Use this exact format (no bold, no markdown, no extra newlines):
    Suggestions:
    - suggestion 1
    - suggestion 2
    - suggestion 3
    
    Suggestions must not include apps, links, or full sentences.
    Each suggestion must be under 12 words.  
    Reply only in ${language}. No transliteration. No English. No too long answers.
    IMPORTANT: Your answer must be less than 50 words. Do not exceed this limit.
     IMPORTANT: Do NOT use any Markdown, asterisks (), or bold. Use only plain text.

    `.trim();
  } else {
    systemPrompt = `
You are a wise, kind Islamic advisor helping ${name} from ${country}. 
Guide users with sincere care, rooted in authentic Islamic teachings.
 don't greet user. you are in the middle of a chat.
Support each user based on their background, questions, and needs. 
If they face problems, offer Islamic solutions and, when helpful, share real-life-inspired stories.

Your role spreads goodness, Islam, and peace. 
You are essential to our app and valued for your guidance.

At the end of your answer, follow these steps :
1-understand the current message topic
2- Predict 2 or 3 **next Islamic questions** the user might naturally ask.
3-These should be short, practical, and follow from their current concern — not general themes.
Use this exact format (no bold, no markdown, no extra newlines):
Suggestions:
- suggestion 1
- suggestion 2
- suggestion 3

Each suggestion must be under 15 words.  
Suggestions must have no apps suggestions, or links.
Reply only in ${language}. No transliteration.
IMPORTANT: Your answer must be less than 50 words. Do not exceed this limit.
 IMPORTANT: Do NOT use any Markdown, asterisks (), or bold. Use only plain text.

`.trim();
  }

  const chatHistory = history.map((item) => {
    return item.sender === "user"
      ? new HumanMessage(item.message)
      : new AIMessage(item.message);
  });

  if (message && message.trim() && !isReturning) {
    chatHistory.push(new HumanMessage(message));
  } else if (isReturning && lastUserMessage && lastUserMessage.trim()) {
    chatHistory.push(new HumanMessage("..."));
  }

  // Build the prompt as an array: system prompt first, then chat history
  const prompt = [new AIMessage(systemPrompt), ...chatHistory];
  console.log("prompt send to ai is", prompt);
  const result = await model.invoke(prompt);
  console.log("ai result.content", result);
  return result.content;
}

export { askGeminiWithLangchain };

// Helpers: memory gating and deduplication
function isMemoryWorthy(text) {
  if (!text) return false;
  const trimmed = text.trim();
  if (trimmed.length < 30) return false;
  const stopPhrases = [
    /^(hi|hello|thanks|thank you|ok|okay|bye|السلام|مرحبا)/i,
  ];
  let cleaned = trimmed;
  stopPhrases.forEach((regex) => {
    cleaned = cleaned.replace(regex, "").trim();
  });
  const keywords = [
    /\bi (prefer|like|love|live|work|study|plan|aim|goal|struggle|face|suffer|need|want)\b/i,
  ];
  keywords.forEach((regex) => {
    cleaned = cleaned.replace(regex, "").trim();
  });
  return cleaned.length > 0;
}

async function maybeSaveLongTermMemory(userId, text) {
  try {
    console.log(
      "maybeSaveLongTermMemory called with userId:",
      userId,
      "text:",
      text
    );
    if (!isMemoryWorthy(text)) {
      console.log("Text is not memory worthy, skipping save.");
      return;
    }
    const matches = await getRelevantMemory(userId, text, 1);
    console.log("Relevant memory matches found:", matches);
    if (Array.isArray(matches) && matches.length > 0) {
      console.log("Near-duplicate found, skipping save.");
      return; // near-duplicate, skip
    }
    await saveLongTermMemory(userId, text);
    console.log("Long-term memory saved for userId:", userId);
  } catch (err) {
    // Do not block chat flow on memory errors
    console.error("maybeSaveLongTermMemory error:", err);
  }
}

// New function: integrates short-term history with long-term memory (Supabase + embeddings)
export async function askGeminiWithLangGraph({ user, message }) {
  // 1️⃣ Get or create a single chat session (short-term memory)
  let session = await getLastSession(user.id);
  if (!session) {
    session = await createNewSupabaseSession(user.id);
  }
  const name = user?.displayName || "Guest";
  const country = user?.country || "an unknown country";
  const language = "en";
  const shortTermMessages = await fetchRecentMessages(session.id, 10);

  // 2️⃣ Fetch relevant long-term memory
  const longTermMemory = await getRelevantMemory(user.id, message, 3);

  // 3️⃣ System prompt
  const systemPrompt = `
You are a wise, kind Islamic advisor helping ${name} from ${country}. 
Guide users with sincere care, rooted in authentic Islamic teachings.
 don't greet user. you are in the middle of a chat.
Support each user based on their background, questions, and needs. 
If they face problems, offer Islamic solutions and, when helpful, share real-life-inspired stories.

Your role spreads goodness, Islam, and peace. 
You are essential to our app and valued for your guidance.

At the end of your answer, follow these steps :
1-understand the current message topic
2- Predict 2 or 3 **next Islamic questions** the user might naturally ask.
3-These should be short, practical, and follow from their current concern — not general themes.
Use this exact format (no bold, no markdown, no extra newlines):
Suggestions:
- suggestion 1
- suggestion 2
- suggestion 3

Each suggestion must be under 15 words.  
Suggestions must have no apps suggestions, or links.
Reply only in ${language}. No transliteration.
IMPORTANT: Your answer must be less than 50 words. Do not exceed this limit.
 IMPORTANT: Do NOT use any Markdown, asterisks (), or bold. Use only plain text.

`.trim();

  // 4️⃣ Build prompt with long-term memory + short-term context
  const prompt = [
    new AIMessage(systemPrompt),
    ...longTermMemory.map((m) => new AIMessage(`Remember: ${m}`)),
    ...shortTermMessages.map((m) =>
      m.sender === "user"
        ? new HumanMessage(m.message)
        : new AIMessage(m.message)
    ),
    new HumanMessage(message),
  ];

  // 5️⃣ Call Gemini
  const result = await model.invoke(prompt);

  // 6️⃣ Save messages
  await saveChatMessage(session.id, "user", message);
  await saveChatMessage(session.id, "ai", result.content);
  console.log("message saved to supabase");

  // 7️⃣ Save long-term memory (embed user's message)
  await maybeSaveLongTermMemory(user.id, message);
  console.log("long-term memory saved");

  // 8️⃣ User Matching System - Find similar users and record matches
  try {
    const { findSimilarUsers, recordUserMatch } = await import(
      "./aiservices.js"
    );

    // Find users with similar interests based on the current message
    const similarUsers = await findSimilarUsers(user.id, message, 3);
    console.log("Found similar users:", similarUsers.length);

    // Record matches with each similar user
    for (const similarUser of similarUsers) {
      if (similarUser.user_id && similarUser.user_id !== user.id) {
        const matchResult = await recordUserMatch(user.id, similarUser.user_id);
        if (matchResult) {
          console.log(
            `Match recorded with user ${similarUser.user_id}, count: ${matchResult.match_count}`
          );
        }
      }
    }
  } catch (err) {
    console.error("User matching error:", err);
    // Don't block the main chat flow on matching errors
  }

  return result.content;
}

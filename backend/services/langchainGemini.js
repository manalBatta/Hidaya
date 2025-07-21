const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { HumanMessage, AIMessage } = require("@langchain/core/messages");
// Set up Gemini LLM
const model = new ChatGoogleGenerativeAI({
  model: "gemini-1.5-flash",
  temperature: 0.3,
  apiKey: process.env.GEMINI_API_KEY,
});
// Converts your message history to LangChain format
function formatToLangchainMessages(history) {
  return history.map((item) => {
    return item.sender === "user"
      ? new HumanMessage(item.message)
      : new AIMessage(item.message);
  });
}

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

  const result = await model.invoke(prompt);
  return result.content;
}

module.exports = { askGeminiWithLangchain };

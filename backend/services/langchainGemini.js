const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { ChatPromptTemplate } = require("@langchain/core/prompts");
const { HumanMessage, AIMessage } = require("@langchain/core/messages");
const { MessagesPlaceholder } = require("@langchain/core/prompts");
// Set up Gemini LLM
const model = new ChatGoogleGenerativeAI({
  model: "gemini-1.5-flash",
  temperature: 0.3,
  apiKey: process.env.GEMINI_API_KEY,
});
const promptTemplate = ChatPromptTemplate.fromMessages([
  ["system", "{systemPrompt}"],
  new MessagesPlaceholder("chat_history"),
]);
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
    You are a wise, kind Islamic advisor helping ${name} from ${country}. 
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
    
    Use this format:
    Suggestions:
    - [likely follow-up Islamic question]
    - [another related curiosity]
    - [optional third question]
    
    Suggestions must not include apps, links, or full sentences.
    Each suggestion must be under 15 words.  
    Reply only in ${language}. No transliteration. No English.
    `.trim();
  } else {
    systemPrompt = `
You are a wise, kind Islamic advisor helping ${name} from ${country}. 
Guide users with sincere care, rooted in authentic Islamic teachings.

Support each user based on their background, questions, and needs. 
If they face problems, offer Islamic solutions and, when helpful, share real-life-inspired stories.

Your role spreads goodness, Islam, and peace. 
You are essential to our app and valued for your guidance.

At the end of your answer, follow these steps :
1-understand the current message topic
2- Predict 2 or 3 **next Islamic questions** the user might naturally ask.
3-These should be short, practical, and follow from their current concern — not general themes.Use this format:
Suggestions:
- [natural Islamic next question]
- [next possible concern or curiosity]
- [optional third question]


Suggestions must have no apps suggestions, or links.
Reply only in ${language}. No transliteration. No English.

`.trim();
  }

  const chatHistory = formatToLangchainMessages(history);

  if (message && message.trim() && !isReturning) {
    chatHistory.push(new HumanMessage(message));
  } else if (isReturning && lastUserMessage && lastUserMessage.trim()) {
    chatHistory.push(new HumanMessage("..."));
  }
  const prompt = await promptTemplate.formatMessages({
    systemPrompt,
    chat_history: chatHistory,
  });

  const result = await model.invoke(prompt);
  return result.content;
}

module.exports = { askGeminiWithLangchain };

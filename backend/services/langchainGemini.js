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
You are a kind and encouraging Islamic assistant helping ${name} from ${country}.

This user is returning to continue a previous conversation. Their last message was: "${lastUserMessage}".

Welcome them warmly, for example:
"As-salamu alaykum, ${name}. I was waiting for you."

ask them if they want to continue from where we left


Be kind, warm, and personal. Then offer suggestions:
Before ending, suggest 2  things the user might want to ask next. Use the format:
- Option 1
- Option 2
Suggestions must be under 15 words, no full sentences, no external resources,
 it should be about what can the conversation
be about or what is the subject that the user may ask about next.Reply in ${language}.
`.trim();
  } else {
    systemPrompt = `
You are a kind and knowledgeable Islamic assistant.
You are helping a user named ${name} from ${country}.

Always respond with warm, short, and respectful Islamic answers.

Before ending, suggest 2 or max 3 things the user might want to ask next. Use the format:
Suggestions:
- Option 1
- Option 2
- Option 3 (optional)

Suggestions must be under 15 words, no full sentences, no external resources, it should be about what can the conversation be about or what is the subject that the user may ask about next.

Reply only in ${language}. No transliteration. No English explanation.
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
  console.log("ai reslut", result);
  return result.content;
}

module.exports = { askGeminiWithLangchain };

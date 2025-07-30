import express from "express";
const router = express.Router();
import User from "../models/User.js";
import { askGeminiWithLangchain } from "../services/langchainGemini.js";

import {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  detectLanguage,
} from "../services/aiservices.js";

router.post("/start", async (req, res) => {
  const { userId } = req.body;

  try {
    const user = await User.findOne({ userId });
    let session = await getLastSession(userId);
    let greetingMessage;

    if (!session) {
      session = await createNewSupabaseSession(userId);
      await User.updateOne({ userId: userId }, { ai_session_id: session.id });

      // Use LangChain to generate welcome
      greetingMessage = await askGeminiWithLangchain({
        user,
        history: [],
        message: "start", // trigger for a warm intro
      });

      // Save greeting to Supabase
      await saveChatMessage(session.id, "ai", greetingMessage);
    } else {
      const recentMessages = await fetchRecentMessages(session.id);
      const lastUserMessage =
        recentMessages.filter((m) => m.sender === "user").slice(-1)[0]
          ?.message || "";
      //detect lang
      const language = detectLanguage(lastUserMessage);
      greetingMessage = await askGeminiWithLangchain({
        user,
        history: recentMessages,
        message: "__resume__", // Special marker
        /*         language,
         */ lastUserMessage,
      });

      await saveChatMessage(session.id, "ai", greetingMessage);
    }
    res.json({ sessionId: session.id, greeting: greetingMessage });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/send", async (req, res) => {
  const { userId, sessionId, message } = req.body;

  console.log("Received /send request:", { userId, sessionId, message });

  try {
    // Save user message to Supabase
    await saveChatMessage(sessionId, "user", message);
    console.log("Saved user message to Supabase");

    // Fetch previous messages for context (optional)
    const history = await fetchRecentMessages(sessionId);
    console.log("Fetched chat history:", history);

    // Get user profile from MongoDB
    const user = await User.findOne({ userId });
    console.log("Fetched user profile:", user);

    //detect lang
    const language = detectLanguage(message);
    console.log("Detected language:", language);

    // Call Gemini API
    const aiReply = await askGeminiWithLangchain({
      user,
      history,
      message,
      language,
    });
    console.log("AI reply from Gemini:", aiReply);

    // Save AI message to Supabase
    await saveChatMessage(sessionId, "ai", aiReply);
    console.log("Saved AI reply to Supabase");

    res.json({ reply: aiReply });
  } catch (error) {
    console.error("Error in /send route:", error);
    res.status(500).json({ error: error.message });
  }
});

export default router;

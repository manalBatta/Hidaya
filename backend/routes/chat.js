const express = require("express");
const router = express.Router();
const User = require("../models/User");
const { askGeminiWithLangchain } = require("../services/langchainGemini.js");

const {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  buildPrompt,
  sendToGemini,
  buildWelcomePrompt,
} = require("../services/aiservices.js");

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

      greetingMessage = await askGeminiWithLangchain({
        user,
        history: recentMessages,
        message: "__resume__", // Special marker
        lastUserMessage,
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

  try {
    // Save user message to Supabase
    await saveChatMessage(sessionId, "user", message);

    // Fetch previous messages for context (optional)
    const history = await fetchRecentMessages(sessionId);

    // Get user profile from MongoDB
    const user = await User.findOne({ userId });

    // Call Gemini API
    const aiReply = await askGeminiWithLangchain({
      user,
      history,
      message,
    });

    // Save AI message to Supabase
    await saveChatMessage(sessionId, "ai", aiReply);

    res.json({ reply: aiReply });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

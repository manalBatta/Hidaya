const express = require("express");
const router = express.Router();
const User = require("../models/User");
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
      const prompt = buildWelcomePrompt(user);
      greetingMessage = await sendToGemini(prompt);

      // Save to Supabase
      await saveChatMessage(session.id, "ai", greetingMessage);
    } else {
      const recentMessages = await fetchRecentMessages(session.id);

      console.log("recnet messages to continue: ", recentMessages);
      // Use buildPrompt with isStartWithHistory flag
      const prompt = buildPrompt(user, recentMessages, "", true);
      greetingMessage = await sendToGemini(prompt);
      // Save AI message
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

    // Compose prompt with personalization
    const prompt = buildPrompt(user, history, message);
    // Call Gemini API
    const aiReply = await sendToGemini(prompt);

    // Save AI message to Supabase
    await saveChatMessage(sessionId, "ai", aiReply);

    res.json({ reply: aiReply });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

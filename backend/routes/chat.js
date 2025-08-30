import express from "express";
const router = express.Router();
import User from "../models/User.js";
import {
  askGeminiWithLangchain,
  askGeminiWithLangGraph,
} from "../services/aiservices.js";

import {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
} from "../services/aiservices.js";

router.post("/start", async (req, res) => {
  const { userId } = req.body;

  try {
    console.log("=== CHAT START ROUTE DEBUG ===");
    console.log("User ID:", userId);

    const user = await User.findOne({ userId });
    console.log("User found:", user);
    console.log("User ai_session_id:", user?.ai_session_id);

    let session = await getLastSession(user._id);
    console.log("user id to fetch last session:", user._id);
    console.log("Last session found:", session ? "Yes" : "No");
    console.log("Session ID:", session?.id);

    let greetingMessage;
    let isNewSession = false;

    if (!session) {
      console.log("Creating new session...");
      session = await createNewSupabaseSession(userId);
      await User.updateOne({ userId: userId }, { ai_session_id: session.id });
      isNewSession = true;

      // Use LangChain to generate welcome
      greetingMessage = await askGeminiWithLangchain({
        user,
        history: [],
        message: "start", // trigger for a warm intro
      });

      // Save greeting to Supabase
      await saveChatMessage(session.id, "ai", greetingMessage);
      console.log("New session greeting saved:", greetingMessage);
    } else {
      console.log("Resuming existing session...");
      const recentMessages = await fetchRecentMessages(session.id);
      console.log("Recent messages count:", recentMessages.length);

      const lastUserMessage =
        recentMessages.filter((m) => m.sender === "user").slice(-1)[0]
          ?.message || "Asalamualaikum";
      console.log("Last user message:", lastUserMessage);

      greetingMessage = await askGeminiWithLangchain({
        user,
        history: recentMessages,
        message: "__resume__", // Special marker
        lastUserMessage,
      });

      await saveChatMessage(session.id, "ai", greetingMessage);
      console.log("Resume message saved:", greetingMessage);
    }

    // If this is a new session, also return the ai_session_id so frontend can set it
    const responseData = {
      ai_session_id: session.id,
      greeting: greetingMessage, // Only send greeting for new sessions
      isNewSession: isNewSession,
    };

    if (!user.ai_session_id) {
      responseData.ai_session_id = session.id;
      console.log("Setting new ai_session_id:", session.id);
    }

    console.log("Response data:", responseData);
    console.log("=== END CHAT START ROUTE DEBUG ===");

    res.json(responseData);
  } catch (error) {
    console.error("Error in chat start route:", error);
    res.status(500).json({ error: error.message });
  }
});

router.post("/send", async (req, res) => {
  const { userId, message, ai_session_id } = req.body;

  console.log("=== CHAT SEND ROUTE DEBUG ===");
  console.log("Received /send request:", { userId, message, ai_session_id });

  try {
    // Get user profile from MongoDB
    const user = await User.findOne({ userId });
    console.log("Fetched user profile:", user ? "Yes" : "No");
    console.log("User ai_session_id:", user?.ai_session_id);
    console.log("User ", user);

    // Call Gemini API with integrated short-term + long-term memory
    const aiReply = await askGeminiWithLangGraph({ user, message });
    console.log("AI reply from Gemini:", aiReply);

    console.log("=== END CHAT SEND ROUTE DEBUG ===");
    res.json({ reply: aiReply });
  } catch (error) {
    console.error("Error in /send route:", error);
    res.status(500).json({ error: error.message });
  }
});

export default router;

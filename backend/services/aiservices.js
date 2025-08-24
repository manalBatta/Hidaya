import { createClient } from "@supabase/supabase-js";
import { GoogleGenerativeAI } from "@google/generative-ai";
import cld3 from "cld3-asm";
import dotenv from "dotenv";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Ensure environment variables are loaded before using them
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, "..", "..");
const rootEnvPath = path.join(projectRoot, ".env");
if (fs.existsSync(rootEnvPath)) {
  dotenv.config({ path: rootEnvPath });
} else {
  dotenv.config();
}

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

// Initialize Google GenAI client for embeddings
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const embeddingModel = genAI.getGenerativeModel({
  model: "text-embedding-004",
});

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
  //console.log("History messages", data);
  return data || [];
}

// ----------------- Long-Term Memory -----------------
async function saveLongTermMemory(userId, text) {
  try {
    if (!text || !text.trim()) return;

    const { embedding } = await embeddingModel.embedContent(text);
    const vector = embedding?.values || [];

    const { error } = await supabase.from("user_memory").insert({
      user_id: userId,
      content: text,
      embedding: vector,
    });

    if (error) console.error("Error saving long-term memory:", error);
  } catch (err) {
    console.error("saveLongTermMemory exception:", err);
  }
}

// Fetch top-K relevant memories
async function getRelevantMemory(userId, query, matchCount = 3) {
  try {
    if (!query || !query.trim()) return [];

    // Generate embedding using Gemini
    const { embedding } = await embeddingModel.embedContent(query);
    const vector = embedding?.values || [];

    // Call Supabase function
    const { data, error } = await supabase.rpc("match_user_memory", {
      query_embedding: vector,
      match_threshold: 0.75,
      match_count: matchCount,
      user_id: userId, // text type in your SQL
    });

    if (error) {
      console.error("Error retrieving long-term memory:", error);
      return [];
    }

    // Each row has { id, content, similarity }
    return (
      data?.map((row) => ({
        id: row.id,
        content: row.content,
        similarity: row.similarity,
      })) || []
    );
  } catch (err) {
    console.error("getRelevantMemory exception:", err);
    return [];
  }
}

// ----------------- User Matching System -----------------

async function recordUserMatch(userA, userB) {
  if (!userA || !userB || userA === userB) return null;

  try {
    // Call your SQL function instead of doing upsert here
    const { data, error } = await supabase.rpc("increment_user_match", {
      first_user: userA,
      second_user: userB,
    });

    if (error) {
      console.error("Error saving match:", error);
      return null;
    }
    console.log("recordUserMatch data:", data);
    // Threshold check
    if (data && data.length > 0 && data[0].match_count >= 10) {
      console.log(
        "Users reached match threshold:",
        data[0].user_a,
        data[0].user_b
      );

      const connectionStatus = await checkConnectionStatus(
        data[0].user_a,
        data[0].user_b
      );

      if (!connectionStatus.bothAccepted) {
        await sendMatchNotification(data[0].user_a, data[0].user_b);
      }
    }

    return data[0];
  } catch (err) {
    console.error("recordUserMatch error:", err);
    return null;
  }
}

async function checkConnectionStatus(userA, userB) {
  try {
    const [first, second] = [userA, userB].sort();

    const { data, error } = await supabase
      .from("user_connections")
      .select("user_a_accepted, user_b_accepted")
      .eq("user_a", first)
      .eq("user_b", second)
      .single();

    if (error || !data) {
      return {
        bothAccepted: false,
        userAAccepted: false,
        userBAccepted: false,
      };
    }

    const bothAccepted = data.user_a_accepted && data.user_b_accepted;
    return {
      bothAccepted,
      userAAccepted: data.user_a_accepted,
      userBAccepted: data.user_b_accepted,
    };
  } catch (err) {
    console.error("checkConnectionStatus error:", err);
    return { bothAccepted: false, userAAccepted: false, userBAccepted: false };
  }
}

async function sendMatchNotification(userA, userB) {
  try {
    // Import notification service dynamically to avoid circular dependencies
    const { sendNotification } = await import("./notificationService.js");

    // Get user details for personalized messages
    const userADetails = await getUserDetails(userA);
    const userBDetails = await getUserDetails(userB);
    console.log(
      "sendMatchNotification",
      userADetails.userId,
      userBDetails.userId
    );
    if (userADetails && userBDetails) {
      // Send notification to user A
      await sendNotification({
        userId: userADetails.userId,
        type: "user_match",
        title: "Great News!  🌿A Special Connection opportinity",
        message: `We noticed that you and ${
          userBDetails.displayName || "another user"
        } have much in common. Would you like to connect and remind one another of Allah along this journey?`,
        data: {
          matchedUserId: userB,
          matchType: "initial",
        },
      });

      // Send notification to user B
      await sendNotification({
        userId: userBDetails.userId,
        type: "user_match",
        title: "Great News!  🌿A Special Connection opportinity",
        message: `We noticed that you and ${
          userADetails.displayName || "another user"
        } have much in common. Would you like to connect and remind one another of Allah along this journey?`,
        data: {
          matchedUserId: userA,
          matchType: "initial",
        },
      });
    }
  } catch (err) {
    console.error("sendMatchNotification error:", err);
  }
}

async function getUserDetails(userId) {
  //supabase uses user._id but send notifications uses user.userId
  try {
    // Import the User model from MongoDB
    const User = await import("../models/User.js");

    // Get user details from MongoDB
    const user = await User.default.findOne({ _id: userId });

    if (user) {
      return {
        userId: user.userId,
        displayName: user.displayName || `User ${userId.substring(0, 8)}`,
        email: user.email || `${userId.substring(0, 8)}@hidaya.app`,
        country: user.country || "Unknown",
        language: user.language || "en",
      };
    }

    // Fallback: check if user exists in chat_sessions (Supabase)
    const { data: sessionData, error: sessionError } = await supabase
      .from("chat_sessions")
      .select("user_id")
      .eq("user_id", userId)
      .single();

    if (sessionData) {
      // User exists in chat_sessions, return basic info
      return {
        displayName: `User ${userId.substring(0, 8)}`,
        email: `${userId.substring(0, 8)}@hidaya.app`,
        country: "Unknown",
        language: "en",
      };
    }

    // Final fallback: return basic user info
    return {
      displayName: `User ${userId.substring(0, 8)}`,
      email: `${userId.substring(0, 8)}@hidaya.app`,
      country: "Unknown",
      language: "en",
    };
  } catch (err) {
    console.error("getUserDetails error:", err);
    // Return fallback user info
    return {
      displayName: `User ${userId.substring(0, 8)}`,
      email: `${userId.substring(0, 8)}@hidaya.app`,
      country: "Unknown",
      language: "en",
    };
  }
}

async function acceptConnection(acceptingUserId, matchedUserId) {
  try {
    const [first, second] = [acceptingUserId, matchedUserId].sort();

    // Check if connection record exists
    const { data: existingConnection, error: checkError } = await supabase
      .from("user_connections")
      .select("*")
      .eq("user_a", first)
      .eq("user_b", second)
      .single();

    if (checkError && checkError.code !== "PGRST116") {
      // PGRST116 = no rows returned
      throw new Error(`Error checking connection: ${checkError.message}`);
    }

    let connectionData;

    if (existingConnection) {
      // Update existing connection
      const updateField =
        first === acceptingUserId ? "user_a_accepted" : "user_b_accepted";
      const { data, error } = await supabase
        .from("user_connections")
        .update({
          [updateField]: true,
          updated_at: new Date().toISOString(),
        })
        .eq("user_a", first)
        .eq("user_b", second)
        .select()
        .single();

      if (error) throw new Error(`Error updating connection: ${error.message}`);
      connectionData = data;
    } else {
      // Create new connection record
      const { data, error } = await supabase
        .from("user_connections")
        .insert({
          user_a: first,
          user_b: second,
          user_a_accepted: first === acceptingUserId,
          user_b_accepted: second === acceptingUserId,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (error) throw new Error(`Error creating connection: ${error.message}`);
      connectionData = data;
    }

    // Check if both users have now accepted
    const bothAccepted =
      connectionData.user_a_accepted && connectionData.user_b_accepted;

    if (bothAccepted) {
      // Send email exchange notification
      await sendEmailExchangeNotification(first, second);
    }

    return {
      success: true,
      bothAccepted,
      connectionData,
    };
  } catch (err) {
    console.error("acceptConnection error:", err);
    return {
      success: false,
      error: err.message,
    };
  }
}

async function sendEmailExchangeNotification(userA, userB) {
  try {
    const { sendNotification } = await import("./notificationService.js");

    const userADetails = await getUserDetails(userA);
    const userBDetails = await getUserDetails(userB);

    if (userADetails && userBDetails) {
      // Send notification to user A with user B's email
      await sendNotification({
        userId: userA,
        type: "connection_established",
        title: "Connection Established!",
        message: `You're now connected with ${
          userBDetails.displayName || "another user"
        }! Their email: ${userBDetails.email}`,
        data: {
          connectedUserId: userB,
          connectedUserEmail: userBDetails.email,
        },
      });

      // Send notification to user B with user A's email
      await sendNotification({
        userId: userB,
        type: "connection_established",
        title: "Connection Established!",
        message: `You're now connected with ${
          userADetails.displayName || "another user"
        }! Their email: ${userADetails.email}`,
        data: {
          connectedUserId: userA,
          connectedUserEmail: userADetails.email,
        },
      });
    }
  } catch (err) {
    console.error("sendEmailExchangeNotification error:", err);
  }
}

async function findSimilarUsers(userId, messageContent, limit = 5) {
  try {
    // Generate embedding for the message content
    const { embedding } = await embeddingModel.embedContent(messageContent);
    const vector = embedding?.values || [];

    // Find users with similar message content using the SQL function
    const { data, error } = await supabase.rpc("find_similar_users", {
      query_embedding: vector,
      current_user_id: userId,
      match_threshold: 0.7,
      match_count: limit,
    });
    if (error) {
      console.error("Error finding similar users:", error);

      // Fallback: try direct query if the function doesn't exist
      const { data: fallbackData, error: fallbackError } = await supabase
        .from("user_memory")
        .select("user_id, content")
        .neq("user_id", userId)
        .limit(limit);

      if (fallbackError) {
        console.error("Fallback query also failed:", fallbackError);
        return [];
      }

      // Return basic user info if the function doesn't exist
      return (
        fallbackData?.map((item) => ({
          user_id: item.user_id,
          display_name: `User ${item.user_id.substring(0, 8)}`,
          similarity: 0.5, // Default similarity score
        })) || []
      );
    }
    if (data) {
      const seen = new Set();
      const uniqueData = data.filter((item) => {
        if (seen.has(item.user_id)) return false;
        seen.add(item.user_id);
        return true;
      });
      console.log(uniqueData);
      return uniqueData || [];
    }
  } catch (err) {
    console.error("findSimilarUsers error:", err);
    return [];
  }
}

export {
  getLastSession,
  createNewSupabaseSession,
  saveChatMessage,
  fetchRecentMessages,
  detectLanguage,
  saveLongTermMemory,
  getRelevantMemory,
  // User matching exports
  recordUserMatch,
  acceptConnection,
  findSimilarUsers,
  checkConnectionStatus,
};

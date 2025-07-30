import express from "express";
import bodyParser from "body-parser";
import UserRoute from "./routes/userroutelogandregisteration.js";
import ChatRoute from "./routes/chat.js";
const app = express();
import cors from "cors";
import admin from "firebase-admin";
import CronService from "./services/cronService.js";
import fs from "fs";
import dotenv from "dotenv";
dotenv.config();

// Firebase Admin SDK initialization
const serviceAccount = JSON.parse(
  fs.readFileSync(new URL("./serviceAccountKey.json", import.meta.url), "utf-8")
);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Initialize simple cron service
new CronService();

app.use(cors());
app.use(bodyParser.json());
app.use("/", UserRoute);
app.use("/chat", ChatRoute);

export default app;

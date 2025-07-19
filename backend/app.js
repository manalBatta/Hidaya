const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/userroutelogandregisteration");
const ChatRoute = require("./routes/chat");
const app = express();
const cors = require("cors");

// Firebase Admin SDK initialization
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.use(cors());
app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/chat", ChatRoute);

module.exports = app;

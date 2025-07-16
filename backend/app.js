const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/userroutelogandregisteration");
const ChatRoute = require("./routes/chat");
const app = express();
const cors = require("cors");
app.use(cors());
app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/chat", ChatRoute);

module.exports = app;

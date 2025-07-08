
const express = require("express");
const bodyParser = require("body-parser")
const UserRoute = require("./routes/userroutelogandregisteration");
const app = express();
const cors = require('cors');
app.use(cors());
app.use(bodyParser.json())

app.use("/",UserRoute);

module.exports = app;
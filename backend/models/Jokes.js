import mongoose from "../config/db.js";

const { Schema } = mongoose;

const jokeSchema = new Schema({
  
  content: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000
  },
   reson:{
    type:String,
    required: true,
    trim: true,
    maxlength: 1000
   },
 
  createdAt: {
    type: Date,
    default: Date.now
  },
 
});


export default mongoose.model("Joke", jokeSchema, "Jokes");

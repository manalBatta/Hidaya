import Joke from "../models/Jokes.js";

class JokesServices {
  // Get all jokes for admin
  static async getAllJokesForAdmin() {
    try {
      const jokes = await Joke.find()
        .sort({ createdAt: -1 });
      
      return {
        success: true,
        jokes: jokes
      };
    } catch (error) {
      console.error("Error getting all jokes for admin:", error);
      return {
        success: false,
        message: "Failed to retrieve jokes",
        error: error.message
      };
    }
  }

  // Get jokes for users (only approved and active)
  static async getJokesForUsers() {
    try {
      
      const jokes = await Joke.find()
        .sort({ createdAt: -1 })
        .select('content reson ');


      return {
        success: true,
        jokes: jokes,
      };
    } catch (error) {
      console.error("Error getting jokes for users:", error);
      return {
        success: false,
        message: "Failed to retrieve jokes",
        error: error.message
      };
    }
  }

  // Create new joke
  static async createJoke(jokeData) {
    try {
      const joke = new Joke(jokeData);
      const savedJoke = await joke.save();
      
      return {
        success: true,
        message: "Joke created successfully",
        joke: savedJoke
      };
    } catch (error) {
      console.error("Error creating joke:", error);
      return {
        success: false,
        message: "Failed to create joke",
        error: error.message
      };
    }
  }

  // Update joke
  static async updateJoke(jokeId, updateData) {
    try {
      const joke = await Joke.findByIdAndUpdate(
        jokeId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true }
      );

      if (!joke) {
        return {
          success: false,
          message: "Joke not found"
        };
      }

      return {
        success: true,
        message: "Joke updated successfully",
        joke: joke
      };
    } catch (error) {
      console.error("Error updating joke:", error);
      return {
        success: false,
        message: "Failed to update joke",
        error: error.message
      };
    }
  }

  // Delete joke
  static async deleteJoke(jokeId) {
    try {
      const joke = await Joke.findByIdAndDelete(jokeId);

      if (!joke) {
        return {
          success: false,
          message: "Joke not found"
        };
      }

      return {
        success: true,
        message: "Joke deleted successfully",
        joke: joke
      };
    } catch (error) {
      console.error("Error deleting joke:", error);
      return {
        success: false,
        message: "Failed to delete joke",
        error: error.message
      };
    }
  }


 

 
}

export default JokesServices;

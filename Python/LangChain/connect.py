import getpass
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

if not os.environ.get("GEMINI_API_KEY"):
    import getpass
    os.environ["GEMINI_API_KEY"] = getpass.getpass("Enter API key for Google Gemini: ")

from langchain.chat_models import init_chat_model

model = init_chat_model("gemini-2.0-flash", model_provider="google_genai")

model.invoke("Hello, world!")
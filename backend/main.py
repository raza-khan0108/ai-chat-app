import os
import json
import logging
from typing import List, Optional, Dict, Any

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import aiohttp
from dotenv import load_dotenv

# 1. Load Environment Variables
load_dotenv()

# Configuration
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

# 2. Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 3. Initialize FastAPI App
app = FastAPI(title="Clarity.AI Backend")

# 4. Setup CORS (Cross-Origin Resource Sharing)
# This allows your Flutter app (running on a different port/device) to access this server.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# 5. Define Data Models
class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[Message]
    model: str = "openai/gpt-3.5-turbo" # Default model, can be changed

# 6. Stream Generator Function
async def stream_generator(payload: Dict[str, Any], headers: Dict[str, str]):
    """
    Connects to OpenRouter and yields chunks of data as they arrive.
    """
    async with aiohttp.ClientSession() as session:
        try:
            async with session.post(OPENROUTER_URL, json=payload, headers=headers) as response:
                if response.status != 200:
                    error_text = await response.text()
                    logger.error(f"OpenRouter API Error: {error_text}")
                    yield f"data: Error: {response.status} - {error_text}\n\n"
                    return

                # Iterate through the stream line by line
                async for line in response.content:
                    if line:
                        decoded_line = line.decode('utf-8').strip()
                        if decoded_line.startswith("data: "):
                            yield f"{decoded_line}\n\n"
                        elif decoded_line == "":
                            continue
                        else:
                            # Keep alive or other signals
                            pass
                            
        except Exception as e:
            logger.error(f"Stream error: {str(e)}")
            yield f"data: Internal Server Error: {str(e)}\n\n"

# 7. Main Chat Endpoint
@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    """
    Receives chat history from Flutter, forwards to OpenRouter, 
    and streams the text back.
    """
    if not OPENROUTER_API_KEY:
        raise HTTPException(status_code=500, detail="OpenRouter API Key not configured")

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/raza-khan0108/ai-chat-app", # OpenRouter requirement
        "X-Title": "Clarity.AI"
    }

    # Construct the payload for OpenRouter
    payload = {
        "model": request.model,
        "messages": [msg.dict() for msg in request.messages],
        "stream": True # Enable streaming
    }

    logger.info(f"Starting stream for model: {request.model}")
    
    # Return a StreamingResponse using Server-Sent Events (SSE)
    return StreamingResponse(
        stream_generator(payload, headers),
        media_type="text/event-stream"
    )

@app.get("/")
async def health_check():
    return {"status": "active", "service": "Clarity.AI Backend"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
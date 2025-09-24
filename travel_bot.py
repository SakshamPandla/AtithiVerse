import json
import os
import requests
import numpy as np
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_cors import CORS

# ------------------- Load Environment -------------------
load_dotenv()
PORT = 5001  # Different port from main website

# ------------------- Embedding Setup -------------------
try:
    from sentence_transformers import SentenceTransformer
    embedder = SentenceTransformer("all-MiniLM-L6-v2")
    print("✅ Embedding model loaded successfully.")
except ImportError:
    print("⚠️ sentence-transformers not installed. Falling back to keyword search.")
    embedder = None
except Exception as e:
    print(f"⚠️ Could not initialize embedder: {e}. Falling back to keyword search.")
    embedder = None

# ------------------- Dummy Document Loading -------------------
# Replace this with actual loading logic from your data source
try:
    # Example: load from a local JSON or text file
    with open("data/documents.json", "r", encoding="utf-8") as f:
        documents = json.load(f)
except FileNotFoundError:
    print("⚠️ No documents found. Using empty list.")
    documents = []

# ------------------- Ollama Setup -------------------
OLLAMA_SERVER = os.getenv("OLLAMA_SERVER", "http://localhost:11434")
OLLAMA_CHAT_MODEL = os.getenv("OLLAMA_CHAT_MODEL", "llama3")  # default model

# ------------------- Flask App -------------------
app = Flask(__name__)

# Updated CORS to allow your main website
CORS(app, resources={
    r"/*": {"origins": [
        "http://127.0.0.1:5000",  # Your main AtithiVerse website
        "http://localhost:5000",
        "http://127.0.0.1:5001",  # Alternative port
        "http://localhost:5001",
        "https://travel-buddy-ga201.netlify.app"
    ]}
})

# ------------------- Routes -------------------
@app.route('/travel-chat', methods=['POST'])
def enhanced_travel_chat():
    try:
        if not request.json or 'user_input' not in request.json:
            return jsonify({'error': 'Missing user_input in request'}), 400
            
        user_input = request.json['user_input']
        user_context = request.json.get('context', {})

        system_prompt = """You are AtithiBot, an expert Indian travel assistant for AtithiVerse tourism platform. 

IMPORTANT GUIDELINES:
- Provide specific, actionable travel advice for India
- Include approximate costs in Indian Rupees (₹)
- Mention best times to visit
- Suggest both budget and luxury options
- Be enthusiastic about Indian culture and destinations
- Keep responses under 200 words for better readability
- Use emojis to make responses engaging
- Always end with a follow-up question to keep conversation going

Available destinations on our platform:
• Taj Mahal, Agra (₹500/person)
• Goa Beaches (₹350/person)  
• Jaipur City Palace (₹400/person)
• Kerala Backwaters (₹1,200/person)
• Himalayan Adventures (₹2,500/person)
• Udaipur Lake Palace (₹15,000/person)

If users show interest in any destination, mention they can book directly through our website."""

        payload = {
            "model": OLLAMA_CHAT_MODEL,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_input}
            ],
            "stream": False
        }

        try:
            response = requests.post(f"{OLLAMA_SERVER}/api/chat", json=payload, timeout=30)
            response.raise_for_status()
            completion = response.json()
            chatbot_reply = completion.get("message", {}).get("content", "Sorry, no response generated.")
        except requests.exceptions.RequestException as e:
            print(f"⚠️ Ollama API error: {e}")
            chatbot_reply = get_travel_fallback(user_input)

        return jsonify({
            "response": chatbot_reply,
            "ai_powered": True,
            "suggestions": get_quick_suggestions(user_input)
        })
        
    except Exception as e:
        print(f"❌ Error in /travel-chat endpoint: {e}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500

# ------------------- Helper Functions -------------------
def get_travel_fallback(user_input):
    """Enhanced travel-specific fallback responses"""
    input_lower = user_input.lower()
    
    if any(word in input_lower for word in ['taj mahal', 'agra']):
        return "🏛️ The Taj Mahal is absolutely breathtaking! Visit early morning (6 AM) for the best experience and fewer crowds. Entry is ₹500 for Indians, ₹1100 for foreigners. Best photographed during sunrise or sunset. The monument is closed on Fridays. Would you like help planning your Agra itinerary?"
    
    elif any(word in input_lower for word in ['goa', 'beach']):
        return "🏖️ Goa is perfect year-round, but November-March offers the best weather! Popular beaches: Baga & Calangute (lively), Palolem & Arambol (peaceful). Budget: ₹2,000-4,000/day, Luxury: ₹8,000+/day. Try water sports, beach shacks, and vibrant nightlife! Which type of Goa experience interests you?"
    
    elif any(word in input_lower for word in ['kerala', 'backwaters']):
        return "🌴 Kerala's backwaters are magical! Alleppey & Kumarakom offer the best houseboat experiences. Costs: ₹3,000-12,000/night depending on luxury level. Best time: October-March. Don't miss: Ayurvedic spa treatments, toddy tapping, and traditional Kerala meals. Planning a romantic getaway or family trip?"
    
    elif any(word in input_lower for word in ['rajasthan', 'jaipur', 'palace']):
        return "🏰 Rajasthan is a royal treat! Jaipur (Pink City), Udaipur (City of Lakes), Jodhpur (Blue City) form the Golden Triangle. Palace hotels from ₹5,000-50,000/night. Best time: October-March. Must-do: Camel safari, folk performances, heritage walks. Interested in luxury palace stays or budget heritage tours?"
    
    elif any(word in input_lower for word in ['budget', 'cheap', 'affordable']):
        return "💰 India is incredibly budget-friendly! Daily costs:\n• Hostels: ₹500-1,500\n• Local food: ₹200-800\n• Local transport: ₹100-500\n• Attractions: ₹50-500\n\nTotal: ₹1,500-3,000/day for comfortable budget travel. Street food, local trains, and budget hotels offer authentic experiences! What's your daily budget range?"
    
    elif any(word in input_lower for word in ['best time', 'when', 'weather']):
        return "🌤️ India's diverse climate offers year-round travel! \n• **Oct-Mar**: Pleasant weather, peak season\n• **Apr-Jun**: Hot, perfect for hill stations\n• **Jul-Sep**: Monsoon, lush landscapes in Kerala/Western Ghats\n\nEach season has its charm! Which region interests you most?"
    
    else:
        return "🇮🇳 Welcome to AtithiVerse! I'm here to help you discover Incredible India. Whether you're interested in iconic monuments, pristine beaches, royal palaces, or spiritual journeys - I can create the perfect itinerary for you! What type of experience are you looking for?"

def get_quick_suggestions(user_input):
    """Generate contextual quick action buttons"""
    input_lower = user_input.lower()
    
    if any(word in input_lower for word in ['taj mahal', 'agra']):
        return [
            "Best time to visit Taj Mahal",
            "Agra itinerary for 2 days", 
            "Hotels near Taj Mahal",
            "Book Taj Mahal tour"
        ]
    elif any(word in input_lower for word in ['goa', 'beach']):
        return [
            "Best beaches in Goa",
            "Goa nightlife guide",
            "Water sports in Goa", 
            "Book Goa package"
        ]
    elif any(word in input_lower for word in ['budget']):
        return [
            "Budget India itinerary",
            "Cheap places to stay",
            "Free attractions in India",
            "Budget food options"
        ]
    else:
        return [
            "Popular destinations",
            "Best time to visit India",
            "Budget travel tips",
            "Plan my trip"
        ]

# ------------------- Entry Point -------------------
if __name__ == '__main__':
    print("=" * 50)
    print(f"🤖 Starting Enhanced AtithiVerse AI Travel Assistant")
    print(f"📍 Port: {PORT}")
    print(f"🔍 Search Method: {'Embeddings' if embedder else 'Keyword Search'}")
    print(f"📚 Documents Loaded: {len(documents)}")
    print(f"🤖 Ollama Server: {OLLAMA_SERVER}")
    print(f"🧠 Model: {OLLAMA_CHAT_MODEL}")
    print("=" * 50)
    
    app.run(host="0.0.0.0", port=int(PORT), debug=True)

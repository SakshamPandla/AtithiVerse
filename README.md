# AtithiVerse

AtithiVerse is a web-based travel service platform that combines a main website with an AI-powered travel assistant.

## 🚀 Features

- Main website running on port 5000
- AI travel assistant service on port 5001
- Integrated service management system

## 🛠️ Setup

### Prerequisites

- Python 3.x
- Required Python packages (requirements.txt)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/AtithiVerse.git
cd AtithiVerse
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## 🏃‍♂️ Running the Application

Start both services using the service starter script:

```bash
python start_services.py
```

This will:
- Launch the AI travel assistant on port 5001
- Start the main website on port 5000

## 📁 Project Structure

```
AtithiVerse/
├── Website/
│   └── app.py          # Main website application
├── travel_bot.py       # AI travel assistant service
├── start_services.py   # Service management script
└── README.md          # This file
```

## 🛑 Stopping the Services

To stop all services, press `Ctrl+C` in the terminal running the `start_services.py` script.

## 👥 Contributing

Feel free to submit issues and pull requests.


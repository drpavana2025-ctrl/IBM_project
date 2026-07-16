#!/bin/bash
# LAMAS — Development startup script

echo "🏛️  Starting LAMAS — AI Legal Aid Multi-Agent System"
echo "   Powered by IBM watsonx"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.11+"
    exit 1
fi

# Setup backend
echo "📦 Setting up backend..."
cd backend

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "   Virtual environment created"
fi

source .venv/bin/activate 2>/dev/null || source .venv/Scripts/activate

pip install -r requirements.txt -q

# Copy .env if not exists
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "   ⚠️  Created .env from .env.example — update IBM API keys before connecting watsonx"
fi

# Seed database
echo "🌱 Seeding demo database..."
python seed_db.py 2>/dev/null || true

# Start backend
echo ""
echo "🚀 Starting FastAPI backend on http://localhost:8000"
echo "   API docs: http://localhost:8000/api/docs"
echo ""
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

cd ..

echo "💡 Frontend: cd frontend && npm install && npm run dev"
echo ""
echo "Press Ctrl+C to stop the backend"
wait $BACKEND_PID

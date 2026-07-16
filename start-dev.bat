@echo off
echo  LAMAS — AI Legal Aid Multi-Agent System
echo  Powered by IBM watsonx
echo.

:: Setup backend virtual environment
cd backend

if not exist ".venv" (
    python -m venv .venv
    echo Virtual environment created
)

call .venv\Scripts\activate.bat

pip install -r requirements.txt -q

:: Copy .env if not exists
if not exist ".env" (
    copy .env.example .env
    echo Created .env from .env.example - update IBM API keys!
)

:: Seed database
echo Seeding demo database...
python seed_db.py 2>nul

echo.
echo  Starting FastAPI backend on http://localhost:8000
echo  API docs: http://localhost:8000/api/docs
echo.

start "LAMAS Backend" python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

cd ..
echo  Backend started in separate window
echo.
echo  For frontend: cd frontend, npm install, npm run dev
echo.
pause

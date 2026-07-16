@echo off
setlocal EnableDelayedExpansion
title LAMAS — AI Legal Aid Multi-Agent System

echo.
echo  ==========================================================
echo   LAMAS — AI Legal Aid Multi-Agent System
echo   Powered by IBM watsonx
echo  ==========================================================
echo.

:: ─── Check Python ───────────────────────────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Python is not installed or not on PATH.
    echo          Download from https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  [OK] %%v found

:: ─── Check Node / npm ───────────────────────────────────────────────────────
node --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [WARN] Node.js is not installed or not on PATH.
    echo         Frontend will NOT start.
    echo         Download from https://nodejs.org  (LTS recommended)
    echo.
    set NO_NODE=1
) else (
    for /f "tokens=*" %%v in ('node --version 2^>^&1') do echo  [OK] Node %%v found
    set NO_NODE=0
)
echo.

:: ─── Backend setup ──────────────────────────────────────────────────────────
echo  [1/4] Setting up backend...
cd backend

:: Create virtual environment if missing
if not exist ".venv\Scripts\activate.bat" (
    echo        Creating Python virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo  [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
)

:: Activate venv
call .venv\Scripts\activate.bat

:: Install / upgrade pip quietly
python -m pip install --upgrade pip --quiet

:: Install dependencies (relaxed pins for Python 3.12+, binary-only where possible)
echo        Installing backend dependencies (this may take a few minutes on first run)...
pip install --only-binary :all: --quiet ^
    "fastapi>=0.115" "uvicorn[standard]>=0.30" "python-multipart>=0.0.9" ^
    "pydantic>=2.9" "pydantic-settings>=2.5" "httpx>=0.27" ^
    "python-jose[cryptography]>=3.3" "passlib[bcrypt]>=1.7.4" ^
    "sqlalchemy>=2.0.35" "alembic>=1.13" "asyncpg>=0.29" "aiosqlite>=0.20" ^
    "aiofiles>=24.1" "python-dotenv>=1.0" "loguru>=0.7" "jinja2>=3.1" ^
    "slowapi>=0.1.9" "python-dateutil>=2.9" "redis>=5.1" ^
    "elasticsearch>=8.15" "pytest>=8.3" "pytest-asyncio>=0.24" ^
    "pdfplumber>=0.11" "python-docx>=1.1" "kafka-python>=2.0" ^
    "celery>=5.4" "tiktoken>=0.7" "pymilvus>=2.4" ^
    "langchain>=0.3" "langchain-core>=0.3" "langchain-community>=0.3" ^
    "weasyprint>=62" "email-validator" "tabulate" ^
    "numpy>=2.3" "pandas>=2.2" "sentence-transformers>=3.1" 2>nul

:: IBM packages (no-deps to avoid pandas version conflicts)
pip install --only-binary :all: --no-deps --quiet "ibm-watsonx-ai>=1.1" 2>nul
pip install --only-binary :all: --no-deps --ignore-requires-python --quiet "langchain-ibm>=0.3" 2>nul

:: json-repair needed by langchain-ibm
pip install --only-binary :all: --quiet "json-repair>=0.30,<1.0" 2>nul

echo  [OK] Backend dependencies ready.

:: Copy .env if missing
if not exist ".env" (
    copy .env.example .env >nul
    echo  [OK] Created backend\.env from .env.example
    echo       Edit backend\.env to add your IBM watsonx API keys.
) else (
    echo  [OK] backend\.env already exists.
)

:: Seed demo database if db is missing
if not exist "lamas.db" (
    echo        Seeding demo database...
    python seed_db.py
    if errorlevel 1 (
        echo  [WARN] seed_db.py failed — continuing without seed data.
    ) else (
        echo  [OK] Demo database seeded.
    )
) else (
    echo  [OK] Database already exists, skipping seed.
)

echo.

:: ─── Start Backend ──────────────────────────────────────────────────────────
echo  [2/4] Starting FastAPI backend on http://localhost:8000
echo        API docs: http://localhost:8000/api/docs
start "LAMAS Backend" cmd /k "cd /d %~dp0backend && call .venv\Scripts\activate.bat && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"
echo  [OK] Backend launched in a new window.
echo.

cd ..

:: ─── Frontend setup ─────────────────────────────────────────────────────────
if "%NO_NODE%"=="1" (
    echo  [SKIP] Frontend skipped — Node.js not found.
    echo         Install Node.js from https://nodejs.org then re-run this script.
    goto :done
)

echo  [3/4] Setting up frontend...
cd frontend

if not exist "node_modules" (
    echo        Running npm install (first run — may take a minute)...
    npm install
    if errorlevel 1 (
        echo  [ERROR] npm install failed. Check Node.js installation.
        cd ..
        goto :done
    )
) else (
    echo  [OK] node_modules already present.
)
echo  [OK] Frontend dependencies ready.
echo.

:: ─── Start Frontend ─────────────────────────────────────────────────────────
echo  [4/4] Starting React frontend on http://localhost:3000
start "LAMAS Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"
echo  [OK] Frontend launched in a new window.
echo.

cd ..

:done
echo  ==========================================================
echo   LAMAS is running!
echo.
echo   Backend  : http://localhost:8000
echo   API Docs : http://localhost:8000/api/docs
if "%NO_NODE%"=="0" (
echo   Frontend : http://localhost:3000
)
echo.
echo   Demo login:
echo     Email   : demo@lamas.ai
echo     Password: Demo@12345
echo  ==========================================================
echo.
echo  Press any key to close this setup window.
echo  (Backend and frontend continue running in their own windows.)
echo.
pause
endlocal

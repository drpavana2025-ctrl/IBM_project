# LAMAS — AI Legal Aid Multi-Agent System

> **Disclaimer:** This system provides general legal information only and is **not a substitute for professional legal advice**. Always consult a qualified lawyer for specific legal matters.

## Overview

LAMAS is a full-stack AI-powered Legal Aid Multi-Agent System built on **IBM watsonx** technologies. It provides contract review, compliance checking, legal Q&A with RAG, and case research through specialised collaborating AI agents.

## Architecture

```
frontend/          React 18 + TypeScript + Vite + TailwindCSS
backend/           FastAPI + Python 3.11
  ├── app/
  │   ├── api/           REST endpoints
  │   ├── core/          Config, DB, security
  │   ├── models/        SQLAlchemy ORM + Pydantic schemas
  │   └── services/
  │       ├── agents/    4 specialist agents + orchestrator
  │       ├── watsonx_client.py   IBM Granite LLM wrapper
  │       ├── vector_store.py     Milvus + Elasticsearch
  │       ├── ingestion.py        Document pipeline
  │       └── report_service.py  PDF generation
docker-compose.yml   Full stack + Milvus + Elasticsearch + Redis
```

## Quick Start

### Backend (Python 3.11+)

```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate

pip install -r requirements.txt
cp .env.example .env          # Edit with your IBM API keys
python seed_db.py              # Seed demo data
python -m uvicorn main:app --reload      # http://localhost:8000
```

### Frontend (Node 20+)

```bash
cd frontend
npm install
npm run dev                    # http://localhost:3000
```

### Docker (full stack)

```bash
docker-compose up -d
```

## Demo Credentials

```
Email:    demo@lamas.ai
Password: Demo@12345
```

## IBM watsonx Configuration

Edit `backend/.env`:

```env
WATSONX_API_KEY=your_ibm_api_key
WATSONX_PROJECT_ID=your_project_id
WATSONX_URL=https://us-south.ml.cloud.ibm.com
```

> Without IBM credentials, the system runs in **demo mode** with mock LLM responses and pre-seeded data.

## Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| Orchestrator | Granite 13B | Intent classification, routing, merging |
| Contract Reviewer | Granite 34B | Clause extraction, risk scoring |
| Compliance Checker | Granite 13B + Rules | GDPR/CCPA/ISO gap analysis |
| Q&A RAG Agent | Granite 13B + Milvus | Hybrid retrieval, legal Q&A |
| Case Research | Granite 34B + Watson Discovery | Case law search & summarisation |

## API Documentation

Once running: **http://localhost:8000/api/docs**

## Testing

```bash
cd backend
pytest tests/ -v
```

## Technology Stack

- **Frontend:** React 18, TypeScript, Vite, TailwindCSS, Recharts, Zustand
- **Backend:** FastAPI, SQLAlchemy (async), Pydantic v2
- **AI/LLM:** IBM Granite 13B/34B via watsonx.ai
- **Vector DB:** Milvus 2.4 (IBM watsonx.data)
- **Search:** Elasticsearch 8 (BM25)
- **Storage:** IBM Cloud Object Storage
- **Auth:** JWT (IBM AppID in production)
- **Container:** Docker + Docker Compose
- **Orchestration:** RedHat OpenShift (production)

## Legal Disclaimer

All AI-generated content in LAMAS is for informational purposes only. The system **does not provide legal advice** and is not a substitute for consultation with a qualified and licensed lawyer. Risk scores, compliance assessments, and contract analyses are indicative only.

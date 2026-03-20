# Reference: escritha-book (FastAPI + Python + PGVector)

## Folder structure

```
app/
├── __init__.py
├── config.py          # Settings via pydantic-settings + .env
├── main.py            # FastAPI app + endpoints + CORS
├── models.py          # Pydantic schemas (request/response)
├── prompts.py         # LLM prompt templates
├── rag_service.py     # Core logic: ingestion, chunking, embeddings, querying
└── pgvector_store/
    ├── __init__.py
    └── store.py       # Vector store implementation (LlamaIndex/PGVector)
```

### File responsibilities
- **`config.py`**: reads environment variables and validates them via `pydantic-settings`
- **`main.py`**: route definitions, app initialization, HTTP error handling
- **`models.py`**: all Pydantic input and output schemas
- **`rag_service.py`**: all business logic (do not put rules in `main.py`)
- **`prompts.py`**: prompt strings kept separate from logic code

---

## Creating a new endpoint

```python
# app/main.py

from app.models import MyRequest, MyResponse

@app.post(
    "/my-endpoint",
    response_model=MyResponse,
    summary="Short description of the endpoint",
)
async def my_endpoint(request: MyRequest) -> MyResponse:
    """Detailed description of what the endpoint does."""
    try:
        result = await _rag_service.my_method(request.field)
        return MyResponse(result=result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")
```

Rules:
- Always define `response_model` in the decorator
- Business logic **never** lives in the endpoint — delegate to `rag_service`
- Use `HTTPException` for expected errors (do not return error dicts manually)
- Use `async def` for I/O-bound operations

---

## Schema pattern (Pydantic)

```python
# app/models.py
from pydantic import BaseModel, Field
from typing import Optional, List

class MyRequest(BaseModel):
    required_field: str = Field(..., description="Field description")
    optional_field: Optional[str] = Field(None, description="Optional field")
    limit: int = Field(10, ge=1, le=100, description="Between 1 and 100")

class MyResponse(BaseModel):
    success: bool
    data: List[str]
    message: Optional[str] = None
```

Rules:
- All fields must use `Field(...)` with a `description`
- Use `Optional[T]` + `Field(None)` for optional fields (not `T | None`)
- Never return dicts from endpoints — always return `BaseModel` instances

---

## Configuration (Settings)

```python
# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str
    PGVECTOR_SCHEMA: str = "public"
    PGVECTOR_TABLE: str = "rag_documents"
    PGVECTOR_COLLECTION_NAME: str = "scientific-papers"

    # New configuration
    MY_NEW_PARAM: str = "default_value"

    class Config:
        env_file = ".env"

def get_settings() -> Settings:
    return Settings()
```

Never access `os.environ` directly — always use `get_settings()`.

---

## Response and error pattern

### Success responses
Always typed via `response_model`. The global exception handler already formats unhandled errors:

```python
# Already implemented in main.py — do not replicate
@app.exception_handler(Exception)
async def unhandled_exception_handler(request, exc):
    return JSONResponse(status_code=500, content={"detail": str(exc)})
```

### HTTP status codes used in the project
| Situation | Code |
|---|---|
| Successful creation | 201 |
| Generic success | 200 |
| Invalid input data | 400 |
| Unsupported format | 415 |
| Not found | 404 |
| Internal error | 500 |

---

## Database (PGVector)

The `PGVectorStore` in `pgvector_store/store.py` manages table creation and the `vector` extension:

```python
# Real table name derived from settings
self._table_name = f"data_{settings.pgvector_table}"
# default: "data_rag_documents"
```

The `pgvector` extension is guaranteed on startup:
```python
cur.execute("CREATE EXTENSION IF NOT EXISTS vector")
```

When adding new fields or tables, do so via an explicit SQL migration — do not change the main table schema without updating `store.py`.

---

## Python conventions

- Typing: always use type hints (`def my_method(text: str) -> list[str]:`)
- Prompt strings: always in `prompts.py`, never inline in the service
- Environment variables: always via `Settings` in `config.py`
- Naming: `snake_case` for everything except classes (which use `PascalCase`)
- Imports: order by stdlib → third-party → local (PEP8 standard)

```python
# ✅ Correct import order
import os
from pathlib import Path

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app.config import get_settings
from app.models import QueryRequest
```

---

## Tests

`escritha-book` does not yet have formal test coverage. When writing tests:

- Use **pytest** + **httpx** for endpoint tests
- File: `tests/test_<n>.py`
- Mock `RAGService` in endpoint tests

```python
# tests/test_query.py
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.anyio
async def test_query_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/query", json={"query": "test", "limit": 5})
    assert response.status_code == 200
```
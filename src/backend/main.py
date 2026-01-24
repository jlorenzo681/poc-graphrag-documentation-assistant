from fastapi import FastAPI
from src.backend.routers import health, documents, tasks
from src.backend.middleware.cors import setup_cors
from src.backend.middleware.logging import LoggingMiddleware
from src.backend.middleware.error_handler import setup_error_handlers, logger as error_logger

# Initialize Application
app = FastAPI(title="RAG Chatbot API")

# 1. Setup Middleware
setup_cors(app)
app.add_middleware(LoggingMiddleware)
setup_error_handlers(app)

# 2. Include Routers
app.include_router(health.router)
app.include_router(documents.router)
app.include_router(tasks.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.backend.main:app", host="0.0.0.0", port=8000, reload=True)

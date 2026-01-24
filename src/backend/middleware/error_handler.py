from fastapi import Request, FastAPI
from fastapi.responses import JSONResponse
import logging

logger = logging.getLogger("error_handler")

def setup_error_handlers(app: FastAPI):
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        logger.error(f"Global exception: {str(exc)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal Server Error",
                "detail": str(exc)
            },
        )

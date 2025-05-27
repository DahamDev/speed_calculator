from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.core.logging_config import setup_logging
from app.api.endpoints import router
from app.core.exceptions import ValidationException
from fastapi.middleware.cors import CORSMiddleware

setup_logging()

def create_application() -> FastAPI:
    app = FastAPI(
        title=settings.API_TITLE,
        description=settings.API_DESCRIPTION,
        version=settings.API_VERSION,
        docs_url="/docs",
        redoc_url="/redoc",
    )
    app.include_router(router, prefix="/api")
    return app
app = create_application()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWD_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
)


#######  Exception handlers  #######

@app.exception_handler(ValidationException)
async def speed_calculator_exception_handler(request: Request, exc: ValidationException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.__class__.__name__,
            "message": exc.message
        }
    )

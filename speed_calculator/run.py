import uvicorn
import logging
from app.core.config import settings

logger = logging.getLogger(__name__)

if __name__ == "__main__":
    logger.info(f"Starting Speed Calculator API on port {settings.API_PORT}")
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.API_PORT,
        reload=True
    )
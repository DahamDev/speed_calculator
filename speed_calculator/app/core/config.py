import os
from dotenv import load_dotenv

load_dotenv()

class Settings:  
    API_PORT: int = int(os.getenv("API_PORT", 8000))
    API_TITLE: str = "Spped calculation API"
    API_DESCRIPTION: str = "API calculating character final speed"
    API_VERSION: str = "1.0.0"
    ALLOWD_ORIGINS: list = ["*"]
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
settings = Settings()
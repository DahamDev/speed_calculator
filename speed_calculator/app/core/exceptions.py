import logging
from fastapi import status
logger = logging.getLogger(__name__)

class ValidationException(Exception):
    def __init__(self, message: str):
        self.message = message
        self.status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
        super().__init__(self.message)
from typing import List
import logging
from app.core.exceptions import ValidationException
logger = logging.getLogger(__name__)

class SpeedCalculator:

    @staticmethod
    def calculate(initial_speed: float, inclines: List[float]) -> float:
        if initial_speed <= 0:
            logger.error(f"Initial speed cannot be negative. Received initial value :{initial_speed}")
            raise ValidationException("Initial speed cannot be negative.")
        
        final_speed = initial_speed
        for incline in inclines:
            if incline < -90 or incline > 90:
                logger.error(f"Incline must be between -90 and 90 degrees. Received value: {incline}")
                raise ValidationException("Incline must be between -90 and 90 degrees.")
            if incline == 0: continue
            final_speed  = final_speed - incline
            if final_speed <= 0: return 0

        return final_speed
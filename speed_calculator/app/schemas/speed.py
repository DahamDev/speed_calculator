from pydantic import BaseModel, Field
from typing import List

class SpeedCalcualatuonRequest(BaseModel):
    initial_speed: float = Field(..., description="Initial speed in km/h")
    inclines: List[float] = Field(..., description="List of incline angles in degrees")
    
    class Config:
        json_schema_extra = {
            "example": {
                "initial_speed": 60,
                "inclines": [0, 30, 0, -45, 0]
            }
        }

class SpeedCalculationResponse(BaseModel):
    final_speed: float = Field(..., description="Final speed in km/h")
    
    class Config:
        json_schema_extra = {
            "example": {
                "final_speed": 75
            }
        }

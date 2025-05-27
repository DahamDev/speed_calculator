from fastapi import APIRouter

from app.services.speedCalculator import SpeedCalculator
from app.schemas.speed import SpeedCalcualatuonRequest, SpeedCalculationResponse
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/health", summary="Health check endpoint")
async def health_check() -> dict:
    logger.info("Health check endpoint called")
    return {"status": "healthy"}

@router.post(
    "/finalspeed",
    response_model=SpeedCalculationResponse,
    summary="Calculate the final speed of user",
    description="Calculate the final speed of a user, using the initial speed and the path incline"
)
async def calcualte_final_speed(request: SpeedCalcualatuonRequest) -> SpeedCalculationResponse:
    initial_speed = request.initial_speed
    inclines = request.inclines
    final_spped = SpeedCalculator.calculate(initial_speed, inclines)
    logger.info(f"Final speed calculated: {final_spped}")
    return SpeedCalculationResponse(final_speed=final_spped)

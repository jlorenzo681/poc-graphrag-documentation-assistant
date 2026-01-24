from fastapi import APIRouter
from src.backend.monitoring.health import check_health

router = APIRouter(prefix="/health", tags=["health"])

@router.get("")
def health_check():
    return check_health()

from fastapi import APIRouter
from src.backend.celery_config import celery_app

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.get("/{task_id}")
async def get_task_status(task_id: str):
    task_result = celery_app.AsyncResult(task_id)
    response = {
        "task_id": task_id,
        "status": task_result.status,
    }
    
    if task_result.status == 'SUCCESS':
         response["result"] = task_result.result
    elif task_result.status == 'FAILURE':
         response["error"] = str(task_result.result)
    elif task_result.status == 'PROGRESS':
        response["result"] = task_result.info
         
    return response

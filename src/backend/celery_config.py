import os
from celery import Celery
from celery.schedules import crontab

# Celery Configuration - All values from environment variables
broker_url = os.getenv("CELERY_BROKER_URL")
result_backend = os.getenv("CELERY_RESULT_BACKEND")

if not broker_url or not result_backend:
    raise ValueError("CELERY_BROKER_URL and CELERY_RESULT_BACKEND must be set in environment variables")

celery_app = Celery(
    "rag_backend",
    broker=broker_url,
    backend=result_backend,
    include=["src.backend.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

# Beat Schedule
celery_app.conf.beat_schedule = {
    # Placeholder for scheduled tasks
    # 'sample-task-every-minute': {
    #     'task': 'src.backend.tasks.sample_task',
    #     'schedule': crontab(minute='*'),
    # },
}

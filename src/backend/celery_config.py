import os
from celery import Celery
from celery.schedules import crontab

broker_url = os.getenv("CELERY_BROKER_URL", "redis://localhost:6379/0")
result_backend = os.getenv("CELERY_RESULT_BACKEND", "redis://localhost:6379/0")

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

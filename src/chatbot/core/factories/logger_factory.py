import logging
import os

class LoggerFactory:
    @staticmethod
    def setup_task_logger(task_id: str, file_path: str, base_name: str = "task"):
        logger = logging.getLogger(f"{base_name}_{task_id}")
        logger.setLevel(logging.INFO)
        
        # Prevent adding multiple handlers
        if not logger.handlers:
            # File handler
            log_dir = "logs"
            os.makedirs(log_dir, exist_ok=True)
            file_handler = logging.FileHandler(os.path.join(log_dir, f"{base_name}_{task_id}.log"))
            formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
            
            return logger, file_handler
            
        return logger, logger.handlers[0]

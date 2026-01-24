from .celery_config import celery_app
from src.chatbot.core.processing.document_processor import DocumentProcessor
from src.chatbot.core.storage.vector_store_manager import VectorStoreManager
from src.chatbot.core.storage.graph_store_manager import GraphStoreManager
from src.chatbot.core.events.event_bus import EventBus, GraphExtractionStartEvent, GraphExtractionCompleteEvent, ErrorEvent
from src.chatbot.core.factories.logger_factory import LoggerFactory
import os
import time
import config.settings as settings

@celery_app.task(bind=True)
def process_document_task(self, file_path: str, api_key: str, embedding_type: str, llm_model: str = None):
    """
    Celery task to process a document.
    """
    logger = None
    file_handler = None
    
    try:
        # 0. Setup Logger
        logger, file_handler = LoggerFactory.setup_task_logger(
            task_id=self.request.id, 
            file_path=file_path, 
            base_name="document_processor"
        )
        logger.info(f"Task Started: {self.request.id}")
        logger.info(f"Processing File: {file_path}")
        
        # Initialize Event Bus
        event_bus = EventBus()
        
        self.update_state(state='PROGRESS', meta={'status': 'Initializing...'})
        
        # 1. Initialize Managers
        vector_manager = VectorStoreManager(embedding_type=embedding_type)
        graph_manager = GraphStoreManager(model_name=llm_model)

        # 2. Check Cache
        self.update_state(state='PROGRESS', meta={'status': 'Checking cache...'})
        file_hash = vector_manager.get_file_hash(file_path)
        
        # 3. Process
        self.update_state(state='PROGRESS', meta={'status': 'Chunking document...'})
        processor = DocumentProcessor(chunk_size=1000, chunk_overlap=200)
        chunks = processor.process_document(file_path)
        logger.info(f"Generated {len(chunks)} chunks")
        
        # 4. Create Vector Store
        self.update_state(state='PROGRESS', meta={'status': f'Embedding {len(chunks)} chunks...'})
        vector_manager.create_vector_store(chunks, cache_key=file_hash)
        
        # 5. Graph Extraction (if enabled)
        if getattr(settings, "ENABLE_GRAPHRAG", False):
            if graph_manager.check_cache(file_hash):
                self.update_state(state='PROGRESS', meta={'status': 'Graph data already cached. Skipping extraction.'})
                logger.info("Graph data cached. Skipping.")
            else:
                self.update_state(state='PROGRESS', meta={'status': f'Extracting Graph data (this may take a while)...'})
                logger.info("Starting graph extraction...")
                
                # Publish Start Event
                event_bus.publish(GraphExtractionStartEvent(file_path=file_path, chunk_count=len(chunks)))
                
                start_time = time.time()
                success = graph_manager.add_documents_to_graph(chunks)
                duration = time.time() - start_time
                
                if success:
                    graph_manager.mark_as_completed(file_hash)
                    logger.info(f"Graph extraction completed in {duration:.2f}s")
                    
                    # Publish Complete Event
                    # Note: We'd ideally get exact node/edge counts from manager, using placeholders or method return
                    event_bus.publish(GraphExtractionCompleteEvent(
                        file_path=file_path, 
                        node_count=0, # TODO: Get actual count
                        relationship_count=0, 
                        duration_seconds=duration
                    ))
        
        logger.info("Task Completed Successfully.")
        
        return {
            "status": "completed", 
            "chunks": len(chunks), 
            "file_hash": file_hash,
            "message": "Processing complete",
            "log_file": file_handler.baseFilename if file_handler else "unknown"
        }
        
    except Exception as e:
        if logger: logger.error(f"Task Failed: {e}", exc_info=True)
        # Publish Error Event
        try:
             EventBus().publish(ErrorEvent(error_type=type(e).__name__, message=str(e)))
        except: pass
        
        self.update_state(state='FAILURE', meta={'exc_type': type(e).__name__, 'exc_message': str(e)})
        raise e
    finally:
        # Clean up handlers
        if logger and file_handler:
            logger.removeHandler(file_handler)
            file_handler.close()

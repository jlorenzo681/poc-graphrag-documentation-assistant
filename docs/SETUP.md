# Setup Guide

This guide will help you set up and run the RAG Chatbot application locally.

## Prerequisites

- **Python 3.10** or higher
- **Docker Desktop** (for containerized deployment)
- **LM Studio** (for local LLM inference)

## Installation Steps

### 1. Clone the Repository

```bash
git clone <repository_url>/poc-graphrag-documentation-assistant.git
cd poc-graphrag-documentation-assistant
```

### 2. Create a Virtual Environment (Recommended for Local Dev)

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On Linux/Mac:
source venv/bin/activate
# On Windows:
venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env
```

Edit `.env` to configure your local LLM server:

```bash
# Default for LM Studio on Host (Docker/Mac/Windows)
LLM_BASE_URL=http://host.docker.internal:1234/v1

# Default for local python only (no docker)
# LLM_BASE_URL=http://localhost:1234/v1
```



## Running the Application

### Web Interface (Streamlit)

```bash
streamlit run app.py
```

The app will open in your browser at `http://localhost:8501`

## Project Structure Overview

```
poc-poc-graphrag-documentation-assistant-wiki/
├── src/chatbot/          # Main application package
│   ├── core/            # Core modules (processing, vector store, RAG)
│   └── utils/           # Utility functions
├── config/              # Configuration and settings
├── data/               # Runtime data (documents, vector stores)
├── logs/               # Application logs
├── tests/              # Test files
├── app.py             # Streamlit web interface
```

## Configuration

Main configuration settings are in [config/settings.py](config/settings.py).

### Key Settings:

- **Chunk Size**: Default 1000 characters
- **Chunk Overlap**: Default 200 characters
- **Retrieval K**: Default 4 documents
- **Temperature**: Default 0.3
- **LLM Model**: Default "local-model" (dynamic)

## Usage Examples

### 1. Upload and Query a Document

1. Start the web interface: `streamlit run app.py`
2. Ensure LM Studio Server is running (Port 1234)
3. Upload a PDF, TXT, or MD file
4. Click "Process Document"
5. Start asking questions!

### 2. Save and Reuse Vector Stores

```python
from src.chatbot import DocumentProcessor, VectorStoreManager

# Create and save
processor = DocumentProcessor()
chunks = processor.process_document("my_doc.pdf")

manager = VectorStoreManager(embedding_type="lmstudio")
manager.create_vector_store(chunks)
manager.save_vector_store("data/vector_stores/my_index")

# Load later
new_manager = VectorStoreManager(embedding_type="lmstudio")
new_manager.load_vector_store("data/vector_stores/my_index")
```

## Troubleshooting

### Connection Errors

If you cannot connect to the LLM:
- Ensure LM Studio server is running on port 1234.
- Check `LLM_BASE_URL` in `.env`.
- **Enable CORS** in LM Studio server settings.

### Import Errors

If you get import errors, ensure you're running from the project root:
```bash
cd /path/to/poc-poc-graphrag-documentation-assistant-wiki
python app.py  # or streamlit run app.py
```

### Memory Issues

- Use quantized embedding models in LM Studio.
- Reduce chunk size in `config/settings.py`.
- Process smaller documents.

## Development

### Adding New Features

1. Core modules go in `src/chatbot/core/`
2. Utility functions go in `src/chatbot/utils/`
3. Update `__init__.py` files to export new functionality

### Running Tests

```bash
# Tests directory is ready for pytest
pytest tests/
```

## Getting Help

- Check the [README.md](../README.md) for detailed documentation
- Open an issue on GitHub for bugs or questions

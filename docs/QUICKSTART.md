# Quick Start Guide

Get the RAG Chatbot running in minutes with local LLMs!

## 🚀 Fastest Way to Deploy

### Using Docker (Recommended)

```bash
# 1. Clone and navigate
git clone <your-repo-url>
cd poc-graphrag-documentation-assistant

# 2. Setup Env
cp .env.example .env

# 3. Start LM Studio Server
# - Open LM Studio -> Local Server
# - Start Server (Port 1234)
# - Enable CORS

# 4. Deploy!
make deploy

# Visit: http://localhost:8501
```

### Using Python (Local Development)

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run!
streamlit run app.py

# Visit: http://localhost:8501
```

## 📋 Common Commands

### Docker Deployment

```bash
make deploy          # Deploy application
make logs            # View logs
make stop            # Stop application
make restart         # Restart application
make shell           # Open container shell
make clean           # Remove containers
```

### Local Development

```bash
streamlit run app.py              # Start web interface
make test                         # Run tests
```

## 📝 First Steps After Deployment

1. **Open the app**: Navigate to `http://localhost:8501`
2. **Configure Provider**: Ensure "LM Studio" is selected in sidebar.
3. **Select Model**: Choose a loaded model from the dropdown.
4. **Upload a document**: Choose a PDF, TXT, or MD file.
5. **Process document**: Click the "Process Document" button.
6. **Ask questions**: Start chatting!

## 🛠️ Troubleshooting

### LM Studio Connection Failed
- Ensure server is running on port `1234`.
- If using Docker, ensure `LLM_BASE_URL` is `http://host.docker.internal:1234/v1`.
- **Enable CORS** in LM Studio server settings.

### Port Already in Use
```bash
# Find what's using port 8501
sudo lsof -i :8501

# Kill the process
kill -9 <PID>
```

### Container Won't Start
```bash
# Check logs
docker logs webapp

# Rebuild image
make clean
make build
make deploy
```

## 📚 Learn More

- **Full Documentation**: See [README.md](../README.md)
- **Deployment Guide**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Setup Instructions**: See [SETUP.md](SETUP.md)

## 🎯 What's Next?

- Try different models in LM Studio (Llama 3, Mistral, etc.)
- Experiment with temperature settings
- Upload larger documents
- Save and reuse vector stores

## 💡 Tips

- Use quantized models (q4_k_m) in LM Studio for speed.
- Lower temperature (0.1-0.3) for factual answers.

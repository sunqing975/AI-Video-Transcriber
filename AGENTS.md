# AI Video Transcriber - Agent Instructions

## Project Overview
AI-powered video/podcast transcription and summarization tool supporting 30+ platforms.

## Development Workflow

### ⚠️ Critical: Code Push Protocol
**DO NOT push code directly after making changes.** Follow this process:
1. Complete code modifications
2. Restart the server for testing
3. Wait for user to test and confirm functionality works
4. Only push code after user explicitly requests it

### Starting the Server
```bash
cd /Users/superman/projects/personal-git/opensource/AI-Video-Transcriber
./start.sh
```
Server runs at http://localhost:8000

### Stopping the Server
```bash
./start.sh stop
```

### Git Remote Setup
- `origin`: Original repo (wendy7756/AI-Video-Transcriber)
- `myfork`: User's fork (sunqing975/AI-Video-Transcriber)

## Architecture

### Backend (FastAPI)
- `backend/main.py` - API endpoints and task management
- `backend/video_processor.py` - Video download and subtitle extraction (yt-dlp)
- `backend/transcriber.py` - Audio transcription (Faster-Whisper, local)
- `backend/summarizer.py` - Text optimization and summarization (OpenAI API)
- `backend/translator.py` - Translation (OpenAI API)

### Frontend
- `static/index.html` - UI with toggle switches and settings
- `static/app.js` - Frontend logic, SSE for real-time updates

## Key Features
- **Subtitle-first architecture**: Extracts platform subtitles when available (fast path)
- **Whisper fallback**: Downloads audio and transcribes locally when no subtitles
- **Auto繁体转简体**: Chinese transcription automatically converts traditional to simplified
- **Summary toggle**: Users can disable AI summary to skip OpenAI API calls

## Environment
- Python 3.11+ with virtualenv (`venv/`)
- FFmpeg required for audio processing
- OpenAI API key needed for summary/translation features

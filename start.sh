#!/bin/bash

# AI Video Transcriber - Start/Stop Script
# Usage:
#   ./start.sh        Start the server (create venv, install deps, launch)
#   ./start.sh stop   Stop the server

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
PID_FILE="$PROJECT_DIR/.server.pid"
PORT="${PORT:-8000}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

stop_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo -e "${YELLOW}Stopping server (PID: $PID)...${NC}"
            kill "$PID"
            sleep 1
            if kill -0 "$PID" 2>/dev/null; then
                kill -9 "$PID" 2>/dev/null
            fi
            rm -f "$PID_FILE"
            echo -e "${GREEN}Server stopped.${NC}"
            return 0
        else
            rm -f "$PID_FILE"
        fi
    fi

    # Fallback: kill by port
    PIDS=$(lsof -t -i :"$PORT" 2>/dev/null || true)
    if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}Killing process on port $PORT...${NC}"
        echo "$PIDS" | xargs kill 2>/dev/null || true
        sleep 1
        echo -e "${GREEN}Stopped.${NC}"
        return 0
    fi

    echo -e "${RED}No running server found.${NC}"
    return 1
}

start_server() {
    echo -e "${GREEN}AI Video Transcriber${NC}"
    echo "=========================="

    # Check Python
    if ! command -v python3 &>/dev/null; then
        echo -e "${RED}Python3 not found. Please install Python 3.8+.${NC}"
        exit 1
    fi

    # Create venv if not exists
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${YELLOW}Creating virtual environment...${NC}"
        python3 -m venv "$VENV_DIR"
        echo -e "${GREEN}Virtual environment created.${NC}"
    fi

    # Activate venv
    source "$VENV_DIR/bin/activate"

    # Install/upgrade pip and dependencies
    echo -e "${YELLOW}Installing dependencies...${NC}"
    pip install --upgrade pip -q
    pip install -r "$PROJECT_DIR/requirements.txt" -q
    echo -e "${GREEN}Dependencies installed.${NC}"

    # Check FFmpeg
    if command -v ffmpeg &>/dev/null; then
        echo -e "${GREEN}FFmpeg found.${NC}"
    else
        echo -e "${YELLOW}FFmpeg not found - some formats may not work.${NC}"
    fi

    # Stop existing server if running
    if [ -f "$PID_FILE" ] || lsof -t -i :"$PORT" &>/dev/null; then
        echo -e "${YELLOW}Stopping existing server...${NC}"
        stop_server
    fi

    # Start server in background
    cd "$PROJECT_DIR"
    nohup "$VENV_DIR/bin/python3" start.py > "$PROJECT_DIR/server.log" 2>&1 &
    SERVER_PID=$!
    echo "$SERVER_PID" > "$PID_FILE"
    sleep 1

    if kill -0 "$SERVER_PID" 2>/dev/null; then
        echo -e "${GREEN}Server started on http://localhost:$PORT (PID: $SERVER_PID)${NC}"
        echo -e "${YELLOW}Run './start.sh stop' to stop the server${NC}"
    else
        echo -e "${RED}Server failed to start. Check server.log for details.${NC}"
        rm -f "$PID_FILE"
        exit 1
    fi
}

case "${1:-start}" in
    stop)
        stop_server
        ;;
    start|"")
        start_server
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        exit 1
        ;;
esac

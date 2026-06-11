#!/bin/bash
echo "Stopping server on port 3000..."
PID=$(lsof -ti:3000 2>/dev/null)
if [ -n "$PID" ]; then
  kill $PID
  sleep 2
  echo "Killed PID $PID"
else
  echo "No process on port 3000"
fi
cd "$(dirname "$0")/server"
echo "Starting server..."
npm run start:dev

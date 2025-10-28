#!/bin/bash

# Already in /HuggingCraft due to WORKDIR

ngrok update
ngrok config add-authtoken $NGROK_TOKEN  
ngrok tcp 7860 &

while true; do
  timeout 600s java -Xmx14336M ... -jar purpur.jar --nogui
  
  git -c safe.directory=/HuggingCraft add --all
  git -c safe.directory=/HuggingCraft commit -m "Auto-backup $(date)" || true
  git -c safe.directory=/HuggingCraft push origin main
done

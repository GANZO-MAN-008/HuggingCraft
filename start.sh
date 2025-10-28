#!/bin/bash

# Fix git ownership issue first
git config --global --add safe.directory /HuggingCraft

ngrok update
ngrok config add-authtoken $NGROK_TOKEN
ngrok tcp 7860 &  # Run ngrok in background so script continues

while true; do
  timeout 50s java -Xmx14336M -Xms14336M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Daikars.new.flags=true -Dusing.aikars.flags=https://mcflags.emc.gs -jar purpur.jar --nogui
  
  # No need to git init every time - it's already initialized
  git remote set-url origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git 2>/dev/null || git remote add origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git
  git pull origin main --rebase  # Use rebase to avoid merge commits
  git add --all  
  git commit -m "Auto-backup $(date)" || true  # Don't fail if nothing to commit
  git push origin main
done

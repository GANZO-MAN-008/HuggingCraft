#!/bin/bash

# Set git config to a writable location
export HOME=/HuggingCraft
export GIT_CONFIG_GLOBAL=/HuggingCraft/.gitconfig
export GIT_CONFIG_NOSYSTEM=1

# Configure git identity
git config --global user.email "bot@huggingcraft.com"
git config --global user.name "HuggingCraft Bot"
git config --global safe.directory '*'

# Set git credential helper to avoid username prompts
git config --global credential.helper store

ngrok update
ngrok config add-authtoken $NGROK_TOKEN
ngrok tcp 7860 &

while true; do
  timeout 600s java -Xmx14336M -Xms14336M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Daikars.new.flags=true -Dusing.aikars.flags=https://mcflags.emc.gs -jar purpur.jar --nogui
  
  git remote set-url origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git 2>/dev/null || git remote add origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git
  git add --all
  git commit -m "Auto-backup $(date)" || true
  git push origin main
done

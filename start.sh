#!/bin/bash

ngrok update
ngrok config add-authtoken $NGROK_TOKEN
ngrok tcp 7860

timeout 2h java -Xmx14336M -Xms14336M  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Daikars.new.flags=true -Dusing.aikars.flags=https://mcflags.emc.gs -jar purpur.jar --nogui

git init
git remote set-url origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git
git pull https://github.com/GANZO-MAN-008/HuggingCraft.git
git add --all  
git commit -m "first commit"   
git push origin main

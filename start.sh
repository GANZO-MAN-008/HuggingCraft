#!/bin/bash

# Configuration
SHUTDOWN_TIME=7200  # 2 hours in seconds
SAVE_INTERVAL=600   # Save to GitHub every 10 minutes

# Function to save to GitHub
save_to_github() {
    echo "[$(date)] Saving world to GitHub..."
    cd /HuggingCraft
    
    # Configure git with token authentication
    git config --global user.email "minecraft@huggingcraft.com"
    git config --global user.name "HuggingCraft Server"
    
    # Set up remote URL with token if GITHUB_TOKEN is provided
    if [ ! -z "$GITHUB_TOKEN" ]; then
        git remote set-url origin https://${GITHUB_TOKEN}@github.com/GANZO-MAN-008/HuggingCraft.git
    fi
    
    # Add and commit changes
    git add world/ world_nether/ world_the_end/ plugins/ server.properties usercache.json ops.json whitelist.json banned-players.json banned-ips.json 2>/dev/null
    
    if git diff --staged --quiet; then
        echo "No changes to commit"
    else
        git commit -m "Auto-save: $(date '+%Y-%m-%d %H:%M:%S')"
        git push origin main && echo "Successfully pushed to GitHub" || echo "Push failed"
    fi
}

# Function to perform final save and shutdown
final_save() {
    echo "[$(date)] Performing final save before shutdown..."
    # Send save command to server
    tmux send-keys -t minecraft "save-all" C-m
    sleep 10
    tmux send-keys -t minecraft "stop" C-m
    sleep 30
    save_to_github
    echo "[$(date)] Server stopped and saved. Exiting..."
    exit 0
}

# Set up trap for graceful shutdown
trap final_save SIGTERM SIGINT

# Display startup info
echo "===== Server Configuration ====="
echo "Shutdown time: 2 hours"
echo "Auto-save interval: 10 minutes"
echo "GitHub Token: ${GITHUB_TOKEN:+Set}${GITHUB_TOKEN:-Not set}"
echo "================================"

ls

# Update and configure ngrok
ngrok update
ngrok config add-authtoken $NGROK_TOKEN
ngrok tcp 7860 > /dev/null &

# Wait for ngrok to start
sleep 5

# Get ngrok URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
echo "Server address: $NGROK_URL"

# Start Minecraft server in tmux session
tmux new-session -d -s minecraft "java -Xmx14336M -Xms14336M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Daikars.new.flags=true -Dusing.aikars.flags=https://mcflags.emc.gs -jar purpur.jar --nogui"

# Monitor and display server output
tmux pipe-pane -t minecraft -o "cat >> /HuggingCraft/server.log"

# Background task for periodic saves
(
    while true; do
        sleep $SAVE_INTERVAL
        tmux send-keys -t minecraft "save-all" C-m
        sleep 10
        save_to_github
    done
) &

# Background task for shutdown timer
(
    sleep $SHUTDOWN_TIME
    final_save
) &

# Attach to tmux session to show server output
tmux attach -t minecraft

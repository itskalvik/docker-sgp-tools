#!/bin/bash

echo "Starting.."
[ ! -e /var/run/nginx.pid ] && nginx&

# Create a new tmux session
tmux -f /etc/tmux.conf start-server
tmux new -d -s "SGP-Tools"

# Split the screen into a 2x1 matrix
tmux split-window -v

memory="$(free | sed -n '2{p;q}' | sed 's/|/ /' | awk '{print $2}')"
swap="$(free | sed -n '3{p;q}' | sed 's/|/ /' | awk '{print $2}')"

# Start ros_sgp_tools only if memory + swap greater than 4 GB
# Avoids crashing BlueOS because of low memory
if (( memory+swap >= 3906250 )); then
    tmux send-keys -t 0 "/ros_entrypoint.sh ros2 launch ros_sgp_tools single_robot.launch.py" Enter
    tmux send-keys -t 1 "/ros_entrypoint.sh" Enter
else
    echo "Low memory, increase swap size!"
    echo "Not starting informative path planner!"
fi

function create_service {
    tmux new -d -s "$1" || true
    SESSION_NAME="$1:0"
    # Set all necessary environment variables for the new tmux session
    for NAME in $(compgen -v | grep MAV_); do
        VALUE=${!NAME}
        tmux setenv -t $SESSION_NAME -g $NAME $VALUE
    done
    tmux send-keys -t $SESSION_NAME "$2" C-m
}

create_service 'ttyd' 'ttyd -p 88 sh -c "/usr/bin/tmux attach -t SGP-Tools || /usr/bin/tmux new -s user_terminal"'

echo "Done!"
sleep infinity
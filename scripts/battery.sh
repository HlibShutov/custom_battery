notify_file="/tmp/battery_notify_status"

if [ ! -f "$notify_file" ]; then
    echo "false" > "$notify_file"
fi

battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
power_profile=$(powerprofilesctl get)
energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
power_now=$(cat /sys/class/power_supply/BAT0/power_now)
status=$(cat /sys/class/power_supply/BAT0/status)
notification_sent=$(cat "$notify_file")
classes=()

if [[ $power_profile = "power-saver" ]]; then
	classes[0]="power-saver"
fi
if [[ $power_profile = "balanced" ]]; then
	classes[0]="balanced"
fi
if [[ $power_profile = "performance" ]]; then
	classes[0]="performance"
fi

if [[ $battery_capacity -lt 15 && "$status" != "Charging" ]]; 
then
	classes+=("critical")
	if [[ $notification_sent == "false" ]]; then
	    notify-send "Battery is discharging" -u critical
	    echo "true" > "$notify_file"
	fi
else
        echo "false" > "$notify_file"
fi


text="$battery_capacity%"

if [[ $status = "Charging" ]]; then
	classes+=("charging")
	text+=" ⚡"
fi

length=${#classes[@]}

if [[ $length > 1 ]]; 
then
        json_classes="["
        
        for i in "${!classes[@]}"; do
            json_classes+="\"${classes[$i]}\""
            if (( i < ${#classes[@]} - 1 )); then
                json_classes+=", "
            fi
        done
        
        json_classes+="]"
else
	json_classes=\"$classes\"
fi

if [[ $power_now > 0 ]]; 
then
        time_decimal=$(echo "scale=10; $energy_now / $power_now" | bc)
	if [[ "$time_decimal" =~ ^\.[0-9]+$ ]]; then
            time_decimal="0$time_decimal"
        fi
	hours=${time_decimal%.*}

        substract_time=$(echo "$time_decimal - $hours" | bc)

        minutes=$(echo "$substract_time * 60" | bc)
        time_to_empty=$(printf "%d hours and %.0f minutes\n" "$hours" "$minutes")
else
	time_to_empty="Charging"
fi

JSON_FMT="{
        \"text\": \"$text\",
        \"percentage\": $battery_capacity, 
	\"class\": $json_classes, 
	\"tooltip\": \"$time_to_empty\"
}"
echo $JSON_FMT

battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
power_profile=$(powerprofilesctl get)
energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
power_now=$(cat /sys/class/power_supply/BAT0/power_now)
status=$(cat /sys/class/power_supply/BAT0/status)
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

if [[ $battery_capacity < 15 ]]; then
	classes+=("critical")
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

if [[ $status != "Charging" ]]; 
then
        time_decimal=$(echo "scale=10; $energy_now / $power_now" | bc)
        hours=${time_decimal%.*}
        minutes=$(echo "(${time_decimal} - $hours) * 60" | bc)
        time_to_empty=$(printf "%d hours and %.0f minutes\n" "$hours" "$minutes")
        echo $time_to_empty
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


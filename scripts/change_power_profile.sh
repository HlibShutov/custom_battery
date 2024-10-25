profiles=('power-saver' 'balanced' 'performance')
power_profile=$(powerprofilesctl get)

index=-1

for i in "${!profiles[@]}"; do
    if [[ "${profiles[$i]}" = "$power_profile" ]]; then
        index=$i
        break
    fi
done
((index++))
if [[ $index = 3 ]]; then
	index=0
fi

powerprofilesctl set ${profiles[$index]}

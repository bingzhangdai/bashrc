source os.lib.bash

function battery::value() {
    local _val
    battery::_value _val
    printf '%d\n' $_val
}

function battery::is_low() {
    local _val
    battery::_value _val
    (( _ < 20 ))
}

if os::is_mac; then
    function battery::_value() {
        local lp_battery batt_status
        IFS=';' read -r lp_battery batt_status <<<"$(pmset -g batt | sed -n 's/^ -InternalBattery.*[[:space:]]\([0-9]*[0-9]\)%; \([^;]*\).*$/\1;\2/p')"
        printf -v "$1" $lp_battery
    }
else
    : /sys/class/power_supply
fi

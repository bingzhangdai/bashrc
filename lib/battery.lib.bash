source os.lib.bash

function battery::value() {
    local _val
    battery::_value _val || return
    printf '%d\n' $_val
}

function battery::is_low() {
    local _val
    battery::_value _val || return
    (( _ != -1 && _ < 20 ))
}

function _detect_battery() {
    if os::is_mac; then
        function battery::_value() {
            local lp_battery batt_status
            IFS=';' read -r lp_battery batt_status <<<"$(pmset -g batt | sed -n 's/^ -InternalBattery.*[[:space:]]\([0-9]*[0-9]\)%; \([^;]*\).*$/\1;\2/p')"
            printf -v "$1" $lp_battery
        }
        return
    fi
    # try sysfs
    function battery::_value() {
        local power_supply
        for power_supply in /sys/class/power_supply/*; do
            if ! [[ -r "${power_supply}/type" && -r "${power_supply}/present" && \
                -r "${power_supply}/status" && -r "${power_supply}/capacity" ]]; then
                continue
            fi

            local power_supply_type power_supply_present power_supply_scope
            IFS= read -r power_supply_type <"${power_supply}/type" 2>/dev/null || continue
            [[ $power_supply_type == 'Battery' ]] || continue
            IFS= read -r power_supply_present <"${power_supply}/present" 2>/dev/null || continue
            [[ $power_supply_present == '1' ]] || continue

            # Scope is a property of a power supply
            # Scope = System or missing - power supply powers the system
            # Scope = Device - power supply powers a device
            if [[ -r "${power_supply}/scope" ]]; then
                IFS= read -r power_supply_scope <"${power_supply}/scope" 2>/dev/null || continue
                [[ $power_supply_scope == 'System' ]] || continue
            fi

            IFS= read -r lp_battery_status <"${power_supply}/status" 2>/dev/null || continue
            IFS= read -r lp_battery <"${power_supply}/capacity" 2>/dev/null || continue
            printf -v "$1" $lp_battery
            return
        done
        false
    }
    battery::_value _ && return
    # try acpi
    if command -v apci >/dev/null; then
        function battery::_value() {
            local acpi
            acpi="$(acpi --battery 2>/dev/null)"

            # Extract the battery load value in percent
            # First, remove the beginning of the line...
            lp_battery="${acpi#Battery *, }"
            lp_battery="${lp_battery%%%*}" # remove everything starting at '%'
            lp_battery_status="${acpi}"
            printf -v "$1" $lp_battery
        }
        battery::_value _ && return
    fi
    function battery::_value() {
        printf -v "$1" -1
        false
    }
}

_detect_battery
unset -f _detect_battery
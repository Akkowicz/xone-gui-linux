#!/usr/bin/env bash

PASSWD="$(zenity --width=240 --height=240 --timeout=20 --password --title='Run as root user')\n"

function show_gui() {
    pairing_mode_kernel=$(cat /sys/bus/usb/drivers/xone-dongle/*/pairing)
    pairing_mode_text="<span foreground='red'>Disabled</span>"

    if [[ "${pairing_mode_kernel}" == "1" ]]; then
       pairing_mode_text="<span foreground='green'>Enabled</span>"
    fi

    zenity --question \
    --width=240 \
    --height=240 \
    --title="XONE Driver GUI" \
    --text="Pairing mode state: <b>$pairing_mode_text</b>" \
    --ok-label="Enable" \
    --cancel-label="Disable and exit" \
    --window-icon="question"

    case $? in
        0)
            echo -e "$PASSWD" | sudo -S bash -c "echo 1 | tee /sys/bus/usb/drivers/xone-dongle/*/pairing" &> /dev/null
            zenity --info \
            --width=240 \
            --height=240 \
            --timeout=3 \
            --text="Pairing mode enabled!\rYou can now pair your device."
            show_gui
        ;;
        1)  
            echo -e "$PASSWD" | sudo -S bash -c "echo 0 | tee /sys/bus/usb/drivers/xone-dongle/*/pairing" &> /dev/null
            zenity --info \
            --width=240 \
            --height=240 \
            --timeout=1 \
            --text="Pairing mode disabled! Quitting..."
            exit 0
        ;;
        -1)
            echo "Unexpected error."
        ;;
    esac
}

show_gui
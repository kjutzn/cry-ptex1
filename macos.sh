#!/bin/bash

## all variables: script_path, installsshrd, act_have, act_path

_info() {
    if [ "$1" = 'recovery' ]; then
        echo $("$dir"/irecovery -q | grep "$2" | sed "s/$2: //")
    elif [ "$1" = 'normal' ]; then
        echo $("$dir"/ideviceinfo | grep "$2: " | sed "s/$2: //")
    fi
}

step() {
    rm -f .entered_dfu
    for i in $(seq "$1" -1 0); do
        if [[ -e .entered_dfu ]]; then
            rm -f .entered_dfu
            break
        fi
        if [[ $(get_device_mode) == "dfu" || ($1 == "10" && $(get_device_mode) != "none") ]]; then
            touch .entered_dfu
        fi &
        printf '\r\e[K\e[1;36m%s (%d)' "$2" "$i"
        sleep 1
    done
    printf '\e[0m\n'
}

get_device_mode() {
    if [ "$os" = "Darwin" ]; then
        sp="$(system_profiler SPUSBDataType 2> /dev/null)"
        apples="$(printf '%s' "$sp" | grep -B1 'Vendor ID: 0x05ac' | grep 'Product ID:' | cut -dx -f2 | cut -d' ' -f1 | tail -r)"
    elif [ "$os" = "Linux" ]; then
        apples="$(lsusb | cut -d' ' -f6 | grep '05ac:' | cut -d: -f2)"
    fi
    local device_count=0
    local usbserials=""
    for apple in $apples; do
        case "$apple" in
            12a8|12aa|12ab)
            device_mode=normal
            device_count=$((device_count+1))
            ;;
            1281)
            device_mode=recovery
            device_count=$((device_count+1))
            ;;
            1227)
            device_mode=dfu
            device_count=$((device_count+1))
            ;;
            1222)
            device_mode=diag
            device_count=$((device_count+1))
            ;;
            1338)
            device_mode=checkra1n_stage2
            device_count=$((device_count+1))
            ;;
            4141)
            device_mode=pongo
            device_count=$((device_count+1))
            ;;
        esac
    done
    if [ "$device_count" = "0" ]; then
        device_mode=none
    elif [ "$device_count" -ge "2" ]; then
        echo "[-] Please attach only one device" > /dev/tty
        kill -30 0
        exit 1;
    fi
    if [ "$os" = "Linux" ]; then
        usbserials=$(cat /sys/bus/usb/devices/*/serial)
    elif [ "$os" = "Darwin" ]; then
        usbserials=$(printf '%s' "$sp" | grep 'Serial Number' | cut -d: -f2- | sed 's/ //')
    fi
    if grep -qE '(ramdisk tool|SSHRD_Script) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' <<< "$usbserials"; then
        device_mode=ramdisk
    fi
    echo "$device_mode"
}

_dfuhelper() {
    if [ "$(get_device_mode)" = "dfu" ]; then
        echo "[*] Device is already in DFU"
        return
    fi

    local step_one;
    deviceid=$( [ -z "$deviceid" ] && _info normal ProductType || echo $deviceid )

    if [[ "$1" = 0x801* && "$deviceid" != *"iPad"* ]]; then
        step_one="Hold volume down + side button"
    else
        step_one="Hold home + power button"
    fi

    if $dfuhelper_first_try; then
        echo "[*] Press any key when ready for DFU mode"
        read -n 1 -s
        dfuhelper_first_try=false
    fi

    step 3 "Get ready"
    step 4 "$step_one" &
    sleep 2
    "$dir"/irecovery -c "reset" &
    wait

    if [[ "$1" = 0x801* && "$deviceid" != *"iPad"* ]]; then
        step 10 'Release side button, but keep holding volume down'
    else
        step 10 'Release power button, but keep holding home button'
    fi

    sleep 1
    
    if [ "$(get_device_mode)" = "dfu" ]; then
        echo "[*] Device entered DFU!"
        dfuhelper_first_try=true
    else
        echo "[-] Device did not enter DFU mode"
        return -1
    fi
}

script_path="$(cd "$(dirname "$0")" && pwd)"

echo "== Cry Ptex1 =="
echo "Made by Kjutzn"
echo "Thanks to Orangera1n, VeryGenericName (ssh)"
echo "This tool DOES NOT work on iPhone X, due to sep breaking restores."

echo

echo "Please open the guide in another tab and follow it closely!"
echo "If you need any help, open a new issue on GitHub or contact me on Discord."
echo

##echo "What version is your iPhone on?"
##read ios1
##echo

##echo "Hello, $ios1! Welcome to the script." ## this is just for testing input!!!
##echo $script_path
##echo

if [ -d "$script_path/SSHRD_Script" ]; then
    ##echo "The folder SSHRD_Script exists in the script's directory."
    cd "$script_path/SSHRD_Script" && git pull

else
    echo "The folder SSHRD_Script does not exist in the script's directory. Exiting the program."
    echo "This tool depends on SSHRD_Script by Nathan."
    echo

    echo "Do you want to install it now? (y/n)"
    read installsshrd

    if [ "$installsshrd" = "y" ]; then
        echo "Cloning verygenericname/SSHRD_Script"
        git clone https://github.com/verygenericname/SSHRD_Script --recursive
        
        cd "$script_path/SSHRD_Script" && git pull

    else
        echo "Exiting"
        exit 100
    fi
fi

## SSHRD exists and it is up to date! Script can continue.

echo
echo "[?] Do you have activation files? (y/n)"
read act_have

if [ "$act_have" = "y" ]; then
        cd $script_path && mkdir Actiation 
        echo "[*] Copy them to: $script_path/Actiation"
        cd $script_path/activation
        

    else
        echo
        echo "[*] Plug you device and trust it"
         _dfuhelper    ##disabled for now!!!!
        cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $ios1
        cd $script_path/SSHRD_Script && ./sshrd.sh boot

        cd $script_path && mkdir Actiation

        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass

        echo "[*] You might have to press allow for opening new terminal window"
        osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
        echo "[*] Switch to opened terminal and enter this command: mount_filesystems "
        echo "[!] Do not close it"
        echo

        echo "[*] Connecting to your device. Downloading Fairplay folder... "
        sftp -oPort=2222 root@localhost:/mnt2/mobile/Library/Fairplay $script_path/Activation
        ## add check

        echo "[*] Downloading commcenter.device_specific_nobackup.plist "
        sftp -oPort=2222 root@localhost:/mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist $script_path/Activation
        ## add check

        ssh -p 2222 root@localhost 'cd /mnt2/containers/Data/System; find /mnt2/containers/Data/System -name internal'

    fi

#!/bin/bash

script_path="$(cd "$(dirname "$0")" && pwd)"

echo "== Cry ptex1 =="
echo "Made by Kjutzn"
echo "Thanks to Orangera1n, VeryGenericName (ssh), Palera1n"
echo "This tool DOES NOT work on iPhone X, due to sep breaking restores."
echo
echo "Please open the guide in another tab and follow it!"
echo "If you need any help or run into any problems, open an issue on GitHub or contact me on Discord."

echo "[?] What version is your iDevice on?"
read ios1

##echo $script_path
##echo

if [ -d "$script_path/SSHRD_Script" ]; then
    echo "[*] SSHRD_Script exists in the script's directory."
    cd "$script_path/SSHRD_Script" && git pull

else
    echo "[!] The folder SSHRD_Script does not exist in the script's directory. Exiting the program."
    echo "[!] This tool depends on SSHRD_Script by Nathan."
    echo

    echo "[?] Do you want to install it now? (y/n)"
    read installsshrd

    if [ "$installsshrd" = "y" ]; then
        echo "[*] Cloning SSHRD_Script... Please wait!"
        git clone https://github.com/verygenericname/SSHRD_Script --recursive
        cd "$script_path/SSHRD_Script" && git pull

    else
        echo "[*] Exiting"
        exit 100
    fi
fi

## SSHRD exists and it is up to date! Script can continue.

if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/Darwin/sshpass" "$script_path/"
else
    echo 
fi

## sshpass is in $script_path

echo "[?] Do you have activation files? (y/n)"
read act_have

if [ "$act_have" = "y" ]; then
        cd $script_path && mkdir Activation 
        echo "[*] Copy them to: $script_path/Activation"        

else
        echo
        echo "[*] Plug you device and trust it"

        echo
        echo "[!] New terminal window should pop up, follow instructions on entering DFU Mode"
        osascript -e "tell application \"Terminal\" to do script \"palera1n -D\""

        sleep 4
        cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $ios1
        echo "[*] Booting ramdisk"
        cd $script_path/SSHRD_Script && ./sshrd.sh boot

        cd $script_path && mkdir Actiation

        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
        chmod +x "$script_path"/sshpass

        sleep 3

        echo "[*] This part of script resets known_hosts to avoid any ssh issues. "
        echo "[?] Is that alright? (y/n)"
        read resethosts

        if [ "$resethosts" = "y" ]; then
            echo "Please enter your username(of this mac): "
            read usernamemac

            rm -rf /Users/$usernamemac/.ssh/known_hosts
            
        else
            echo "Trying without reseting known_hosts!"
        fi

        sleep 5

        echo "[*] You might have to press allow for opening new terminal window"
        osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
        echo "[*] Switch to opened terminal and enter this command: mount_filesystems "
        echo "[!] Do not close it"
        echo

        sleep 15

        echo "[*] Connecting to your device. Downloading Fairplay folder... "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 -r root@localhost:/mnt2/mobile/Library/FairPlay "$script_path/Activation"
        ## add check

        sleep 5

        echo "[*] Downloading commcenter.device_specific_nobackup.plist "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:/mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist "$script_path/Activation"
        ## add check
        sleep 5

        echo "[*] Check if Fairplay folder and com.apple.commcenter.device_specific_nobackup.plist exist in Activation folder!"
        sleep 5
        
        echo
        echo "[*] This part needs to be done manually. Guide is in GitHub repo. "
        echo "[*] Open FileZilla and follow the guide. "
        sleep 10
    
fi

echo "[*] If you prepared activation files, you can futurerestore to desired 14/15 version."
echo

echo "[?] Continue? (y/n)"
read preparedact

if [ "$preparedact" = "y" ]; then
    sudo chmod -R 755 $script_path/Activation
    sleep 3

    echo "[*] Creating FakeFS follow Palera1n Instructions in new terminal window. "
    osascript -e "tell application \"Terminal\" to do script \"palera1n -c -f\""
    sleep 3

    echo "[!] Enter y when FakeFS finishes creating. "
    read fakefsdone
    sleep 1
    
    else
    exit 101
    fi

    if [ "$fakefsdone" = "y" ]; then
    echo "Please enter what version did you downgrade to: "
    read _iosdowngraded
    sleep 3

    echo "[*] Creating ramdisk for $_iosdowngraded"

    cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $_iosdowngraded
    sleep 3

    echo "[*] Booting ramdisk"
    cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
    sleep 3

    echo
    echo "[*] Terminal window should pop up, follow instructions from 3. Activating "
    osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
    sleep 120
    exit 1

    else
    exit 102
fi

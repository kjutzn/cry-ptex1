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
echo

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
        echo "[!] Exit code: 100"
        exit 100
    fi
fi


if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/Darwin/sshpass" "$script_path/"
else
    echo "[*] Copying sshpass to script path (Will be needed for later)"
fi

if [ ! -f "$script_path/iproxy" ]; then
    cp "$script_path/SSHRD_Script/Darwin/iproxy" "$script_path/"
else
    echo "[*] Copying iproxy to script path (Will be needed for later)"
fi

echo "[?] Do you have activation files? (y/n)"
read act_have
cd $script_path 
mkdir activation

if [ "$act_have" = "y" ]; then
        echo "[*] Copy them to: $script_path/activation"        

else
        echo
        echo "[*] Plug you device and trust it"

        echo
        echo "[!] New terminal window should pop up, follow instructions on entering DFU Mode"
        osascript -e "tell application \"Terminal\" to do script \"palera1n -D\""

        sleep 2
        cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $ios1
        echo "[*] Booting ramdisk"
        cd $script_path/SSHRD_Script && ./sshrd.sh boot

        cd $script_path

        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/sshpass
        chmod +x "$script_path"/activate.sh
        chmod +x "$script_path"/iproxy
        chmod +x "$script_path"/futurerestored.sh


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

        sleep 2

        echo "[*] You might have to press allow for opening new terminal window"
        osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
        echo "[!] Do not close opened Terminal window"
        echo

        
        echo "[*] Mounting filesystems"
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
        sleep 5

        echo "[*] Connecting to your device. Downloading Fairplay folder... "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 -r root@localhost:/mnt2/mobile/Library/FairPlay "$script_path/activation"

        ## check needs to be added

        sleep 3

        echo "[*] Downloading commcenter.device_specific_nobackup.plist "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:/mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist "$script_path/activation"

        if [ -e "$script_path/activation/com.apple.commcenter.device_specific_nobackup.plist" ]; then
            echo "[*] com.apple.commcenter.device_specific_nobackup.plist downloaded successfully"
        else
            echo "[!] com.apple.commcenter.device_specific_nobackup.plist failed downloading. Download it manually"
        fi

        sleep 5

        echo "[*] Downloading internal"
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt2/containers/Data/System
        ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name internal)
        ACT3=$ACT1/data_ark.plist
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:$ACT3 "$script_path/activation"

        if [ -e "$script_path/activation/data_ark.plist" ]; then
            echo "[*] data_ark.plist downloaded successfully"
        else
            echo "[!] data_ark.plist failed downloading. Download it manually"
        fi

        sleep 1

        echo "[*] Downloading activation_record.plist"
        cd $script_path/activation && mkdir activation_records

        cd $script_path
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt2/containers/Data/System

        ACT5=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name activation_records)
        ACT6=$ACT5/activation_record.plist
        sleep 1

        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:$ACT6 "$script_path/activation/activation_records"
        sleep 2
        cp "$script_path/activation/activation_records/activation_record.plist" "$script_path/activation/"
        
        sleep 2
        
        if [ -e "$script_path/activation/activation_records/activation_record.plist" ]; then
            echo "[*] activation_record.plist downloaded successfully"
        else
            echo "[!] activation_record.plist failed downloading. Download it manually"
        fi
        
        sleep 1

        echo "[*] Check if Fairplay folder, com.apple.commcenter.device_specific_nobackup.plist, activation_record.plist exist in activation folder!"
        sleep 5
        
        echo
        echo "[*] Finished downloading activation files, also you can close ssh and palera1n terminal"
        sleep 1
    
fi

echo "[*] Now you can futurerestore to desired 14/15 version."
echo

echo "[?] Continue? (y/n)"
read preparedact

if [ "$preparedact" = "y" ]; then
    echo "[*] Starting ./futurerestored.sh, also save activation folder just in case"
    echo "[*] Script is continuing in 10 seconds"
    sleep 10
    cd $script_path && ./futurerestored.sh
else
    exit 160
fi

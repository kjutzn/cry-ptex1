#!/bin/bash

skip_rdboot=false
debug=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-rdboot)
      skip_rdboot=true
      ;;
    --debug)
      debug=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

printg() {
  printf "\e[32m$1\e[m\n"
}

printy() {
  printf "\e[33;1m%s\n" "$1"
}

printr() {
  echo -e "\033[1;31m$1\033[0m"
}

script_path="$(cd "$(dirname "$0")" && pwd)"

printg " == Cry ptex1 =="
printg
printg " Made by Kjutzn"
printg " Thanks to Orangera1n, VeryGenericName (ssh), Palera1n"
printg " This tool DOES NOT work on iPhone X, due to sep breaking restores."
printg
printg " Please open the guide in another tab and follow it!"
printg " If you need any help or run into any problems, open an issue on GitHub or contact me on Discord."
printg 

printg " [?] What version is your iDevice on?"
read ios1
printg

if [ -d "$script_path/SSHRD_Script" ]; then
    printg " [*] SSHRD_Script exists in the script's directory."
    cd "$script_path/SSHRD_Script" && git pull

else
    echo -e "\033[1;31m[!] The folder SSHRD_Script does not exist in the script's directory. Exiting the program. \033[0m"
    echo -e "\033[1;31m[!] This tool depends on SSHRD_Script by Nathan. \033[0m"
    echo

    printg " [?] Do you want to install it now? (y/n)"
    read installsshrd

    if [ "$installsshrd" = "y" ]; then
        echo " [*] Cloning SSHRD_Script... Please wait!"
        git clone https://github.com/verygenericname/SSHRD_Script --recursive
        cd "$script_path/SSHRD_Script" && git pull

    else
        echo -e "\033[1;31m[!] Exit code: 100 \033[0m"
        exit 100
    fi
fi

if [ -d "$script_path/knownhosts" ]; then
    cd $script_path
else
    cd $script_path && mkdir knownhosts
fi


if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/Darwin/sshpass" "$script_path/"
    printg " [*] Copying sshpass to script path (Will be needed for later)"
else
    cd $script_path
fi

if [ ! -f "$script_path/iproxy" ]; then
    cp "$script_path/SSHRD_Script/Darwin/iproxy" "$script_path/"
    printg " [*] Copying iproxy to script path (Will be needed for later)"

else
    cd $script_path
fi

printg " [?] Do you have activation files? (y/n)"
read act_have

if [ -d "$script_path/activation" ]; then
    cd $script_path
else
    cd $script_path && mkdir activation

fi

if [ "$act_have" = "y" ]; then
        printg " [*] Copy them to: $script_path/activation"        

else
        echo
        printg " [*] Plug you device and trust it"

        if [ "$skip_rdboot" = true ]; then
            printg " [*] Skipped booting ramdisk as specified"
        else
            echo -e "\033[1;31m [!] New terminal window should pop up, follow instructions on entering DFU Mode \033[0m"
            osascript -e "tell application \"Terminal\" to do script \"palera1n -D\""

            sleep 2
            cd "$script_path/SSHRD_Script" && chmod +x sshrd.sh && ./sshrd.sh "$ios1"
            printg " [*] Booting ramdisk"
            cd "$script_path/SSHRD_Script" && ./sshrd.sh boot
        fi

        cd $script_path

        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/sshpass
        chmod +x "$script_path"/activate.sh
        chmod +x "$script_path"/iproxy
        chmod +x "$script_path"/futurerestored.sh


        sleep 3

        echo -e "\033[1;31m [*] This part of script resets known_hosts to avoid any ssh issues. \033[0m"
        echo -e "\033[1;31m [*] But it will make backup of existing known_hosts file. \033[0m"
        echo -e "\033[1;31m [*] If you have really important known_hosts saved backup it manually just in case \033[0m"
        echo -e "\033[1;31m [?] Is that alright? (y/n) \033[0m"

        read resethosts

        if [ "$resethosts" = "y" ]; then
            echo
            printg "[?] Please enter your username(of this mac): "
            read usernamemac

            cd $script_path && cp "/Users/$usernamemac/.ssh/known_hosts" "$script_path/"
            sleep 2

            cd $script_path && cp "$script_path/known_hosts" "$script_path/knownhosts/"  
            sleep 2          

            rm -rf /Users/$usernamemac/.ssh/known_hosts
            
        else
            printg " [*] Trying without reseting known_hosts!"
        fi

        sleep 2

        printg " [*] You might have to press allow for opening new terminal window"
        osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
        echo -e "\033[1;31m [!] Do not close opened Terminal window \033[0m"
        echo

        
        printg " [*] Mounting filesystems"
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
        sleep 5

        printg " [*] Connecting to your device. Downloading Fairplay folder... "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 -r root@localhost:/mnt2/mobile/Library/FairPlay "$script_path/activation"

        ##check needs to be added

        sleep 3

        printg " [*] Downloading commcenter.device_specific_nobackup.plist "
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:/mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist "$script_path/activation"

        if [ -e "$script_path/activation/com.apple.commcenter.device_specific_nobackup.plist" ]; then
            printg " [*] com.apple.commcenter.device_specific_nobackup.plist downloaded successfully"
        else
            echo -e "\033[1;31m [!] com.apple.commcenter.device_specific_nobackup.plist failed downloading. Download it manually \033[0m"
        fi

        sleep 5

        printg " [*] Downloading internal"
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt2/containers/Data/System
        ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name internal)
        ACT3=$ACT1/data_ark.plist
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:$ACT3 "$script_path/activation"

        if [ -e "$script_path/activation/data_ark.plist" ]; then
            printg " [*] data_ark.plist downloaded successfully"
        else
            echo "\033[1;31m [!] data_ark.plist failed downloading. Download it manually \033[0m"
        fi

        sleep 1

        printg " [*] Downloading activation_record.plist"
        cd $script_path/activation

        if [ -d "$script_path/activation" ]; then
            cd $script_path
        else
            cd $script_path/activation && mkdir activation_records
            sleep 1
            cd $script_path
        fi

        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt2/containers/Data/System

        ACT5=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name activation_records)
        ACT6=$ACT5/activation_record.plist
        sleep 1

        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:$ACT6 "$script_path/activation/activation_records"
        sleep 2
        cp "$script_path/activation/activation_records/activation_record.plist" "$script_path/activation/"
        
        sleep 2
        
        if [ -e "$script_path/activation/activation_records/activation_record.plist" ]; then
            printg " [*] activation_record.plist downloaded successfully"
        else
            echo "\033[1;31m [!] activation_record.plist failed downloading. Download it manually \033[0m"
        fi
        
        sleep 1

        printg " [*] Check if Fairplay folder, com.apple.commcenter.device_specific_nobackup.plist, activation_record.plist exist in activation folder!"
        sleep 5
        
        echo
        printg " [*] Finished downloading activation files, also you can close ssh and palera1n terminal"
        sleep 1
    
fi

printg " [*] Now you can futurerestore to desired 14/15 version."
echo

printg " [?] Continue? (y/n)"
read partonedone

if [ "$partonedone" = "y" ]; then
    printg " [*] Starting ./futurerestored.sh, also save activation folder just in case"
    printg " [*] Script is continuing in 10 seconds"
    echo 
    sleep 10
    cd $script_path && ./futurerestored.sh
else
    exit 160
fi

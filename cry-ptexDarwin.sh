#!/bin/bash

rmrfinternal() {
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /var/containers/Data/System
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -type d -name internal -prune -o -exec rm -rf {} \; 
}


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
    ##cd "$script_path/SSHRD_Script" && git pull

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

## SSHRD exists and it is up to date! Script can continue.

if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/Darwin/sshpass" "$script_path/"
else
    echo 
fi

## sshpass is in $script_path

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
        ##osascript -e "tell application \"Terminal\" to do script \"palera1n -D\""

        ##sleep 2
        ##cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $ios1
        echo "[*] Booting ramdisk"
        ##cd $script_path/SSHRD_Script && ./sshrd.sh boot

        cd $script_path

        chmod +x "$script_path"/SSHRD_Script/Darwin/iproxy
        chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
        chmod +x "$script_path"/sshpass

       ## sleep 3

        echo "[*] This part of script resets known_hosts to avoid any ssh issues. "
        echo "[?] Is that alright? (y/n)"
        ##read resethosts

        if [ "$resethosts" = "y" ]; then
            echo "Please enter your username(of this mac): "
            read usernamemac

            ##rm -rf /Users/$usernamemac/.ssh/known_hosts
            
        else
            echo "Trying without reseting known_hosts!"
        fi

        ##sleep 2

        echo "[*] You might have to press allow for opening new terminal window"
        ##osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
        echo "[!] Do not close opened Terminal window"
        echo

        
        echo "[*] Mounting filesystems"
        ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
        ##sleep 3

        echo "[*] Connecting to your device. Downloading Fairplay folder... "
        sleep 1
        ##./sshpass -p 'alpine' sftp -oPort=2222 -r root@localhost:/mnt2/mobile/Library/FairPlay "$script_path/activation"
        ## add check

        ##sleep 5

        echo "[*] Downloading commcenter.device_specific_nobackup.plist "
        sleep 1
        ##./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:/mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist "$script_path/activation"
        ## add check
        ##sleep 5

        echo "[*] Downloading internal"
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt2/containers/Data/System
        ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name internal)
        ACT3=$ACT1/data_ark.plist
        sleep 1
        ./sshpass -p 'alpine' sftp -oPort=2222 root@localhost:$ACT3 "$script_path/activation"
        ## add check
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
        ## add check
        sleep 1

        echo "[*] Check if Fairplay folder, com.apple.commcenter.device_specific_nobackup.plist, activation_record.plist  exist in activation folder!"
        sleep 5
        
        echo
        echo "[*] Finished downloading activation files, also you can close ssh and palera1n terminal"
        sleep 1
    
fi

echo "[*] Now you can futurerestore to desired 14/15 version."
echo

echo "[?] Continue? (y/n)"
read preparedact

sudo chmod -R 755 $script_path/activation
sleep 3

echo "[*] Creating FakeFS follow Palera1n Instructions in new terminal window. "
osascript -e "tell application \"Terminal\" to do script \"palera1n -c -f\""
sleep 3

echo "[!] Enter y when FakeFS finishes creating. "
read fakefsdone
sleep 1
    
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

    osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
    echo "[!] Do not close sshrd ssh terminal"

    echo "[*] Mounting filesystems"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
    sleep 3

    echo "[?] Does your device have Baseband? (y/n)"
    echo "[*] Enter y if it isn't iPad"
    sleep 1
    read basebandyn

    if [ "$basebandyn" = "y" ]; then
        echo "[*] Mounting apfs" 
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
    else
        echo "[*] Mounting apfs" 
        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
    fi

    echo "[*] ldid mobileactivationd"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -e /mnt8/usr/libexec/mobileactivationd > /mnt8/ents.xml
    sleep 1

    echo "[*] Renaming mobileactivationd to mobileactivationd_backup"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd /mnt8/usr/libexec/mobileactivationd_backup
    sleep 1

    echo "[*] Downloading required files."
    curl -o "$script_path/mobileactivationd" "https://cdn.discordapp.com/attachments/1020892312756293695/1102082543253205012/mobileactivationd"
    sleep 3

    echo "[*] Uploading required files to iDevice "
    ./sshpass -p 'alpine' scp -P 2222 "$script_path/mobileactivationd" root@localhost:/mnt8/usr/libexec/

    echo "[*] Reparing permisions"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt8/usr/libexec/mobileactivationd
    sleep 2

    echo "[*] Resigning files"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt8
    sleep 2
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -Sents.xml /mnt8/usr/libexec/mobileactivationd
    sleep 2

    echo "[*] Device should reboot"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
    sleep 6
    echo "[*] Now you need to follow guide in other terminal window with instructions on jailbreaking with palera1n"
    
    osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
    echo "[*] Opened new Terminal window"
    echo "[*] Also if you are on Apple Silicon mac you need to replug ligtning cable when you see apple logo on device"
    sleep 3

    echo "[!] Enter y when device finishes jailbreaking "
    read finishedjb
    if [ "$finishedjb" = "y" ]; then

    echo "[*] Then Complete setup as normal, and use the palera1n loader to install Sileo"
    echo "[!] You MUST set password for sudo commands in palera1n to: alpine"
    echo "[*] After Bootstrap finishes downloading, open Sileo and install openssh."
    sleep 3
        if [ "$installingbootstrap" = "y" ]; then
                echo "[*] Booting ramdisk"
                cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
                sleep 3

                echo "[*] SSH window should pop up"
                osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
                echo "[!] Do not close it"
                if [ "$basebandyn" = "y" ]; then
                    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
                else
                    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
                fi

                echo 
                ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd_backup /mnt8/usr/libexec/mobileactivationd
                sleep 2

                echo "[*] Rebooting, after jailbreak finishes jailbreak with palera1n"
                ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
                echo "[*] Also you can close all opened terminal windows, exept this one"
                sleep 7

                echo "[*] Opened new palera1n window"
                osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
                echo "[*] Same as last time, if you are on Apple Silicon mac you need to replug ligtning cable when you see apple logo on device"
                sleep 3

                echo
                echo "[*] Enter y when device finishes jailbreaking"

                if [ "$finishedjb1" = "y" ]; then
                    echo "[*] Reseting known_hosts"
                    rm -rf /Users/$usernamemac/.ssh/known_hosts
                    sleep 1

                    osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
                    echo "[!] Do not close sshrd ssh terminal"

                    echo
                    
                    echo "[*] Do you want script to try to automatically remove internal folders, or you want to do it manually?"
                    read manualrmrf
                    if [ "$manualrmrf" = "y" ]; then
                        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /var/containers/Data/System
                        sleep 1

                        echo "[*] Internal folders are located in these directories: "
                        ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -name internal
                        sleep 1

                        echo
                        echo "[*] Open ssh window and enter this command rm -rf and both container numbers(one by one) without EXCLUDING internal"
                        
                        echo "[*] Enter y when done"
                        read donermrf1

                        if [ "$donermrf1" = "y" ]; then

                        else
                        echo "[!] Exit code: 106"
                        exit 106
                        fi
                    else
                        rmrfinternal
                    fi

                    sleep 5

                    echo "[*] Device should reboot now"
                    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
                    sleep 6 

                    echo "[*] Wait for phone to reboot (if it doesn't force reboot) and try to activate"
                    echo "[*] This part of script ends here. When done open next part ./activate.sh"
                    sleep 3
                    exit 200
                else
                    echo "[!] Exit code: 105"
                    exit 105
                fi
        else
            echo "[!] Exit code: 104"
            exit 104
        fi

    else
        echo "[!] Exit code: 103"
        exit 103
    fi

else
    echo "[!] Exit code: 102"
    exit 102
fi

#!/bin/bash

script_path="$(cd "$(dirname "$0")" && pwd)"

echo "Terminal might ask for your password(for runnning sudo commands)"
sleep 1
##sudo chmod -R 755 $script_path/activation
##sleep 3

echo "[*] Creating FakeFS follow Palera1n Instructions in new terminal window. "
##osascript -e "tell application \"Terminal\" to do script \"palera1n -c -f\""
##sleep 3

echo "[!] Enter y when FakeFS finishes creating. "
read fakefsdone
##sleep 1
    
if [ "$fakefsdone" = "y" ]; then
    echo "Please enter what version did you downgrade to: "
    read _iosdowngraded
    ##sleep 3

    echo "[*] Creating ramdisk for $_iosdowngraded"

    ##cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $_iosdowngraded
    ##sleep 3

    echo "[*] Booting ramdisk"
    ##cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
    ##sleep 3

    ##osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
    echo "[!] Do not close sshrd ssh terminal"

    echo "[*] Mounting filesystems"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
    ##sleep 3

    echo "[?] Does your device have Baseband? (y/n)"
    echo "[*] Enter y if it isn't iPad"
    ##sleep 1
    read basebandyn

    if [ "$basebandyn" = "y" ]; then
        echo "[*] Mounting apfs" 
        ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
    else
        echo "[*] Mounting apfs" 
        ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
    fi

    echo "[*] ldid mobileactivationd"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -e /mnt8/usr/libexec/mobileactivationd > /mnt8/ents.xml
    ##sleep 1

    echo "[*] Renaming mobileactivationd to mobileactivationd_backup"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd_backup /mnt8/usr/libexec/mobileactivationd
    ##sleep 1

    echo "[*] Downloading required files."
    ##curl -o "$script_path/mobileactivationd" "https://cdn.discordapp.com/attachments/1020892312756293695/1102082543253205012/mobileactivationd"
    ##sleep 3

    echo "[*] Uploading required files to iDevice "
    ##./sshpass -p 'alpine' scp -P 2222 "$script_path/mobileactivationd" root@localhost:/mnt8/usr/libexec/

    echo "[*] Repairing permissions"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt8/usr/libexec/mobileactivationd
    ##sleep 2

    echo "[*] Resigning files"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt8
    ##sleep 2
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -Sents.xml /mnt8/usr/libexec/mobileactivationd
    ##sleep 2

    echo "[*] Device should reboot, also do not set passcode or sign in into iCloud yet"
    ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
    ##sleep 6
    echo "[*] Now you need to follow guide in another terminal window with instructions on jailbreaking with palera1n"
    
    ##osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
    echo "[*] Opened new Terminal window"
    echo "[*] Also if you are on Apple Silicon Mac, you need to replug the lightning cable when you see the Apple logo on the device"
    ##sleep 3

    echo "[!] Enter y when the device finishes jailbreaking "
    read finishedjb1

    if [ "$finishedjb1" = "y" ]; then

        echo "[*] Then complete setup as normal, and use the palera1n loader to install Sileo"
        echo "[!] You MUST set the password for sudo commands in palera1n to: alpine"
        echo "[*] After Bootstrap finishes downloading, open Sileo and install openssh."
        sleep 3

        echo
        echo "[*] Enter y when you finish installing openssh"
        read installingbootstrap

        if [ "$installingbootstrap" = "y" ]; then
            echo "[*] Booting ramdisk"
            ##cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
            sleep 3

            echo "[*] SSH window should pop up"
            ##osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
            echo "[!] Do not close it"

        else
            echo " "
        fi

        if [ "$basebandyn" = "y" ]; then
            cd $script_path && ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
        else
            cd $script_path && ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
        fi


        echo 
        ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd_backup /mnt8/usr/libexec/mobileactivationd
        sleep 2

        echo "[*] Rebooting, after jailbreak finishes jailbreak with palera1n"
        ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
        echo "[*] Also, you can close all opened terminal windows, except this one"
        sleep 7

        echo "[*] Opened new palera1n window"
        ##osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
        echo "[*] Same as last time, if you are on Apple Silicon Mac, you need to replug the lightning cable when you see the Apple logo on the device"
        sleep 3

        echo
        echo "[*] Enter y when the device finishes jailbreaking"

        if [ "$finishedjb1" = "y" ]; then
            echo "[*] Resetting known_hosts"
            ##rm -rf /Users/$usernamemac/.ssh/known_hosts
            sleep 1

            ##osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
            echo "[!] Do not close sshrd ssh terminal"
            
            ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /var/containers/Data/System
            ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -type d -name internal -prune -o -exec rm -rf {} \; 

            sleep 5

            echo "[*] Device should reboot now"
            ##./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
            sleep 6 


            echo "[*] Wait for the phone to reboot (if it doesn't force a reboot) and try to activate"
            echo "[*] This part of the script ends here. When done, open the next part ./activate.sh"
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
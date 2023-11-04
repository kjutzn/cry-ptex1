#!/bin/bash

skip_rdboot=false
skip_ffs=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-rdboot)
      skip_rdboot=true
      ;;
    --skip-ffs)
      skip_ffs=true
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

if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/Darwin/sshpass" "$script_path/"
    printg "[*] Copying sshpass to script path (Will be needed for later)"
else
    cd $script_path
fi

if [ ! -f "$script_path/iproxy" ]; then
    cp "$script_path/SSHRD_Script/Darwin/iproxy" "$script_path/"
    printg "[*] Copying iproxy to script path (Will be needed for later)"
else
    cd $script_path
fi

if [ -d "$script_path/knownhosts" ]; then
    cd $script_path
else
    cd $script_path && mkdir knownhosts
fi

if [ ! -f "$script_path/knownhosts/known_hosts" ]; then
    printr "[!] Known hosts aren't saved in $script_path/knownhosts"

    printg "[?] Do you want to save them manually or should script automatically save them? (m/a)"
    read savehosts

    if [ "$savehosts" = "a" ]; then
        printg "[*] Saving automatically"
        printg "[?] Please enter your username(of this mac): "
        read usernamemac

        cd $script_path && cp "/Users/$usernamemac/.ssh/known_hosts" "$script_path/"
        sleep 2

        cd $script_path && cp "$script_path/known_hosts" "$script_path/knownhosts/"  
        sleep 2

    else
        printg "[*] Save known_hosts manually. Script will sleep for 60 seconds. "
        printg "[*] Also it is located in /Users/username/.ssh/known_hosts"
        sleep 60
    fi

else
    printg "[*] Known_hosts file is already saved."
    sleep 1
fi


printg "[*] Script is repairing permissions for activation folder."
printg "[*] Terminal might ask for your password (for runnning sudo commands)"
sleep 1
sudo chmod -R 755 $script_path/activation
sleep 3

if [ "$skip_ffs" = true ]; then
    printr "[*] Skipped creating fakefs as specified"
else
    printg "[*] Creating FakeFS follow Palera1n Instructions in new terminal window. "
    osascript -e "tell application \"Terminal\" to do script \"palera1n -c -f\""
    sleep 3
fi

printr "[!] Enter enter when FakeFS finishes creating. "
read fakefsdone
sleep 1
    
printg "[?] Please enter what version did you downgrade to: "
read _iosdowngraded
sleep 3

printg "[*] Creating ramdisk for $_iosdowngraded"

cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh $_iosdowngraded
sleep 3

if [ "$skip_rdboot" = true ]; then
    printr "[*] Skipped booting ramdisk as specified"
else
    printg "[*] Booting ramdisk"
    cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
    sleep 3
fi

osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
printr "[!] Do not close sshrd ssh terminal"

printg "[*] Mounting filesystems"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
sleep 3

printg "[?] Does your device have Baseband? (y/n)"
printg "[*] Enter y if it isn't iPad"
sleep 1
read basebandyn

if [ "$basebandyn" = "y" ]; then
    printg "[*] Mounting apfs" 
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
else
    printg "[*] Mounting apfs" 
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
fi

printg "[*] ldid mobileactivationd"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -e /mnt8/usr/libexec/mobileactivationd > /mnt8/ents.xml
sleep 1

printg "[*] Renaming mobileactivationd to mobileactivationd_backup"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd_backup /mnt8/usr/libexec/mobileactivationd
sleep 1

printg "[*] Downloading required files."
curl -o "$script_path/mobileactivationd" "https://cdn.discordapp.com/attachments/1020892312756293695/1102082543253205012/mobileactivationd"
sleep 3

if [ ! -f "$script_path/mobileactivationd" ]; then
    printr "[!] mobieactivationd wasn't downloaded successfully, check your internet connection and rerun this script. "
    sleep 15
    printr "[!] Critical error script is exiting..."
    exit 256
else
    cd $script_path
    printg "[*] mobileactivationd was successfully downloaded"
    sleep 1
fi

sleep 1

printg "[*] Uploading required files to iDevice "
./sshpass -p 'alpine' scp -P 2222 "$script_path/mobileactivationd" root@localhost:/mnt8/usr/libexec/

printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt8/usr/libexec/mobileactivationd
sleep 2

printg "[*] Resigning files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /mnt8
sleep 2
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldid -Sents.xml /mnt8/usr/libexec/mobileactivationd
sleep 2

printg "[*] Device should reboot, also do not set passcode or sign in into iCloud yet"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
sleep 6
printg "[*] Now you need to follow guide in another terminal window with instructions on jailbreaking with palera1n"

osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
printg "[*] Opened new Terminal window"
printg "[*] Also if you are on Apple Silicon Mac, you need to replug the lightning cable when you see the Apple logo on the device"
sleep 3

printr "[!] Enter enter when the device finishes jailbreaking "
read finishedjb1

printr "[*] Then complete setup as normal, and use the palera1n loader to install Sileo"
printr "[!] You MUST set the password for sudo commands in palera1n to 'alpine' "
printr "[*] After Bootstrap finishes downloading, open Sileo and install openssh."
sleep 3

printg
printg "[*] Enter enter when you finish installing openssh"
read installingbootstrap

printg "[*] Booting ramdisk"
cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
sleep 3

printg "[*] SSH window should pop up"
osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
printr "[!] Do not close it"

printg "[?] Does your device have Baseband? (y/n)"
printg "[*] Enter y if it isn't iPad"
sleep 1
read basebandyntwo

if [ "$basebandyntwo" = "y" ]; then
    printg "[*] Mounting apfs" 
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s8 /mnt8
else
    printg "[*] Mounting apfs" 
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_apfs /dev/disk0s1s7 /mnt8
fi

printg "[*] Restoring old mobileactivationd" 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv /mnt8/usr/libexec/mobileactivationd_backup /mnt8/usr/libexec/mobileactivationd
sleep 2

printr "[!] Rebooting, after jailbreak finishes jailbreak with palera1n"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
printg "[*] Also, you can close all opened terminal windows, except this one"
sleep 7

printg "[*] Opened new palera1n window"
osascript -e "tell application \"Terminal\" to do script \"palera1n -f\""
printg "[*] Same as last time, if you are on Apple Silicon Mac, you need to replug the lightning cable when you see the Apple logo on the device"
sleep 3

printg
printg "[*] Enter y when the device finishes jailbreaking"
read finishedjbtwo

if [ "$finishedjbtwo" = "y" ]; then

    printg "[*] Resetting known_hosts"
    rm -rf /Users/$usernamemac/.ssh/known_hosts
    sleep 1

    osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
    printg "[!] Do not close sshrd ssh terminal"
    
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 cd /var/containers/Data/System
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -type d -name internal -prune -o -exec rm -rf {} \; 

    sleep 5

    printg "[*] Device should reboot now"
    ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot
    sleep 6 


    printg "[*] Wait for the phone to reboot (if it doesn't force a reboot) and try to activate"
    printg "[*] This part of the script ends here. When done, open the next part ./activate.sh"
    sleep 3
    exit 200

else
    printr "[!] Exit code: 105"
    exit 105
fi

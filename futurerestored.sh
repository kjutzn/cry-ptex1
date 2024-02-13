#!/bin/bash

skip_rdboot=false
skip_ffs=false
debug=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-rdboot)
      skip_rdboot=true
      ;;
    --skip-ffs)
      skip_ffs=true
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
        printg " [*] Automatically getting hosts file location and copying it to script path"

        cd $script_path && cp "${HOME}/.ssh/known_hosts" "$script_path/"
        sleep 2

        cd $script_path && cp "$script_path/known_hosts" "$script_path/knownhosts/"  
        sleep 2          

        printg " [*] Please check if known_hosts file exists in /knownhosts folder. If it doesn't copy it by yourself!"
        printg " [*] When you finish checking press enter"

        printg " [*] Files in .ssh directory are: "
        cd ${HOME}/.ssh/ && ls

        read donecheckinghostsidk
        sleep 1

        rm -rf ${HOME}/.ssh/known_hosts

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
    printg "[*] Press enter when you want to continue"
    read skiprdbootdone
else
    printg "[*] Booting ramdisk"
    cd $script_path/SSHRD_Script && chmod +x sshrd.sh && ./sshrd.sh boot
    sleep 3
fi

if [ "$debug" = true ]; then
    printy "[DEBUG] osascript -e tell application Terminal to do script ./sshrd.sh ssh"
else
    sleep 1
fi

pring "[*] Waiting for ramdisk to finish booting."
sleep 25
osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
printr "[!] Do not close sshrd ssh terminal"

printg "[*] Mounting filesystems"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems
sleep 5

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

printg "[*] Starting activate.sh"
./activate.sh

#!/bin/bash

skip_rdboot=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-rdboot)
      skip_rdboot=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

script_path="$(cd "$(dirname "$0")" && pwd)"

printg() {
  printf "\e[32m$1\e[m\n"
}

printy() {
  printf "\e[33;1m%s\n" "$1"
}

printr() {
  echo -e "\033[1;31m$1\033[0m"
}

printg "[*] Reseting known_hosts. Make sure to backup it manually before running this script if it is important!"
printr "[!] Press enter when ready to continue! "
read readytocontinue1

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
      printg "[*] Automatically getting hosts file location and copying it to script path"

      cd $script_path && cp "${HOME}/.ssh/known_hosts" "$script_path/"
      sleep 2

      cd $script_path && cp "$script_path/known_hosts" "$script_path/knownhosts/"  
      sleep 2          

      printg "[*] Please check if known_hosts file exists in /knownhosts folder. If it doesn't copy it by yourself!"
      printg "[*] When you finish checking press enter"

      printg "[*] Files in /.ssh directory are: "
      cd ${HOME}/.ssh/ && ls

      read donecheckinghostsidk
      sleep 1

      rm -rf ${HOME}/.ssh/known_hosts

    else
        printg "[*] Save known_hosts manually. Script will sleep for 60 seconds. "
        printg "[*] Also it is located in /Users/username/.ssh/known_hosts"
        printg "[*] Press enter when you are done."
        read donesavinghostsidkyes
    fi

else
    printg "[*] Known_hosts file is already saved."
    sleep 1
fi

chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
rm -rf ${HOME}/.ssh/known_hosts

if [ "$skip_rdboot" = true ]; then
    printg "[*] Make sure to create ramdisk for your version if you haven't used futurerestored.sh!"
else
    printg "[?] What version is your iDevice on?"
    read ios1
    printg
fi

if [ -d "$script_path/SSHRD_Script" ]; then
    printg " [*] SSHRD_Script exists in the script's directory."
    cd "$script_path/SSHRD_Script" && git pull

else
    echo -e "\033[1;31m[!] The folder SSHRD_Script does not exist in the script's directory. Exiting the program. \033[0m"
    echo -e "\033[1;31m[!] This tool depends on SSHRD_Script by Nathan. \033[0m"
    echo

    printg "[?] Do you want to install it now? (y/n)"
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

printg "[*] Creating Ramdisk, make sure that your iDevice is in DFU mode"
printg "[*] If it isn't do palera1n --dfuhelper in another terminal window."
sleep 1


if [ "$skip_rdboot" = true ]; then
    printg "[*] Skipped booting ramdisk as specified"
else
    printg "[*] Creating Ramdisk"
    cd "$script_path/SSHRD_Script" && chmod +x sshrd.sh && ./sshrd.sh "$ios1"
    printg "[*] Booting ramdisk"
    cd "$script_path/SSHRD_Script" && ./sshrd.sh boot
fi

printg "[*] You might have to press allow for opening new terminal window"

if [ "$skip_rdboot" = true ]; then
    printg "[*] Terminal window with ssh should already be opened"
else
  osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
fi

printr "[!] Do not close it, and make sure that ssh is successfully connected!"
printg "[*] Press enter when everything is ready. "
read rdbready

printg "[*] Deleting previous activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /mnt2/mobile/Media/Downloads/1
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /mnt2/mobile/Media/1
sleep 1

printg "[*] Making directory /mnt2/mobile/Media/Downloads/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir /mnt2/mobile/Media/Downloads/1
sleep 1

printg "[*] Transfering Activation folder to /mnt2/mobile/Media/Downloads/1, make sure that Activation folder is located in Script Path! "
printg "[*] Press enter when done checking!"
read checkifactivationfolder
./sshpass -p alpine scp -rP 2222 -o StrictHostKeyChecking=no ~/$script_path/Activation root@localhost:/mnt2/mobile/Media/Downloads/1
sleep 1

printg "[*] Moving activation files to /mnt2/mobile/Media/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/Downloads/1 /mnt2/mobile/Media
sleep 3

printg "[*] Fixing permisions of activation folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown -R mobile:mobile /mnt2/mobile/Media/1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod -R 755 /mnt2/mobile/Media/1
sleep 1

printg "[*] Fixing permissions of all activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/data_ark.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist 

sleep 4

printg "[*] Moving Fairplay folder to /mnt2/mobile/Library/FairPlay"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/FairPlay /mnt2/mobile/Library/FairPlay 
sleep 5

printg "[*] Reparing FairPlay permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt2/mobile/Library/FairPlay

printg "[*] Finding internal folder"
ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name internal) 
ACT2=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name activation_records) 

printg "[*] Internal folder: "
echo $ACT1 

ACT2=${ACT1%?????????????????}
sleep 1
printg "[*] activation_records: "
echo $ACT2 ACT3=$ACT2/Library/internal/data_ark.plist

printg "[*] Setting permissions of data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg $ACT3 
sleep 1

printg "[*] Replacing data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/data_ark.plist $ACT3 
sleep 3

printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT3 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT3
sleep 1

ACT4=$ACT2/Library/activation_records 

printg "[*] Making directory activation_records"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir $ACT4 
sleep 2

printg "[*] Copying activation_record.plist to activation_records folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/activation_record.plist $ACT4/activation_record.plist 
sleep 3

printg "[*] Reparing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT4/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT4/activation_record.plist 

printg "[*] Replacing com.apple.commcenter.device_specific_nobackup.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 5

printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown root:mobile /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1

printg "[*] Rebooting"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 reboot

sleep 2
printg "[*] Script done, your device should be in homescreen"
printg "[*] You can sign in into iCloud now, also if you set passcode you will have to restore if you want to jailbreak with Palera1n again"
sleep 2

printg "[*] Restoring known_hosts file"
sleep 1
cd $script_path && ./grabbingFiles.sh --restorehosts
sleep 1

printg "[*] All done! Enjoy iOS 14/15."

exit 1

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

      printg " [*] Files in /.ssh directory are: "
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

printg "[*] Terminating all processes that use port 2222"
kill -9 $(lsof -ti:2222)
sleep 1
printg "[*] Opened new terminal window, DO NOT close it"
osascript -e "tell application \"Terminal\" to do script \"$script_path/iproxy 2222 22\""

printg "[*] Reseting known_hosts. Backup is stored in /knownhosts or in your manual backup."
sleep 3

chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass

printg "[*] Please enter your username(of this mac): "
read usernamemac
rm -rf ${HOME}/.ssh/known_hosts

printg "[*] You might have to press allow for opening new terminal window"
osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
printr "[!] Do not close opened Terminal window"

printg "[*] Deleting previous activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /var/mobile/Media/Downloads/1
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /var/mobile/Media/1
sleep 1

printg "[*] Making directory /var/mobile/Media/Downloads/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir /var/mobile/Media/Downloads/1
sleep 1

printg "[*] Transfering Activation folder to /var/mobile/Media/Downloads/1"
./sshpass -p alpine scp -rP 2222 -o StrictHostKeyChecking=no ~/Desktop/Activation root@localhost:/var/mobile/Media/Downloads/1
sleep 1

printg "[*] Moving activation files to /var/mobile/Media/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/Downloads/1 /var/mobile/Media
sleep 3

printg "[*] Fixing permisions of activation folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown -R mobile:mobile /var/mobile/Media/1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod -R 755 /var/mobile/Media/1
sleep 1

printg "[*] Fixing permissions of all activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/data_ark.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist 

sleep 5
printg "[*] Respringing device"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 killall backboardd sleep 12 

printg "[*] Moving Fairplay folder to /var/mobile/Library/FairPlay"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/FairPlay /var/mobile/Library/FairPlay 
sleep 5

printg "[*] Reparing FairPlay permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /var/mobile/Library/FairPlay

printg "[*] Finding internal folder"
ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -name internal) 
ACT2=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -name activation_records) 

printg "[*] Internal folder is located here: "
echo $ACT1 

ACT2=${ACT1%?????????????????}
sleep 1
printg "[*] activation_records folder is located here: "
echo $ACT2 ACT3=$ACT2/Library/internal/data_ark.plist

printg "[*] Setting permissions of data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg $ACT3 
sleep 1

printg "[*] Replacing data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/data_ark.plist $ACT3 
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
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/activation_record.plist $ACT4/activation_record.plist 
sleep 3

printg "[*] Reparing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT4/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT4/activation_record.plist 

printg "[*] Replacing com.apple.commcenter.device_specific_nobackup.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 5

printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown root:mobile /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1

printg "[*] Replaced all files, unloading mobileactivationd"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 launchctl unload /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist 
sleep 1

printg "[*] Reloading mobileactivationd"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 launchctl load /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist
sleep 1

printg "[*] Userspace rebooting"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldrestart

sleep 2
printg "[*] Script done, your device should be in homescreen"
printg "[*] You can sign in into iCloud now, also if you set passcode you will have to restore if you want to jailbreak with Palera1n again"
sleep 2

printg "[*] Restoring known_hosts file"
sleep 1
cd $script_path && ./main.sh --restorehosts
sleep 1

printg "[*] All done! Enjoy iOS 14/15."

exit 1

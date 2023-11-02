script_path="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Terminating all processes that use port 2222"
kill -9 $(lsof -ti:2222)
sleep 1
echo "[*] Opened new terminal window, DO NOT close it"
osascript -e "tell application \"Terminal\" to do script \"$script_path/iproxy 2222 22\""

echo "[*] Known hosts will get reseted. If you aren't alright with that close this script"
sleep 3

chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass

echo "Please enter your username(of this mac): "
read usernamemac
rm -rf /Users/$usernamemac/.ssh/known_hosts

echo "[*] You might have to press allow for opening new terminal window"
osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\""
echo "[!] Do not close opened Terminal window"

echo "[*] Deleting previous activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /var/mobile/Media/Downloads/1
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /var/mobile/Media/1
sleep 1

echo "[*] Making directory /var/mobile/Media/Downloads/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir /var/mobile/Media/Downloads/1
sleep 1

echo "[*] Transfering Activation folder to /var/mobile/Media/Downloads/1"
./sshpass -p alpine scp -rP 2222 -o StrictHostKeyChecking=no ~/Desktop/Activation root@localhost:/var/mobile/Media/Downloads/1
sleep 1

echo "[*] Moving activation files to /var/mobile/Media/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/Downloads/1 /var/mobile/Media
sleep 3

echo "[*] Fixing permisions of activation folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown -R mobile:mobile /var/mobile/Media/1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod -R 755 /var/mobile/Media/1
sleep 1

echo "[*] chmod 644 all activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/data_ark.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /var/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist 

sleep 5
echo "[*] Respringing device"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 killall backboardd sleep 12 

echo "[*] Moving Fairplay folder to /var/mobile/Library/FairPlay"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/FairPlay /var/mobile/Library/FairPlay 
sleep 5

echo "[*] Reparing FairPlay permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /var/mobile/Library/FairPlay

echo "[*] Finding internal folder"
ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -name internal) 
ACT2=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /private/var/containers/Data/System -name activation_records) 

echo "[*] Internal folder is located here: "
echo $ACT1 

ACT2=${ACT1%?????????????????}
sleep 1
echo "[*] activation_records folder is located here: "
echo $ACT2 ACT3=$ACT2/Library/internal/data_ark.plist

echo "[*] Setting permissions of data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg $ACT3 
sleep 1

echo "[*] Replacing data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/data_ark.plist $ACT3 
sleep 3

echo "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT3 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT3
sleep 1

ACT4=$ACT2/Library/activation_records 

echo "[*] Making directory activation_records"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir $ACT4 
sleep 2

echo "[*] Copying activation_record.plist to activation_records folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/activation_record.plist $ACT4/activation_record.plist 
sleep 3

echo "[*] Reparing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT4/activation_record.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT4/activation_record.plist 

echo "[*] Replacing com.apple.commcenter.device_specific_nobackup.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /var/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 5

echo "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chown root:mobile /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 
sleep 1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist ./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
sleep 1

echo "[*] Replaced all files, unloading mobileactivationd"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 launchctl unload /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist 
sleep 1

echo "[*] Reloading mobileactivationd"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 launchctl load /System/Library/LaunchDaemons/com.apple.mobileactivationd.plist
sleep 1

echo "[*] Userspace rebooting"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 ldrestart

sleep 2
echo "[*] Script done, your device should be in homescreen"
echo "[*] You can sign in into iCloud now, also if you set passcode you will have to restore if you want to jailbreak with Palera1n again"
sleep 2

echo "[*] Restoring known_hosts file"

echo
echo "[?] Please enter your username (of this Mac) "
read usernamemac
sleep 1
cd $script_path && cp " "$script_path/knownhosts/known_hosts" "/Users/$usernamemac/.ssh/
sleep 3

exit 1

# Fix failed to activate when downgrading with iOS 16/17 sep

# Prerequsites
1. A computer running macOS
2. A11 device(iPhone X **isn't** supported)
3. Have [Palera1n](https://github.com/palera1n/palera1n) installed

# Disclamer
This script is for educational purposes. I am aware people might use this to bypass iCloud, but I am NOT encouraging you to bypass iCloud and you **shouldn't do that**. This guide is **legitametly** activating it!
ALSO: This script is for advanced users, i am not responsable if your device becomes broken (idk how but just in case) or if your known_hosts get reseted. If you have important saved hosts in known_hosts file save them manually (script already saves it but this is just in case). 

# Usage
1. Clone and cd into this repository: `git clone https://github.com/kjutzn/cry-ptex1 --recursive && cd cry-ptex1`
    - If you have cloned this before, run `cd cry-ptex1 && git pull` to pull new changes
2. Run `./grabbingFiles.sh `
3. After it finishes run `./activate.sh`

# Have in mind before using
1. If you are already on iOS 15.0-15.4.1 or any 14.x version, i wouldn't advise you to use this script, check [Possible Issues](https://github.com/kjutzn/cry-ptex1/blob/main/Guides/PossibleIssues.md) in Guides folder
2. Also if signing in into iCloud doesn't work try grabing new activation files (from latest iOS 16 version) and redoing whole script
3. If you are on iOS 17, use filza for obtaining files, if you need any help with that join Discord.

# Help
If you run into any issues, message me on Discord server, here is the [invite](https://discord.gg/buPefAxnVn)

# Linux
Support for linux will be added most likely next month, but until them you can replace binaries manually

# Credits
- [Orangera1n](https://github.com/Orangera1n/) - Guide about activativating futurerestored idevices on ios 15
- [Nathan](https://github.com/verygenericname/SSHRD_Script) - SSHRD script
- [Edwin](https://github.com/edwin170) - Guided me thru this script and helped me fix few things in it
- [Palera1n](https://github.com/palera1n/palera1n) - Used when creating fakefs
- Also have in mind patched mobileactivationd is **NOT MINE** it is from [Orangera1n's gist](https://gist.github.com/Orangera1n/fa3ca03d6aa9f5be963fd3b72c3f4225)

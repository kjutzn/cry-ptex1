# Fix failed to activate when downgrading with iOS 16/17 sep

# Prerequisites
1. A computer running macOS
2. A11 device(iPhone X **isn't** supported)

# Usage
1. Clone and cd into this repository: `git clone https://github.com/kjutzn/cry-ptex1 --recursive && cd cry-ptex1`
    - If you have cloned this before, run `cd cry-ptex1 && git pull` to pull new changes
2. Run `./grabbingFiles.sh `
3. After it finishes run `./activate.sh`

# Have in mind before using
1. If you are already on iOS 15.0-15.4.1 or any 14.x version, i wouldn't advise you to use this script, check [Possible Issues](https://github.com/kjutzn/cry-ptex1/blob/main/Guides/PossibleIssues.md) in Guides folder
2. Also if signing in into iCloud doesn't work try grabbing new activation files (from latest iOS 16 version) and redoing whole script
3. If you are on iOS 17, use filza for obtaining files, if you need any help with that join Discord.

# Help
If you run into any issues, message me on Discord server, here is the [invite](https://discord.gg/buPefAxnVn)

# Linux
Support for linux isn't planned but you can just replace binaries in /Darwin folder from sshrd script with /Linux or manually do all commands from script

# Disclamer
This script is for educational purposes. I am aware people might use this to bypass iCloud, but I am NOT encouraging you to bypass iCloud and you **shouldn't do that**. This guide is **legitimately** activating it!
ALSO: This script is for advanced users, i am not responsible if your device becomes broken (idk how but just in case) or if your known_hosts get reseted. **If you have important saved hosts in known_hosts file save them manually (script already saves it but this is just in case).**

# Credits
- [Orangera1n](https://github.com/Orangera1n/) - Guide about activating futurerestored idevices on iOS 15
- [Nathan](https://github.com/verygenericname/SSHRD_Script) - SSHRD script
- [Edwin](https://github.com/edwin170) - Guided me through this script and helped me fix few things in it
- [Sasa](https://github.com/sasa8810) - Idea and few parts of code using only sshrd

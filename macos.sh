#!/bin/bash

## all variables: script_path, installsshrd, act_have, act_path

script_path="$(cd "$(dirname "$0")" && pwd)"

echo "== Cry Ptex1 =="
echo "Made by Kjutzn"
echo "Thanks to Orangera1n, VeryGenericName (ssh)"
echo "This tool DOES NOT work on iPhone X, due to sep breaking restores."

echo

echo "Please open the guide in another tab and follow it closely!"
echo "If you need any help, open a new issue on GitHub or contact me on Discord."
echo

echo "What version is your iPhone on?"
read ios1
echo

echo "Hello, $ios1! Welcome to the script." ## this is just for testing input!!!

echo $script_path

if [ -d "$script_path/SSHRD_Script" ]; then
    echo "The folder SSHRD_Script exists in the script's directory."
    cd "$script_path/SSHRD_Script" && git pull

else
    echo "The folder SSHRD_Script does not exist in the script's directory. Exiting the program."
    echo "This tool depends on SSHRD_Script by Nathan."

    echo "Do you want to install it now? (y/n)"
    read installsshrd

    if [ "$installsshrd" = "y" ]; then
        echo "Cloning verygenericname/SSHRD_Script"
        git clone https://github.com/verygenericname/SSHRD_Script --recursive
        
        cd "$script_path/SSHRD_Script" && git pull

    else
        echo "Exiting the program."
        exit 100
    fi
fi


echo "Do you have activation files? (y/n)"
read act_have

if [ "$act_have" = "y" ]; then
        echo "Copy them to: $script_path/activation"
        cd $script_path/activation
        

    else
        echo "Plug you device and trust it"


    fi

#!/bin/bash

echo "== Cry Ptex1 =="
echo "Made by Kjutzn"
echo "Thanks to Orangera1n, VeryGenericName (ssh)"
echo

echo "Please open the guide in another tab and follow it closely!"
echo "If you need any help, open a new issue on GitHub or contact me on Discord."
echo

echo "What version is your iPhone on?"
read ios1
echo

echo "Hello, $ios1! Welcome to the script." ## this is just for testing input!!!

echo

if [ -d "SSHRD_Script" ]; then
    echo "The folder SSHRD_Script exists in the current directory."
else
    echo "The folder SSHRD_Script does not exist in the current directory. Exiting the program."

    echo "This tool depends on SSHRD_Script by Nathan."

    echo "Do you want to install it now? (y/n)"
    read installsshrd

    if [ "$installsshrd" = "y" ]; then
        echo "Cloning verygenericname/SSHRD_Script"
        git clone https://github.com/verygenericname/SSHRD_Script --recursive

    else
        echo "Exiting the program."
        exit 100
    fi
fi

echo

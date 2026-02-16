#!/bin/bash

# Check if the source file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <source_file.cpp>"
    exit 1
fi

# Extract the filename without the extension
filename="${1%.cpp}"

# Compile the C++ source file
g++ "$1" -o "$filename"
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Execute the compiled program
time "./$filename"
# { time "./$filename"; } 2>&1


# Automatically delete the executable after execution
if [ $? -eq 0 ]; then
    rm "$filename"
    printf "\n\nExecutable deleted after execution.\n"
else
    echo "Program execution failed. Keeping the executable for debugging."
fi

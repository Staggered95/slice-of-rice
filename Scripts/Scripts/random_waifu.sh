#!/bin/bash

names=("Kamisato Ayaka" "Raiden Shogun" "Nahida" "Shenhe" "Focalor" "Yamauchi Sakura" "Makinohara Shouko" "Kawamoto Hinata" "Matou Sakura" "Mahiru Shiina" "Emilia" "Watanabe Akari" "Rem" "Ijichi Nijika" "Tsundere Elf" "Asuna Yuuki" "Anna Yamada" "Ichigyou Ruri")

# Get a random index within the array bounds
random_index=$((RANDOM % ${#names[@]}))

# Get the random name
random_name="${names[$random_index]}"

# Generate figlet output and pipe to lolcat
figlet "$random_name"

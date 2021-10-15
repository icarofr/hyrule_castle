#!/bin/bash
characters_file="./assets/players.csv"
enemies_file="./assets/enemies.csv"
current_character=1
current_enemy=12
i=1
IFS=","
RED='\033[0;31m'
NC='\e[0m'
GREEN='\033[0;32m'
ITALIC="\e[3m"

while read -r id name hp mp str int def res spd luck race class rarity; do
    if [[ $current_character = $id ]]; then
        current_name=$name
        current_total_hp=$hp
        current_mp=$mp
        current_str=$str
    fi
done < <(tail -n +2 $characters_file)

while read -r id name hp mp str int def res spd luck race class rarity; do
    if [[ $current_enemy = $id ]]; then
        enemy_name=$name
        enemy_total_hp=$hp
        enemy_mp=$mp
        enemy_str=$str
    fi
done < <(tail -n +2 $enemies_file)

function main {
    enemy_hp=$enemy_total_hp
    current_hp=$current_total_hp
    while [ $i -le 10 ]; do
        echo "========== FIGHT $i =========="
        echo -e "${RED}$enemy_name${NC}"
        echo -e "HP: $(seq -sI $enemy_hp | tr -d '[:digit:]')\n"
        echo -e "${GREEN}$current_name${NC}"
        echo -e "HP: $(seq -sI $current_hp | tr -d '[:digit:]')\n"
        echo -e "---Options-----------\n1. Attack    2. Heal\n"
        echo -e "${ITALIC}You encounter a $enemy_name\n${NC}"
        while true; do
            read -n 1 -p "" action
            if [ $action = 1 ]; then
                enemy_hp=$(($enemy_hp - $current_str))
                echo -e "\n${ITALIC}You attacked and dealt $current_str damage!${NC}"
            fi
            if [ $enemy_hp -le 0 ]; then
                echo -e "Enemy fainted!\n"
                enemy_hp=$enemy_total_hp
                break
            fi
            current_hp=$(($current_hp - $enemy_str))
            echo -e "\n${ITALIC}$enemy_name attacked and dealt $enemy_str damage!${NC}"
            if [ $current_hp -le 0 ]; then
                echo -e "$current_name fainted!\n"
                i=0
                current_hp=$current_total_hp
                enemy_hp=$enemy_total_hp
                main
                break
            fi
            echo -e "${RED}$enemy_name${NC}"
            echo -e "HP: $(seq -sI $enemy_hp | tr -d '[:digit:]')\n"
            echo -e "${GREEN}$current_name${NC}"
            echo -e "HP: $(seq -sI $current_hp | tr -d '[:digit:]')\n"
            echo -e "---Options-----------\n1. Attack    2. Heal\n"
        done
        i=$(($i + 1))
    done
}
while true; do main; done

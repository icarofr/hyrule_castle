#!/bin/bash
characters_file="./assets/players.csv"
enemies_file="./assets/enemies.csv"
current_character=1
current_enemy=11
boss=0
eog=0
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
    while [ $i -le 7 ]; do
        if [[ $boss -ne 0 ]]; then
            while read -r id name hp mp str int def res spd luck race class rarity; do
                if [[ $boss = $id ]]; then
                    enemy_name=$name
                    enemy_hp=$hp
                    enemy_total_hp=$hp
                    enemy_mp=$mp
                    enemy_str=$str
                fi
            done < <(tail -n +2 "./assets/bosses.csv")
            eog=1
            boss=0
        fi
        echo "========== FIGHT $i =========="
        echo -e "${RED}$enemy_name${NC}"
        echo -e "HP: $(seq -sI $enemy_hp | tr -d '[:digit:]')$(seq -s_ $(($enemy_total_hp - $enemy_hp)) | tr -d '[:digit:]') $enemy_hp / $enemy_total_hp\n"
        echo -e "${GREEN}$current_name${NC}"
        echo -e "HP: $(seq -sI $current_hp | tr -d '[:digit:]')$(seq -s_ $(($current_total_hp - $current_hp)) | tr -d '[:digit:]') $current_hp / $current_total_hp\n"
        echo -e "---Options-----------\n1. Attack    2. Heal\n"
        echo -e "${ITALIC}You encounter a $enemy_name\n${NC}"
        while true; do
            function player_action {
                read -n 1 -p "" action
                if [ $action = 1 ]; then
                    enemy_hp=$(($enemy_hp - $current_str))
                    echo -e "\n${ITALIC}You attacked and dealt $current_str damage!${NC}"
                elif [ $action = 2 ]; then
                    current_hp=$(($current_hp + $current_total_hp / 2))
                    if [ $current_hp -ge $current_total_hp ]; then
                        echo -e "\n${ITALIC}You restored half of your HP!${NC}"
                        current_hp=$current_total_hp
                    fi
                else
                    player_action
                fi
            }
            player_action
            if [ $enemy_hp -le 0 ]; then
                echo -e "Enemy fainted!\n"
                if [ $eog = 1 ]; then
                    echo -e "A winner is you\n"
                    exit 1
                fi
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
            echo -e "HP: $(seq -sI $enemy_hp | tr -d '[:digit:]')$(seq -s_ $(($enemy_total_hp - $enemy_hp)) | tr -d '[:digit:]') $enemy_hp / $enemy_total_hp\n"
            echo -e "${GREEN}$current_name${NC}"
            echo -e "HP: $(seq -sI $current_hp | tr -d '[:digit:]')$(seq -s_ $(($current_total_hp - $current_hp)) | tr -d '[:digit:]') $current_hp / $current_total_hp\n"
            echo -e "---Options-----------\n1. Attack    2. Heal\n"
        done
        i=$(($i + 1))
        if [ $i -eq 7 ]; then
            boss=1
        fi
    done
}
while true; do main; done

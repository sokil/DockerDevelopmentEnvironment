#!/bin/bash

projectName="{PROJECT_NAME}"

# ask for confirm
while true; do
    read -p "Do you really want to drop containers? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# drop containers
docker ps -a -f NAME=$projectName --format "{{.Names}}" | xargs -I{} docker rm {}
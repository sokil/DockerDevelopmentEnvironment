#!/usr/bin/env bash

CURRENT_DIR=$(dirname $(readlink -f $0))
PROJECT_FILES_DIR=${CURRENT_DIR}/projects

function print_usage {
    MESSAGE=$1
    echo -e "\033[1;37mUseage\033[0m: ./run.sh command project_name [command_argument, ...]"
    echo $MESSAGE
}

function print_available_commands {
    echo -e "\033[1;37mAvailable commands:\033[0m"
    echo -e "\033[0;32mup\033[0m: build or run containers"
    echo -e "\033[0;32mbash\033[0m: launch bash in container"
    echo -e "\033[0;32mshell_php\033[0m: launch bash as www-user in container"
    echo -e "\033[0;32mshell_mysql\033[0m: launch mysql in container"
    echo -e "\033[0;32mdrop\033[0m: drop container"
    echo ""
}

function print_available_projects {
    echo -e "\033[1;37mAvailable projects:\033[0m"
    find $PROJECT_FILES_DIR -type f -printf "%f\n" -name ".env" | sed 's/\.env//g' | xargs -I{} echo "-" {}
    echo ""
}

function drop_container {
    PROJECT_NAME=$1
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
    docker ps -a -f NAME=${PROJECT_NAME} --format "{{.Names}}" | xargs -I{} docker rm {}
}

function up_container {
    PROJECT_NAME=$1
    echo $IMAGE_NGINX;
}

function exec_container_command_root {
    PROJECT_NAME=$1
    SERVICE_NAME=$2
    SHELL_COMMAND=$3
    docker exec -it ${PROJECT_NAME}_${SERVICE_NAME} ${SHELL_COMMAND}
}

function exec_container_command_user {
    PROJECT_NAME=$1
    SERVICE_NAME=$2
    SHELL_COMMAND=$3
    USER_NAME=$4
    docker exec --user ${USER_NAME} -it ${PROJECT_NAME}_${SERVICE_NAME} $SHELL_COMMAND
}

# read project name from cli arguments
PROJECT_NAME=$1
if [[ -z $PROJECT_NAME ]];
then
    print_usage
    print_available_commands
    print_available_projects
    exit
fi

# check project file
PROJECT_FILE=${PROJECT_FILES_DIR}/${PROJECT_NAME}.env
if [[ ! -e $PROJECT_FILE ]];
then
    echo -e "\033[1;31mInvalid project specified\033[0m"
    print_available_projects
    exit
fi

# read command cli arguments
COMMAND_NAME=$2
if [[ -z $COMMAND_NAME ]];
then
    echo -e "\033[1;31mInvalid command specified\033[0m"
    print_available_commands
    exit
fi

# import project
source $PROJECT_FILE

# dispatch command
case $COMMAND_NAME in
    up)
        up_container ${PROJECT_NAME}
        ;;
    bash)
        SERVICE_NAME=$3
        exec_container_command_root ${PROJECT_NAME} $SERVICE_NAME bash
        ;;
    shell_php)
        exec_container_command_user ${PROJECT_NAME} php bash www-data
        ;;
    shell_mysql)
        exec_container_command_root ${PROJECT_NAME} php "mysql ${PROJECT_NAME}"
        ;;
    drop)
        drop_container "${PROJECT_NAME}"
        ;;
    *)
        echo "Unknown command"
        ;;
esac

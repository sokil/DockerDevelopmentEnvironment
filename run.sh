#!/usr/bin/env bash

CURRENT_DIR=$(dirname $(readlink -f $0))
ENVIRONMENT_DIR=${CURRENT_DIR}/env

function print_usage {
    message=$1
    echo -e "\033[1;37mUseage\033[0m: ./run.sh [command] [environment_name]"
    echo $message
}

function print_help {
    print_usage
    echo -e "\033[1;37mAvailable commands:\033[0m"
    echo -e "\033[0;32mbuild\033[0m: build containers"
    echo -e "\033[0;32mbash\033[0m: launch bash in container"
    echo -e "\033[0;32mshell_php\033[0m: launch bash as www-user in container"
    echo -e "\033[0;32mshell_mysql\033[0m: launch mysql in container"
    echo -e "\033[0;32mdrop\033[0m: drop container"
    echo ""
    echo -e "\033[1;37mAvailable environments:\033[0m"
    find $ENVIRONMENT_DIR -type f -printf "%f\n" -name ".env" | sed 's/\.env//g'
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
    docker ps -a -f NAME=$PROJECT_NAME --format "{{.Names}}" | xargs -I{} docker rm {}
}

function exec_container_command_root {
    service_name=$1
    command=$2
    docker exec -it ${PROJECT_NAME}_${service_name} $command
}

function exec_container_command_user {
    service_name=$1
    command=$2
    user=$3
    docker exec --user $user -it ${PROJECT_NAME}_${service_name} $command
}

# read command cli arguments
COMMAND_NAME=$1
if [[ -z $COMMAND_NAME ]];
then
    print_usage "Command name not specified"
    exit
fi

# if command is help - prent help
if [[ $COMMAND_NAME = "help" ]];
then
    print_help
    exit
fi

# read environment name from cli arguments
ENVIRONMENT_NAME=$2
if [[ -z $ENVIRONMENT_NAME ]];
then
    print_usage "Environment name not specified"
    exit
fi

# import environment
ENVIRONMENT_FILE=${ENVIRONMENT_DIR}/${ENVIRONMENT_NAME}.env
if [[ ! -e $ENVIRONMENT_FILE ]];
then
    echo "Environment file not found"
    exit
fi

source $ENVIRONMENT_FILE

# dispatch command
case $COMMAND_NAME in
    build)
        echo "hello1"
        ;;
    bash)
        $service=$3
        exec_container_command_root $service bash
        ;;
    shell_php)
        exec_container_command_user php bash www-data
        ;;
    shell_mysql)
        exec_container_command_root php "mysql ${PROJECT_NAME}"
        ;;
    drop)
        drop_container ${PROJECT_NAME}"
        ;;
    *)
        echo "Unknown command"
        ;;
esac


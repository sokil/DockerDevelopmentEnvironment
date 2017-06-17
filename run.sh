#!/usr/bin/env bash

CURRENT_DIR=$(dirname $(readlink -f $0))

function print_usage {
    MESSAGE=$1
    echo -e "\033[1;37mUseage\033[0m: ./run.sh command [command_argument, ...]"
    echo $MESSAGE
}

function print_available_commands {
    echo -e "\033[1;37mAvailable commands:\033[0m"
    echo -e "\033[0;32mbash [service_name]\033[0m: launch bash in container"
    echo -e "\033[0;32mshell_php\033[0m: launch bash as www-user in container"
    echo -e "\033[0;32mshell_mysql\033[0m: launch mysql in container"
    echo -e "\033[0;32mAny commands not in list above goes directly to docker-compose, so be free to use this tool as docker-compose\033[0m"
    echo ""
}

# drop containers
function drop_container {
    COMPOSE_PROJECT_NAME=$1
    # ask for confirm
    while true; do
        read -p "Do you really want to drop containers? (y/n): " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    docker ps -a -f NAME=${COMPOSE_PROJECT_NAME} --format "{{.Names}}" | xargs -I{} docker rm {}
}

# stop containers
function stop_container {
    docker ps -a -f NAME=${COMPOSE_PROJECT_NAME} --format "{{.Names}}" | xargs -I{} docker stop {}
}

function compose {
    DOCKER_COMPOSE_COMMAND="docker-compose --project-name ${COMPOSE_PROJECT_NAME} --project-directory ${CURRENT_DIR}"

    # append service confugs
    if [[ ! -z $NGINX_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/nginx/compose.yaml"
    fi

    if [[ ! -z $MYSQL_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/php/compose.yaml"
    fi

    if [[ ! -z $PHP_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/mysql/compose.yaml"
    fi

    if [[ ! -z $ELASTICSEARCH_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/elasticsearch/compose.yaml"
    fi

    if [[ ! -z $REDIS_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/redis/compose.yaml"
    fi

    if [[ ! -z $MEMCACHED_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/memcached/compose.yaml"
    fi

    if [[ ! -z $RABBITMQ_IMAGE ]];
    then
        DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} -f ${CURRENT_DIR}/compose/rabbitmq/compose.yaml"
    fi

    # append up params
    DOCKER_COMPOSE_COMMAND="${DOCKER_COMPOSE_COMMAND} ${@}"

    # show command
    echo -e "\033[1;37mCommand\033[0m: ${DOCKER_COMPOSE_COMMAND}"

    # start up
    bash -c "${DOCKER_COMPOSE_COMMAND}"
}

function exec_container_command_root {
    COMPOSE_PROJECT_NAME=$1
    SERVICE_NAME=$2
    SHELL_COMMAND=$3
    docker exec -it ${COMPOSE_PROJECT_NAME}_${SERVICE_NAME} ${SHELL_COMMAND}
}

function exec_container_command_user {
    COMPOSE_PROJECT_NAME=$1
    SERVICE_NAME=$2
    SHELL_COMMAND=$3
    USER_NAME=$4
    docker exec --user ${USER_NAME} -it ${COMPOSE_PROJECT_NAME}_${SERVICE_NAME} $SHELL_COMMAND
}

# read command cli arguments
COMMAND_NAME=$1
if [[ -z $COMMAND_NAME ]];
then
    print_available_commands
    exit
fi

# import environment
set -o allexport
source .env
set +o allexport

# dispatch command
case $COMMAND_NAME in
    bash)
        SERVICE_NAME=$2
        exec_container_command_root ${COMPOSE_PROJECT_NAME} $SERVICE_NAME bash
        ;;
    shell_php)
        exec_container_command_user ${COMPOSE_PROJECT_NAME} php bash www-data
        ;;
    shell_mysql)
        exec_container_command_root ${COMPOSE_PROJECT_NAME} php "mysql ${COMPOSE_PROJECT_NAME}"
        ;;
    drop)
        drop_container "${COMPOSE_PROJECT_NAME}"
        ;;
    stop)
        stop_container
        ;;
    *)
        # fallback to docker-container
        compose ${@:1}
        ;;
esac

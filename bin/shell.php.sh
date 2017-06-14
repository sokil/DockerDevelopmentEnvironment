#!/bin/bash

projectName="{PROJECT_NAME}"

docker exec --user www-data -it ${projectName}_php bash

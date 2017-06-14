#!/bin/bash

projectName="{PROJECT_NAME}"

docker exec -it ${projectName}_mysql mysql ${projectName}

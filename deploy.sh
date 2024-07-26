#!/bin/bash

if [ ! "$1" ] || [ ! "$2" ] || [ ! "$3" ] || [ ! "$4" ] || [ ! "$5" ]; then
    echo "Please enter required arguments:  REMOTE_HOST REMOTE_USER REMOTE_PWD REMOTE_DIR SFTP_PORT"
    exit 1
fi

FTP_HOST=$1
FTP_USER=$2
FTP_PWD=$3
FTP_DIR=$4
SFTP_PORT=$5
REPO_DIR=$(pwd)

if [ ! -d .git ]; then
    echo "${REPO_DIR}  is not a git repository"
    exit 1
fi
declare -a IGNOREFILES=("bitbucket-pipelines.yml" ".gitignore" "deploy.sh")

inArray(){
 local element
  for element in "${IGNOREFILES[@]}"; do
    if [[ "$element" == "$1" ]]; then
      return 1
    fi
  done
  return 0
}

CHANGED_FILES=$(git diff --name-only HEAD HEAD~1)

if [ -z "${CHANGED_FILES}" ]; then
    echo "No changed files to upload."
    exit 0
fi

UPLOADED_FILES=()

for FILE in $CHANGED_FILES; do
    inArray "${FILE}"
    if [ $? -eq 0 ]; then
        sshpass -p "${FTP_PWD}" rsync -avz --progress -e "ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no" ${FILE} "${FTP_USER}@${FTP_HOST}:${FTP_DIR}/${FILE}"
        if [ $? -ne 0 ]; then
            echo "Exception: [ ${FILE} ] upload failed, $?"
        else
            UPLOADED_FILES+=($FILE)
            echo "[ ${FILE} ] uploaded successfully."
        fi
    fi
done

echo -e "\nDeployment completed.\n\nChanged files: [ $(echo "$CHANGED_FILES" | wc -l) ].\nUploaded files: [ ${#UPLOADED_FILES[*]} ]."
exit 0

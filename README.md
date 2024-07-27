# bash-push-commit-managed-remote

This script deploys the latest commit files to a remote managed server via SSH. It ensures only changed files are transferred, excluding certain ignored files.

## Prerequisites

- Ensure you have `sshpass` and `rsync` installed on your local machine.
- Your local repository should be a valid Git repository.

## Usage

```bash
./deploy.sh REMOTE_HOST REMOTE_USER REMOTE_PWD REMOTE_DIR SFTP_PORT

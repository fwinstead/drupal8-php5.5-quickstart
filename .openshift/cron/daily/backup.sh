#!/bin/bash

NOW=$(date "+%Y_%m_%d_%H_%M")

echo "${NOW} Backup to Dropbox using: ${DROPBOX_TOKEN}" >> /tmp/backup.log

#!/bin/bash

if [[ -z ${BUCKET_NAME} ]]; then
    echo "The destination bucket name (BUCKET_NAME) is required as an environment variables."
else
  REPO="readsb"

  # archive old tar1090-db
  aws s3 mv "s3://${BUCKET_NAME}/${REPO}/latest" "s3://${BUCKET_NAME}/${REPO}/$(date +%F-%H-%M-%S-%N)" --recursive

  # install packages required for update script
  for DEP in $(cat required_packages); do
    yum -y install "${DEP}"
  done
  make readsb

  # push updated db folder to S3
  aws s3 cp readsb "s3://${BUCKET_NAME}/${REPO}/latest/" --recursive
fi
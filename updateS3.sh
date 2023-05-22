#!/bin/bash

if [[ -z ${BUCKET_NAME} ]]; then
    echo "The destination bucket name (BUCKET_NAME) is required as an environment variables."
else
  REPO="readsb"

  # archive old tar1090-db
  aws s3 mv "s3://${BUCKET_NAME}/${REPO}/latest" "s3://${BUCKET_NAME}/${REPO}/$(date +%F-%H-%M-%S-%N)" --recursive

  # install packages required for update script
  sudo apt update
  for DEP in $(cat required_packages); do
    sudo apt install --no-install-recommends --no-install-suggests -y "${DEP}"
  done
  export DEB_BUILD_OPTIONS=noddebs
  dpkg-buildpackage -b -Prtlsdr -ui -uc -us
  sudo dpkg -i ../readsb_*.deb

  # push updated db folder to S3
  aws s3 cp /usr/bin/readsb "s3://${BUCKET_NAME}/${REPO}/latest/" --recursive
fi
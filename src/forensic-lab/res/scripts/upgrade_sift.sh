#! /bin/bash

export DEBIAN_FRONTEND=noninteractive

upgrade_sift() {
  echo "Upgrading sift"
  sift upgrade
}

main() {
  upgrade_sift
}

main
exit 0
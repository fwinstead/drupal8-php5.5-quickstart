#!/bin/bash

# update Drupal 8

pushd ${OPENSHIFT_REPO_DIR}
	VERSION=$(wget -q -O - https://www.drupal.org/project/drupal | grep 'drupal-8' | sed 's/^.*drupal-//; s/-.*//;')
	DRUPAL="drupal-${VERSION}"
	FNAME="${DRUPAL}.tar.gz"
	DEFAULT="${OPENSHIFT_REPO_DIR}${DRUPAL}/sites/default"
	SETTINGS="${DEFAULT}/settings.php"
	DEFAULTSETTINGS="${DEFAULT}/default.settings.php"

	# check if NEW is newer
	# might want to use symbolic link in install ? or check CHANGELOG.txt

popd

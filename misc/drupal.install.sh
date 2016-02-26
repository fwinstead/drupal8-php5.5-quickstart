#!/bin/bash

# install Drupal 8

pushd ${OPENSHIFT_REPO_DIR}
	VERSION="8.0.3"
	DRUPAL="drupal-${VERSION}" # NEED grab latest version
	FNAME="${DRUPAL}.tar.gz"
	SETTINGS="settings.php"

	cd ${OPENSHIFT_REPO_DIR}
	# Get Drupal 8.x 
	if test \! -f "${FNAME}"; then wget "https://www.drupal.org/files/projects/${FNAME}" ; fi
	time tar -zxf "${FNAME}" > /dev/null

	cd ${OPENSHIFT_REPO_DIR}/${DRUPAL}/sites/default
	cp "default.${SETTINGS}" "${SETTINGS}"
	chmod a+w . "${SETTINGS}"

	# Drupal settings.php
	cat "${OPENSHIFT_REPO_DIR}/misc/openshift.drupal.append.settings.php" >> "${SETTINGS}"

	# "Trusted Host Settings" Security fix
	# could be more secure by limiting rhcloud.com
	# https://www.drupal.org/node/1992030
	# https://www.drupal.org/node/2410395

	echo '# Trusted Host Settings security fix' >> "${SETTINGS}"
	echo '$settings["trusted_host_patterns"] = array (' >> "${SETTINGS}"

	echo "Trusted Host Settings String: " $REDIRECTS
	for i in ${REDIRECTS[*]}
	do
		echo -e "\t>>> '${i}',"
		echo -e "\t'${i}',"  >> "${SETTINGS}"
	done
	echo ');' >> "${SETTINGS}"

	rm -rf www
	mv drupal-8.0.3 www

popd




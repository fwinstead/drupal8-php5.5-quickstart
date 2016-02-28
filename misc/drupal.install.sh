#!/bin/bash

# install Drupal 8

pushd ${OPENSHIFT_REPO_DIR}
	VERSION=$(wget -q -O - https://www.drupal.org/project/drupal | grep 'drupal-8' | sed 's/^.*drupal-//; s/-.*//;')
	#VERSION="8.0.3"		# REMOVE after TESTING update.sh
	DRUPAL="drupal-${VERSION}"
	FNAME="${DRUPAL}.tar.gz"
	DEFAULT="${OPENSHIFT_REPO_DIR}${DRUPAL}/sites/default"
	SETTINGS="${DEFAULT}/settings.php"
	DEFAULTSETTINGS="${DEFAULT}/default.settings.php"

	# Get Drupal 8.x 
	if test \! -f "${FNAME}"; then wget "https://www.drupal.org/files/projects/${FNAME}" ; fi
	time tar -zxf "${FNAME}" > /dev/null

	cp "${DEFAULTSETTINGS}" "${SETTINGS}"
	chmod a+w "${DEFAULT}" "${SETTINGS}"

	# Drupal settings.php with Openshift mods
	cat "${OPENSHIFT_REPO_DIR}/misc/openshift.drupal.append.settings.php" >> "${SETTINGS}"

	# "Trusted Host Settings" Security fix: https://www.drupal.org/node/1992030 https://www.drupal.org/node/2410395
	echo '# Trusted Host Settings security fix: ' >> "${SETTINGS}"
	echo '$settings["trusted_host_patterns"] = array (' >> "${SETTINGS}"

	for i in ${REDIRECTS[*]}
	do
		echo -e "\t'${i}',"  >> "${SETTINGS}"
	done
	echo ');' >> "${SETTINGS}"

	mv www www.OLD
	ln -s "${DRUPAL}" www
popd


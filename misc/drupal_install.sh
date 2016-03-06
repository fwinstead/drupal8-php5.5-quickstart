#!/bin/bash

# install Drupal 8


###################################	
# drush install
# http://www.drush.org/en/master/install/
# pass NODRUSH=1 to skip step
if test -z "${NODRUSH}"
then
	pushd ${OPENSHIFT_REPO_DIR}
		DRUSH_PHAR="drush.phar"
		echo -e "\tInstalling: ${DRUSH_PHAR}"
		wget "http://files.drush.org/${DRUSH_PHAR}"
		if [ $? != 0 ]; then
			echo -e "\tERROR! Download failed: ${DRUSH_PHAR}"
			return 1	# FTW ????
		fi
		# NEED: PHP installed to test
		# PHP="${OPENSHIFT_HOMEDIR}/app-root/runtime/bin/php"
		# ${PHP} ${OPENSHIFT_REPO_DIR}drush.phar core-status
	popd
fi
###################################	
# Drupal 8 install
# pass NODRUPAL=1 to skip step
if test -z "${NODDRUPAL}"
then
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
fi
###################################	
# Twig install
# pass NODRUPAL=1 to skip step
if test -z "${NOTWIG}"
then
	echo -e "\tInstalling Twig."
fi

echo "Drupal install: Normal Finish."
# ## ### ####



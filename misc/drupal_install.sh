#!/bin/bash

# install Drupal 8

###################################	
# drush install
# http://www.drush.org/en/master/install/
# pass NODRUSH=1 to skip step
# NEED: FIX: seems to disappear maybe Drupal install, maybe php make ???
# move to correct directory ????

# NEED: PHP installed to test
# PHP="${OPENSHIFT_HOMEDIR}/app-root/runtime/bin/php"
# ${PHP} ${OPENSHIFT_REPO_DIR}drush.phar core-status

###################################	
# Drupal 8 install
# pass NODRUPAL=1 to skip step
if test -z "${NODRUPAL}"
then
	pushd ${OPENSHIFT_REPO_DIR}
		DRUPAL_DIR="drupal-${DRUPAL_VER}" # 2 use later
		DEFAULT_DIR="${OPENSHIFT_REPO_DIR}${DRUPAL_DIR}/sites/default"

		SETTINGS="${DEFAULT_DIR}/settings.php"
		DEFAULTSETTINGS="${DEFAULT_DIR}/default.settings.php"

		# untar Drupal 8.x 
		tar -zxf "${DRUPAL_TAR_PATH}"

		cp "${DEFAULTSETTINGS}" "${SETTINGS}"; chmod a+w "${DEFAULT_DIR}" "${SETTINGS}"

		# Drupal settings.php with Openshift mods
		cat "${OPENSHIFT_REPO_DIR}/misc/openshift.drupal.append.settings.php" >> "${SETTINGS}"

		# "Trusted Host Settings" Security fix: https://www.drupal.org/node/1992030 https://www.drupal.org/node/2410395
		echo '# Trusted Host Settings security fix: ' >> "${SETTINGS}"
		echo '$settings["trusted_host_patterns"] = array (' >> "${SETTINGS}"
		for i in ${REDIRECTS[*]} ; do echo -e "\t'${i}',"  >> "${SETTINGS}" ; done
		echo ');' >> "${SETTINGS}"

		# move sites, hopefully helps with upgrades
		mv "${DRUPAL_DIR}/sites" .
		ln -s ../sites "${DRUPAL_DIR}/sites"

		mv www www.OLD
		ln -s "${DRUPAL_DIR}" www
	popd	
fi
###################################	
# Twig install
# pass NODRUPAL=1 to skip step
if test -z "${NOTWIG}"
then
	pushd ${OPENSHIFT_REPO_DIR}
		echo -e "\tInstalling Twig."
	popd	
fi

echo "Drupal install: Normal Finish."
# ## ### ####




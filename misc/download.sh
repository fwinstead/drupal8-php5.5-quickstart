#!/bin/bash

# check to see if packages are up to date
# 	download if needed

DOWNLOAD_DIR="${OPENSHIFT_REPO_DIR}downloads"
if [ \! -d "${DOWNLOAD_DIR}" ] ; then mkdir -vp "${DOWNLOAD_DIR}"; fi
TO_DOWNLOAD=()

DRUPAL_VER=$(wget -q -O - https://www.drupal.org/project/drupal | sed -n '/drupal-8/{s/^.*drupal-//; s/-.*//; p;}')
DRUPAL_FN="drupal-${DRUPAL_VER}.tar.gz"
HTTP_DRUPAL="https://www.drupal.org/files/projects/${DRUPAL_FN}"
if [ \! -f "${DOWNLOAD_DIR}/${DRUPAL_FN}" ] ; then TO_DOWNLOAD+=("${HTTP_DRUPAL}") ; fi

DRUPAL_CONSOLE_FN="drupal.phar"		# Automaticly gets latest
HTTP_DRUPAL_CONSOLE="-O drupal_console-${DRUPAL_CONSOLE_FN} https://drupalconsole.com/installer"
if [ \! -f "${DOWNLOAD_DIR}/${DRUPAL_CONSOLE_FN}" ] ; then TO_DOWNLOAD+=("${HTTP_DRUPAL_CONSOLE}") ; fi

DRUSH_FN="drush.phar"			# Automaticly gets latest
HTTP_DRUSH="http://files.drush.org/${DRUSH_FN}"
if [ \! -f "${DOWNLOAD_DIR}/${DRUSH_FN}" ] ; then TO_DOWNLOAD+=("${HTTP_DRUSH}") ; fi

PHP_VER="5.5.31"			# NEED: check for latest?
PHP_FN="php-${PHP_VER}.tar.gz"
HTTP_PHP="http://php.net/distributions/${PHP_FN}"
if  [ "${PHP_PRECOMPILED_URL}" ] ; then HTTP_PHP="${PHP_PRECOMPILED_URL}" ; fi # if passed URL to precompiled PHP, then use that
if [ \! -f "${DOWNLOAD_DIR}/${PHP_FN}" ] ; then TO_DOWNLOAD+=("${HTTP_PHP}") ; fi

TWIG_VER=$(wget -q -O - https://github.com/twigphp/Twig/releases | sed -n '/tar.gz/{s_^.*\/.*v__; s_\.tar\.gz.*__; p;}' | head -1)
TWIG_FN="v${TWIG_VER}.tar.gz"
HTTP_TWIG="-O twig-${TWIG_FN} https://github.com/twigphp/Twig/archive/${TWIG_FN}"
if [ \! -f "${DOWNLOAD_DIR}/${TWIG_FN}" ] ; then TO_DOWNLOAD+=("${HTTP_TWIG}") ; fi

# Is Composer already installed ???

# Retrieve files
pushd "${DOWNLOAD_DIR}"
	for ((i = 0; i < ${#TO_DOWNLOAD[@]}; i++))
	do
		STATUS="FAIL"
		NOW=$(date "+%Y_%m_%d_%H_%M_%S")
		CMD="wget -nv ${TO_DOWNLOAD[$i]}"
		echo -e "\t${NOW} ${CMD}" 
		eval $CMD
		if [ $? = 0 ] ; then STATUS="Success"; fi
		echo -e "\t\t${STATUS}."
	done
popd

echo "$0 Finished."
# ## ### #### ##### #### ### ## #

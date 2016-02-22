#!/bin/bash

# build PHP and get latest Drupal 8

# NEED: pass this in: ###############################
REDIRECTFROM='atlanticcoastcabinets\.com'

# not sure if needed ?
export HTTPD_ARGUMENT="-f ${OPENSHIFT_REPO_DIR}/conf/httpd.conf"
env|>${OPENSHIFT_TMP_DIR}/httpd_temp.conf awk 'BEGIN{FS="="} $1 ~ /^OPENSHIFT/ {print "PassEnv", $1}'
# not sure 

export OPENSHIFT_RUNTIME_DIR="${OPENSHIFT_HOMEDIR}/app-root/runtime"
export ROOT_DIR="${OPENSHIFT_HOMEDIR}/app-root/runtime"
export LIB_DIR="${ROOT_DIR}/lib"
export CONF_DIR="${OPENSHIFT_REPO_DIR}/conf"
export DIST_PHP_VER="5.5.31"

##################################################
# PHP Install
pushd ${OPENSHIFT_REPO_DIR}/misc

	if [[ -x $OPENSHIFT_RUNTIME_DIR/bin/php-cgi ]] && [[ "`$OPENSHIFT_RUNTIME_DIR/bin/php-cgi`" =~ "${DIST_PHP_VER}" ]] 
	then
		return 0 # FTW ????
	fi
	echo -e "\tCheck PHP ${DIST_PHP_VER} not found. Install started."

	pushd ${OPENSHIFT_DIY_DIR}
	rm -f php-${DIST_PHP_VER}.tar.gz

	if [ -d php-${DIST_PHP_VER} ]; then
		echo -e "\tPHP Source code dir found. skipping downloading."
	else
		TARGZ="php-${DIST_PHP_VER}.tar.gz"
		echo -e "\tDownloading PHP source code"
		wget -nv "http://php.net/distributions/${TARGZ}" && tar -zxf "${TARGZ}" && rm -f "${TARGZ}"
		if [ $? != 0 ]; then
			echo "ERROR! Download failed: ${TARGZ}"
			return 1	# FTW ????
		fi
	fi

	pushd php-${DIST_PHP_VER}
		mkdir -p ${LIB_DIR}
		mkdir -p ${CONF_DIR}/php5/conf.d/
	
		[ ! -f Makefile ] && \
			./configure \
			--with-libdir=lib64 \
			--prefix=${ROOT_DIR} \
			--with-config-file-path=${CONF_DIR}/php5/ \
			--with-config-file-scan-dir=${CONF_DIR}/php5/conf.d/ \
			--with-layout=PHP \
			--with-curl \
			--with-pear \
			--with-gd \
			--with-zlib \
			--with-mhash \
			--with-mysql \
			--with-pgsql \
			--with-mysqli \
			--with-pdo-mysql \
			--with-pdo-pgsql \
			--with-openssl \
			--with-xmlrpc \
			--with-xsl \
			--with-bz2 \
			--with-gettext \
			--with-readline \
			--with-kerberos \
			--disable-debug \
			--enable-cli \
			--enable-inline-optimization \
			--enable-exif \
			--enable-wddx \
			--enable-zip \
			--enable-bcmath \
			--enable-calendar \
			--enable-ftp \
			--enable-mbstring \
			--enable-soap \
			--enable-sockets \
			--enable-shmop \
			--enable-dba \
			--enable-sysvsem \
			--enable-sysvshm \
			--enable-sysvmsg \
			--enable-opcache
		make
		make install
	popd
		rm -rf php-${DIST_PHP_VER}
popd
###################################	
# drush install
# http://www.drush.org/en/master/install/
pushd ${OPENSHIFT_REPO_DIR}
	DRUSH_PHAR="drush.phar"
	echo -e "\tInstalling: ${DRUSH_PHAR}"
	wget -nv "http://files.drush.org/${DRUSH_PHAR}"
	if [ $? != 0 ]; then
		echo -e "\tERROR! Download failed: ${DRUSH_PHAR}"
		return 1	# FTW ????
	fi
	# TEST
	echo -e "\tDrush test:"
	PHP="${OPENSHIFT_HOMEDIR}/app-root/runtime/bin/php"
	${PHP} ${OPENSHIFT_REPO_DIR}drush.phar core-status
	echo
popd
###################################	
# Drupal 8 install
pushd ${OPENSHIFT_REPO_DIR}
	VERSION="8.0.3"
	DRUPAL="drupal-${VERSION}" # NEED grab latest version
	FNAME="${DRUPAL}.tar.gz"
	SETTINGS="settings.php"
	cd ${OPENSHIFT_REPO_DIR}
	# Get Drupal 8.x 
	if test \! -f "${FNAME}"; then wget "https://www.drupal.org/files/projects/${FNAME}" fi
	time tar -zxf "${FNAME}" > /dev/null

	cd ${OPENSHIFT_REPO_DIR}/${DRUPAL}/sites/default
	cp "default.${SETTINGS}" "${SETTINGS}"
	chmod a+w . "${SETTINGS}"
	cat << "EOF" >> "${SETTINGS}"
        # FTW modifications Begin ######################
        # "Trusted Host Settings" Security fix
        # could be more secure by limiting rhcloud.com
        # https://www.drupal.org/node/1992030
        # https://www.drupal.org/node/2410395
	# MIGHT BE BROKEN:
        $settings['trusted_host_patterns'] = array(
          '^'${REDIRECTFROM}'$',		
          '^.+\.'${REDIRECTFROM}'$',		
          '^.+\.rhcloud\.com$'
        );

        # Openshift mods
        # When run from Drush, only $_ENV is available.  Might be a bug
        if (array_key_exists('OPENSHIFT_APP_NAME', $_SERVER)) {
          $src = $_SERVER;
        } else {
          $src = $_ENV;
        }
        $databases = array (
          'default' =>
          array (
            'default' =>
            array (
              'database' => $src['OPENSHIFT_APP_NAME'],
              'username' => $src['OPENSHIFT_MYSQL_DB_USERNAME'],
              'password' => $src['OPENSHIFT_MYSQL_DB_PASSWORD'],
              'host' => $src['OPENSHIFT_MYSQL_DB_HOST'],
              'port' => $src['OPENSHIFT_MYSQL_DB_PORT'],
              'driver' => 'mysql',
              'prefix' => '',
            ),
          ),
        );
        $scheme = !empty($src['HTTPS']) ? 'https' : 'http';
        $base_url = $scheme . '://' . $src['HTTP_HOST'];
        $conf['file_private_path'] = $src['OPENSHIFT_DATA_DIR'] . 'private/';
        $conf['file_temporary_path'] = $src['OPENSHIFT_TMP_DIR'] . 'drupal/';
        # FTW modifications End ######################

popd
###################################	


popd
echo "Normal Finish."

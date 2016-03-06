#!/bin/bash

# build PHP and get latest Drupal 8

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
		wget -nv "http://php.net/distributions/${TARGZ}" && tar -zxf "${TARGZ}" 
		# && rm -f "${TARGZ}"
		if [ $? != 0 ]; then
			echo "ERROR! Download failed: ${TARGZ}"
			return 1	# FTW ????
		fi
	fi

	# time consuming, about 20 minutes, pass NOMAKE=1 to skip step
	# MAKE begin
	if test -z "${NOMAKE}"
	then
		pushd php-${DIST_PHP_VER}
			mkdir -vp ${LIB_DIR} ${CONF_DIR}/php5/conf.d/
	
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
			# NEED: look at make install   make -n install
		popd
		strip "${OPENSHIFT_HOMEDIR}app-root/runtime/bin/php" "${OPENSHIFT_HOMEDIR}app-root/runtime/bin/php-cgi"
	fi # MAKE end
popd

echo "PHP make: Normal Finish."

# ## ### ####


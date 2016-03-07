#!/bin/bash

# build PHP 

export ROOT_DIR="${OPENSHIFT_HOMEDIR}app-root/runtime"
export LIB_DIR="${ROOT_DIR}/lib"	
export CONF_DIR="${OPENSHIFT_REPO_DIR}conf"

##################################################
# PHP make/install

# time consuming, about 20 minutes, pass NOMAKE=1 to skip step
# MAKE begin
if test -z "${NOMAKE}"
then
	pushd ${OPENSHIFT_DIY_DIR}
	# untar php source code
	tar -zxf "${PHP_TAR_PATH}"
	pushd php-${PHP_VER}
		mkdir -vp ${LIB_DIR} ${CONF_DIR}/php5/conf.d
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
		make -j 2
		make install
		# NEED: look at make install, use: make -n install
		strip ${OPENSHIFT_HOMEDIR}app-root/runtime/bin/php{-cgi,}
	popd
	popd
fi # MAKE end

echo -e "\t$(date) PHP make: Normal Finish."

# ## ### ####


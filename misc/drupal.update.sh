#!/bin/bash

# update Drupal 8

pushd ${OPENSHIFT_REPO_DIR}
	CURRENT_VERSION=$(cat ${OPENSHIFT_REPO_DIR}/www/core/modules/system/system.info.yml  | sed -n '/^version/{s/.* .//; s/.$//; p;}')
	NEW_VERSION=$(wget -q -O - https://www.drupal.org/project/drupal | grep 'drupal-8' | sed 's/^.*drupal-//; s/-.*//;')

	if test "${CURRENT_VERSION}" \< "${NEW_VERSION}"
	then
		echo -e "\tDoing upgrade. Current: ${CURRENT_VERSION} Proposed: ${NEW_VERSION}"
		DRUPAL="drupal-${NEW_VERSION}"
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

# ( cd drupal-8.0.3 ; find . -type f -print0 | xargs -0 sum > ../3.data)
# ( cd drupal-8.0.4 ; find . -type f -print0 | xargs -0 sum > ../4.data)
# cat ?.data | sort | uniq -c | sort -n | nl 
# cat ?.data | sort | uniq -c | sort -n | grep -v '^ *2'

		# NEED: compare new to old
		# NEED: add old section ??????????????/
		# NEED: backup file system/database

		# restart web server with new files
		${OPENSHIFT_REPO_DIR}.openshift/action_hooks/stop
		rm www && ln -s "${DRUPAL}" www
		${OPENSHIFT_REPO_DIR}.openshift/action_hooks/start
	else
		echo -e "\tNo upgrade needed. Current: ${CURRENT_VERSION} Proposed: ${NEW_VERSION}"
	fi





popd


exit

cat << "EOF"
#!/bin/bash

O="8.0.3"
N="8.0.4"

echo -e "\tfile count"
( cd drupal-${O} ; find . -type f ) > ${O}.data 
( cd drupal-${N} ; find . -type f ) > ${N}.data 
echo -e "\t\t$(wc -l ${O}.data)"
echo -e "\t\t$(wc -l ${N}.data)"

echo -e "\tdiff filenames"
diff ${O}.data ${N}.data

echo -e "\tcksums"
( cd drupal-${O} ; find . -type f -print0 | xargs -0 cksum ) > ${O}.cksums
( cd drupal-${N} ; find . -type f -print0 | xargs -0 cksum ) > ${N}.cksums
cat *.cksums | sort | uniq -c | sort -n | grep -v '^ *2' | sed 's/^[^\.]*//;' | sort | uniq -c | sort -n > cksums.data 

echo -e "\tcksum differences not in ./core"
cat cksums.data | grep '^ *2 '| sed 's_\/[^\/]*$__; s/^ *2 //;' | sort | uniq -c|  grep -v './core'

echo -e "\t ./core directories with file cksum diffrences"
cat cksums.data | grep '^ *2 '| sed 's_\/[^\/]*$__; s/^ *2 //;' | sort | sed 's/^.\/core\///;' | sort | uniq | sed 's/\/.*$//;' | sort | uniq -c

EOF






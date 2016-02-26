
# Prompt ######################################
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;43m\]${OPENSHIFT_APP_NAME}\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${SSH_CLIENT/ */} ${OPENSHIFT_APP_NAME} \W\a\]$PS1"
    ;;
*)
    ;;
esac

# if connecting via SSH set DISPLAY
if test -n "${SSH_CLIENT}"
then
	export DISPLAY="${SSH_CLIENT/ */}:0.0"
fi
# ############################################
function findx
{
	find $* 2> /dev/null
}
# ############################################

# check for line in app-root/data/.bash_profile
grep "bash_interactive.sh" "${OPENSHIFT_DATA_DIR}.bash_profile"
if test $? -ne 0 
then
	echo -e "\tUpdating .bash_profile"
	echo 'case $- in  *i*) ;; *) return;; esac ; . ${OPENSHIFT_HOMEDIR}app-root/repo/misc/bash_interactive.sh' >> "${OPENSHIFT_DATA_DIR}.bash_profile"
fi


HISTCONTROL=ignoredups
shopt -s histappend

PHP="${OPENSHIFT_HOMEDIR}app-root/runtime/bin/php"

alias .b=". ${OPENSHIFT_HOMEDIR}app-root/repo/misc/bash_interactive.sh"	# reload to get color prompt
alias c="clear"
alias d="df -Tha --total"
alias drush="${PHP} ${OPENSHIFT_REPO_DIR}drush.phar"
alias catlog="cat ~/app-root/logs/access_log"
alias catelog="cat ~/app-root/logs/error_log"
alias catcronlog="cat ~/app-root/logs/cron*.log"
alias catmysqllog="cat ~/app-root/logs/mysql.log"
alias catphpmyadminlog="cat ~/app-root/logs/phpmyadmin.log"



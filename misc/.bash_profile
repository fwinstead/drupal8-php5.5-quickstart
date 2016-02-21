
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
# if interactive, load nice interactive utils
. ${OPENSHIFT_HOMEDIR}app-root/data/.bash_profile_interactive


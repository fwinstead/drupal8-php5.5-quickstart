# drupal8-php5.5-quickstart
Drupal 8 with PHP 5.5 Quickstart for Openshift.com 

Status: Testing passing parameters

Disabled: PHP 5.5, drush installs. Drupal to come.

## From RHC CLI

rhc create-app d8test mysql-5.5 phpmyadmin-4 cron-1.4 diy-0.1 --from-code https://github.com/fwinstead/drupal8-php5.5-quickstart.git \
	--env 'REDIRECTS=(a b c)'

## Acknowledgements

Inspired by:https://github.com/laobubu/openshift-php5.5-cgi-apache





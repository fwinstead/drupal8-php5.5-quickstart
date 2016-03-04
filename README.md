# drupal8-php5.5-quickstart
Drupal 8 with PHP 5.5 Quickstart for Openshift.com 

Status: 

* PHP 5.5 installs
* Drupal installs with OPENSHIFT variables. (you still need to go to: http://yoursite-yourdomain.rhcloud.com/core/install.php to finish install)

## From RHC CLI

rhc create-app yourhostname mysql-5.5 phpmyadmin-4 cron-1.4 diy-0.1 --from-code https://github.com/fwinstead/drupal8-php5.5-quickstart.git --env 'REDIRECTS=^.+\.rhcloud\.com$'

## Features

* php.ini modified to activate opcache
* www is a symbolic link pointing to drupal-8.x.x for easier updating
* bash additions via ".  ~/app-root/repo/misc/bash_interactive.sh"

## Known problems and work-arounds

* During Drupal 8 web install, you may get Gateway timeout errors. Work-around: reload page in web browser.

## To do

* Need: usable drush install, drush can install but has trouble installing Drupal due to long pathnames.
* Need: composer install.
* Need: Druapl Console install.
* Maybe: add CiviCRM option if possible.
* Need: simple updater.
* Need: sites as a symbolic link.
* Need: Drupal 8 openshift installation profile option via environment variable. SQLite option.
* Need: All web install option.
* Need: Twig

## Acknowledgements

Inspired by:https://github.com/laobubu/openshift-php5.5-cgi-apache






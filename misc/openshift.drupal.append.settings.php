
# FTW Openshift modifications Begin ######################


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
# FTW Openshift modifications End ######################


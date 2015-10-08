# == Class: contrail::database
#
# Install and configure the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database (
#  $package_name = $contrail::params::database_package_name,
) inherits contrail::params {

  anchor {'contrail::database::start': } ->
  class {'::contrail::database::config': } ~>
  class {'::contrail::database::service': }
  anchor {'contrail::database::end': }
  
}

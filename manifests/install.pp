# @api private
class artifactory::install (
  String[1] $package_name    = $artifactory::package_name,
  String[1] $package_version = $artifactory::package_version,
){
  package { $package_name:
    ensure => $package_version,
  }
}

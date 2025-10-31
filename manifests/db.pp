# @api private
class artifactory::db (
  String[1]    $db_name     = $artifactory::db_name,
  Stdlib::Port $db_port     = $artifactory::db_port,
  String[1]    $db_user     = $artifactory::db_user,
  Variant[
    Sensitive[String[1]],
    String[1]
  ]            $db_password = $artifactory::db_password,
) {
  # We only 'include' the main postgresql server class here
  # If any customisation is needed, it should be done in the user's profile code before declaring the artifactory class
  include postgresql::server

  # We can one small bit of sanity checking though...
  unless $postgresql::server::port == $db_port {
    fail("PostgreSQL is configured to listen on ${postgresql::server::port}. This does not match ${db_port}. Please declare `postgresql::server` yourself before including the artifactory module")
  }

  postgresql::server::db { $db_name:
    user     => $db_name,
    owner    => $db_name,
    password => postgresql::postgresql_password($db_name, $db_password),
  }
}

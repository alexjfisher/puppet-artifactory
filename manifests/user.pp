# @api private
class artifactory::user (
  Integer $uid = $artifactory::uid,
  Integer $gid = $artifactory::gid,
) {
  group { 'artifactory':
    gid => $gid,
  }

  user { 'artifactory':
    uid        => $uid,
    gid        => $gid,
    home       => '/var/opt/jfrog/artifactory',
    managehome => false,
    shell      => '/sbin/nologin',
  }
}

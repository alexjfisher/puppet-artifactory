# @api private
class artifactory::repo (
  $edition = $artifactory::edition,
){
  $baseurl = $edition ? {
    'pro'   => 'https://releases.jfrog.io/artifactory/artifactory-pro-rpms/',
    default => 'https://releases.jfrog.io/artifactory/artifactory-rpms/',
  }

  yumrepo { 'Artifactory':
    enabled       => true,
    baseurl       => $baseurl,
    descr         => 'Artifactory',
    repo_gpgcheck => true,
    gpgcheck      => false,
    gpgkey        => "${baseurl}/repodata/repomd.xml.key",
  }
}

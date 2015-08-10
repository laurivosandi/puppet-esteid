class esteid(
    $enable_tray = false
) {
    if ! defined( Package["apt-transport-https"] ) {
        package { "apt-transport-https": ensure => installed }
    }

    case $lsbdistcodename {
        'trusty', 'precise': {
            # Estonian ID-card
            Package["apt-transport-https"]
            ->
            apt::source { "ria-repository":
                location => "https://installer.id.ee/media/ubuntu/",
                release => $lsbdistcodename,
                repos => "main",
                include_src => false,
                key => "43650273CE9516880D7EB581B339B36D592073D4",
                key_source => "https://installer.id.ee/media/install-scripts/ria-public.key"
            }
            ->
            Package["estonianidcard"]
        }
        default: {
            err { "Distribution $lsbcodename not supported yet!": }
        }
    }

    # Estonian ID-card
    package { "estonianidcard": ensure => installed } ->
    package { "libnss3-tools": ensure => installed } ->
    Package["opensc"]

    if $enable_tray {
        package { "pcscd": ensure => installed }
        package { "python-pyscard": ensure => installed } ->
        package { "esteidtray": ensure => installed, provider => "pip" }
    }

    case $lsbdistcodename {
        'trusty': {
            package { "opensc": ensure => "0.13.0-3ubuntu4.1ria1" }
        }
        default: {
            package { "opensc": ensure => installed }
        }
    }

    # Generate qdigidoc plugin for MATE's Caja file browser
    if defined( Package["python-caja"] ) {
        Package["python-caja"] ->
        Package["estonianidcard"]
        ->
        exec { "generate-caja-qdigidoc":
            command => "/bin/sed -e 's/Nautilus/Caja/g' /usr/share/nautilus-python/extensions/nautilus-qdigidoc.py > /usr/share/caja-python/extensions/caja-qdigidoc.py",
            creates => "/usr/share/caja-python/extensions/caja-qdigidoc.py"
        }
    }
}

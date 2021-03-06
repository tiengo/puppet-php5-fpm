# Define : php5-fpm::config
#
# Define a php-fpm config snippet. Places all config snippets into
# /etc/php5/fpm/pool.d, where they will be automatically loaded
#
# Parameters :
#    * ensure: typically set to "present" or "absent".
#       Defaults to "present"
#    * content: set the content of the config snipppet.
#       Defaults to    'template("php5-fpm/pool.d/$name.conf.erb")'
#    * order: specifies the load order for this config snippet.
#       Defaults to "500"
#
# Sample Usage:
#    php5-fpm::config { "global":
#        ensure => present,
#        order  => '000',
#    }
#    php5-fpm::config { "www-example-pool":
#        ensure     => present,
#        content    => template("php5-fpm/pool.d/www-pool.conf.erb"),
#    }
#

define php5-fpm::config ( $ensure = 'present', $content = '', $order='500', $poolname = '', $owner = '', $groupowner = '' ) {

    $real_owner = $owner ? {
	    ''          => "www-data",
	    default     => $owner,
    }

    $real_groupowner = $groupowner ? {
	    ''          => $real_owner,
	    default     => $groupowner,
    }

    $real_poolname = $owner ? {
	    ''          => "www",
	    default     => $real_owner,
    }

    $real_content = $content ? {
        ''          => "php5-fpm/pool.d/${name}.conf.erb",
        default     => $content,
    }

    file { "/etc/php5/fpm/pool.d/${order}-${name}.conf":
        ensure  => $ensure,
        content => template("${real_content}"),
        mode    => '0644',
        owner   => root,
        group   => root,
        notify  => Service['php5-fpm'],
        require => Package['php5-fpm']
    }

    # Cleans up configs not managed by php5-fpm module
    exec { "cleanup-pool-${name}":
        cwd     => '/etc/php5/fpm/pool.d',
        path    => "/usr/bin:/usr/sbin:/bin",
        command => "find -name '[^0-9]*.conf' -exec rm {} +",
        unless  => "test -z $(find -name '[^0-9]*.conf')",
        notify  => Service['php5-fpm'],
        require => Package['php5-fpm']
    }
}

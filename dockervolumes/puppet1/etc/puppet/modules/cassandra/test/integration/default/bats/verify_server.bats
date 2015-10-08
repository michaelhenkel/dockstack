# Test verify methods for midonet_repository

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# Code copied unashamedly from http://get.docker.io
get_distro() {
    lsb_dist=''
    if command_exists lsb_release; then
        lsb_dist="$(lsb_release -si)"
    fi
    if [ -z "$lsb_dist" ] && [ -r /etc/lsb-release ]; then
        lsb_dist="$(. /etc/lsb-release && echo "$DISTRIB_ID")"
    fi
    if [ -z "$lsb_dist" ] && [ -r /etc/debian_version ]; then
        lsb_dist='debian'
    fi
    if [ -z "$lsb_dist" ] && [ -r /etc/redhat-release ]; then
        lsb_dist='red-hat'
    fi
    if [ -z "$lsb_dist" ] && [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi

    distro=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')
}

get_distro

@test 'cassandra repo is set' {

    case $distro in
        ubuntu)
            run file /etc/apt/sources.list.d/datastax.list
            [ "$status" -eq 0 ]
            ;;
        centos|red-hat)
            run ls /etc/yum.repos.d/datastax.repo
            [ "$status" -eq 0 ]
            ;;
        *)
            exit 1;
    esac
}

@test 'cassandra packages are available' {
    case $distro in
        ubuntu)
            run bash -c "apt-cache search dsc20"
            [ "$status" -eq 0 ]
            ;;
        centos|red-hat)
            run bash -c "yum search dsc20-2.0.10-1"
            [ "$status" -eq 0 ]
            ;;
        *)
            exit 1;
    esac
}

@test 'cassandra is running' {
    case $distro in
        ubuntu)
          run sudo service cassandra status
          [ "$status" -eq 0 ]
          ;;
        centos|red-hat)
          run sudo service cassandra status
          [ "$status" -eq 0 ]
          ;;
        *)
          exit 1;
    esac
}

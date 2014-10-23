#!/bin/bash

: ${ETCD_PORT_4001_TCP_ADDR:=127.0.0.1}
: ${ETCD_PORT_4001_TCP_PORT:=4001}

# If a descendent image provides a static hiera.yaml, do
# not overwrite it.
if [ ! -f /etc/puppet/hiera.yaml ]; then
	> /tmp/hiera-paths

	i=0
	while :; do
		pathvar="PUPPET_HIERARCHY_$i"
		[ "${!pathvar}" ] || break
		let i++
		echo "  - ${!pathvar}" >> /tmp/hierarchy
	done

	i=0
	while :; do
		pathvar="PUPPET_HIERA_PATH_$i"
		[ "${!pathvar}" ] || break
		let i++
		echo "    - ${!pathvar}" >> /tmp/hiera-paths
	done

	sed '
	s/@ETCD_HOST@/'"$ETCD_PORT_4001_TCP_ADDR"'/g
	s/@ETCD_PORT@/'"$ETCD_PORT_4001_TCP_PORT"'/g

	/@HIERARCHY@/ {
	r /tmp/hierarchy
	d
	}

	/@PATHLIST@/ {
	r /tmp/hiera-paths
	d
	}
	' /etc/puppet/hiera.yaml.in > /etc/puppet/hiera.yaml
fi

exec "$@"


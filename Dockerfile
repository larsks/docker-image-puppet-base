FROM larsks/fedora-base
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

# Set up repositories
RUN yum install -y https://rdo.fedorapeople.org/rdo-release.rpm \
	; yum clean all
RUN yum -y install dnf dnf-plugins-core \
	; yum clean all
RUN dnf copr enable -y larsks/crux

# Update packages
RUN yum update -y; yum clean all

# Install base packages
RUN yum install -y \
	puppet \
	augeas \
	hiera \
	git \
	; yum clean all

RUN puppet module install puppetlabs-stdlib
RUN puppet module install puppetlabs-concat

# Install dummy service provider
COPY dummy_service /usr/share/puppet/modules/dummy_service

RUN git clone https://github.com/garethr/hiera-etcd.git \
	/usr/share/puppet/modules/hiera-etcd
RUN gem install etcd

ENTRYPOINT ["/entrypoint.sh"]

COPY hiera.yaml /etc/puppet/hiera.yaml.in
COPY entrypoint.sh /entrypoint.sh
COPY docker-puppet /usr/bin/docker-puppet

RUN mkdir /puppet
COPY puppet /puppet/base
COPY lsdep /usr/bin/lsdep

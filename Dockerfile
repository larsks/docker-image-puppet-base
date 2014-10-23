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
	hiera \
	git \
	openstack-puppet-modules \
	; yum clean all

COPY hiera.yaml /etc/puppet/hiera.yaml

# Install dummy service provider
COPY dummy_service /usr/share/puppet/modules/dummy_service

# Replace mysql module in openstack-puppet-modules with
# a more recent version.
RUN rm -rf /usr/share/openstack-puppet/modules/mysql
RUN git clone https://github.com/puppetlabs/puppetlabs-mysql.git \
	/usr/share/openstack-puppet/modules/mysql


FROM ubuntu:14.04
MAINTAINER ntmggr root@sysxpert.com

RUN apt-get update 

# fix ssh and configure keys for jenkins
RUN mkdir /var/run/sshd
RUN chown -R root:root /var/run/sshd && chmod 711 /var/run/sshd
RUN mkdir /root/.ssh && chmod 600 /root/.ssh
ADD .ssh/ /root/.ssh/ 
RUN chmod 600 /root/.ssh/deis
RUN chmod 600 /root/.ssh/id_rsa
RUN useradd -m -G sudo -d /home/nayeem nayeem
RUN chown nayeem /home/nayeem
RUN echo nayeem:cr0n1cl3 | chpasswd

USER root
# Install build tools
RUN apt-get install -y build-essential curl git
RUN apt-get install -y zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2 libxml2-dev libxslt-dev libcurl4-openssl-dev postgresql-client libpq-dev libsqlite3-dev gccgo gccgo-go
RUN apt-get install -q -y git openssh-server python python-dev python-pip vim apt-transport-https
RUN pip install deis
# Install latest docker
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install -y --force-yes lxc-docker

# Install fleet
RUN cd /usr/local/src && git clone https://github.com/coreos/fleet
RUN cd /usr/local/src/fleet && ./build
RUN cp /usr/local/src/fleet/bin/fleetctl /sbin/


# Install ruby
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/ruby-build
ENV RUBY_VERSION 2.1.2
RUN /usr/local/ruby-build/bin/ruby-build $RUBY_VERSION /opt/ruby
# Install bundler and rake
RUN /opt/ruby/bin/gem install bundler

# Add supervisord in order to start the services
RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

CMD ["/usr/bin/supervisord", "-n"]

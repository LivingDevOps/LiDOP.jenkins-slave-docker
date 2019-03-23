FROM ubuntu:latest

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# setup SSH server
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd

# setup jdk
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
	apt-get -y install oracle-java8-installer

# setup tools
RUN apt-get update && apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
	apt-get update && \
	apt-get -y install ansible \
    python-pip \
    python-pexpect \
    git
 
VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/bin/bash"]
CMD ["/usr/local/bin/entrypoint.sh"]

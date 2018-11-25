FROM docker:18.09.0-dind

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN addgroup -g ${gid} ${group} \
	&& adduser -D -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -s /bin/bash "${user}" \
	&& passwd -u jenkins

# setup SSH server
RUN apk update \
    && apk add --no-cache sudo bash openssh openjdk8 git subversion curl wget 
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' \
    && mkdir /var/run/sshd \
    && echo "%${group} ALL=(ALL) NOPASSWD: /usr/local/bin/docker" >> /etc/sudoers  

#Update credential for Jenkins user
RUN delgroup ping \
    && addgroup -g 999 docker \
    && addgroup jenkins docker \
    && ln -s /usr/local/bin/docker /usr/bin/docker 

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY entrypoint.sh /usr/local/bin/

EXPOSE 22

ENTRYPOINT ["bash", "entrypoint.sh"]
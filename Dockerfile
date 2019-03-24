FROM docker:18.09.0-dind

ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

RUN addgroup -g ${gid} ${group} \
	&& adduser -D -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -s /bin/bash "${user}" \
	&& passwd -u jenkins

RUN apk update \
    && apk add --no-cache sudo bash openssh openjdk8 git subversion curl wget python py2-pip ansible nss

ARG AGENT_WORKDIR=/home/${user}/agent

RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}


USER root

RUN pip2 install docker && pip2 install docker-compose

RUN git config --system http.sslVerify false

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]

#USER jenkins
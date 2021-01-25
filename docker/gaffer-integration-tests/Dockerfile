FROM openjdk:7
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_VERSION=1.13.4
COPY ./docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh \
    git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
	cd /tmp/gaffer && \
	git checkout ${GAFFER_VERSION}
ENTRYPOINT ["/bin/bash","./docker-entrypoint.sh"]
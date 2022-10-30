FROM phusion/baseimage:jammy-1.0.1

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DISPLAY :0
ENV HOME /home/docker/
ENV NOVNC_HOME /usr/libexec/noVNCdim

# Updating and upgrading a bit.
# Install vnc, window manager and basic tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends x11vnc supervisor git sudo okular xvfb && \
# Create user for ssh
    adduser \
            --home /home/docker \
            --disabled-password \
            --shell /bin/bash \
            --gecos "user for running application" \
            --quiet \
            docker && \
    echo "docker:1234" | chpasswd && \
    adduser docker sudo && \
# Clone noVNC
    mkdir -p "${NOVNC_HOME}"/utils/websockify && \
    curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C "${NOVNC_HOME}" && \
    curl -L https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C "${NOVNC_HOME}"/utils/websockify && \
    chmod +x -v "${NOVNC_HOME}"/utils/novnc_proxy && \
    ln -s "${NOVNC_HOME}"/vnc.html "${NOVNC_HOME}"/index.html && \
    chown -R docker "${NOVNC_HOME}" && \
# Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add supervisor conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add entrypoint.sh
COPY entrypoint.sh /etc/entrypoint.sh

ENTRYPOINT ["/bin/bash","/etc/entrypoint.sh"]
# Expose Port
EXPOSE 8080

FROM gitpod/workspace-full-vnc
USER gitpod

# update
RUN sudo apt-get update

# install deps for x11
RUN sudo apt-get install -y xorg-dev

# install choosenim
RUN (curl https://nim-lang.org/choosenim/init.sh -sSf > /tmp/init.sh; sh /tmp/init.sh -y; rm /tmp/init.sh)

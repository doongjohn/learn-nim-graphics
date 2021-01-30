FROM gitpod/workspace-full-vnc
USER gitpod

# update
RUN sudo apt-get update

# install deps
RUN sudo apt-get -y libx11-dev

# install choosenim
RUN (curl https://nim-lang.org/choosenim/init.sh -sSf > /tmp/init.sh; sh /tmp/init.sh -y; rm /tmp/init.sh)

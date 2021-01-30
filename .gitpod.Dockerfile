FROM gitpod/workspace-full

USER gitpod


# update
RUN sudo apt-get update

# install choosenim
RUN (curl https://nim-lang.org/choosenim/init.sh -sSf > /tmp/init.sh; sh /tmp/init.sh -y; rm /tmp/init.sh)
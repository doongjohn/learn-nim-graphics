FROM gitpod/workspace-full

USER gitpod


# update
RUN sudo apt-get update

# install opengl
RUN sudo apt-get install -y build-essential
RUN sudo apt-get install freeglut3-dev libglu1-mesa-dev mesa-common-dev

# install choosenim
RUN (curl https://nim-lang.org/choosenim/init.sh -sSf > /tmp/init.sh; sh /tmp/init.sh -y; rm /tmp/init.sh)
FROM ubuntu:22.04

# Set non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Doom Emacs
RUN apt-get update && apt-get install -y \
    emacs \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    fonts-hack \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y wget gnupg unzip \
    && wget -O- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /tmp/Hack.zip \
    && mkdir -p /usr/share/fonts/hack \
    && unzip /tmp/Hack.zip -d /usr/share/fonts/hack \
    && fc-cache -fv \
    && rm -rf /tmp/Hack.zip \
    && apt-get purge -y wget gnupg \
    && rm -rf /var/lib/apt/lists/*
#RUN apt-get update && apt-get install -y wget gnupg unzip \
#    && wget -O- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip -O /tmp/FiraCode.zip \
#    && mkdir -p /usr/share/fonts/firacode \
#    && unzip /tmp/FiraCode.zip -d /usr/share/fonts/firacode \
#    && fc-cache -fv \
#    && rm -rf /tmp/FiraCode.zip \
#    && apt-get purge -y wget gnupg \
#    && rm -rf /var/lib/apt/lists/*

# Set up a user to avoid running as root
ARG USERNAME=emacsuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Switch to the new user
USER $USERNAME
WORKDIR /home/$USERNAME

# Install Doom
RUN git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs /home/$USERNAME/.config/emacs
RUN /home/$USERNAME/.config/emacs/bin/doom install --no-env

# Make my changes
RUN sed -i '/evil +everywhere/s/^/;;/' /home/$USERNAME/.config/doom/init.el \
    && sed -i '/(cc +lsp)/s/^\([ \t]*\);;/\1/' /home/$USERNAME/.config/doom/init.el \
    && sed -i '/docker/s/^\([ \t]*\);;/\1/' /home/$USERNAME/.config/doom/init.el \
    && sed -i '/;;python/s/^\([ \t]*\);;/\1/' /home/$USERNAME/.config/doom/init.el \
    && sed -i '/;;yaml/s/^\([ \t]*\);;/\1/' /home/$USERNAME/.config/doom/init.el

# Crazy quote sequence is to insert 'bold using sed running in the sh shell.
RUN sed -i '31a (setq doom-font \(font-spec :family "Hack Nerd Font Mono" :size 14 :weight '"'"'bold\) \n\
      doom-variable-pitch-font \(font-spec :family "Hack Nerd Font" :size 16\))\n' /home/$USERNAME/.config/doom/config.el
      
# Sync emacs doom
RUN /home/$USERNAME/.config/emacs/bin/doom sync

# Execute this when container starts
ENTRYPOINT ["emacs"]

# No params to the command specified in ENTRYPOINT. I'll use overides from docker run
CMD []

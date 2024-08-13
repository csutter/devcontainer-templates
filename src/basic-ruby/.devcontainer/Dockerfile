FROM ruby:${templateOption:imageVariant}

ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install basic development tools
RUN apt update && apt install -y less man-db sudo

# Set up unprivileged local user
#
# NOTE: The Ruby images will eventually be available with Ubuntu 24.04 (`noble`), the base images of
# which already have a default `ubuntu` user configured. You will need to remove the creation of the
# user and group when you upgrade the Ruby images.
RUN groupadd --gid $USER_GID $USERNAME \
    && groupadd bundler \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME --shell /bin/bash --groups bundler \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set unprivileged user as default user
USER $USERNAME

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

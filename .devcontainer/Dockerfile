FROM mcr.microsoft.com/devcontainers/dotnet:1-10.0

# Work around broken Yarn apt signing key in the base image.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    /etc/apt/trusted.gpg.d/yarn.gpg \
    /usr/share/keyrings/yarn.gpg

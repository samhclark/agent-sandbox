FROM docker.io/library/debian:13-slim

# Set up ca-certificates and https for deb
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    sed -i 's|http://|https://|g' /etc/apt/sources.list.d/debian.sources

# build-essential, procps, curl, file, and git are Homebrew's prerequisites.
# jq, ripgrep, ssh, and sudo round out the fundamentals.
RUN apt-get install -y build-essential procps curl file git jq ripgrep ssh sudo

# Homebrew refuses to run as root, and the build environment can't grant it
# real root via sudo anyway (buildah mounts the rootfs nosuid). Pre-creating
# the prefix owned by nonroot makes it writable, so the installer takes its
# no-sudo path and never needs to elevate during the build. The sudoers grant
# is purely for runtime convenience (installing apt packages in the sandbox).
RUN useradd --create-home --shell /bin/bash nonroot && \
    echo 'nonroot ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nonroot && \
    chmod 0440 /etc/sudoers.d/nonroot && \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R nonroot:nonroot /home/linuxbrew

# Login shells source /etc/profile, which resets PATH and would drop the brew
# entries set via ENV below. This drop-in re-adds brew for login shells.
RUN printf 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\n' > /etc/profile.d/homebrew.sh

USER nonroot:nonroot

# Vendored upstream installer script (refresh with `make deps-update`).
# retry.sh wraps the install to ride out transient upstream HTTP 504s.
COPY scripts/ /tmp/scripts/

# Install Homebrew. The shellenv values below are set via ENV (not .bashrc) so
# every process inherits them: Debian's .bashrc returns early for non-interactive
# shells, which would hide brew from `bash -lc`, `exec`, and CMD overrides.
RUN NONINTERACTIVE=1 bash /tmp/scripts/retry.sh bash /tmp/scripts/install-homebrew.sh

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH" \
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew" \
    HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar" \
    HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew" \
    MANPATH="/home/linuxbrew/.linuxbrew/share/man:" \
    INFOPATH="/home/linuxbrew/.linuxbrew/share/info:"

CMD [ "/bin/bash", "-l" ]

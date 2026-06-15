FROM docker.io/library/debian:13-slim

RUN useradd --create-home --shell /bin/bash nonroot

# Set up ca-certificates and https for deb
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    sed -i 's|http://|https://|g' /etc/apt/sources.list.d/debian.sources

RUN apt-get install -y curl ripgrep

USER nonroot:nonroot

# Vendored upstream installer scripts (refresh with `make deps-update`).
# retry.sh wraps each install to ride out transient upstream HTTP 504s.
COPY scripts/ /tmp/scripts/

# Install Claude Code
RUN bash /tmp/scripts/retry.sh bash /tmp/scripts/install-claude.sh
RUN printf 'export PATH="$HOME/.local/bin:$PATH"\n' | tee -a /home/nonroot/.bashrc


# Install OpenAI Codex CLI
RUN CODEX_NON_INTERACTIVE=1 bash /tmp/scripts/retry.sh sh /tmp/scripts/install-codex.sh

# Install opencode (symlink into ~/.local/bin, which is already on PATH)
RUN bash /tmp/scripts/retry.sh bash /tmp/scripts/install-opencode.sh && \
    ln -s "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"

CMD [ "/bin/bash", "-l" ]

FROM docker.io/library/debian:13-slim

RUN useradd --create-home --shell /bin/bash nonroot

# Set up ca-certificates and https for deb
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    sed -i 's|http://|https://|g' /etc/apt/sources.list.d/debian.sources

RUN apt-get install -y curl ripgrep

USER nonroot:nonroot

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN printf 'export PATH="$HOME/.local/bin:$PATH"\n' | tee -a /home/nonroot/.bashrc


# Install OpenAI Codex CLI
RUN curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh

CMD [ "/bin/bash", "-l" ]

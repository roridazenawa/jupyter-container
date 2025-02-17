# Build stage
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION} AS builder

# Create virtual environment
RUN python -m venv /opt/venv

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/venv/bin:$PATH

# Install base Python packages
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
    jupyter \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    && jupyter notebook --generate-config \
    && rm -rf /root/.cache/pip/*

# Final stage
FROM python:${PYTHON_VERSION}

ARG NOTEBOOKS_DIR=/notebooks
ENV PATH=/opt/venv/bin:$PATH

# Copy virtual env from builder
COPY --from=builder /opt/venv /opt/venv

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy and run install scripts
COPY ./build_scripts/install_packages.sh /opt/install_packages.sh
COPY ./build_scripts/pull_repo.sh /opt/pull_repo.sh
RUN chmod +x /opt/install_packages.sh && chmod +x /opt/pull_repo.sh

# Add args for GitHub repository
ARG GITHUB_REPO
ARG GITHUB_BRANCH=main
ARG GITHUB_TOKEN
ARG REPO_DIR=/notebooks/repo
ARG PY_REQUIREMENTS

# Setup non-root user
RUN groupadd -r paracord && useradd -r -g paracord paracord && \
    mkdir -p /home/paracord && \
    mkdir -p "${NOTEBOOKS_DIR}/samples" && \
    chown -R paracord:paracord /home/paracord && \
    chown -R paracord:paracord "${NOTEBOOKS_DIR}" && \
    chown -R paracord:paracord /opt/venv

# Pull GitHub repository if GITHUB_REPO is provided
RUN if [ ! -z "$GITHUB_REPO" ]; then \
        /opt/pull_repo.sh "$GITHUB_REPO" "$GITHUB_BRANCH" "$REPO_DIR"; \
    fi

# Install additional requirements
RUN /opt/install_packages.sh "${PY_REQUIREMENTS}" "${NOTEBOOKS_DIR}"

# Copy samples
COPY ./samples "${NOTEBOOKS_DIR}/samples"
RUN chown -R paracord:paracord "${NOTEBOOKS_DIR}"

WORKDIR /notebooks

# Expose Jupyter port
EXPOSE 8888

# Create jupyter runner script
RUN printf "#!/bin/bash\n" > /opt/jupyter_runner.sh && \
    printf "cd ${NOTEBOOKS_DIR} && jupyter notebook --ip=\${JUPYTER_IP:-0.0.0.0} --port=\${PORT:-8888} --no-browser --allow-root --NotebookApp.password=\$(python -c \"from jupyter_server.auth import passwd; print(passwd('\$JUPYTER_PASSWORD'))\") --NotebookApp.allow_root=True\n" >> /opt/jupyter_runner.sh && \
    chmod +x /opt/jupyter_runner.sh && \
    chown paracord:paracord /opt/jupyter_runner.sh

USER paracord

CMD ["sh", "-c", "/opt/jupyter_runner.sh"] 
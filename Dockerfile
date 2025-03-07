FROM dfdsdk/prime-pipeline:2.1.2

# ========================================
# Atlantis https://github.com/runatlantis/atlantis/releases
# ========================================

# Dependencies for entrypoint script from atlantis base
RUN apt-get update \
    && apt-get install -y dumb-init gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Finally actually atlantis
ENV ATLANTIS_VERSION=0.32.0

RUN export BUILD_ARCHITECTURE=$(uname -m); \
    if [ "$BUILD_ARCHITECTURE" = "x86_64" ]; then export BUILD_ARCHITECTURE_ARCH=amd64; fi; \
    if [ "$BUILD_ARCHITECTURE" = "aarch64" ]; then export BUILD_ARCHITECTURE_ARCH=arm64; fi; \
    curl -sSLO https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/atlantis_linux_${BUILD_ARCHITECTURE_ARCH}.zip \
    && curl -sSLO https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/checksums.txt \
    && grep atlantis_linux_${BUILD_ARCHITECTURE_ARCH}.zip checksums.txt | sha256sum --check \
    && unzip atlantis_linux_${BUILD_ARCHITECTURE_ARCH}.zip \
    && chmod +x atlantis \
    && mv atlantis /usr/local/bin/ \
    && rm -f atlantis_linux_${BUILD_ARCHITECTURE_ARCH}.zip checksums.txt

# Fetch the entrypoint script from source
RUN curl -sSLO https://github.com/runatlantis/atlantis/archive/v${ATLANTIS_VERSION}.zip \
    && unzip v${ATLANTIS_VERSION}.zip \
    && rm v${ATLANTIS_VERSION}.zip \
    && mv atlantis-${ATLANTIS_VERSION}/docker-entrypoint.sh /usr/local/bin/ \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && rm -rf atlantis-${ATLANTIS_VERSION}

# Create home dir and assign permissions
RUN useradd -u 200 --create-home --user-group --shell /bin/bash atlantis && \
    chown atlantis:root /home/atlantis/ && \
    chmod u+rwx /home/atlantis/


# ========================================
# Terragrunt-Atlantis-Config https://github.com/transcend-io/terragrunt-atlantis-config/releases
# ========================================

ENV TERRAGRUNT_ATLANTIS_CONFIG_VERSION=1.20.0

RUN wget https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}/terragrunt-atlantis-config_${terragrunt_atlantis_config_version}_linux_amd64.tar.gz \
    && sudo tar xf terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64.tar.gz \
    && sudo mv terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 terragrunt-atlantis-config \
    && sudo install terragrunt-atlantis-config /usr/local/bin

# ========================================
# END
# ========================================

USER atlantis
ENTRYPOINT [ "bash", "docker-entrypoint.sh" ]

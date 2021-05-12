FROM scratch
LABEL maintainer="synoniem" \
      description="A lightweight BOINC client on ARMv6 32-bit architecture."

# Global environment settings
ENV BOINC_GUI_RPC_PASSWORD="123" \
    BOINC_REMOTE_HOST="0.0.0.0" \
    BOINC_CMD_LINE_OPTIONS="" \
    DEBIAN_FRONTEND=noninteractive
# Untar raspbian/buster files
ADD buster/buster.tgz /
# Copy files
COPY bin/ /usr/bin/
# Configure
WORKDIR /var/lib/boinc

# BOINC RPC port
EXPOSE 31416

# Install
RUN apt-get update && apt-get install -y --no-install-recommends \
# Install Time Zone Database
	tzdata \
# Install BOINC Client
    boinc-client && \
# Cleaning up
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

CMD ["start-boinc.sh"]

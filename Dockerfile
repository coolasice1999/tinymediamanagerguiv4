#
# TinyMediaManager Dockerfile
#
FROM jlesage/baseimage-gui:alpine-3.12-glibc

# Define software versions.
ARG TMM_VERSION=4.3.13

# Define software download URLs.
ARG TMM_URL=https://release.tinymediamanager.org/v4/dist/tmm_${TMM_VERSION}_linux-amd64.tar.gz
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jre/bin
# Define working directory.
WORKDIR /tmp

# Download TinyMediaManager
RUN \
    mkdir -p /defaults && \
    wget ${TMM_URL} -O /defaults/tmm.tar.gz

# Install dependencies.
RUN \
    add-pkg \
        libmediainfo \
        ttf-dejavu \
        bash \
	zstd \
	zenity && \
    apk --update add tar

# Fix Java Segmentation Fault
RUN mkdir -p /tmp/libz \
    && wget "https://www.archlinux.org/packages/core/x86_64/zlib/download" -O /tmp/libz/libz.tar.zst \
    && unzstd -v /tmp/libz/libz.tar.zst \
    && tar -xvf /tmp/libz/libz.tar -C /tmp/libz \
    && cp -v /tmp/libz/usr/lib/libz.so.1.2.13 /usr/glibc-compat/lib \
    && /usr/glibc-compat/sbin/ldconfig \
    && rm -rfv /tmp/libz

# Maximize only the main/initial window.
# It seems this is not needed for TMM 3.X version.
#RUN \
#    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ ${TMM_VERSION}">/' \
#        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://gitlab.com/tinyMediaManager/tinyMediaManager/raw/45f9c702615a55725a508523b0524166b188ff75/AppBundler/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="TinyMediaManager" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
LABEL \
      org.label-schema.name="tinymediamanager" \
      org.label-schema.description="Docker container for TinyMediaManager" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/romancin/tmm-docker" \
      org.label-schema.schema-version="1.0"

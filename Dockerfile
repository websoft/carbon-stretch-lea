FROM node:carbon-stretch

#Install libvips because of sharp https://github.com/TailorBrands/docker-libvips/blob/c4b0f8e559abd858123654470af5bc70f48c0822/8.6.1/Dockerfile
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  automake build-essential curl \
  cdbs debhelper dh-autoreconf flex bison \
  libjpeg-dev libtiff-dev libpng-dev libgif-dev librsvg2-dev libpoppler-glib-dev zlib1g-dev fftw3-dev liblcms2-dev \
  liblcms2-dev libmagickwand-dev libfreetype6-dev libpango1.0-dev libfontconfig1-dev libglib2.0-dev libice-dev \
  gettext pkg-config libxml-parser-perl libexif-gtk-dev liborc-0.4-dev libopenexr-dev libmatio-dev libxml2-dev \
  libcfitsio-dev libopenslide-dev libwebp-dev libgsf-1-dev libgirepository1.0-dev gtk-doc-tools \
  ghostscript libgs-dev nano

ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 6
ENV LIBVIPS_VERSION_PATCH 1
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH

RUN \
  # Build libvips
  cd /tmp && \
  curl -L -O https://github.com/jcupitt/libvips/releases/download/v$LIBVIPS_VERSION/vips-$LIBVIPS_VERSION.tar.gz && \
  tar zxvf vips-$LIBVIPS_VERSION.tar.gz && \
  cd /tmp/vips-$LIBVIPS_VERSION && \
  ./configure --enable-debug=no --without-python $1 && \
  make && \
  make install && \
  ldconfig

RUN \
  # Clean up
  apt-get remove -y automake curl build-essential && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser node root
RUN mkdir /home/node/client
RUN mkdir /home/node/server
WORKDIR /home/node/server

# install node modules for root, server and client
WORKDIR /home/node/
COPY --chown=node:root root-package.json ./package.json
COPY --chown=node:root root-package-lock.json ./package-lock.json
RUN npm install

WORKDIR /home/node/server
COPY --chown=node:root server-package.json ./package.json
COPY --chown=node:root server-package-lock.json ./package-lock.json
RUN npm install

WORKDIR /home/node/client
COPY --chown=node:root client-package.json ./package.json
COPY --chown=node:root client-package-lock.json ./package-lock.json
RUN npm install

RUN chown -R node:root /home/node
RUN chmod -R 775 /home/node
WORKDIR /home/node


# Openshift does not run containers as root, use our new user.
USER node


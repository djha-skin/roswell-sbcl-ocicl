FROM fedora:latest

ARG OCICL_VERSION
ARG ROSWELL_VERSION
ARG SBCL_VERSION

RUN dnf install -y gcc \
               g++ \
               rlwrap \
               rsync \
               automake \
               git \
               sbcl \
               libcurl-devel \
               zlib-devel \
               texlive-amsfonts \
               texlive-mdwtools \
               pandoc \
               texlive-collection-fontsextra \
               xmlstarlet \
               jq \
               texlive-latex && \
               dnf clean all

RUN useradd builder
USER builder
WORKDIR /home/builder

RUN git clone -b release https://github.com/roswell/roswell.git && \
    cd roswell && \
    git checkout $ROSWELL_VERSION && \
    mkdir -p /home/builder/.local && \
    sh bootstrap && \
    ./configure --prefix=/home/builder/.local && \
    make && \
    make install && \
    cd ..

ENV PATH=/home/builder/.local/bin:/usr/local/bin:/usr/bin:/bin

RUN ros install sbcl-bin/$SBCL_VERSION
RUN ros use sbcl-bin/$SBCL_VERSION

RUN git clone https://github.com/ocicl/ocicl && \
    cd ocicl && \
    git checkout $OCICL_VERSION && \
    sbcl --load setup.lisp && \
    chmod a+x ocicl && \
    mv ocicl /home/builder/.local/bin

COPY init.lisp /home/builder/.roswell/init.lisp

ENTRYPOINT ["/home/builder/.local/bin/ros"]
CMD ["run"]

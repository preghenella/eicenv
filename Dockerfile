FROM rootproject/root-ubuntu16

USER root

RUN apt-get update && \
    apt-get -y install \
    emacs-nox \
    libboost-all-dev \
    swig

ENV EIC_ROOT /EIC
RUN mkdir -p $EIC_ROOT

COPY bin     $EIC_ROOT/bin
COPY patches $EIC_ROOT/patches
COPY utils   $EIC_ROOT/utils

RUN /bin/bash -c "source $EIC_ROOT/bin/eicenv && $EIC_ROOT/bin/eicbuild"

ARG username=eicuser
RUN userdel -r builder && useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

RUN echo "root:eicroot" | chpasswd

USER ${username}
WORKDIR /home/${username}

CMD ["/EIC/bin/eicenv"]

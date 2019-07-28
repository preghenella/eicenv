FROM rootproject/root-ubuntu16

USER root

RUN apt-get update && \
    apt-get -y install \
    emacs-nox \
    libboost-all-dev \
    swig

ARG username=eic
RUN useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

USER ${username}
WORKDIR /home/${username}

ENV EIC_ROOT $HOME/EIC
RUN mkdir -p $EIC_ROOT

COPY bin     $EIC_ROOT/bin
COPY patches $EIC_ROOT/patches

RUN /bin/bash -c "source $EIC_ROOT/bin/eicenv && $EIC_ROOT/bin/eicbuild"

COPY utils $EIC_ROOT/utils

CMD ["/home/eic/EIC/bin/eicenv"]

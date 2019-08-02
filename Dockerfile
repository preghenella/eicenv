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

RUN /bin/bash -c "source $EIC_ROOT/bin/eicenv && $EIC_ROOT/bin/eicbuild"

COPY pdfs     $EIC_ROOT/pdfs
COPY utils    $EIC_ROOT/utils
COPY examples $EIC_ROOT/examples

RUN /bin/bash -c "source $EIC_ROOT/bin/eicenv && $EIC_ROOT/pdfs/lhapdf/install cteq6l1"

ARG username=eicuser
RUN userdel -r builder && useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

RUN echo "root:eicroot" | chpasswd

USER ${username}
WORKDIR /home/${username}

CMD ["/EIC/bin/eicenv"]

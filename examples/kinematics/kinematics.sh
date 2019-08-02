#! /usr/bin/env bash

mkdir -p kinematics && \
    cd kinematics && \
    $EIC_ROOT/utils/pythia6/mkpypar.sh --electronP 10. --hadronP 100. --output pythia.params && \
    agile-runmc Pythia6:HEAD -n 10000 -P pythia.params -o pythia.hepmc && \
    DelphesHepMC $DELPHES_ROOT/cards/converter_card.tcl delphes.root pythia.hepmc && \
    root.exe -b -q $EIC_ROOT/examples/kinematics/kinematics.C && \
    cd -


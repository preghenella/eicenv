# eicenv - a EIC simulation environment

This repository provides a set of tools to perform fast Monte Carlo simulations.
It is mainly targeted at simulations for the future EIC collider, although the tools are generic enough to allow one to extend it for any Monte Carlo simulation purposes.

The core of the fast Monte Carlo simulation is provided by [Delphes](https://cp3.irmp.ucl.ac.be/projects/delphes), a framework for fast simulation of a generic collider experiment. Several Monte Carlo event generators can be used in a fully generalised way as input providers to Delhes. A convenient interface between the Monte Carlo event generators and Delphes simulations is provided by the [HepMC](http://hepmc.web.cern.ch/hepmc/index.html) package, which is the baseline used here.

## Docker installation

To make life and installation of all the necessary packages easy for all kind of users, a [Docker](https://www.docker.com/) image is made available. Please, follow the necessary instructions to install Docker on your system.

Once you have Docker installed and running on your system, you can obtain the image with  
```
# docker pull preghenella/eicenv
```

You can run the image with  
```
# docker run --rm -it preghenella/eicenv
```

You should be presented with the following prompt  
```
[eicenv] eicuser@ed3ad649abee ~ $
```
and ready for the following steps.  

The default user is `eicuser`, with home directory `/home/eicuser`.  
Should you for any reason need to have `root` priviliges, the password is `eicroot`.  

You should get familiar with the use of Docker, please read guideline and instructions elsewhere.  
Notice that if you need to access some files located on your computer within the Docker and/or get some output from jobs running in the Docker container available on your computer disk, you need to mount a local volume in the Docker container.  
To do that, run the image with  
```
# docker run --rm -it -v <localdir>:<dockerdir> preghenella/eicenv
```
where `<localdir>` is the local directory on your computer that you want to mount in the Docker container and `<dockerdir>` is the location in the Docker container filesystem where the volume will be mounted.  
For instance  
```
# docker run --rm -it -v $HOME:/home/eicuser preghenella/eicenv
```
will mount your home directory at the place of the `eicuser` home directory inside the Docker.  
Like this, you will basically operate as if you were on your local disk.

## Pythia6 generator

[Pythia6](https://pythiasix.hepforge.org/) is one of the Monte Carlo event generators provided with **eicenv**. As it is written in Fortran, interfacing with it might not be straigtforward. On the other hand, the [AGILe](https://agile.hepforge.org/) software provides a uniform object oriented C++ interface for a variety of Fortran-based Monte Carlo event generators.

You don't need to know much about this, but that your main entry point to run Pythia6 is  
```
[eicenv] agile-runmc Pythia6:HEAD -n 1000 -P pythia.params -o pythia.hepmc
```
which generates 1000 events according to the physics settings specified in `pythia.params` and writes them in the `pythia.hepmc` output file.

If you need some more help or a curious of what other parameters can be used with AGILe, do no hesitate to run  
```
[eicenv] agile-runmc --help
```

### utils/pythia6/mkpypar.sh

If you are not familiar with the settings of Pythia6 (parameters), you can either study the [Pythia6 manual](https://arxiv.org/abs/hep-ph/0603175) or use the simple **utils/pythia6/mkpypar.sh** program.

This program automatically generates a `pythia.params` file with some default settings  
```
[eicenv] /EIC/utils/pythia6/mkpypar.sh
```

The main parameters you might want to play with are the electron and target beam energies (GeV), that can be modified with  
```
[eicenv] /EIC/utils/pythia6/mkpypar.sh --electronP 10. --targetP 100.
```

There are other parameters that you can play with, like for instance setting the minimum and maximum photon virtuality (Q2)  
```
[eicenv] /EIC/utils/pythia6/mkpypar.sh --electronP 10. --targetP 100. --Q2min 10. --Q2max 12.
```

If you need some more help or a curious of what other parameters can be used with mkpypar, do no hesitate to run  
```
[eicenv] /EIC/utils/pythia6/mkpypar.sh --help
```

Notice on the other hand that not everything is likely to work as expected, so use it with common sense and cross-check that the physics is simulated as expected by Pythia6 with some short runs. Also, you might want to refer to the Pythia6 manual for more detailed information.

## Delphes simulation

[Delphes](https://cp3.irmp.ucl.ac.be/projects/delphes) is a framework for fast simulation of a generic collider experiment. To run a Delphes simulation you need to specify
* a configuration file in Tcl format
* an output file in ROOT format
* an input file(s) in HepMC format

A Delphes configuration file in Tcl format is also called a Delphes **card**. You can find some examples of Delphes cards in  
```
[eicenv] ls $DELPHES_ROOT/cards
```

Let's take for example `$DELPHES_ROOT/cards/gen_card.tcl`.  
This card just translates the HepMC file into a ROOT file, taking all particles stored in the HepMC file and putting them in a nice ROOT tree.

I assume you have already generated a HepMC file with some Pythia6 configuration as done in the following  
```
[eicenv] $EIC_ROOT/utils/pythia6/mkpypar.sh --electronP 10. --targetP 100. --Q2min 10. --Q2max 12. --output pythia.params
[eicenv] agile-runmc Pythia6:HEAD -n 1000 -P pythia.params -o pythia.hepmc
```

You can run the Delphes simulation based on the `gen_card.tcl` card prescriptions as  
```
[eicenv] DelphesHepMC $DELPHES_ROOT/cards/gen_card.tcl delphes.root pythia.hepmc
```

You should now have a `delphes.root` file, that contains all the generated events/particles organised in ROOT tree.  

Let's try another example with a different card  
```
[eicenv] DelphesHepMC $DELPHES_ROOT/cards/validation_card.tcl delphes.root pythia.hepmc
```

You might have hit an error  
```
Error in <TFile::TFile>: file delphes.root already exists  
** ERROR: can't create output file delphes.root
```

This is because Delphes does not overwrite an already existing file. There is no way (AFAIK) to force it, so what you have to to is
```
[eicenv] rm delphes.root
[eicenv] DelphesHepMC $DELPHES_ROOT/cards/validation_card.tcl delphes.root pythia.hepmc
```

Now that you have your Delphes output, you can start writing your ROOT analysis. You might need some examples for that and there are several in 
```
[eicenv] ls $DELPHES_ROOT/examples
```

Let's pick `$DELPHES_ROOT/examples/Example1.C` and run
```
[eicenv] root.exe $DELPHES_ROOT/examples/Example1.C\(\"delphes.root\"\)
```

This runs nicely, but in the end you don't see the canvas with the results of the analysis. 

#! /usr/bin/env bash

### usage: ./mkpypar.sh --help

###
electronP=10.
hadronP=100.
hadron="proton"
process="all"
photon="all"
pdf="CT10"
decay="all"
Xmin=0.
Xmax=1.
Q2min=1.
Q2max=-1.
Ymin=0.01
Ymax=0.95
Wmin=2.
Wmax=-1.
output=pythia.params
dump=false

while [ ! -z "$1" ]; do
    option="$1"
    shift
    if [ "$option" = "--help" ]; then
	echo "usage: ./mkpypar.sh"
	echo "options:"
	echo "          --electronP  [electron momentum] ($electronP)"
	echo "          --hadronP    [hadron momentum] ($hadronP)"
	echo "          --hadron     [hadron] ($hadron)"
	echo "          --process    [process] ($process)"
	echo "          --photon     [photon] ($photon)"
	echo "          --pdf        [pdf] ($pdf)"
	echo "          --decay      [decay] ($decay)"
	echo "          --disQ2      [> 1]"
	echo "          --lowQ2      [< 1]"
	echo "          --midQ2      [8 < Q2 < 12]"
	echo "          --highQ2     [25 < Q2 < 45]"
	echo "          --process    [process] ($process)"
	echo "          --Xmin       [parton x min] ($Xmin)"
	echo "          --Xmax       [parton x max] ($Xmax)"
	echo "          --Q2min      [min photon virtuality Q2] ($Q2min)"
	echo "          --Q2max      [max photon virtuality Q2] ($Q2max)"
	echo "          --Ymin       [y min] ($Ymin)"
	echo "          --Ymax       [y max] ($Ymax)"
	echo "          --Wmin       [W min] ($Wmin)"
	echo "          --Wmax       [W max] ($Wmax)"
	echo "          --output     [output filename] ($output)"
	echo "          --dump       [dump output filename]"
	exit
    elif [ "$option" = "--electronP" ]; then
	electronP="$1"
        shift
    elif [ "$option" = "--hadronP" ]; then
	hadronP="$1"
        shift
    elif [ "$option" = "--hadron" ]; then
	hadron="$1"
        shift
    elif [ "$option" = "--process" ]; then
	process="$1"
        shift
    elif [ "$option" = "--photon" ]; then
	photon="$1"
        shift
    elif [ "$option" = "--pdf" ]; then
	pdf="$1"
        shift
    elif [ "$option" = "--decay" ]; then
	decay="$1"
        shift
    elif [ "$option" = "--disQ2" ]; then
	Q2min=1.
	Q2max=-1.
    elif [ "$option" = "--lowQ2" ]; then
	Q2min=0.
	Q2max=1.
    elif [ "$option" = "--midQ2" ]; then
	Q2min=8.
	Q2max=12.
    elif [ "$option" = "--highQ2" ]; then
	Q2min=25.
	Q2max=45.
    elif [ "$option" = "--Xmin" ]; then
	Xmin="$1"
        shift
    elif [ "$option" = "--Xmax" ]; then
	Xmax="$1"
	shift
    elif [ "$option" = "--Q2min" ]; then
	Q2min="$1"
        shift
    elif [ "$option" = "--Q2max" ]; then
	Q2max="$1"
	shift
    elif [ "$option" = "--Ymin" ]; then
	Ymin="$1"
        shift
    elif [ "$option" = "--Ymax" ]; then
	Ymax="$1"
	shift
    elif [ "$option" = "--output" ]; then
	output="$1"
	shift
    elif [ "$option" = "--dump" ]; then
	dump=true
    fi
done

main() {
    generate_pythia_params > $output
    if [ "$dump" = true ]; then
	cat $output
    fi
}

generate_pythia_params() {
###
### BEAMS
###
    echo "###"
    echo "### BEAMS"
    echo "###"
    echo "RG:Beam1 $hadron"
    echo "RG:Beam2 gamma/e-"
    echo "RG:Mom1  $hadronP"
    echo "RG:Mom2  $electronP"
#    echo "PMAS(4,1)=1.27    # charm mass"
###
### PROCESS
###
    echo "###"
    echo "### PROCESS"
    echo "###"
case $process in
  "all")   
	    echo -e "MSEL=2" "\t\t ### all QCD processes";;
  "charm") 
	    echo -e "MSEL=4" "\t\t ### charm (c-cbar) production";;
esac
###
### PHOTON STRUCTURE
###
    echo "###"
    echo "### PHOTON STRUCTURE"
    echo "###"
case $photon in
    "all")
	    echo -e "MSTP(14)=30" "\t ### a mixture of all the available components (D = 30)";;
    "direct")
	    echo -e "MSTP(14)=21" "\t ### a photon is assumed to be point-like (D = 30)";;
    "resolved")
	    echo -e "MSTP(14)=24" "\t ### a photon is assumed to be resolved (D = 30)";;
    "dis")
	    echo -e "MSTP(14)=26" "\t ### deep-inelastic scattering (D = 30)";;
    *)
	    echo -e "MSTP(14)=$photon" "\t ### a mixture of structure of the incoming photon (D = 30)";;
esac
###
### PDF
###
echo "###"
echo "### PDF"
echo "###"
case $pdf in
    "internal")
    	echo -e "MSTP(52)=1" "\t ### use Pythia internal PDF";;
    "cteq6l1")
	echo -e "MSTP(51)=10042" "\t ### cteq6l1"
    	echo -e "MSTP(52)=2";;
    "CT10")
	echo -e "MSTP(51)=10800" "\t ### CT10"
    	echo -e "MSTP(52)=2";;
    *)
	echo -e "MSTP(51)=$pdf" "\t ### "
    	echo -e "MSTP(52)=2";;
esac
###
### DECAYS
###
echo "###"
echo "### DECAYS"
echo "###"
case $decay in
    "all")
    	echo -e "MSTJ(21)=2" "\t ### may decay within the region given by MSTJ(22) (D = 2)"
	echo -e "MSTJ(22)=1" "\t ### a particle declared unstable is also forced to decay (D = 1)";;
    "none")
    	echo -e "MSTJ(21)=0" "\t ### all particle decays are inhibited (D = 2)";;
    *)
	echo -e "MSTJ(21)=2" "\t ### may decay within the region given by MSTJ(22) (D = 2)"
    	echo -e "MSTJ(22)=2" "\t ### only if its average proper lifetime is smaller than PARJ(71)"
	echo -e "PARJ(71)=$decay" "\t ### maximum average proper lifetime for particles allowed to decay (D = 10 mm)";;
esac
###
### DEFAULTS
###
    echo "###"
    echo "### DEFAULTS"
    echo "###"
    echo "MSTP(17)=4 #! MSTP(17)=6 is the R-rho measured as by hermes, =4 Default"
    echo "MSTP(19)=1 #! Hermes MSTP(19=)1 different Q2 suppression, default = 4"
    echo "MSTP(20)=0 #! Hermes MSTP(20)=0 , default MSTP(20)=3"
    echo "MSTP(38)=4"
    echo "MSTP(53)=3"
    echo "MSTP(54)=1"
    echo "MSTP(55)=5"
    echo "MSTP(56)=1"
    echo "MSTP(57)=1"
    echo "MSTP(58)=5"
    echo "MSTP(59)=1"
    echo "MSTP(60)=7"
    echo "MSTP(61)=2"
    echo "MSTP(71)=1"
    echo "MSTP(81)=0"
    echo "MSTP(82)=1"
    echo "MSTP(91)=1"
    echo "MSTP(92)=3      #! hermes MSTP(92)=4"
    echo "MSTP(93)=1"
    echo "MSTP(101)=3"
    echo "MSTP(102)=1"
    echo "MSTP(111)=1"
    echo "MSTP(121)=0"
    echo "#! ----------- Now all the PARPs -----------"
    echo "PARP(13)=1"
    echo "PARP(18)=0.40 #! hermes PARP(18)=0.17"
    echo "PARP(81)=1.9"
    echo "PARP(89)=1800"
    echo "PARP(90)=0.16"
    echo "PARP(91)=0.40"
    echo "PARP(93)=5."
    echo "PARP(99)=0.40"
    echo "PARP(100)=5"
    echo "PARP(102)=0.28"
    echo "PARP(103)=1.0"
    echo "PARP(104)=0.8"
    echo "PARP(111)=2."
    echo "PARP(161)=3.00"
    echo "PARP(162)=24.6"
    echo "PARP(163)=18.8"
    echo "PARP(164)=11.5"
    echo "PARP(165)=0.47679"
    echo "PARP(166)=0.67597 #! PARP165/166 are linked to MSTP17 as R_rho of HERMES is used"
    echo "#! PARP(166)=0.5"
    echo "#! ----------- Now come all the switches for Jetset -----------"
    echo "PARJ(1)=0.100"
    echo "PARJ(2)=0.300"
    echo "PARJ(11)=0.5"
    echo "PARJ(12)=0.6"
    echo "PARJ(21)= 0.40"
    echo "PARJ(32)=1.0"
    echo "PARJ(33)= 0.80"
    echo "PARJ(41)= 0.30"
    echo "PARJ(42)= 0.58"
    echo "PARJ(45)= 0.5"
    echo "#!----------------------------------------------------------------------"
    echo "MSTJ(1)=1"
    echo "MSTJ(12)=1"
    echo "MSTJ(45)=5"
    echo "MSTU(16)=2"
    echo "MSTU(112)=5"
    echo "MSTU(113)=5"
    echo "MSTU(114)=5"
###
### CUTS
###
    echo "###"
    echo "### CUTS"
    echo "###"
    echo -e "CKIN(1)=1."      "\t ### min m-hat = sqrt(s-hat) (D = 2.)"
    echo -e "CKIN(2)=-1."     "\t ### max m-hat = sqrt(s-hat) (D = -1)"
    echo -e "CKIN(21)=$Xmin"  "\t ### min parton Bjorken-x (D = 0.)"
    echo -e "CKIN(22)=$Xmax"  "\t ### max parton Bjorken-x (D = 1.)"
    echo -e "CKIN(67)=$Q2min" "\t ### min photon virtuality, Q2 (D = 0.)"
    echo -e "CKIN(68)=$Q2max" "\t ### max photon virtuality, Q2 (D = -1.)"
    echo -e "CKIN(75)=$Ymin"  "\t ### min light-cone fraction, y (D = 0.0001)"
    echo -e "CKIN(76)=$Ymax"  "\t ### max light-cone fraction, y (D = 0.99)"
    echo -e "CKIN(77)=$Wmin"  "\t ### min photon-hadron invariant mass, W (D = 2.)"
    echo -e "CKIN(78)=$Wmax"  "\t ### max photon-hadron invariant mass, W (D = -1.)"
###
### MASSES AND WIDTHS
###
    cat "$(dirname -- "$0")/pmas.dat"
}

main

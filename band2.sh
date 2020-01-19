# This is a program aimed at obtaining band energies from OUTCAR
# Writen by Junze Deng, contact via dengjunze@me.com

#!bin/bash

# grep E-fermi from OUTCAR
EF=`grep E-fermi OUTCAR | awk '{print $3}'`
# grep number of bands and number of k-points from OUTCAR
nk=`grep NKPTS OUTCAR | awk '{print $4}'`
nb=`grep NBANDS OUTCAR | awk '{print $15}'`
# module of nk k-points
grep -A $nk weights: OUTCAR > tmpkp1
grep -v k tmpkp1 | awk '{printf "%.5f\n",sqrt($1**2+$2**2+$3**2)}' > tmpkp2
# nb band energies corresponding to nk k-points
grep -A $nb energies OUTCAR  > tmpba1
grep -v b tmpba1 | awk '{print $2}'> tmpba2
# data rearrangement of band enengies
cat tmpba2 | xargs > tmpba3
awk -v nb=`echo $nb` -v EF=`echo $EF` '{j=1;while(j<=nb){i=j;while(i<=NF){printf "%.5f\n", $i-EF; i=i+nb}print '\n';j++}}' tmpba3 > tmpba4
# data rearrangement of k-points
cat tmpkp2 | xargs > tmpkp3
awk -v nb=`echo $nb` -v nk=`echo $nk` '{j=1;while(j<=nb){i=1;while(i<=NF){printf "%.5f\n", $i; i++}print '\n';j++}}' tmpkp3 > tmpkp4
# k-path configuration
grep -v k tmpkp1 | awk '{printf "%.5f %.5f %.5f\n", $1, $2, $3}'> kpath1
cat kpath1 | xargs > kpath2
awk -v nb=`echo $nb` -v nk=`echo $nk` '{n=1;while(n<=nb){kx=$1;ky=$2;kz=$3;kpath=0;diffkpath=0;i=1;j=2;k=3;while(i<=NF){i=i+3;j=j+3;k=k+3;kpath=kpath+diffkpath;printf "%.5f %.5f %.5f %.5f\n", kx,ky,kz,kpath;diffkpath=sqrt(($i-kx)**2+($j-ky)**2+($k-kz)**2);kx=$i;ky=$j;kz=$k}print '\n';n++}}' kpath2 > kpath3
# final data with each block representing a band
paste -d" " tmpkp4 tmpba4 > band.dat # tmpba5
# uniq tmpba5 > band.dat
# end of program
rm -rf tmpkp* tmpba*

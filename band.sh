# This is a program for obtaining band energy from OUTCAR 
# Writen by Junze Deng ; contact via dengjunze@me.com

#!bin/bash

# number of bands and number of k-points from OUTCAR
nk=`grep NKPTS OUTCAR | awk '{print $4}'`
nb=`grep NBANDS OUTCAR | awk '{print $15}'`
# modulo of nk k-points 
grep -A $nk weights: OUTCAR | awk '{print sqrt($1**2+$2**2+$3**2)}' > tmpkp1
# nb band energies corresponding to nk k-points
grep -A $nb energies OUTCAR  > tmpba1
grep -v b tmpba1 | awk '{print $2}'> tmpba2
# data rearrangement of band enengies 
cat tmpba2 | xargs > tmpba3
awk -v nb=`echo $nb` '{j=1;while(j<=nb){i=j;while(i<=NF){print $i; i=i+nb}print '\n';j++}}' tmpba3 > tmpba4
# data rearrangement of k-points
cat tmpkp1 | xargs > tmpkp2
awk -v nb=`echo $nb` -v nk=`echo $nk` '{j=1;while(j<=nb){i=1;while(i<=nk){print $i; i++}print '\n';j++}}' tmpkp2 > tmpkp3
# final data with each block representing a band
paste -d" " tmpkp3 tmpba4 > band.dat
# end of the script
rm -rf tmpkp* tmpba*

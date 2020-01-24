## This is a program aimed at obtaining band energies from OUTCAR
## Writen by Junze Deng, contact via dengjunze@me.com

#!bin/bash

## Start of program
startTime=`date +%s%N`
echo "Please wait..."

## band.dat of band structure from OUTCAR

# grep E-fermi from OUTCAR
EF=`grep E-fermi OUTCAR | awk '{print $3}'`
# grep number of bands and number of k-points from OUTCAR
nk=`grep NKPTS OUTCAR | awk '{print $4}'`
nb=`grep NBANDS OUTCAR | awk '{print $15}'`

nl=`awk 'NR==2' KPOINTS`
# band energy part

grep -A $nb energies OUTCAR  > tmpba1
grep -v b tmpba1 | awk '{print $2}'> tmpba2
# change y-placement to x-placement of band energies
awk -f ytox.wak tmpba2 > tmpba3
# band energies rearranged to each block representing a band
awk -v nb=`echo $nb` -v EF=`echo $EF` '{\
    j=1;\
    while(j<=nb)\
        {\
            printf "\n";\
            i=j;\
            while(i<=NF)\
                {\
                    printf "%.8f\n", $i-EF;\
                    i+=nb;\
                }\
                printf "\n";\
                j++;\
            }\
        }' tmpba3 > tmpba4

# end of band energy part

# k-point part

# module of nk k-points
grep -A $nk 2pi OUTCAR > tmpkp1
grep -v k tmpkp1 | awk '{printf "%.8f\n",sqrt($1**2+$2**2+$3**2)}' > tmpkp2
# change y-placement to x-placement of coordinates of k-points
awk -f ytox.wak tmpkp2 > tmpkp3
# data rearrangement of k-points
awk -v nb=`echo $nb` -v nk=`echo $nk` '{\
    j=1;\
    while(j<=nb)\
        {\
            printf "\n";\
            i=1;\
            while(i<=NF)\
                {\
                    printf "%.8\n", $i;\
                    i++;\
                }\
                printf "\n";\
                j++\
            }\
        }' tmpkp3 > tmpkp4

# end of k-point part

## k-path determination

# coordinates of k-points along k-path
grep -v k tmpkp1 | awk '{printf "%.8f %.8f %.8f\n", $1, $2, $3}'> kpath1
# change y-placement to x-placement of coordinates
cat kpath1 | sed 's/[ ][ ]*/,/g' > kpath2
awk -f ytox.wak kpath2 > kpath3
awk '{gsub(","," "); print $0 }' kpath3 > kpath4
# determination of k-path
awk -v nb=`echo $nb` -v nk=`echo $nk` -v nl=`echo $nl` -v nh=`echo $nk/$nl | bc` '{\
    a=1;\
    while(a<=nb)\
        {\
            print "#Band " a;
            kx=$1;ky=$2;kz=$3;\
            kp=0;deltakp=0;\
            d=3*nl+1;\
            i=1;j=2;k=3;\
            while(i<=NF)\
                {\
                    i=i+3;j=j+3;k=k+3;\
                    kp+=deltakp;\
                    printf "%.8f %.8f %.8f %.8f\n", kx,ky,kz,kp;\
                    if(i==d)\
                        {\
                            deltakp=0;\
                            d+=3*nl;\
                        }\
                    else\
                        {\
                            deltakp=sqrt(($i-kx)**2+($j-ky)**2+($k-kz)**2);\
                        }\
                    kx=$i;ky=$j;kz=$k;\
                }\
                printf "\n";\
                a++;\
            }\
        }' kpath4 > kpath5
# final data with each block representing a band
paste -d" " kpath5 tmpba4 > band.dat # tmpba5
sed '1i#   kx         ky         kz       k-path   band energies' band.dat > bandstruc.dat

## plot.dat for gnuplot

# high symmetry k-points along k-path
tail -n +5 KPOINTS | awk '{print $NF}' > klabel1


# number of k-points in one high-symmetry line segment along k-path

# process of obtaining plot.dat for gnuplot 
awk '{print $4,$5}' band.dat > plot.dat

# clean up
rm -rf tmpkp* tmpba* kpath* band.dat

## End of program
endTime=`date +%s%N`
runTime=`echo "scale=3;($endTime-$startTime)/1000000000" | bc`
echo "Complete, this program cast $runTime sec"

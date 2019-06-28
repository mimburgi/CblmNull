method ml
precision 4
set zr 0.5
set d 0
set szr 0
set sv 0
depends v load stim
depends a load stim
depends t0 load stim
format RESPONSE TIME load stim
load *.dat
log sternbergpars_ml_150.txt

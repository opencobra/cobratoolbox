addpath(genpath('/home/rfleming/bin/nullspace/'))
load S
nullS=nullspaceLUSOLform(S);
save('nullS','nullS');
exit


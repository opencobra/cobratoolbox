% D28: a function on the search path that reads a global it does not assign.
global RUNMAT_REPRO_D28
RUNMAT_REPRO_D28 = 5;
addpath(fullfile(pwd, 'lib'));
fprintf('%d\n', runmatReproGlobal());

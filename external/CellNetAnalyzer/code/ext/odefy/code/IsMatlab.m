% ISMATLAB  Determine whether MATLAB or GNU Octave is running.
%
%   r=ISMATLAB returns 1 if MATLAB is running and 0 otherwise.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function m=IsMatlab

m=exist('matlabroot')>0;

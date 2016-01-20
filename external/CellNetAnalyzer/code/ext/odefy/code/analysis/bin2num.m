% BIN2NUM  Convert binary vector to integer value.
%
%   NUM=BIN2NUM(BIN) converts the binary vector BIN to its decimal
%   representation NUM.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function v=bin2num(vec)
v = 0;
for i=1:numel(vec)
    v = v + 2^(i-1)*vec(i);
end
% SAVERMODEL  Export Odefy model to R ODE script file
%
%   SAVERMODEL(ODEFYMODEL,FILE,TYPE) converts ODEFYMODEL into an ODE system
%   of type TYPE and stores the results in an R-compatible ODE file FILE.
%
%   TYPE must be one of: 'boolcube', 'hillcube', 'hillcubenorm'
%
%   Reference:
%   http://www.r-project.org/

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveRModel(odefymodel, file, type)

type=ValidateType(type);

% init
h = fopen(file, 'w');
n = numel(odefymodel.species);

% cube calls
[calls paramnames] = CreateCubeCalls(odefymodel,type,3);

% parameters
fprintf(h,'# Ordered parameter list:\n');
for i=1:numel(paramnames)
    fprintf(h,'# %s\n', paramnames{i});
end

% header
fprintf(h,'\n# ODE function def\n');
fprintf(h,'odetest <- function (t,cvals,params) {\n');
fprintf(h,'res=array(0,dim=%d)\n', n);
% ODE
for i=1:n
    fprintf(h,'res[%d]=',i);
    fprintf(h,calls{i});
    fprintf(h,'\n');
end

% footer, close file
fprintf(h,'list(res)\n');
fprintf(h,'}\n');
fclose(h);
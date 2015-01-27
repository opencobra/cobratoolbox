% SAVEMATLABODE  Export Odefy model to MATLAB ODE script
%
%   SAVEMATLABODE(MODEL,OUTFILE,TYPE) converts MODEL to a system of
%   ordinary differential equations of type TYPE and writes the resulting
%   script to OUTFILE.
%
%   TYPE must be one of: 'boolcube', 'hillcube', 'hillcubenorm'

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveMatlabODE(odefymodel, outfile, type)
% SAVEMATLABODE [...]
%
%  Parameters:
%    model   - odefy model for which the ODE system will be created
%    outfile - output file name
%    type    - [document me]


type=ValidateType(type);

% prepare
[path, name] = fileparts(outfile);

file = fopen(outfile,'w');

% function header
fprintf(file, 'function ydot=%s(t,cvals,params)\n', name);

fprintf(file, 'cvals(cvals<0)=0;\ncvals(cvals>1)=1;\n\n');

tables = odefymodel.tables;
species = odefymodel.species;
numspecies = size(tables,2);

% shortcuts
fprintf(file, '%% shortcuts\n');
for i=1:numspecies
    fprintf(file, '%s=%i;\n', species{i}, i);
end
fprintf(file, '\n\n');


calls = CreateCubeCalls(odefymodel, type, 1);

% iterate over all species
fprintf(file, '%% ODE\n');
fprintf(file, 'ydot = zeros(%i,1);\n',size(tables,2)); 
for i=1:numspecies
    fprintf(file, 'ydot(%s) = %s;\n',species{i},calls{i});
end

% finish
fclose(file);
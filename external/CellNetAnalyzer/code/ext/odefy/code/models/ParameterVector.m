% PARAMETERVECTOR  Convert Odefy parameter matrix to ODE-compatible vector
%
%   VEC=PARAMETERVECTOR(SIMSTRUCT) converts the parameter matrix in the
%   given simulation structure SIMSTRUCT to a parameter vector.
%
%   VEC=PARAMETERVECTOR(MODEL,MATRIX) operates directly on a given matrix
%   and thus requires the corresponding Odefy model.
%
%   This function is needed when directly simulating exported ODE MATLAB
%   scripts from the command line (see HTML help).

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function vec = ParameterVector(varargin)

if nargin==1
    simstruct=varargin{1};
    if (~IsSimulationStructure(simstruct))
        error('First parameter must be a simulation structure');
    end
    model=simstruct.model;
    matrix=simstruct.params;
else
    model=varargin{1};
    matrix=varargin{2};
end

numspecies = size(model.tables,2);
index = 1;
for i=1:numspecies
    % set tau
    to = numel(model.tables(i).inspecies);
    if to>0
        vec(index)=matrix(i,1);
        index = index + 1;

        for j=1:to
            vec(index) = matrix(i,j*2);
            vec(index+1) = matrix(i,j*2+1);
            index = index + 2;
        end
    end
end




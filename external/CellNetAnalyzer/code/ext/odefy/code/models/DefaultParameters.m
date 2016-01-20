% DEFAULTPARAMETERS  Generate generic parameter matrix.
%
%   params=DEFAULTPARAMETERMATRIX(MODEL,TAU,N,K) generates a parameter
%   matrix for MODEL with the parameters tau=TAU, n=N and k=K. The three
%   parameter values are optional, default values are:
%   TAU=1, N=3, K=0.5

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function result = DefaultParameters(model, tau, n, k)

numspecies = size(model.tables,2);

if nargin<2; tau=1; end
if nargin<3; n=3; end
if nargin<4; k=0.5; end

for i=1:numspecies
    % set tau
    result(i,1) = tau;
    to = numel(model.tables(i).inspecies);
    if to>0
        for j=1:to
            result(i,j*2) = n;
            result(i,j*2+1) = k;
        end
    end
end


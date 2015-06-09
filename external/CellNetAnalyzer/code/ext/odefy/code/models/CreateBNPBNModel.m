% CREATEBNPBNMODEL Create a model in BN/PBN toolbox format from a given 
% Odefy model
%
%   [F,VARF,CIJ] = CREATEBNPBNMODEL(ODEFYMODEL) converts ODEFYMODEL into
%   BN/PBN-compatible structures. 
%
%   Output: the BN/PBN model specified by the matrices F, varF and cij as 
%   documented e.g. in the pbnRnd.m function contained in this toolbox.
%   
%   For unregulated species a positive self-activation is added, in order
%   to ensure their remaining at the initial level.
%
%   The BN/PBN MATLAB Toolbox written by Harri Laehdesmaeki and Ilya
%   Shmulevich can be used to work with Boolean Networks and Probabilistic
%   Boolean Networks. It includes functions for simulating the network
%   dynamics, computing network statistics (numbers and sizes of
%   attractors, basins, transient lengths, Derrida curves, percolation on
%   2-D lattices, influence matrices), computing state transition matrices
%   and obtaining stationary distributions, inferring networks from data,
%   generating random networks and functions, visualization and printing,
%   intervention, and membership testing of Boolean functions.
%
%   Web: http://personal.systemsbiology.net/ilya/PBN/PBN.htm

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%

function [F, varF, cij] = CreateBNPBNModel(odefymodel)
    
    % number of species
    n=numel(odefymodel.species); 
    % maximal number of inputs per species
    nv=0;
    for i=1:n % iterate over all species
        nv=max(nv, numel(odefymodel.tables(i).inspecies));
    end
    
    % initialize output variables
    F=-ones(2^nv, n);
    varF=-ones(nv, n);
    cij=ones(1, n); % no probabilistic network
    
    % create F and varF
    for i=1:n % iterate over all species
        nv = numel(odefymodel.tables(i).inspecies);
        if nv==0 % no regulation
            varF(1,i) = i; % add self-loop
            F(1:2,i) = [0; 1]; % self-loop is activating
        else
            varF(1:nv, i) = odefymodel.tables(i).inspecies; % input species
            F(1:2^nv,i) = reshape(odefymodel.tables(i).truth, 2^nv, 1); % reshape truthtable as column-vector
        end
    end

end


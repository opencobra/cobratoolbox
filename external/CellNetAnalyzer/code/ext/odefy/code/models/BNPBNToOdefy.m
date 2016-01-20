% BNPBNToOdefy  Convert a BN/PBN Toolbox model to an Odefy model
%
%   MODEL=BNPBNToOdefy(F,VARF,CIJ[, SPECIES]) takes the BN/PBN model
%   specified by the matrices F, VARF and CIJ and converts it to an Odefy
%   model. For specification of BN/PBN Toolbox models, see e.g. the file
%   pbnRnd.m contained in this toolbox. BNPBNToOdefy will return the Odefy
%   version of a randomly chosen realization of the BN/PBN Toolbox model. 
%   Additionally, the name of the species can be given in the cell array of
%   strings 'species'. If this parameter is not given, default setting
%   {'x1', 'x2', ..., 'xn'} is used.
%
%   The BN/PBN MATLAB Toolbox
%   (http://personal.systemsbiology.net/ilya/PBN/PBN.htm) was written by
%   Harri Laehdesmaeki and Ilya Shmulevich.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%

function odefymodel = BNPBNToOdefy(F, varF, cij, varargin)
    

    % number of species
    n=size(cij, 2);
    % set model name
    odefymodel.name='BNPBNimport';
    % set name of species
    odefymodel.species=cell(1,n);
    if nargin<5 % species names not provided
        for i=1:n % iterate over all species
            odefymodel.species{i}=['x' num2str(i)]; % set default name
        end
    else % use provided names
        odefymodel.species=varargin{1};
    end
        
    % create tables
    idx=1; % index of column in F corresponding to first function of i-th node
    for i=1:n % iterate over all species
        nf=sum(cij(:,i)>-1); % number of Boolean functions
      %  f=randsample(nf,1,'true',cij(1:nf,i))-1; % select index of boolean function
      f=find(rand(1)<(cumsum(cij(1:nf,i))./sum(cij(1:nf,i))),1,'first')-1;
        nv=sum(varF(:,idx+f)>-1); % number of inputs of f-th Boolean function
        odefymodel.tables(i).inspecies=varF(1:nv,idx+f); % set input species
        if nv==1 % no reshaping necessary
            odefymodel.tables(i).truth=F(1:2,idx+f);
        else
            odefymodel.tables(i).truth=reshape(F(1:2^nv,idx+f),2*ones(1,nv)); % reshape to hypercube truth table
        end
        idx=idx+nf; % update index
    end

end


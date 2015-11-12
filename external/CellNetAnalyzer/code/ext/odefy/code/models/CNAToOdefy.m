% CNATOODEFY  Convert CellNetAnalyzer to Odefy model
%
%   MODEL=CNAToOdefy(CNAMODEL) takes the CellNetAnalyzer model structure 
%   CNAMODEL and converts it to the Odefy internal Boolean network
%   representation. 
%
%   Can take an optional second parameter containing a reaction vector.
%   Each reaction with a value of zero in this vector will not be
%   considered.
%
%   MODEL=CNATOODEFY(SPECIES,INTERMAT,NOTMAT,MODELNAME)  Alternatively, you
%   can provide the species list (as a cell array of strings), the
%   interaction matrix, the inhibition matrix (notMat) and a model name
%   separately:
%
%   Can take an optional fifth parameter containing a reaction vector. Each
%   reaction with a value of zero in this vector will not be considered.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function result = CNAToOdefy(varargin)

if ~IsMatlab
    error('No CNA support in Octave');
end

if (nargin == 1 || nargin==2)
    % is CNA model
    cnamodel = varargin{1};
    mat = cnamodel.interMat;
    notmat = cnamodel.notMat;
    cnaspecies = cnamodel.specLongName;
    modelname = cnamodel.net_var_name;
    
    % store species as cell array
    for i=1:size(cnaspecies,1)
        species{i} = strtrim(cnaspecies(i,:));
    end
    numspecies = size(cnaspecies,1);
    
    % get enabled reactions
    if (nargin==2)
        enabledreactions = varargin{2};
    else
        enabledreactions  = ones(size(mat,2),1);
    end

elseif (nargin == 4 || nargin==5) 
    % variables provided seperately
    species = varargin{1};
    numspecies = numel(species);
    mat = varargin{2};
    notmat = varargin{3};
    modelname = varargin{4};

    % get enabled reactions
    if (nargin==5)
        enabledreactions = varargin{5};
    else
        enabledreactions = ones(size(mat,2),1);
    end

else
    error('Function takes 1 or 4 parameters. Type ''help CNAToOdefy'' for more information.');
end

result.species = cell(size(species));
for i=1:numel(species)
    result.species{i} = validvarname(species{i});
end
% result.species = species;


% ensure no values <-1 or >+1
mat(mat<-1)=-1;
mat(mat>1)=1;

% generate set of transition rules
rules = TransitionRules(mat, notmat, enabledreactions);

% iterate over all species
for i=1:size(rules,2)
    currules = rules{i};
    % get all involved input species
    [x,y] = find(currules~=0);
    input = unique(x);
    numinput = size(input,1);
       
    if (numinput > 0)

        % initialize truth table
        if (numinput == 1)
            truth = zeros(2,1);
        else
            truth = zeros(ones(1,numinput)*2);
        end
        
        % iterate over all possible boolean input vectors
        for j=0:2^size(input,1)-1
            % generate actual input vector
            inpmapped = bin2vec(j,numinput);
            inp = zeros(numspecies,1);
            for k=1:numinput
                if (inpmapped(k)==1)
                    inp(input(k))=1;
                end
            end
            
            % check whether at least one function is active
            istrue=0;
            for k=1:size(currules,2)
                trues = size( find(currules(:,k)>0),1);
                value = inp'*currules(:,k);
                % value = number of positive values in function => true!
                if (value == trues)
                    % true!
                    istrue=1;
                    break;
                end
            end
            % store in truth table
            truth(j+1) = istrue;
        
        end
        
        % store truth table and input species in result structure
        result.tables(i).truth = truth;
        result.tables(i).inspecies = input;
        
    else
        % no input for this species => source
        result.tables(i).truth = [];
        result.tables(i).inspecies = [];
    end

end

result.name = modelname;

function v = bin2vec(binnum, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if binnum >= pow2
        v(i+1) = 1;
        binnum = binnum - pow2;
    end
end
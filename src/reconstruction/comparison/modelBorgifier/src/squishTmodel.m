% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function Tmodel = squishTmodel(Tmodel, varargin)
% squishTmodel compresses Tmodel to look like one model, rather than a
% combination of othes models. 
%
% USAGE:
%    Tmodel = squishTmodel(Tmodel, modelName, revMethod)
%
% INPUTS:
%    Tmodel
%
% OPTIONAL INPUTS:
%    modelName:     Indicate model to preference in term of reveribility,
%                   bounds, and objective function.
%    revMethod:     Indicates how reaction reversibility should be
%                   decided. See switchcase below.
% OUTPUTS:
%    Tmodel
%
% CALLS:
%    buildRxnEquations
%
% CALLED BY:
%    None

if nargin > 1
    prefModel = varargin{1} ;
else
    prefModel = 'none' ;
end

if nargin > 2
    revMethod = varargin{2} ; 
else
    revMethod = 'leniant' ; 
end

% Models in T.
mNames = fieldnames(Tmodel.Models) ; 

% Create reveribility array.
rev = zeros(length(Tmodel.rxns), 1) ;

switch lower(revMethod) 
    case 'leniant'
        % If any model has reaction as reversible, it is reversible. 
        for iM = 1:length(mNames)
            rev = rev + Tmodel.rev.(mNames{iM}) ; 
        end
    case 'conservative'
        % If one model says it is irrev, then it is irrev.
        for iM = 1:length(mNames)
            rev(Tmodel.Models.(mNames{iM}).rxns) = ...
                rev(Tmodel.Models.(mNames{iM}).rxns) + ...
                ~Tmodel.rev.(mNames{iM})(Tmodel.Models.(mNames{iM}).rxns) ;
        end
        rev = ~rev ; 
end

% Now base ub and lb off rev.
rev = logical(rev) ;
lb = zeros(length(Tmodel.rxns), 1) ;
lb(rev) = -1000 ;
ub = ones(length(Tmodel.rxns), 1) * 1000 ;
% Convert rev back to a double.
rev = double(rev) ;

% There is no objective.
c = zeros(length(Tmodel.rxns), 1) ; 

% If model is given, use information from it.
if ~strcmp(prefModel, 'none') 
    c = Tmodel.c.(prefModel) ;
    rev(Tmodel.Models.(prefModel).rxns) = ...
        Tmodel.rev.(prefModel)(Tmodel.Models.(prefModel).rxns) ;
    lb(Tmodel.Models.(prefModel).rxns) = ...
        Tmodel.lb.(prefModel)(Tmodel.Models.(prefModel).rxns) ;
    ub(Tmodel.Models.(prefModel).rxns) = ...
        Tmodel.ub.(prefModel)(Tmodel.Models.(prefModel).rxns) ;
end

% Combine genes.
genes = {} ;
for iM = 1:length(iM)
    if isfield(Tmodel.Models.(mNames{iM}), 'genes')
        genes = [genes; Tmodel.Models.(mNames{iM}).genes] ;
    end
end

% Replace structures in Tmodel with the new matricies.
Tmodel.rev = rev ;
Tmodel.lb = lb ; 
Tmodel.ub = ub ;
Tmodel.c = c ;
Tmodel.genes = genes ;

Tmodel = buildRxnEquations(Tmodel) ;


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
function Model = buildTmodel(Model)
% buildTmodel initiates the template model (Tmodel). It adds model
% designations before some of the cell arrays add creates indenty arrays
% that indicate which reactions and metabolties are contained in which
% models. This function should be used after verifyModel. 
% 
% USAGE:
%    Tmodel = buildTmodel(Model)
%
% INPUTS:
%    Model:     Cobra model.  
%
% OUTPUTS:
%    Model:     Template model which to which another model can be
%               compared. Known as Tmodel in other scripts
%
% CALLS:
%   None
%
% CALLED BY:
%   None

%% Declare variables.
modelName = Model.description ;
nameFields = {'rxnID' 'metID' 'subSystems' 'rxnReferences' ...
               'rxnECNumbers' 'grRules'} ;
    
%% Put the model name in for appropriate fields. 
for iF = 1:length(nameFields)
    % Determine which entries are non empty.
    haveData = find(~cellfun(@isempty, Model.(nameFields{iF}))) ;
    Model.(nameFields{iF})(haveData) = ...
        strcat(modelName, ':', Model.(nameFields{iF})(haveData)) ; 
end

%% Create indentity structure. 
Model.Models.(modelName).rxns = true(length(Model.rxns), 1) ;
Model.Models.(modelName).mets = true(length(Model.mets), 1) ;

%% Add genes.
Model.Models.(modelName).genes = Model.genes ; 

%% Move bound info into structures.
rev = Model.rev ;
lb = Model.lb ;
ub = Model.ub ;
c = Model.c ;

Model.rev = ([]); % Must declare empty structurse first in 2016b.
Model.lb = ([]);
Model.ub = ([]);
Model.c = ([]);

Model.rev.(modelName) = rev ;
Model.lb.(modelName) = lb ;
Model.ub.(modelName) = ub ;
Model.c.(modelName) = c ;

%% Make S sparse.
Model.S = sparse(Model.S) ;

%% Remove extra fields that could get in the way.
unwantedFields = {'description' 'genes' 'rxnGeneMat' 'rules'} ; 
Model = rmfield(Model, unwantedFields) ; 
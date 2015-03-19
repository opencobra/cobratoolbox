function model = setReactionStoichiometry(inputmodel,rxnName,metaboliteList,stoichCoeffList,addmetabolites);
%setReactionStoichiometry - set the Stoichiometry of a reaction to a new stoichiometry
%
% model = setReactionStoichiometry(model,rxnName,mets,coefficients,addmetabolites)
%
%INPUTS
% model             COBRA model structure
% rxnName           Reaction name abbreviation (i.e. 'ACALD')
%                   (Note: can also be a cell array {'abbr','name'}
% metaboliteList    Cell array of metabolite names or alternatively the
%                   reaction formula for the reaction
% stoichCoeffList   List of stoichiometric coefficients 
%
%OPTIONAL INPUTS
% addmetabolites    Add metabolites present in the stoichiometry which are
%                   not yet part of the model (default = false)
%OUTPUTS
% model             COBRA model structure with altered reaction
%
% Examples:
%
%    Change the reaction formula of a transport to atp mediated transport
%
%    model = addReaction(model,'Atrans',{'atp[c]','adp[c]','pi[c]','h[c]','h2o[c]','A[c]','A[n]'},[-1 1 1 1 -1 -1 1])
%
%
% Thomas Pfau 9/2/2015

if nargin < 5
    addmetabolites = 0;
end
model = inputmodel;
[metpos,metorg] = ismember(model.mets,metaboliteList);
%check whether we have to add new metabolites / or abort
if (numel(find(metpos)) < numel(metaboliteList)) 
    nonpresentmets = ~ismember(metaboliteList,model.mets)
    
    if ~addmetabolites    
        
        warning('Unknown Metabolites - Model unchanged!'); 
        disp(metaboliteList(nonpresentmets));
        return 
    else
        warning('Adding unknown metabolites:'); 
        disp(metaboliteList(nonpresentmets));
        model = addMetabolite(model,metaboliteList(nonpresentmets));
        [metpos,metorg] = ismember(model.mets,metaboliteList);
    end
    
end
%get the new stoichiometry
metaboliteList = metaboliteList(metorg(metpos));
stoichCoeffList = stoichCoeffList(metorg(metpos));

%clear the reaction
reacpos = ismember(model.rxns,rxnName);
model.S(:,reacpos) = 0;

%set the new stoichiometry
model.S(metpos,reacpos) = stoichCoeffList;
end



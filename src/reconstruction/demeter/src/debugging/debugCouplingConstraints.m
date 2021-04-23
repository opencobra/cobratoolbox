function [model,addedCouplingRxns] = debugCouplingConstraints(model,biomassReaction,database)
% Part of the DEMETER pipeline. In rare cases, the implementation of
% coupling constraints, which is required for the Microbiome Modeling
% Toolbox, renders the model unable to grow. This can be fixed by adding
% certain reactions that were identiifed through manual testing.
%
% USAGE:
%
%   [model,addedCouplingRxns] = debugCouplingConstraints(model,biomassReaction,database)
%
% INPUTS
% model:               COBRA model structure
% biomassReaction:     Reaction ID of the biomass objective function
% database:            rBioNet reaction database containing min. 3 columns:
%                      Column 1: reaction abbreviation, Column 2: reaction
%                      name, Column 3: reaction formula.
%
% OUTPUT
% model:               COBRA model structure
% addedCouplingRxns:   Reactions added to enable growth with coupling
%                      constraints
%
% .. Author:
%       - Almut Heinken, 04/2021

modelPrevious=model;
addedCouplingRxns = {};

% couple all reactions except biomass and exchange reactions to the biomass
% reaction
rxns2Couple=model.rxns;
rxns2Couple(find(strncmp(rxns2Couple,biomassReaction,length(biomassReaction))),:)=[];
rxns2Couple(find(strncmp(rxns2Couple,'EX_',3)),:)=[];

model=coupleRxnList2Rxn(model,rxns2Couple,biomassReaction,400,0); %couple the specific reactions

% define gap-fills that could enable growth with coupling constraints
growthFixes={'EX_hco3(e)','HCO3abc','H2CO3D','EX_ac(e)','ACt2r','EX_for(e)','FORt2r','EX_lac_L(e)','L_LACt2r','EX_lac_D(e)','D_LACt2','EX_etoh(e)','ETOHt2r','EX_fum(e)','FUMt2r','EX_succ(e)','SUCCt2r','ATPS4'};

tol = 0.000001;

% check if coupling constraints disable growth
solution=optimizeCbModel(model);
if solution.f < tol
    growthFixes2Add=setdiff(growthFixes,model.rxns);
    for j=1:length(growthFixes2Add)
        formula = database.reactions{ismember(database.reactions(:, 1), growthFixes2Add{j}), 3};
        model = addReaction(model, growthFixes2Add{j}, 'reactionFormula', formula);
    end
    solution=optimizeCbModel(model);
    if solution.f > tol
        [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(model, 'FBA', growthFixes2Add);
        growthEnablingRxns=growthFixes2Add(grRateKO(:,1)<tol);
        
        % save the enabled model
        for j=1:length(growthEnablingRxns)
            formula = database.reactions{ismember(database.reactions(:, 1), growthEnablingRxns{j}), 3};
            modelPrevious = addReaction(modelPrevious, growthEnablingRxns{j}, 'reactionFormula', formula);
        end
        model = modelPrevious;
        addedCouplingRxns = growthEnablingRxns;
    end
end

end

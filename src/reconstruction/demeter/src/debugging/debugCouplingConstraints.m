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
growthFixes={'EX_hco3(e)','';'HCO3abc','';'H2CO3D','';'EX_ac(e)','ACt';'ACt2r','ACt';'ATPS4','';'EX_for(e)','FORt';'FORt2r','FORt';'EX_lac_L(e)','';'L_LACt2r','';'EX_lac_D(e)','';'D_LACt2','';'EX_etoh(e)','ETOHt';'ETOHt2r','ETOHt';'EX_succ(e)','SUCCt';'SUCCt2r','SUCCt';'EX_fum(e)','FUMt';'FUMt2r','FUMt'};

tol = 0.000001;

% check if coupling constraints disable growth
solution=optimizeCbModel(model);
if solution.f < tol
    growthFixes2Add=growthFixes;
    [C,IA]=intersect(growthFixes2Add(:,1),model.rxns);
    growthFixes2Add(IA,:)=[];
    [C,IA]=intersect(growthFixes2Add(:,2),model.rxns);
    growthFixes2Add(IA,:)=[];
    
    for j=1:size(growthFixes2Add,1)
        formula = database.reactions{ismember(database.reactions(:, 1), growthFixes2Add{j,1}), 3};
        model = addReaction(model, growthFixes2Add{j,1}, 'reactionFormula', formula);
    end
    solution=optimizeCbModel(model);
    if solution.f > tol
        % find out which added reactions were essential
        cnt=1;
        addedCouplingRxns = {};
        for j=1:size(growthFixes2Add,1)
            modelTest=removeRxns(model,growthFixes2Add{j,1});
            solution=optimizeCbModel(modelTest);
            if solution.f < tol
                addedCouplingRxns{cnt}=growthFixes2Add{j,1};
                cnt=cnt+1;
            else
                model=modelTest;
            end
        end
        
        % save the enabled model
        model=modelPrevious;
        for j=1:length(addedCouplingRxns)
            formula = database.reactions{ismember(database.reactions(:, 1), addedCouplingRxns{j}), 3};
            model = addReaction(model, addedCouplingRxns{j}, 'reactionFormula', formula);
            model.comments{end,1}='Added to enable growth with coupling constraints in place during DEMETER pipeline.';
            model.rxnConfidenceScores(end,1)=1;
        end
    end
else
    model=modelPrevious;
end

end

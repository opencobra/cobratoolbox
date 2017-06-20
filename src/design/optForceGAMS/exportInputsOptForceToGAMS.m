function [] = exportInputsOptForceToGAMS(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM,...
    maxFluxesM, k, n_sets, constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
% This function export the inputs required by GAMS to run optForce. Some
% inputs will be exported to plain text (.txt files) and others will be
% exported using GDXMRW. Inputs will be stored in inputFolder
%
% USAGE:
%         exportInputsOptForceToGAMS(model, targetRxn, mustU, mustL, ...
%         minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, n_sets, ...
%         constrOpt, excludedURxns, excludedLRxns, excludedKRxns, ...
%         inputFolder): export the following variables to text files:
%         model.rxns, model.mets, targetRxn, mustU, mustL,
%         constrOpt.rxnList, excludedURxns, excludedLRxns and
%         excludedKRxns. model.S, model.lb, model.ub, constrOpt.values,
%         minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, n_sets are
%         exported into a file called GtoM.gdx which can be read by GAMS
%         using GDXMRW.
%
% INPUTS:
%
%         model (obligatory):       Type: struct (COBRA model)
%                                   Description: a metabolic model with at least
%                                   the following fields:
%                                   rxns            Reaction IDs in the model
%                                   mets            Metabolite IDs in the model
%                                   S               Stoichiometric matrix (sparse)
%                                   b               RHS of Sv = b (usually zeros)
%                                   c               Objective coefficients
%                                   lb              Lower bounds for fluxes
%                                   ub              Upper bounds for fluxes
%                                   rev             Reversibility flag
%
%         targetRxn (obligatory):   Type: string
%                                   Description: string containing the ID for the
%                                   reaction whose flux is intented to be increased.
%                                   For example, if the production of succionate is
%                                   desired to be increased, 'EX_suc' should be
%                                   chosen as the target reaction
%                                   Example: targetRxn='EX_suc';
%
%         mustU (obligatory):       Type: cell array.
%                                   Description: List of reactions in the MustU set
%                                   This input can be obtained by running the
%                                   script findMustU.m
%                                   Example: mustU={'R21_f';'R22_f'};
%
%         mustL (obligatory):       Type: cell array.
%                                   Description: List of reactions in the MustL set
%                                   This input can be obtained by running the
%                                   script findMustL.m
%                                   Example: mustL={'R11_f';'R26_f'};
%
%         minFluxesW (obligatory):   Type: double array of size n_rxns x1
%                                    Description: Minimum fluxes for each reaction
%                                    in the model for wild-type strain
%                                    Example: minFluxesW=[-90; -56];
%
%         maxFluxesW (obligatory):   Type: double array of size n_rxnsx1
%                                    Description: Maximum fluxes for each reaction
%                                    in the model for wild-type strain
%                                    Example: maxFluxesW=[92; -86];
%
%         minFluxesM (obligatory):   Type: double array of size n_rxnsx1
%                                    Description: Minimum fluxes for each reaction
%                                    in the model for mutant strain
%                                    Example: minFluxesW=[-90; -56];
%
%         maxFluxesM (obligatory):   Type: double array of size n_rxnsx1
%                                    Description: Maxmum fluxes for each reaction
%                                    in the model for mutant strain
%                                    Example: maxFluxesW=[92; -86];
%
%         k(obligatory):            Type: double
%                                   Description: number of intervations to be
%                                   found
%
%         n_sets(obligatory):       Type: double
%                                   Description: maximum number of force sets
%                                   returned by optForce.
%
%         constrOpt (obligatory):   Type: structure
%                                   Description: structure containing constrained
%                                   reactions with fixed values. The structure has
%                                   the following fields:
%                                   rxnList: (Type: cell array)      Reaction list
%                                   values:  (Type: double array)    Values for constrained reactions
%                                   Example: constrOpt=struct('rxnList',{{'EX_for_e','EX_etoh_e'}},'values',[1,5]);
%
%         excludedURxns(obligatory):Type: cell array
%                                   Description: Reactions to be excluded from
%                                   upregulations
%
%         excludedLRxns(obligatory):Type: cell array
%                                   Description: Reactions to be excluded from
%                                   downregulations
%
%         excludedKRxns(obligatory):Type: cell array
%                                   Description: Reactions to be excluded from
%                                   knockouts
%
%         inputFolder(obligatory)   Type: string
%                                   Description: folder where inputs will be
%                                   stored. Just the name of the folder, not the
%                                   full path.
%
%
% OUTPUTS:
%
%         Reactions.txt                 Type: file
%                                       Description: File containing the
%                                       identifiers for reactions
%
%         Metabolites.txt               Type: file
%                                       Description: File containing the
%                                       identifiers for metabolites
%
%         Constrains.txt                Type: file
%                                       Description: File containing the
%                                       identifiers for constrained reactions
%
%         Excluded_U.txt                Type: file
%                                       Description: File containing the
%                                       identifiers for excluded reactions. These
%                                       reactions will not be considered for
%                                       upregulations when running optForce.gms
%
%         Excluded_L.txt                Type: file
%                                       Description: File containing the
%                                       identifiers for excluded reactions. These
%                                       reactions will not be considered for
%                                       downregulations when running optForce.gms
%
%         Excluded_K.txt                Type: file
%                                       Description: File containing the
%                                       identifiers for excluded reactions. These
%                                       reactions will not be considered for
%                                       knowckouts when running optForce.gms
%
%         MustU.txt                     Type: file
%                                       Description: File containing the
%                                       identifiers for upregulated reactions find
%                                       in MustU, MustUU and MustUL
%
%         MustU.txt                     Type: file
%                                       Description: File containing the
%                                       identifiers for downregulated reactions
%                                       find in MustL, MustLL and MustUL
%
%         MtoG.gdx                      Type: file
%                                       Description: File containing the
%                                       parameters which will be read by GAMS
%                                       (lower bounds, upper bounds, stoichiometrix
%                                       matrix S, minimum and maximun fluxes for
%                                       each reaction in the previous step of FVA,
%                                       and the values for contrained reactions)

if nargin < 15 %inputs handling
    error('Optforce: All inputs must be specified when using exportInputsOptForceToGAMS');
end

%Create a temporaty folder for inputs
if ~exist(inputFolder, 'dir')
   mkdir(inputFolder);
end
current = pwd;
cd(inputFolder);

%Export Sets
exportSetToGAMS(model.rxns, 'Reactions.txt');
exportSetToGAMS(model.mets, 'Metabolites.txt');
exportSetToGAMS(constrOpt.rxnList, 'Constraints.txt');
exportSetToGAMS(excludedURxns, 'Excluded_U.txt');
exportSetToGAMS(excludedLRxns, 'Excluded_L.txt');
exportSetToGAMS(excludedKRxns, 'Excluded_K.txt');
exportSetToGAMS(mustL, 'MustL.txt');
exportSetToGAMS(mustU, 'MustU.txt');
exportSetToGAMS(targetRxn, 'TargetRxn.txt');

%Export parameters
s.name = 's';
s.val = full(model.S);
s.type = 'parameter';
s.form = 'full';
s.uels = {model.mets',model.rxns'};

basemin.name = 'basemin';
basemin.val = minFluxesW;
basemin.type = 'parameter';
basemin.form = 'full';
basemin.uels = model.rxns';

phenomax.name = 'phenomax';
phenomax.val = maxFluxesM;
phenomax.type = 'parameter';
phenomax.form = 'full';
phenomax.uels = model.rxns';

phenomin.name = 'phenomin';
phenomin.val = minFluxesM;
phenomin.type = 'parameter';
phenomin.form = 'full';
phenomin.uels = model.rxns';

basemax.name = 'basemax';
basemax.val = maxFluxesW;
basemax.type = 'parameter';
basemax.form = 'full';
basemax.uels = model.rxns';

lb.name = 'lb';
lb.val = model.lb';
lb.type = 'parameter';
lb.form = 'full';
lb.uels = model.rxns';

ub.name = 'ub';
ub.val = model.ub';
ub.type = 'parameter';
ub.form = 'full';
ub.uels = model.rxns';

b.name = 'b';
b.val = constrOpt.values;
b.type = 'parameter';
b.form = 'full';
b.uels = constrOpt.rxnList;

kg.name = 'k';
kg.type = 'parameter';
kg.val = k;

nMax.name = 'nMax';
nMax.type = 'parameter';
nMax.val = n_sets;

%Using GDXMRW to export inputs
wgdx('MtoG', s, basemin, basemax, phenomin, phenomax, lb, ub, b, kg, nMax);
cd(current);

end

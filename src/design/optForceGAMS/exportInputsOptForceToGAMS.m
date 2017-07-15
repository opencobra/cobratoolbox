function [] = exportInputsOptForceToGAMS(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, n_sets, constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
% This function export the inputs required by GAMS to run `optForce`. Some
% inputs will be exported to plain text (.txt files) and others will be
% exported using GDXMRW. Inputs will be stored in inputFolder
%
% USAGE:
%
%         exportInputsOptForceToGAMS(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets, constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
%
% INPUTS:
%    model:             (structure) a metabolic model with at least the
%                       following fields:
%
%                         * .rxns - Reaction IDs in the model
%                         * .mets - Metabolite IDs in the model
%                         * .S -    Stoichiometric matrix (sparse)
%                         * .b -    RHS of `Sv = b` (usually zeros)
%                         * .c -    Objective coefficients
%                         * .lb -   Lower bounds for fluxes
%                         * .ub -   Upper bounds for fluxes
%    targetRxn:         (string) string containing the ID for the
%                       reaction whose flux is intented to be increased.
%                       For example, if the production of succionate is
%                       desired to be increased, 'EX_suc' should be
%                       chosen as the target reaction.
%                       E.g.: `targetRxn = 'EX_suc';`
%    mustU:             (cell array) List of reactions in the `MustU` set
%                       This input can be obtained by running the
%                       script `findMustU.m`.
%                       E.g.: `mustU = {'R21_f';'R22_f'};`
%    mustL:             (cell array) List of reactions in the `MustL` set
%                       This input can be obtained by running the
%                       script `findMustL.m`.
%                       E.g.: `mustL = {'R11_f';'R26_f'};`
%    minFluxesW:        (double array of size `n_rxns x 1`) minimum fluxes
%                       for each reaction in the model for wild-type strain.
%                       E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:        (double array of size `n_rxns x 1`) maximum fluxes
%                       for each reaction in the model for wild-type strain.
%                       E.g.: `maxFluxesW = [92; -86];`
%    minFluxesM:        (double array of size `n_rxns x 1`)
%                       Description: Minimum fluxes for each reaction in
%                       the model for mutant strain E.g.: `minFluxesW = [-90;
%                       -56];`
%    maxFluxesM:        (double array of size `n_rxns x 1`) maximum fluxes
%                       for each reaction in the model for mutant strain.
%                       E.g.: `maxFluxesW = [92; -86];`
%    k:                 (double) number of intervations to be found
%    nSets:             (double) maximum number of force sets returned
%                       by `optForce`.
%    constrOpt:         (Structure) structure containing additional
%                       contraints. Include here only reactions whose flux
%                       is fixed, i.e., reactions whose lower and upper
%                       bounds have the same value. Do not include here
%                       reactions whose lower and upper bounds have
%                       different values. Such contraints should be defined
%                       in the lower and upper bounds of the model. The
%                       structure has the following fields:
%
%                         * .rxnList - Reaction list (cell array)
%                         * .values -  Values for constrained reactions
%                           (double array). E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    excludedURxns:     (cell array) Reactions to be excluded from
%                       upregulations
%    excludedLRxns:     (cell array) Reactions to be excluded from
%                       downregulations
%    excludedKRxns:     (cell array) Reactions to be excluded from
%                       knockouts
%    inputFolder:       (string) folder where inputs will be stored.
%                       Just the name of the folder, not the full path.
%
% OUTPUTS:
%    Reactions.txt:     (file) File containing the identifiers for
%                       reactions
%    Metabolites.txt:   (file) File containing the identifiers for
%                       metabolites
%    Constrains.txt:    (file) File containing the identifiers for
%                       constrained reactions
%    Excluded_U.txt:    (file) File containing the identifiers for
%                       excluded reactions. These reactions will not be
%                       considered for upregulations when running
%                       `optForce.gms`
%    Excluded_L.txt:    (file) File containing the identifiers for
%                       excluded reactions. These reactions will not be
%                       considered for downregulations when running
%                       `optForce.gms`
%    Excluded_K.txt:    (file) File containing the identifiers for
%                       excluded reactions. These reactions will not be
%                       considered for knowckouts when running `optForce.gms`
%    MustU.txt:         (file) File containing the identifiers for
%                       upregulated reactions find in `MustU`, `MustUU` and
%                       `MustUL`
%    MustU.txt:         (file) File containing the identifiers for
%                       downregulated reactions find in `MustL`, `MustLL` and
%                       `MustUL`
%    MtoG.gdx:          (file) File containing the parameters which
%                       will be read by GAMS (lower bounds, upper bounds,
%                       stoichiometrix matrix `S`, minimum and maximun fluxes
%                       for each reaction in the previous step of FVA, and
%                       the values for contrained reactions)
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

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
nMax.val = nSets;

%Using GDXMRW to export inputs
wgdx('MtoGOF', s, basemin, basemax, phenomin, phenomax, lb, ub, b, kg, nMax);
cd(current);

end

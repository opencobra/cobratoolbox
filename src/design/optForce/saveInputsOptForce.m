function [] = saveInputsOptForce(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM,...
    maxFluxesM, k, nSets, constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
% This function saves all the inputs needed to run functions to find second
% order Must Sets (`MustUU`, `MustLL` and `MustUL`) The inputs will be stored in
% inputFolder.
%
% USAGE:
%
%    saveInputsOptForce(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets, constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
%
% INPUTS
%    model:             (structure) COBRA metabolic model with at least
%                       the following fields:
%
%                         * .rxns - Reaction IDs in the model
%                         * .mets - Metabolite IDs in the model
%                         * .S -    Stoichiometric matrix (sparse)
%                         * .b -    RHS of `Sv = b` (usually zeros)
%                         * .c -    Objective coefficients
%                         * .lb -   Lower bounds for fluxes
%                         * .ub -   Upper bounds for fluxes
%    minFluxesW:        (double array) of size `n_rxns x 1`
%                       Minimum fluxes for each
%                       reaction in the model for wild-type strain.
%                       This can be obtained by running the
%                       function `FVAOptForce`.
%                       E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:        (double array) of size `n_rxns x 1`
%                       Maximum fluxes for each
%                       reaction in the model for wild-type strain.
%                       This can be obtained by running the
%                       function `FVAOptForce`.
%    minFluxesM:        (double array) of size `n_rxns x 1`
%                       Minimum fluxes for each
%                       reaction in the model for mutant strain.
%                       This can be obtained by running the
%                       function `FVAOptForce`.
%                       E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesM:        (double array) of size `n_rxns x 1`
%                       Maximum fluxes for each
%                       reaction in the model for mutant strain.
%                       This can be obtained by running the
%                       function `FVAOptForce`.
%    constrOpt:         (structure) structure containing
%                       additional contraints. Include here only
%                       reactions whose flux is fixed, i.e.,
%                       reactions whose lower and upper bounds have
%                       the same value. Do not include here
%                       reactions whose lower and upper bounds have
%                       different values. Such contraints should be
%                       defined in the lower and upper bounds of
%                       the model. The structure has the following
%                       fields:
%
%                         * .rxnList - Reaction list (cell array)
%                         * .values -  Values for constrained
%                           reactions (double array)
%                           E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    excludedURxns:     (cell array) Reactions to be excluded from
%                       upregulations. This could be used to avoid finding
%                       transporters or exchange reactions in the set
%    excludedLRxns:     (cell array) Reactions to be excluded from
%                       downregulations. This could be used to avoid
%                       finding transporters or exchange reactions in the
%                       set
%    excludedKRxns:     (cell array) Reactions to be excluded from
%                       knockouts This could be used to avoid finding
%                       transporters or exchange reactions in the set
%    inputFolder:       (string) Folder where inputs for GAMS function will be stored
%
% OUTPUTS:
%    model.mat:         File containing the model
%    targetRxn.mat:     File containing the target reaction
%    mustU.mat:         File containing `mustU` set
%    mustL.mat:         File containing `mustL` set
%    minFluxesW.mat:    File containing the minimum fluxes for the wild-type
%    maxFluxes.mat:     File containing the maximum fluxes for the wild-type
%    minFluxesM.mat:    File containing the minimum fluxes for the mutant
%    maxFluxesM.mat:    File containing the maximum fluxes for the mutant
%    k.mat:             File containing `k` the number of reactions in the `optForce` set
%    nSets.mat:         File containing the maximum number of sets found by `optForce`
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

if nargin < 15
    error('OptForce: All inputs must be specified. Please add empty array if needed.')
end
if  isempty(model)
    error('OptForce: model must be provided')
end
if isempty(targetRxn)
    error('OptForce: targetRxn must be provided')
end
if isempty(mustU)
    error('OptForce: mustU must be provided')
end
if isempty(mustL)
    error('OptForce: mustL must be provided')
end
if isempty(minFluxesW)
    error('OptForce: minFluxesW must be provided')
end
if isempty(maxFluxesW)
    error('OptForce: maxFluxesW must be provided')
end
if isempty(minFluxesM)
    error('OptForce: minFluxesM must be provided')
end
if isempty(maxFluxesM)
    error('OptForce: maxFluxesM must be provided')
end
if isempty(k)
    error('OptForce: k must be provided')
end
if isempty(nSets)
    error('OptForce: nSets must be provided')
end

%Create a temporaty folder for inputs
if ~exist(inputFolder, 'dir')
   mkdir(inputFolder);
end
current = pwd;
cd(inputFolder);

%save variables
save('model','model');
save('targetRxn','targetRxn');
save('mustU','mustU');
save('mustL','mustL');
save('minFluxesW','minFluxesW');
save('maxFluxesW','maxFluxesW');
save('minFluxesM','minFluxesM');
save('maxFluxesM','maxFluxesM');
save('constrOpt','constrOpt');
save('excludedURxns','excludedURxns');
save('excludedLRxns','excludedLRxns');
save('excludedKRxns','excludedKRxns');

cd(current);

end

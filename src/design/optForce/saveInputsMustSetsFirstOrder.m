function [] = saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt, inputFolder)
% This function saves all the inputs needed to run functions to find first
% order Must Sets (`MustU, `MustL`) The inputs will be stored in
% inputFolder.
%
% USAGE:
%
%    saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt,inputFolder)
%
% INPUTS:
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
%    minFluxesW:        (double array) of size `n_rxns x 1`.
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
%                       E.g.: `maxFluxesW = [90; 56];`
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
%    inputFolder:       (string) Folder where inputs for GAMS
%                       function will be stored
%
% OUTPUTS:
%    model.mat          File containing the model
%    minFluxesW.mat:    File containing the minimum fluxes for the wild-type
%    maxFluxesW.mat:    File containing the maximum fluxes for the mutant
%    constrOpt.mat:     File containing the constraints used
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

if nargin < 5  %inputs handling
    error('OptForce: All inputs must be specified when running saveInputsMustFirstOrder')
end
if isempty(model)
    error('OptForce: model must be specified when running saveInputsMustFirstOrder')
end
if isempty(minFluxesW)
    error('OptForce: minFluxesW must be specified when running saveInputsMustFirstOrder')
end
if isempty(maxFluxesW)
    error('OptForce: maxFluxesW must be specified when running saveInputsMustFirstOrder')
end
if isempty(inputFolder)
    error('OptForce: inputFolder must be specified when running saveInputsMustFirstOrder')
end


%Create a temporary folder for inputs
if ~exist(inputFolder, 'dir')
   mkdir(inputFolder);
end
current = pwd;
cd(inputFolder);

%save variables
save('model','model');
save('minFluxesW','minFluxesW');
save('maxFluxesW','maxFluxesW');
save('constrOpt','constrOpt');

cd(current);

end

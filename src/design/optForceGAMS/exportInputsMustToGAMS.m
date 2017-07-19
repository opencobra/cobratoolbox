function [] = exportInputsMustToGAMS(model, minFluxesW, maxFluxesW, constrOpt, inputFolder)
% This function export all the inputs needed to run the GAMS functions to
% find first order Must Sets (`MustU`, `MustL`). The inputs will
% be stored in inputFolder. Some inputs will be exported using GDXMRW and
% others will be exported as simple .txt files.
%
% USAGE:
%
%         exportInputsMustToGAMS(model, minFluxesW, maxFluxesW, constrOpt, inputFolder)
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
%    minFluxesW:        (double array of size `n_rxns x 1`) minimum fluxes
%                       for each reaction in the model for wild-type
%                       strain. This can be obtained by running the
%                       function `FVAOptForce`. E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:        (double array of size `n_rxns x 1`) maximum fluxes
%                       for each reaction in the model for wild-type
%                       strain. This can be obtained by running the
%                       function `FVAOptForce`. E.g.: `maxFluxesW = [90; 56];`
%    constrOpt:         (structure) structure containing additional
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
%    inputFolder:       (string) Folder where inputs for GAMS function
%                       will be stored
%
% OUTPUTS:
%    Reactions.txt:     (file) File containing the identifiers for
%                       reactions
%    Metabolites.txt:   (file) File containing the identifiers for
%                       metabolites
%    Constrains.txt:    (file) File containing the identifiers for
%                       constrained reactions
%    MtoG.gdx:          (file) File containing the parameters which
%                       will be read by GAMS (lower bounds, upper bounds,
%                       stoichiometrix matrix `S`, minimum and maximun fluxes
%                       for each reaction in the previous step of FVA, and
%                       the values for contrained reactions)
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

if nargin < 6 %input handling
    error('OptForce: All inputs must be specified when running exportInputsMustToGAMS')
end

%Create a temporaty folder for inputs
if ~exist(inputFolder, 'dir')
   mkdir(inputFolder);
end
current = pwd;
cd(inputFolder);

%Export Sets
exportSetToGAMS(model.rxns, 'Reactions.txt')
exportSetToGAMS(model.mets, 'Metabolites.txt')
exportSetToGAMS(constrOpt.rxnList, 'Constraints.txt')

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
b.uels = {'EX_gluc','R75','EX_suc'};

%Using GDXMRW to export inputs
fileName = ['MtoG' setType];
wgdx(fileName, s, basemin, basemax, lb, ub, b)

cd(current);

end

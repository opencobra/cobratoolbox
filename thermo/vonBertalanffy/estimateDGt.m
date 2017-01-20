function model = estimateDGt(model,confidenceLevel)
% Estimates bounds on transformed Gibbs energies for metabolites and
% reactions in model.
% 
% model = estimateDGt(model,confidenceLevel)
% 
% INPUTS
% model             Model structure with following fields:
% .S                m x n stoichiometric matrix.
% .mets             m x 1 array of metabolite identifiers.
% .metFormulas      m x 1 cell array of metabolite formulas. Formulas
%                   for protons should be H.
% .T                Temperature in Kelvin.
% .DfGt0            m x 1 array of standard transformed Gibbs energies of
%                   formation in kJ/mol.
% .uf               m x 1 array of uncertainties in DGft0.
% .DrGt0            n x 1 array of standard transformed reaction Gibbs
%                   energies in kJ/mol.
% .ur               n x 1 array of uncertainties in DrGt0.
% .xmin             m x 1 array of lower bounds on metabolite
%                   concentrations in mol/L.
% .xmin             m x 1 array of upper bounds on metabolite
%                   concentrations in mol/L.
% 
% OPTIONAL INPUTS
% confidenceLevel   {0.50, 0.70, (0.95), 0.99}. Confidence level for DGft0
%                   and DrGt0 interval estimates. Default is 0.95,
%                   corresponding to 95% confidence intervals.
% 
% OUTPUTS
% model             Model structure with following fields added:
% .DfGtMin          Lower bounds on transformed Gibbs energies of formation
%                   in kJ/mol.
% .DfGtMax          Upper bounds on transformed Gibbs energies of formation
%                   in kJ/mol.
% .DrGtMin          Lower bounds on transformed reaction Gibbs energies
%                   in kJ/mol.
% .DrGtMax          Upper bounds on transformed reaction Gibbs energies
%                   in kJ/mol.
% 
% Hulda SH, Nov. 2012

% Configure confidence level
if ~exist('confidenceLevel','var')
   confidenceLevel = 0.95; 
end
if isempty(confidenceLevel)
    confidenceLevel = 0.95;
end

% Map confidence level to t-value
tValueMat = [0.50, 0;...
             0.70, 1.036;...
             0.95, 1.960;...
             0.99, 2.576];
         
tValue = tValueMat(tValueMat(:,1) == confidenceLevel,2);

% Define constants
if ~isfield(model,'R')
    R = 8.3144621e-3; % Gas constant in kJ/(K*mol)
end
if ~isfield(model,'T')
    T= 310.15;
else
    T = model.T; % Temperature in K
end

% Calculate bounds on transformed Gibbs energies of formation
DfGtMin = model.DfGt0 - tValue*model.uf + R*T*log(model.xmin);
DfGtMax = model.DfGt0 + tValue*model.uf + R*T*log(model.xmax);

% Calculate bounds on transformed reaction Gibbs energies
St = full(model.S);
hBool = strcmp(model.metFormulas,'H');
St(hBool,:) = 0; % Set proton coefficients to 0
St_neg = St;
St_neg(St_neg > 0) = 0; % Only negative (reactant) coefficients
St_pos = St;
St_pos(St_pos < 0) = 0; % Only positive (product) coefficients

DrGtMin = model.DrGt0 - tValue*model.ur + R*T*(St_pos'*log(model.xmin) + St_neg'*log(model.xmax));
DrGtMax = model.DrGt0 + tValue*model.ur + R*T*(St_pos'*log(model.xmax) + St_neg'*log(model.xmin));

% Add results to model structure
model.DfGtMin = DfGtMin;
model.DfGtMax = DfGtMax;
model.DrGtMin = DrGtMin;
model.DrGtMax = DrGtMax;

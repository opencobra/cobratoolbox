function model = estimateDrGt0(model, confidenceLevel)
% Estimates bounds on transformed Gibbs energies for metabolites and
% reactions in model.
%
% USAGE:
%
%    model = estimateDrGt0(model, confidenceLevel)
%
% INPUT:
%    model:              Model structure with following fields:
%
%                          * .S - `m x n` stoichiometric matrix.
%                          * .mets - `m x 1` array of metabolite identifiers.
%                          * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas for protons should be H.
%                          * .T - Temperature in Kelvin.
%                          * .DfGt0 - Standard transformed Gibbs energies of formation in kJ/mol.
%                          * .DrGt0_Uncertainty Uncertainty in standard transformed reaction Gibbs energies kJ/mol.
%                          * .ph - `c x 1` array of compartment specific pH values.
%                          * .chi `c x 1` array of compartment specific electricalpotential values in mV.
%                          * .concMin - `m x 1` array of lower bounds on metabolite concentrations in mol/L.
%                          * .concMax - `m x 1` array of upper bounds on metabolite concentrations in mol/L.
%
% OPTIONAL INPUT:
%    confidenceLevel:    {0.50, 0.70, (0.95), 0.99}. Confidence level for DGft0
%                        and DrGt0 interval estimates. Default is 0.95,
%                        corresponding to 95% confidence intervals.
%
% OUTPUT:
%    model:              Model structure with following fields added:
%
%                          * .DrGt0 - `n x 1` array of standard transformed reaction Gibbs
%                            energies in kJ/mol.
%                          * .ur - `n x 1` array of uncertainties in `DrGt0`.
%                          * .DrGtMin - Lower bounds on transformed reaction Gibbs energies in kJ/mol.
%                          * .DrGtMax - Upper bounds on transformed reaction Gibbs energies in kJ/mol.
%
% .. Author: - Hulda SH, Nov. 2012

if ~exist('confidenceLevel','var') || isempty(confidenceLevel) % Configure confidence level
   confidenceLevel = 0.95;
end
% Define constants
if ~isfield(model,'R')
    gasConstant = 8.3144621e-3; % Gas constant in kJ/(K*mol)
end
if ~isfield(model,'T')
    T= 310.15;
else
    T = model.T; % Temperature in K
end
%Faraday Constant (kJ/kmol)
faradayConstant=96.485/1000; %kJ/kmol

[nMet,nRxn]=size(model.S);

% Map confidence level to t-value
tValueMat = [0.50, 0;...
             0.70, 1.036;...
             0.95, 1.960;...
             0.99, 2.576];

tValue = tValueMat(tValueMat(:,1) == confidenceLevel,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REACTION PROPERTIES%%%%%%%%%%%%%%%%%%%%
%standard transformed reaction Gibbs energy - without multicompartmental effect
model.DrG0=model.S'*model.DfG0;
model.DrG0(~model.SIntRxnBool) = NaN;

%standard transformed reaction Gibbs energy - without multicompartmental
%effect
model.DrGt0=model.S'*model.DfGt0;
model.DrGt0(~model.SIntRxnBool) = NaN;

% Special adjustment for protons
%boolean of proton indices
hBool = strcmp(model.metFormulas,'H');

%add multicompartmental effect
if 1
    [transportRxnBool]=transportReactionBool(model);
    model.transportRxnBool=transportRxnBool;

    %number of hydrogen in each metabolite species as per reconstruction
    metH=sparse(nMet,1);
    %charge of each metabolite species as per reconstruction
    for i=1:nMet
         metH(i) = numAtomsOfElementInFormula(model.metFormulas{i},'H'); % Use reconstruction data if no group contribution estimate is available
    end

    [metCompartments,~]=getCompartment(model.mets);
    model.metComps=metCompartments;

    metdGfH=zeros(nMet,1);
    metCHI=zeros(nMet,1);
    for i=1:nMet
        bool=strcmp(model.metComps{i},model.compartments);
        if ~any(bool) || nnz(bool)>1
            disp(model.mets{i})
            disp(model.metComps{i})
            error('All metabolites must be associated with one compartment')
        end
        metdGfH(i)= -gasConstant*T*log(10)*model.ph(bool);
        metCHI(i )= faradayConstant*model.chi(bool);
    end

    fprintf('%s\n','Additional effect due to possible change in chemical potential of Hydrogen ions for transport reactions.')
    delta_pH   = model.S'*spdiags(metH,0,nMet,nMet)*metdGfH;

    fprintf('%s\n','Additional effect due to possible change in electrical potential for transport reactions.')
    %Electrical Potential conversion from mV to kJ with Faraday constant
    %eq 8.5-1 p148 Alberty 2003
    delta_chi  = model.S'*spdiags(model.metCharges,0,nMet,nMet)*metCHI;

    %Legendre transform for intercompartmental effects
    model.DrGt0 = model.DrGt0 + delta_pH + delta_chi;

    model.DrGt0Max = model.DrGt0 + tValue*model.DrGt0_Uncertainty;
    model.DrGt0Min = model.DrGt0 - tValue*model.DrGt0_Uncertainty;

    %matrices for computing min and max change in chemical potential
    F=-model.S;
    F(model.S>0)=0;
    R=model.S;
    R(model.S<0)=0;
    if 1
        F(hBool,:)=0;
        R(hBool,:)=0;
    end
    model.DrGtMax = model.DrGt0Max + gasConstant*T*(R'*log(model.concMax) - F'*log(model.concMin));
    model.DrGtMin = model.DrGt0Min + gasConstant*T*(R'*log(model.concMin) - F'*log(model.concMax));

    if 0
        model.DrGtMean = model.DrGt0 + gasConstant*T*(R-F)'*log((model.concMax+model.concMin)/2);
    else
        model.DrGtMean = model.DrGt0 + gasConstant*T*(R-F)'*log(geomean([model.concMin,model.concMax],2));
    end
else
    % Estimate standard transformed reaction Gibbs energies
    St = model.S;
    St(hBool,:) = 0; % Set proton coefficients to 0
%     model.DrGt0 = St' * model.DfGt0;

    % Adjust DrGt0 for transport across membranes
    fprintf('Assuming that only metabolite species in model.metFormulas are transported across membranes.\n');

    metCompartmentBool = strcmp(repmat(model.metComps,1,length(model.compartments)),repmat(model.compartments',length(model.metComps),1));

    model_nHs = zeros(size(model.mets));
    for i = 1:length(model.mets)
        model_nHs(i) = numAtomsOfElementInFormula(model.metFormulas{i},'H');
    end
    deltaPH = model.S' * diag(model_nHs) * metCompartmentBool * -(gasConstant * T * log(10) * model.ph); % Adjustment due to compartmental differences in pH

    model_zs = double(model.metCharges);
    deltaCHI = model.S' * diag(model_zs) * metCompartmentBool * faradayConstant * model.chi; % Adjustment due to compartmental differences in electrical potential

    model.DrGt0 = model.DrGt0 + deltaPH + deltaCHI;

    % Calculate bounds on transformed reaction Gibbs energies
    St = model.S;
    St(hBool,:) = 0; % Set proton coefficients to 0
    St_neg = St;
    St_neg(St_neg > 0) = 0; % Only negative (substrate) coefficients: -F
    St_pos = St;
    St_pos(St_pos < 0) = 0; % Only positive (product) coefficients: R

    model.DrGtMax = model.DrGt0 + tValue*model.DrGt0_Uncertainty + gasConstant*T*(St_pos'*log(model.concMax) + St_neg'*log(model.concMin));
    model.DrGtMin = model.DrGt0 - tValue*model.DrGt0_Uncertainty + gasConstant*T*(St_pos'*log(model.concMin) + St_neg'*log(model.concMax));
end

try
DrGt0NaNBool=isnan(model.DrGt0) & model.SIntRxnBool;
if any(DrGt0NaNBool)
    warning([int2str(nnz(DrGt0NaNBool)) ' internal reaction DrGt0 are NaN']);
end
DrGtNaNBool=(isnan(model.DrGtMax) | isnan(model.DrGtMin)) & model.SIntRxnBool;
if any(DrGtNaNBool)
    warning([int2str(nnz(DrGtNaNBool)) ' DrGt are NaN']);
end
if any(model.DfGtMin>model.DfGtMax)
    error('DfGtMin greater than DfGtMax');
end
if any(model.DrGtMax<model.DrGtMin)
    error('DrGtMax<DrGtMin')
end
catch
    pause(0.1);
end

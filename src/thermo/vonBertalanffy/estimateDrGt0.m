function model = estimateDrGt0(model,confidenceLevel)
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
% .DfGt0            Standard transformed Gibbs energies of formation in
%                   kJ/mol.
% .covf             m x m estimated covariance matrix for standard
%                   Gibbs energies of formation.
% .uf               m x 1 array of uncertainty in estimated standard
%                   Gibbs energies of formation. uf will be large for
%                   metabolites that are not covered by component
%                   contributions.
% .ph               c x 1 array of compartment specific pH values.
% .chi              c x 1 array of compartment specific electrical
%                   potential values in mV.
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
% .DrGt0            n x 1 array of standard transformed reaction Gibbs
%                   energies in kJ/mol.
% .ur               n x 1 array of uncertainties in DrGt0.
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
if ~exist('confidenceLevel','var') || isempty(confidenceLevel)
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

%boolean of proton indices
hBool = strcmp(model.metFormulas,'H');                   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% METABOLITE PROPERTIES%%%%%%%%%%%%%%%%%%%%
% Special adjustment for protons
%TODO - transformed Gibbs energy for each proton should be zero without
%this hack below
%TODO - uf should be zero for protons when it comes from component contribution method
model.uf(hBool)=0; 
if all(model.xmin(hBool)==model.xmax(hBool))
    RTlogxmin=gasConstant*T*log(model.xmin);
    %RTlogxmax=gasConstant*T*log(model.xmax);
    model.DfGt0(hBool)=-RTlogxmin(hBool);
else
    error('minimium and maximum proton concentrations must be identical for each compartment')
end

% Calculate bounds on standard transformed Gibbs energies of formation
DfGt0Min = model.DfGt0 - tValue*model.uf;
DfGt0Max = model.DfGt0 + tValue*model.uf;

% Calculate bounds on transformed Gibbs energies of formation
DfGtMin = DfGt0Min + gasConstant*T*log(model.xmin);
DfGtMax = DfGt0Max + gasConstant*T*log(model.xmax);

if ~(all(DfGtMin(hBool)==0) && all(DfGtMin(hBool)==0))
    error('Transformed Gibbs energy for each proton should be zero')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REACTION PROPERTIES%%%%%%%%%%%%%%%%%%%%
%uncertainty associated with component contribution estimates
model.ur = sqrt(diag(model.S'*model.covf*model.S));%todo, should only be internal reactions
model.ur(model.ur >= 1e3) = 1e10; % Set large uncertainty in reaction energies to inf
model.ur(sum(model.S~=0)==1) = 1e10; % set uncertainty of exchange, demand and sink reactions to inf

%
model.DrGt0=model.S'*model.DfGt0;

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
    model.metCompartments=metCompartments;
    
    metdGfH=zeros(nMet,1);
    metCHI=zeros(nMet,1);
    for i=1:nMet
        bool=strcmp(model.metCompartments{i},model.compartments);
        if ~any(bool) || nnz(bool)>1
            disp(model.mets{i})
            disp(model.metCompartments{i})
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

    DrGt0Max = model.DrGt0 + tValue*model.ur + delta_pH + delta_chi;
    DrGt0Min = model.DrGt0 - tValue*model.ur + delta_pH + delta_chi;
    
    %matrices for computing min and max change in chemical potential
    F=-model.S;
    F(model.S>0)=0;
    R=model.S;
    R(model.S<0)=0;
    if 1
        F(hBool,:)=0;
        R(hBool,:)=0;
    end
    DrGtMax = DrGt0Max + gasConstant*T*(R'*log(model.xmax) - F'*log(model.xmin));
    DrGtMin = DrGt0Min + gasConstant*T*(R'*log(model.xmin) - F'*log(model.xmax));
    pause(1e-5)
else
    % Estimate standard transformed reaction Gibbs energies
    St = model.S;
    St(hBool,:) = 0; % Set proton coefficients to 0
%     model.DrGt0 = St' * model.DfGt0;
    
    % Adjust DrGt0 for transport across membranes
    fprintf('Assuming that only metabolite species in model.metFormulas are transported across membranes.\n');
    
    metCompartmentBool = strcmp(repmat(model.metCompartments,1,length(model.compartments)),repmat(model.compartments',length(model.metCompartments),1));
    
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

    DrGtMax = model.DrGt0 + tValue*model.ur + gasConstant*T*(St_pos'*log(model.xmax) + St_neg'*log(model.xmin));
    DrGtMin = model.DrGt0 - tValue*model.ur + gasConstant*T*(St_pos'*log(model.xmin) + St_neg'*log(model.xmax));
end

if any(DrGtMax<DrGtMin)
    error('DrGtMax<DrGtMin')
end
    
% Add results to model structure
model.DfGtMin = DfGtMin;
model.DfGtMax = DfGtMax;
model.DrGtMin = DrGtMin;
model.DrGtMax = DrGtMax;

%balance the protons in each reaction given the number of Hydrogens bound
%to each reactant calculated thermodynamically using assignThermoToModel.m
if 0 %TODO Jan 30th 2011 Balancing protons changes growth rate ~0.7 -> 1.1  Need to check
    fprintf('\n%s\n','...pHbalanceProtons');
    model=pHbalanceProtons(model,massImbalance); % Minor changes - Hulda
end





function model = estimateDfGt0(model, confidenceLevel)
% Estimates standard transformed Gibbs energies of formation for metabolites
%
% USAGE:
%
%    model = estimateDfGt0(model, confidenceLevel)
%
% INPUT:
%    model:              Model structure with following fields:
%
%                          * .S - `m x n` stoichiometric matrix.
%                          * .mets - `m x 1` array of metabolite identifiers.
%                          * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas
%                            for protons should be H.
%                          * .metCharges - `m x 1` array of metabolite charges.
%                          * .T - Temperature in Kelvin.
%                          * .cellCompartments - `c x 1` array of cell compartment identifiers.
%                          * .ph - `c x 1` array of compartment specific pH values.
%                          * .is - `c x 1` array of compartment specific ionic strength
%                            values in mol/L.
%                          * .chi - `c x 1` array of compartment specific electrical
%                            potential values in mV.
%                          * .metComps - `m x 1` cell array of compartment assignments for
%                            metabolites in `model.mets`. Compartment identifiers
%                            should be the same as in model.compartments.
%                          * .DfG0 - `m x 1` array of standard Gibbs energies of formation.
%                          * .pKa - `m x 1` structure array with metabolite pKa values.
%                          * .DfG0_Uncertainty - `m x 1` array of uncertainty in estimated standard
%                            Gibbs energies of formation. uf will be large for
%                            metabolites that are not covered by component contributions.
%
% OPTIONAL INPUT:
%    confidenceLevel:    {0.50, 0.70, (0.95), 0.99}. Confidence level for `DGft0`
%                        and `DrGt0` interval estimates. Default is 0.95,
%                        corresponding to 95% confidence intervals.
%
% OUTPUT:
%    model:              Model structure with following fields added:
%
%                          * .DfG0_pseudoisomers - Four column matrix with pseudoisomer standard Gibbs
%                            energies of formation in kJ/mol.
%
%                            * Column 1. Row index of pseudoisomer group in `model.S`.
%                            * Column 2. Standard Gibbs energy of formation.
%                            * Column 3. Number of hydrogen atoms.
%                            * Column 4. Charge.
%                          * .DfGt0 - Standard transformed Gibbs energies of formation in kJ/mol.
%                          * .DfGtMin - Lower bounds on transformed Gibbs energies of formation in kJ/mol.
%                          * .DfGtMax - Upper bounds on transformed Gibbs energies of formation in kJ/mol.
%
% .. Authors:
%       - Elad Noor, Nov. 2012
%       - Hulda SH, Nov. 2012, Added support for compartments with different pH
%         and I. Added adjustment to DrGt0 for transport across membranes.

if ~exist('confidenceLevel','var') || isempty(confidenceLevel) % Configure confidence level
   confidenceLevel = 0.95;
end
if ~isfield(model,'T')
    model.T= 310.15;
end
if ~isfield(model,'gasConstant')
    model.gasConstant=8.3144621e-3; % Gas constant in kJ/(K*mol)
end

% Configure model.compartments
model.compartments = reshape(model.compartments,length(model.compartments),1);
if ischar(model.compartments)
    model.compartments = strtrim(cellstr(model.compartments));
end
if isnumeric(model.compartments)
    model.compartments = strtrim(cellstr(num2str(model.compartments)));
end

rt=model.gasConstant*model.T;

%indices of protons
hBool = strcmp(model.metFormulas,'H');

% Estimate standard transformed Gibbs energies of formation
model.DfG0_pseudoisomers = [];
model.DfGt0 = zeros(length(model.mets), 1);
for i = 1:length(model.mets)
    if hBool(i) && 0
        disp(model.mets{i})
    end
    pH  = model.ph(strcmp(model.compartments,model.metComps{i}));
    I   = model.is(strcmp(model.compartments,model.metComps{i}));
    chi = model.chi(strcmp(model.compartments,model.metComps{i}));
    pseudoisomer = model.pseudoisomers(i);
    pseudoisomer.zs=double(pseudoisomer.zs);%TODO fix the propagation of int64

    %TODO - not sure about this code
    dG0s = cumsum(-[0, diag(pseudoisomer.pKas, 1)'] * model.gasConstant * model.T * log(10));
    dG0s = dG0s - dG0s(pseudoisomer.majorMSpH7) + model.DfG0(i);

    if 0
        %Elad and Hulda's Legendre transform

        % pseudoisomers     p x 3 matrix with a row for each of the p pseudoisomers
        %                   in the group, and the following columns:
        %                   1. Standard Gibbs energy of formation,
        %                   2. Number of hydrogen atoms,
        %                   3. Charge.
        pseudoisomers = [dG0s(:), pseudoisomer.nHs(:), pseudoisomer.zs(:)];
        model.DfG0_pseudoisomers = [model.DfG0_pseudoisomers; ...
            i * ones(size(pseudoisomers, 1), 1), ...
            pseudoisomers];
        tmp=Transform(pseudoisomers, pH, I, T);
        if isempty(tmp)
            warning([model.mets{i} ' has an empty transform, setting to NaN'])
            tmp=NaN;
        end
        model.DfGt0(i) = tmp;
    else
        %Ronan's translation of Alberty's Mathematica implementation of a Legendre transform
        if ~isfield(model, 'DfH0')
            dfH0=[];
        end
        dfG0=double(dG0s(:));
        zi=double(pseudoisomer.zs(:));
        nH=double(pseudoisomer.nHs(:));
        Legendre=1;
        LegendreCHI=1;

        %TODO - check what temp the component contribution estimates for
        pHr=pH;
        printLevel=0;

        [nMet,~]=size(model.S);
        if i==1
            DfGt0=zeros(nMet,1);
            DfHt0=zeros(nMet,1);
            aveHbound=ones(nMet,1)*NaN;
            aveZi=zeros(nMet,1);
        end
        [DfGt0(i,1),DfHt0(i,1),mf,aveHbound(i,1),aveZi(i,1),lambda,gpfnsp]=calcdGHT(dfG0,dfH0,zi,nH,pHr,I,model.T,chi,Legendre,LegendreCHI,printLevel);

        model.pseudoisomers(i).mf=mf;
        model.pseudoisomers(i).lambda=lambda;
        model.pseudoisomers(i).gpfnsp=gpfnsp;

        if i==nMet
            model.DfGt0=DfGt0;
            model.DfHt0=DfHt0;
            model.aveHbound=aveHbound;
            model.aveZi=aveZi;
        end
    end
end

DfGt0NaNBool=isnan(model.DfGt0);
if any(DfGt0NaNBool)
    error([int2str(nnz(DfGt0NaNBool)) ' DfGt0  are NaN']);
end

% Map confidence level to t-value
tValueMat = [0.50, 0;...
             0.70, 1.036;...
             0.95, 1.960;...
             0.99, 2.576];

tValue = tValueMat(tValueMat(:,1) == confidenceLevel,2);

if printLevel>0
    fprintf('%g\n',nnz(isnan(model.DfG0_Uncertainty))/length(model.DfG0_Uncertainty), ' of metabolites with NaN uncertainty in DfGt0')
end

% Special adjustment for protons
%boolean of proton indices
hBool = strcmp(model.metFormulas,'H');
%TODO - transformed Gibbs energy for each proton should be zero without
%this hack below
%TODO - uf should be zero for protons when it comes from component contribution method
model.DfG0_Uncertainty(hBool)=0;
if all(model.concMin(hBool)==model.concMax(hBool))
    RTlogxmin=rt*log(model.concMin);
    %RTlogxmax=gasConstant*T*log(model.concMax);
    model.DfGt0(hBool)=-RTlogxmin(hBool);
else
    error('minimium and maximum proton concentrations must be identical for each compartment')
end

% Calculate bounds on standard transformed Gibbs energies of formation
model.DfGt0Min = model.DfGt0 - tValue*model.DfG0_Uncertainty;
model.DfGt0Max = model.DfGt0 + tValue*model.DfG0_Uncertainty;

% Calculate bounds on transformed Gibbs energies of formation
model.DfGtMin = model.DfGt0Min + rt*log(model.concMin);
model.DfGtMax = model.DfGt0Max + rt*log(model.concMax);

%We choose the arithmetic mean of minimum and maximum concentration since logarithmic concentration is linear in Gibbs energy.
model.DfGtMean = model.DfGt0 + rt*log(geomean([model.concMin,model.concMax],2));

if ~(all(model.DfGtMin(hBool)==0) && all(model.DfGtMin(hBool)==0))
    error('Transformed Gibbs energy for each proton should be zero')
end
bool=isreal(model.DfG0_Uncertainty);
if ~isreal(model.DfG0_Uncertainty)
    model.mets(bool)
    error([int2str(nnz(~bool)) ' DfGt0 are complex numbers.']);
end

if any(isnan(model.DfGtMin))
    error([int2str(nnz(isnan(model.DfGtMin(model.SIntRxnBool)))) ' DfGtMin are NaN.']);
end

if any(isnan(model.DfGtMax))
    error([int2str(nnz(isnan(model.DfGtMax(model.SIntRxnBool)))) ' DfGtMax are NaN.']);
end

% % Estimate standard transformed reaction Gibbs energies
% St = model.S;
% hBool = strcmp(model.metFormulas,'H');
% St(hBool,:) = 0; % Set proton coefficients to 0
% model.DrGt0 = St' * model.DfGt0;
%
% % Adjust DrGt0 for transport across membranes
% fprintf('Assuming that only metabolite species in model.metFormulas are transported across membranes.\n');
%
% metCompartmentBool = strcmp(repmat(model.metComps,1,length(model.compartments)),repmat(model.compartments',length(model.metComps),1));
%
% model_nHs = zeros(size(model.mets));
% for i = 1:length(model.mets)
%     model_nHs(i) = numAtomsOfElementInFormula(model.metFormulas{i},'H');
% end
% deltaPH = model.S' * diag(model_nHs) * metCompartmentBool * -(gasConstant * T * log(10) * model.ph); % Adjustment due to compartmental differences in pH
%
% model_zs = double(model.metCharges);
% deltaCHI = model.S' * diag(model_zs) * metCompartmentBool * F * model.chi/1000; % Adjustment due to compartmental differences in electrical potential
% model.DrGt0 = model.DrGt0 + deltaPH + deltaCHI;

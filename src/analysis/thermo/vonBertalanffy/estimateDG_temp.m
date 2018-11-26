function model = estimateDG_temp(model)
% Estimates standard transformed Gibbs energies of formation for metabolites
%
% USAGE:
%
%    model = estimateDG_temp(model)
%
% INPUT:
%    model:    Model structure with following fields:
%
%                * .S - `m x n` stoichiometric matrix.
%                * .mets - `m x 1` array of metabolite identifiers.
%                * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas
%                  for protons should be 'H'.
%                * .metCharges - `m x 1` array of metabolite charges.
%                * .T - Temperature in Kelvin.
%                * .cellCompartments - `c x 1` array of cell compartment identifiers.
%                * .ph - `c x 1` array of compartment specific pH values.
%                * .is - `c x 1` array of compartment specific ionic strength
%                  values in mol/L.
%                * .chi - `c x 1` array of compartment specific electrical
%                  potential values in mV.
%                * .metComps - `m x 1` cell array of compartment assignments for
%                  metabolites in `model.mets`. Compartment identifiers
%                  should be the same as in `model.cellCompartments`.
%                * .DfG0 - `m x 1` array of standard Gibbs energies of formation.
%                * .pKa - `m x 1` structure array with metabolite pKa values.
%
% OUTPUT:
%    model:    Model structure with following fields added:
%
%                * .DfG0_pseudoisomers - Four column matrix with pseudoisomer standard Gibbs
%                  energies of formation in kJ/mol.
%
%                  * Column 1. Row index of pseudoisomer group in `model.S`.
%                  * Column 2. Standard Gibbs energy of formation.
%                  * Column 3. Number of hydrogen atoms.
%                  * Column 4. Charge.
%                * .DfGt0 - Standard transformed Gibbs energies of formation in kJ/mol.
%                * .DrGt0 - Standard transformed reaction Gibbs energy in kJ/mol.
%
% .. Authors:
%       - Elad Noor, Nov. 2012
%       - Hulda SH, Nov. 2012   Added support for compartments with different pH
%         and I. Added adjustment to DrGt0 for transport across membranes.
%
% .. model.DrG0 = model.S' * model.DfG0;
%    model.ur = sqrt(diag(model.S'*model.covf*model.S));
%    model.ur(model.ur >= 1e3) = 1e10; % Set large uncertainty in reaction energies to inf
%    model.ur(sum(model.S~=0)==1) = 1e10; % set uncertainty of exchange, demand and sink reactions to inf

model.cellCompartments = reshape(model.cellCompartments,length(model.cellCompartments),1); % Configure model.cellCompartments
if ischar(model.cellCompartments)
    model.cellCompartments = strtrim(cellstr(model.cellCompartments));
end
if isnumeric(model.cellCompartments)
    model.cellCompartments = strtrim(cellstr(num2str(model.cellCompartments)));
end

% Define constants
R = 8.3144621e-3; % Gas constant in kJ/(K*mol)
T = model.T; % Temperature in K
F = 96485.3365e-3; % Faraday constant in kC/mol

% Estimate standard transformed Gibbs energies of formation
model.DfG0_pseudoisomers = [];
model.DfGt0 = zeros(length(model.mets), 1);
for i = 1:length(model.mets)
    pH  = model.ph(strcmp(model.cellCompartments,model.metComps{i}));
    I   = model.is(strcmp(model.cellCompartments,model.metComps{i}));
    chi = model.chi(strcmp(model.cellCompartments,model.metComps{i}));

    if 1
        %Elad and Hulda's code
        diss = model.pKa(i);
        dG0s = cumsum(-[0, diag(diss.pKas, 1)'] * R * T * log(10));
        dG0s = dG0s - dG0s(diss.majorMSpH7) + model.DfG0(i);
        % pseudoisomers     p x 3 matrix with a row for each of the p pseudoisomers
        %                   in the group, and the following columns:
        %                   1. Standard Gibbs energy of formation,
        %                   2. Number of hydrogen atoms,
        %                   3. Charge.
        pseudoisomers = [dG0s(:), diss.nHs(:), diss.zs(:)];
        if any(isa(pseudoisomers,'int64'))
            model.pKa(i)
            disp(pseudoisomers)
            pseudoisomers=double(pseudoisomers);
            warning([model.mets{i} 'pKa data should not be in int64 format, converting to double.'])
        else
            pseudoisomers=double(pseudoisomers);
        end
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
        if ~isfield(model, 'DfH0')
            dfH0=[];
        end
        dfG0=dG0s(:);
        zi=diss.zs(:);
        nH=diss.nHs(:);
        Legendre=1;
        LegendreCHI=1;
        %Ronan's translation of Alberty's code
        %TODO - check what temp the component contribution estimates are
        %oupout at
        [dGf0,dHf0,mf,aveHbound,aveZi,lambda,gpfnsp]=calcdGHT(dfG0,dfH0,zi,nH,pHr,I,T,chi,Legendre,LegendreCHI);
        model.dGf0(i)=dGf0;
        model.dHf0(i)=dHf0;
        model.mf(i)=mf;
        model.aveHbound(i)=aveHbound;
        model.aveZi(i)=aveZi;
        model.lambda(i)=lambda;
        model.gpfnsp(i)=gpfnsp;
    end
end

%balance the protons in each reaction given the number of Hydrogens bound
%to each reactant calculated thermodynamically using assignThermoToModel.m
if 0 %TODO Jan 30th 2011 Balancing protons changes growth rate ~0.7 -> 1.1  Need to check
    fprintf('\n%s\n','...pHbalanceProtons');
    model=pHbalanceProtons(model,massImbalance); % Minor changes - Hulda
end

% Estimate standard transformed reaction Gibbs energies
St = model.S;
hBool = strcmp(model.metFormulas,'H');
St(hBool,:) = 0; % Set proton coefficients to 0
model.DrGt0 = St' * model.DfGt0;

% Adjust DrGt0 for transport across membranes
fprintf('Assuming that only metabolite species in model.metFormulas are transported across membranes.\n');

metCompartmentBool = strcmp(repmat(model.metComps,1,length(model.cellCompartments)),repmat(model.cellCompartments',length(model.metComps),1));

model_nHs = zeros(size(model.mets));
for i = 1:length(model.mets)
    model_nHs(i) = numAtomsOfElementInFormula(model.metFormulas{i},'H');
end
deltaPH = model.S' * diag(model_nHs) * metCompartmentBool * -(R * T * log(10) * model.ph); % Adjustment due to compartmental differences in pH

model_zs = double(model.metCharges);
deltaCHI = model.S' * diag(model_zs) * metCompartmentBool * F * model.chi/1000; % Adjustment due to compartmental differences in electrical potential
model.DrGt0 = model.DrGt0 + deltaPH + deltaCHI;

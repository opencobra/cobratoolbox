function model = estimateDfGt0(model)
% Estimate standard transformed Gibbs energies of formation for metabolites
% 
% model = estimateDGt0(model)
% 
% INPUTS
% model                 Model structure with following fields:
% .S                    m x n stoichiometric matrix.
% .mets                 m x 1 array of metabolite identifiers.
% .metFormulas          m x 1 cell array of metabolite formulas. Formulas
%                       for protons should be H.
% .metCharges           m x 1 array of metabolite charges.
% .T                    Temperature in Kelvin.
% .cellCompartments     c x 1 array of cell compartment identifiers.
% .ph                   c x 1 array of compartment specific pH values.
% .is                   c x 1 array of compartment specific ionic strength
%                       values in mol/L.
% .chi                  c x 1 array of compartment specific electrical
%                       potential values in mV.
% .metCompartments      m x 1 cell array of compartment assignments for
%                       metabolites in model.mets. Compartment identifiers
%                       should be the same as in model.cellCompartments.
% .DfG0                 m x 1 array of standard Gibbs energies of
%                       formation.
% .pKa                  m x 1 structure array with metabolite pKa values.
% 
% OUTPUTS
% model                 Model structure with following fields added:
% .DfG0_pseudoisomers   Four column matrix with pseudoisomer standard Gibbs
%                       energies of formation in kJ/mol.
%                       Column 1. Row index of pseudoisomer group in
%                       model.S.
%                       Column 2. Standard Gibbs energy of formation.
%                       Column 3. Number of hydrogen atoms.
%                       Column 4. Charge.
% .DfGt0                Standard transformed Gibbs energies of formation in
%                       kJ/mol.

% 
% Elad Noor, Nov. 2012
% Hulda SH, Nov. 2012   Added support for compartments with different pH
%                       and I. Added adjustment to DrGt0 for transport
%                       across membranes.

% Define constants
if ~isfield(model,'R')
    R = 8.3144621e-3; % Gas constant in kJ/(K*mol)
end
%Faraday Constant (kJ/mol)
F=96.48; %kJ/mol

if ~isfield(model,'T')
    T= 310.15;
else
    T = model.T; % Temperature in K
end

% Configure model.cellCompartments
model.cellCompartments = reshape(model.cellCompartments,length(model.cellCompartments),1);
if ischar(model.cellCompartments)
    model.cellCompartments = strtrim(cellstr(model.cellCompartments));
end
if isnumeric(model.cellCompartments)
    model.cellCompartments = strtrim(cellstr(num2str(model.cellCompartments)));
end

hBool = strcmp(model.metFormulas,'H');

% Estimate standard transformed Gibbs energies of formation
model.DfG0_pseudoisomers = [];
model.DfGt0 = zeros(length(model.mets), 1);
for i = 1:length(model.mets)
    if hBool(i)
        disp(model.mets{i})
    end
    pH  = model.ph(strcmp(model.cellCompartments,model.metCompartments{i}));
    I   = model.is(strcmp(model.cellCompartments,model.metCompartments{i}));
    chi = model.chi(strcmp(model.cellCompartments,model.metCompartments{i}));
    diss = model.pKa(i);
    diss.zs=double(diss.zs);%TODO fix the propagation of int64
    
    %TODO - not sure about this code
    dG0s = cumsum(-[0, diag(diss.pKas, 1)'] * R * T * log(10));
    dG0s = dG0s - dG0s(diss.majorMSpH7) + model.DfG0(i);
    
    if 0
        %Elad and Hulda's Legendre transform
        
        % pseudoisomers     p x 3 matrix with a row for each of the p pseudoisomers
        %                   in the group, and the following columns:
        %                   1. Standard Gibbs energy of formation,
        %                   2. Number of hydrogen atoms,
        %                   3. Charge.
        pseudoisomers = [dG0s(:), diss.nHs(:), double(diss.zs(:))];
        if any(isa(pseudoisomers,'int64'))
            model.pKa(i)
            disp(pseudoisomers)
            pseudoisomers=double(pseudoisomers);
            error([model.mets{i} 'pKa data should not be in int64 format, converting to double.'])
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
        %Ronan's translation of Alberty's Mathematica implementation of a Legendre transform
        if ~isfield(model, 'DfH0')
            dfH0=[];
        end
        dfG0=double(dG0s(:));
        zi=double(diss.zs(:));
        nH=double(diss.nHs(:));
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
        [DfGt0(i,1),DfHt0(i,1),mf,aveHbound(i,1),aveZi(i,1),lambda,gpfnsp]=calcdGHT(dfG0,dfH0,zi,nH,pHr,I,T,chi,Legendre,LegendreCHI,printLevel);
        
        pseudoisomers(i).mf=mf;
        pseudoisomers(i).lambda=lambda;
        pseudoisomers(i).gpfnsp=gpfnsp;
        
        if i==nMet
            model.DfGt0=DfGt0;
            model.DfHt0=DfHt0;
            model.aveHbound=aveHbound;
            model.aveZi=aveZi;
            model.pseudoisomer=pseudoisomers';
        end
    end
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
% metCompartmentBool = strcmp(repmat(model.metCompartments,1,length(model.cellCompartments)),repmat(model.cellCompartments',length(model.metCompartments),1));
% 
% model_nHs = zeros(size(model.mets));
% for i = 1:length(model.mets)
%     model_nHs(i) = numAtomsOfElementInFormula(model.metFormulas{i},'H');
% end
% deltaPH = model.S' * diag(model_nHs) * metCompartmentBool * -(R * T * log(10) * model.ph); % Adjustment due to compartmental differences in pH
% 
% model_zs = double(model.metCharges);
% deltaCHI = model.S' * diag(model_zs) * metCompartmentBool * F * model.chi/1000; % Adjustment due to compartmental differences in electrical potential
% model.DrGt0 = model.DrGt0 + deltaPH + deltaCHI;



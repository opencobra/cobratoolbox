% Creates DAS, a small toy network containing reactions from the dopamine
% synthesis pathway in Recon 2

mets = {'Phe' 'BH4' 'O2' 'Tyr' 'BH2' 'H2O' 'L-DOPA' 'H' 'DA' 'CO2' 'Formate'}'; % Metabolite identifiers
Recon2MetID = {'phe_L' 'thbpt' 'o2' 'tyr_L' 'dhbpt' 'h2o' '34dhphe' 'h' 'dopa' 'co2' 'for'}'; % Corresponding Recon 2 metabolite identifiers.
metFormulas = {'C9H11NO2' 'C9H15N5O3' 'O2' 'C9H11NO3' 'C9H13N5O3' 'H2O' 'C9H11NO4' 'H' 'C8H12NO2' 'CO2' 'CHO2'}'; % Metabolite formulas at physiological pH
metCharges = [0 0 0 0 0 0 0 1 1 0 -1]'; % Metabolite charges at physiological pH.
rxns = {'R1' 'R2' 'R3' 'R4' 'E2' 'E1' 'E3' 'E7' 'E4' 'E5' 'E6'}'; % Reaction identifiers
Recon2RxnID = {'r0399' 'TYR3MO2+THBPTYACAMDASE' '3HLYTCL' 'DHPR+FDH' 'EX_phe_L' 'EX_o2' 'EX_h2o' 'EX_h' 'EX_dopa' 'EX_co2' 'EX_for'}'; % Corresponding Recon 2 reaction identifiers. R2 and R4 are composite reactions.

% The stoichiometric matrix
S = [-1  0  0  0 -1  0  0  0  0  0  0;
     -1 -1  0  1  0  0  0  0  0  0  0;
     -1 -1  0  0  0 -1  0  0  0  0  0;
      1 -1  0  0  0  0  0  0  0  0  0;
      1  1  0 -1  0  0  0  0  0  0  0;
      1  1  0  0  0  0 -1  0  0  0  0;
      0  1 -1  0  0  0  0  0  0  0  0;
      0  0 -1 -1  0  0  0 -1  0  0  0;
      0  0  1  0  0  0  0  0 -1  0  0;
      0  0  1  1  0  0  0  0  0 -1  0;
      0  0  0 -1  0  0  0  0  0  0 -1];
  
% Flux bounds (defining reaction directionality)
lb = zeros(length(rxns),1);
lb([5 6 8 11]) = -1000; % Source reactions for metabolites

ub = 1000*ones(length(rxns),1);
ub([5 6 8 11]) = 0;

% Model structure
model.S = S;
model.mets = mets;
model.Recon2MetID = Recon2MetID;
model.metFormulas = metFormulas;
model.metCharges = metCharges;
model.rxns = rxns;
model.Recon2RxnId = Recon2RxnID;
model.lb = lb;
model.ub = ub;

save DAS.mat model
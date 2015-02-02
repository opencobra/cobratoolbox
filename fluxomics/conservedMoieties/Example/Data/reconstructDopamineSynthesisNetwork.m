% Creates DAS, a small toy network containing reactions from the dopamine
% synthesis pathway in Recon 2

mets = {'phe_L' 'thbpt' 'o2' 'tyr_L' 'dhbpt' 'h2o' '34dhphe' 'h' 'dopa' 'co2' 'for'}'; % Metabolite identifiers
rxns = {'R1' 'R2' 'R3' 'R4' 'EX_phe_L' 'EX_o2' 'EX_h2o' 'EX_h' 'EX_dopa' 'EX_co2' 'EX_for'}'; % Reaction identifiers
Recon2RxnId = {'r0399' 'TYR3MO2+THBPTYACAMDASE' '3HLYTCL' 'DHPR+FDH' 'EX_phe_L' 'EX_o2' 'EX_h2o' 'EX_h' 'EX_dopa' 'EX_co2' 'EX_for'}'; % Corresponding Recon 2 reaction identifiers. R2 and R4 are composite reactions.

% The stoichiometric matrix
S = [-1 0 0 0 -1 0 0 0 0 0 0;
    -1 -1 0 1 0 0 0 0 0 0 0;
    -1 -1 0 0 0 -1 0 0 0 0 0;
    1 -1 0 0 0 0 0 0 0 0 0;
    1 1 0 -1 0 0 0 0 0 0 0;
    1 1 0 0 0 0 -1 0 0 0 0;
    0 1 -1 0 0 0 0 0 0 0 0;
    0 0 -1 -1 0 0 0 -1 0 0 0;
    0 0 1 0 0 0 0 0 -1 0 0;
    0 0 1 1 0 0 0 0 0 -1 0;
    0 0 0 -1 0 0 0 0 0 0 -1];

% Flux bounds (defining reaction directionality)
lb = zeros(length(rxns),1);
lb([5 6 8 11]) = -1000;

ub = 1000*ones(length(rxns),1);
ub([5 6 8 11]) = 0;


intRxnBool = [true(4,1); false(7,1)]; % Indicates internal reactions

% Model structure
model.S = S;
model.mets = mets;
model.rxns = rxns;
model.Recon2RxnId = Recon2RxnId;
model.lb = lb;
model.ub = ub;
model.SIntRxnBool = intRxnBool;

save DAS.mat model
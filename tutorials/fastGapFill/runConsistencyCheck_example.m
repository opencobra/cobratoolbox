%% example to run the stoichiometric consistency check

%  initialize the COBRA toolbox
initCobraToolbox;

% load model
load iTZ479_v2.mat 

% perform stoichiometric consistency check
model = model_Thermotoga_v2;
printLevel = 0;
[inform,m,model]=checkStoichiometricConsistency(model,printLevel);
% if inform == 1 --> model is stoichiometrically consistent
% if inf rm == 0 --> model is stoichiometrically INconsistent
clear m

if inform == 0
    % print metabolites constributing to stoichiometric inconsistency
    MetIncons = model.mets(~model.SConsistentBool);
end


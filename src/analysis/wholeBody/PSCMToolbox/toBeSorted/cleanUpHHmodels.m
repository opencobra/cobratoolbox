% clean up model structures.
load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d

fields = {'check', 'checkName'};
    modelOrganAllCoupled = rmfield(modelOrganAllCoupled,fields);
modelOrganAllCoupled.metNames = [];
modelOrganAllCoupled.metFormulas = [];
modelOrganAllCoupled.metCharge = [];
modelOrganAllCoupled.rxnNotes = [];
modelOrganAllCoupled.rxnReferences = [];
modelOrganAllCoupled.rxnECNumbers = [];
modelOrganAllCoupled.grRulesNotes = modelOrganAllCoupled.grRulesNotes';
modelOrganAllCoupled.rxnNames{end+1} = 'Whole-body metabolic objective';
modelOrganAllCoupled.subSystems{end+1} = 'Exchange/demand reaction';
modelOrganAllCoupled.SetupInfo.HowToCite = 'Thiele et al., "When metabolism meets physiology: Harvey and Harvetta, submitted';
modelOrganAllCoupled.SetupInfo.version = '1.0';
modelOrganAllCoupled.SetupInfo.Info = 'For more information on reactions, metabolites, and genes, please refer to http://vmh.life.';
modelOrganAllCoupled.SetupInfo.Constraints = 'Average European Diet. Physiologically constrained';

save Harvey1_0 modelOrganAllCoupled

clear

% clean up model structures.
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d

fields = {'check', 'checkName'};
    modelOrganAllCoupled = rmfield(modelOrganAllCoupled,fields);
modelOrganAllCoupled.metNames = [];
modelOrganAllCoupled.metFormulas = [];
modelOrganAllCoupled.metCharge = [];
modelOrganAllCoupled.rxnNotes = [];
modelOrganAllCoupled.rxnReferences = [];
modelOrganAllCoupled.rxnECNumbers = [];
modelOrganAllCoupled.grRulesNotes = modelOrganAllCoupled.grRulesNotes';
modelOrganAllCoupled.rxnNames{end+1} = 'Whole-body metabolic objective';
modelOrganAllCoupled.subSystems{end+1} = 'Exchange/demand reaction';
modelOrganAllCoupled.SetupInfo.HowToCite = 'Thiele et al., "When metabolism meets physiology: Harvey and Harvetta, submitted';
modelOrganAllCoupled.SetupInfo.version = '1.0';
modelOrganAllCoupled.SetupInfo.Info = 'For more information on reactions, metabolites, and genes, please refer to http://vmh.life.';
modelOrganAllCoupled.SetupInfo.Constraints = 'Average European Diet. Physiologically constrained';

save Harvetta1_0 modelOrganAllCoupled
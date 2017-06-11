% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
%% driveModelBorgifier walks through the process of comparing and merging 
% models. It is not meant to be used as a function, rather as a guide.
% Please reference the manual and the help information in the individual 
% scripts for additional information.

%% Load and verify Cmodel. (The Compare Model).
% Load with regular COBRA function.
[fileName, pathname] = uigetfile('*.xml','Please select the model your want to compare.') ;
Cmodel = readCbModel([pathname fileName]); 

% Or alternatively with custom written script. 
Cmodel = readModel_xxxx(fileName);

% fix name of Cmodel
Cmodel.description = Cmodel.description(max(strfind(Cmodel.description, folderseparator))+1:end) ;
Cmodel.description = Cmodel.description(1:strfind(Cmodel.description, '.')-1) ;

% Verify model is ready for subsequent scripts. 
Cmodel = verifyModelMB(Cmodel);

% If model has SEED IDs, use the databases to fill in information.
if isunix
    rxnFileName = '/test/SEED_db/ModelSEED-reactions-db.csv'; 
    cpdFileName = '/test/SEED_db/ModelSEED-compounds-db.csv';
elseif ispc
    rxnFileName = '\test\SEED_db\ModelSEED-reactions-db.csv'; 
    cpdFileName = '\test\SEED_db\ModelSEED-compounds-db.csv';
end
Cmodel = addSEEDInfo(Cmodel,rxnFileName,cpdFileName); 
 
% Now is a good time to see if this model carries flux. OPTIONAL.
solverOkay = changeCobraSolver('glpk','LP'); 
CmodelSol = optimizeCbModel(Cmodel); 

%% Load Tmodel. (The Template Model). 
% Load a matlab workspace with a previously used Tmodel.
[fileName, pathname] = uigetfile('*.mat','Please select your Tmodel file.') ;
load([pathname fileName])  ;

% Or alternatively use any model as the template model.
[fileName, pathname] = uigetfile('*.xml','Please select a reference model as template.') ;

% Load with regular COBRA function.
Tmodel = readCbModel([pathname fileName]); 

% fix name of Tmodel
Tmodel.description = Tmodel.description(max(strfind(Tmodel.description, folderseparator))+1:end) ;
Tmodel.description = Tmodel.description(1:strfind(Tmodel.description, '.')-1) ;

% If Tmodel is just another model, verify it as well and convert it to a
% proper format for comparison. Also make sure it carries flux. 
if ~isfield(Tmodel,'Models')
    Tmodel = verifyModel(Tmodel);
    TmodelSol = optimizeCbModel(Tmodel); 
    Tmodel = buildTmodel(Tmodel); 
end

%% Compare models. 
% Score Cmodel against Tmodel. This can taken a few hours. 
[Cmodel,Tmodel,score,Stats] = compareCbModels(Cmodel,Tmodel);

%% Match models.
% Initial comparison and matching.
[rxnList, metList, Stats] = reactionCompare(Cmodel, Tmodel, score);

% OPTIONAL. Declare mets from Cmodel with comps not in Tmodel as new.
metList = newCompsNewMets(metList,Cmodel,Tmodel);

% Subsequent comparisons and matching. 
[rxnList,metList,Stats] = reactionCompare(Cmodel,Tmodel,score, ...
                                          rxnList,metList,Stats);

%% Double-check matching. 
% If you are unsure about the correctness of the matching you may want to 
% re-run this part a couple of times. After each round make sure to re-run
% the optimization of the weighting.

% Double-check 1: Among the reactions from Cmodel that were declared new, find 
% those ten that are the most likely to have a matching reaction and re-visit 
% them in reactionCompare.
newRxn = find(rxnList == 0) ;
newRxnScore = Stats.bestMatch(newRxn) ;
[~,newRxnScoreIdx] = sort(newRxnScore,'descend') ;
rxnList(newRxn(newRxnScoreIdx(1:10))) = -1 ;
Stats.bestMatch(newRxn(newRxnScoreIdx(1:10)))
[rxnList, metList, Stats] = reactionCompare(Cmodel,Tmodel,score,rxnList,metList,Stats) ;

% Double-check 2: Among the reactions from Cmodel that were paired with a reaction
% from Tmodel, find those ten that are the least likely to be correctly matched
% and re-visit them in reactionCompare.
newRxn = find(rxnList > 0) ;
newRxnScore = Stats.bestMatch(newRxn) ;
[~,newRxnScoreIdx] = sort(newRxnScore,'ascend') ;
rxnList(newRxn(newRxnScoreIdx(1:10))) = -1 ;
Stats.bestMatch(newRxn(newRxnScoreIdx(1:10)))
[rxnList, metList, Stats] = reactionCompare(Cmodel,Tmodel,score, rxnList, metList, Stats) ;

%% Merge models and test results.
[TmodelC,Cspawn,Stats] = mergeModels(Cmodel,Tmodel, ...
                                      rxnList,metList,Stats);

%% Extract a model. 
modelToExtract = 'iJO1366'; % Note this name must match the name in Tmodel.
Cspawn = readCbTmodel(modelToExtract, TmodelC); 

%% Write to SBML. 
% This version of writeCbModel does not write all the additional 
% information to the .xml.
fileName = '/test_output.xml';
writeCbModel(Cspawn,'sbml',fileName)

%% Test to see if model can be read back from SBML.
% Note that the readCbModel function doesn't deal with the extra fields if
% they are in the .xml
fileName = '/saves/testoutput.xml';
test = readCbModel(fileName);

%% Save new Tmodel as .mat file. 
Tmodel = TmodelC ;
if isunix
    save(['/Tmodel_' datestr(now,'yyyy.mm.dd') '.mat'], 'TmodelC')
elseif ispc
    save(['\Tmodel_' datestr(now,'yyyy.mm.dd') '.mat'], 'TmodelC')
end

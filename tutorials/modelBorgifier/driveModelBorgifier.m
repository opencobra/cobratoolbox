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
% Please reference the tutorial and the help information in the individual 
% scripts for additional information.

%% Load and verify Cmodel. (The Compare Model).
% Load with regular COBRA function.
Cmodel = readCbModel(['test' filesep 'models' filesep 'ecoli_core_model.mat'], ...
                     'modelDescription', 'Ecoli_core') ;

% Verify model is ready for subsequent scripts. 
Cmodel = verifyModelMB(Cmodel, 'Verbose');

%% Load Tmodel. (The Template Model). 
% Load a matlab workspace with a previously used Tmodel.
[fileName, pathname] = uigetfile('*.mat','Please select your Tmodel file.') ;
load([pathname fileName]) ;

% Or alternatively use any model as the template model.
[fileName, pathname] = uigetfile('*.xml','Please select a reference model as template.') ;

% Load with regular COBRA function.
Tmodel = readCbModel([pathname fileName]); 

% If Tmodel is just another model, verify it as well and convert it to a
% proper format for comparison. Also make sure it carries flux. 
if ~isfield(Tmodel,'Models')
    Tmodel = verifyModel(Tmodel);
    Tmodel = buildTmodel(Tmodel); 
end

%% Compare models. 
% Score Cmodel against Tmodel.
[Cmodel, Tmodel, score, Stats] = compareCbModels(Cmodel, Tmodel, 'Verbose');

%% Match models.
% Initial comparison and matching.
[rxnList, metList, Stats] = reactionCompare(Cmodel, Tmodel, score);

% OPTIONAL. Declare mets from Cmodel with comps not in Tmodel as new.
metList = newCompsNewMets(metList,Cmodel,Tmodel);

% Subsequent comparisons and matching. 
[rxnList, metList, Stats] = reactionCompare(Cmodel, Tmodel, score, ...
                                            rxnList, metList, Stats);

%% Merge models and test results.
[TmodelC, Cspawn, Stats] = mergeModels(Cmodel, Tmodel, ...
                                       rxnList, metList, Stats, 'Verbose');

%% Extract a model. 
modelToExtract = 'iIT341'; % Note this name must match the name in TmodelC.
Cspawn = readCbTmodel(modelToExtract, TmodelC, 'Verbose'); 


%% Save new Tmodel as .mat file. 
Tmodel = TmodelC ;
if isunix
    save(['/Tmodel_' datestr(now,'yyyy.mm.dd') '.mat'], 'TmodelC')
elseif ispc
    save(['\Tmodel_' datestr(now,'yyyy.mm.dd') '.mat'], 'TmodelC')
end

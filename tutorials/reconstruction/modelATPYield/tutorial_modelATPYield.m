%% Test physiologically relevant ATP yields from different carbon sources for a metabolic model 
% *Author(s): Ines Thiele, Ronan M. T. Fleming, LCSB, University of Luxembourg.*
% 
% *Reviewer(s): *
%% INTRODUCTION
% In this tutorial, we show how to compute the ATP yield from different carbon 
% sources under aerobic or anaerobic conditions. The theoretical values for the 
% corresponding ATP yields are also provided. The tutorial can be adapted for 
% Recon 3 derived condition- and cell-type specific models to test whether these 
% models are still able to produce physiologically relevant ATP yields.
%% EQUIPMENT SETUP
% If necessary, initialize the cobra toolbox with

% initCobraToolbox
%% 
% For solving linear programming problems in FBA analysis, certain solvers 
% are required:

changeCobraSolver ('glpk', 'all', 1);
%% 
% This tutorial can be run with <https://opencobra.github.io/cobratoolbox/latest/modules/solvers.html 
% glpk> package as linear programming solver, which does not require additional 
% installation and configuration. However, for the analysis of large models, such 
% as Recon 3, it is not recommended to use <https://opencobra.github.io/cobratoolbox/latest/modules/solvers.html 
% glpk> but rather industrial strength solvers, such as the <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% GUROBI> package. For detail information, refer to the solver<https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md  
% installation guide>.
%% PROCEDURE
% Before proceeding with the simulations, the path for the model needs to be 
% set up:

modelFileName = 'Recon2.0model.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);
tol = 1e-6;
%% 
% In this tutorial, the used model is the generic model of human metabolism, 
% Recon 3$$^1$ or  Recon2.0 model.
% 
% The metabolites structures and reactions are from the Virtual Metabolic 
% Human database (VMH, <http://vmh.life/ http://vmh.life>).
%% Harmonization of abbreviation usage
% First, we will harmonize different bracket types used in different model versions, 
% e.g., different version of the human metabolic reconstruction. 

model.rxns = regexprep(model.rxns, '\(', '\[');
model.rxns = regexprep(model.rxns, '\)', '\]');
model.mets = regexprep(model.mets, '\(', '\[');
model.mets = regexprep(model.mets, '\)', '\]');
%% 
% Recon 3 uses ATPSm4mi instead of <https://vmh.life/#human/all/ATPS4m ATPS4m> 
% as an abbreviation for the ATP synthetase:

model.rxns = regexprep(model.rxns, 'ATPS4mi', 'ATPS4m');
%% 
% Similarly, the glucose exchange reaction has been updated:

if length(strmatch('EX_glc[e]', model.rxns))>0
    model.rxns{find(ismember(model.rxns, 'EX_glc[e]'))} = 'EX_glc_D[e]';
end
%% 
% Add ATP hydrolysis reaction to the model. If the reaction exist already, 
% nothing will be added by the |rxnIDexists| variable will contain the index of 
% the reaction that is present in the model. In this case, we will rename the 
% reaction abbreviation to ensure that the tutorial works correctly.

[model, rxnIDexists] = addReaction(model, 'DM_atp_c_', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
if length(rxnIDexists) > 0
    model.rxns{rxnIDexists} = 'DM_atp_c_';  % rename reaction in case that it exists already
end
%% Close model
% Now, we will set the lower bound ('|model.lb|') of all exchange and sink (|siphon|) 
% reactions to ensure that only those metabolites that are supposed to be taken 
% up are indded supplied to the model.
% 
% First, we will find all reactions based on their abbreviation ('|model.rxns|')

modelClosed = model;
modelexchanges1 = strmatch('Ex_', modelClosed.rxns);
modelexchanges4 = strmatch('EX_', modelClosed.rxns);
modelexchanges2 = strmatch('DM_', modelClosed.rxns);
modelexchanges3 = strmatch('sink_', modelClosed.rxns);
%% 
% Grab also the biomass reaction(s) based on the reaction abbreviation.

BM= (find(~cellfun(@isempty,strfind(lower(modelClosed.mets), 'bioma'))));
%% 
% As these measures may not identify all exchange and sink reactions in 
% a model, depending on the used nomencalture, we will also grab all reactions 
% based on stoichiomettry. Here, we will identify all reactions that contain only 
% one non-zero entry in the |S| matrix (column).

selExc = (find(full((sum(abs(modelClosed.S)==1, 1)==1) & (sum(modelClosed.S~=0) == 1))))';
%% 
% We will now put all these identified reactions together into one variable 
% '|modelexchanges|' and set the lower bound for these reactions to 0.

modelexchanges = unique([modelexchanges1; modelexchanges2; modelexchanges3; modelexchanges4; selExc; BM]);
modelClosed.lb(find(ismember(modelClosed.rxns, modelClosed.rxns(modelexchanges))))=0;
%% 
% Also, set all upper bounds t 1000 (representing infinity). This may be 
% important if other constraints had been applied to the model, which may interfere 
% with the newly set lower bound of lb=0 for all exchange reactions. Note that 
% this may affect any constraints that had been applied, e.g., condition-specific 
% constraints based on measured uptake or secretion rates.

modelClosed.ub(selExc) = 1000; 
%% 
% Define the ATP hydrolysis reactioDefinen <https://vmh.life/#human/all/DM_atp_c 
% DM_atp_c> to  be the objective reaction, for which we will maximize for in the 
% following sections.

modelClosed = changeObjective(modelClosed, 'DM_atp_c_');
%% 
% Store the original closed model setup for consequent use in the variable 
% |modelClosedOri|.

modelClosedOri = modelClosed;
%% Test for ATP yield from different carbon sources
% Now, we re ready to thest for the different individual carbon sources under 
% aerobic and anaerobic conditions for their ATP yield. Therefore, we will provide 
% 1 mol/gdw/hr of a carbon source and maximize the flux through the <https://vmh.life/#human/all/DM_atp_c 
% DM_atp_c_>.
% 
% The results will be stored in the table  'Table_csources'. The table will 
% also contain the theoretical ATP yield, as given by$$^2$. The table also provides 
% the information of how much flux is going throught he ATP syntheatse. Note that 
% the computed flux distribution is not garantied to be unique, although we use 
% the option 'zero', which approximates the sparsest possible flux distribution 
% with an maximal ATP yield.
%% Carbon source: Glucose (VMH ID: <http://vmh.life/#metabolite/glc_D glc_D>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_glc_D[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_glc_D[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% build table
Table_csources{2, 1} = strcat(modelName, ': ATP yield');
Table_csources{3, 1} = strcat(modelName, ': ATPS4m yield');
Table_csources{4, 1} = 'Theoretical';
% fill in results
k = 2;
Table_csources{1, k} = 'glc - aerobic';

Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '31';

%% 
% For this carbon source (glucose), we will also print all reactions that 
% are non-zero in the sparse flux distribution and thus contribute to the maximale 
% ATP yield.

ReactionsInSparseSolution = modelClosed.rxns(find(FBA.x));
%% 
% We now initiate the next test and delete the variable 'FBA'.

k = k+1; clear FBA
%% Carbon source: Glucose (VMH ID: <http://vmh.life/#metabolite/glc_D glc_D>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max');
% fill in results
Table_csources{1, k} = 'glc - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x)>=0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4, k} = '2';
k = k+1; clear FBA
%% Carbon source: Glutamine (VMH ID: <http://vmh.life/#metabolite/gln_L gln_L>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_gln_L[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_gln_L[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% fill in results
Table_csources{1, k} = 'gln_L - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) >= 0
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = 'NA';
k = k+1; clear FBA
%% Carbon source: Glutamine (VMH ID: <http://vmh.life/#metabolite/gln_L gln_L>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_gln_L[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_gln_L[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% fill in results
Table_csources{1, k} = 'gln_L - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) >= 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = 'NA';
k = k+1; clear FBA

%% Carbon source: Fructose (VMH ID: <http://vmh.life/#metabolite/fru fru>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_fru[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_fru[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% fill in results
Table_csources{1, k} = 'fru - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x)>=0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3 ,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '31';
k = k+1; clear FBA
%% Carbon source: Fructose (VMH ID: <http://vmh.life/#metabolite/fru fru>), Oxygen: No

modelClosed = changeObjective(modelClosed, 'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_fru[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_fru[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% fill in results
Table_csources{1, k} = 'fru - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x)>=0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '2';
k = k+1; clear FBA
%% Carbon source: Butyrate (VMH ID: <http://vmh.life/#metabolite/but but>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_but[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_but[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
% fill in results
Table_csources{1, k} = 'but - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) >= 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '21.5';
k = k+1; clear FBA
%% Carbon source: Butyrate (VMH ID: <http://vmh.life/#metabolite/but but>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_but[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_but[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'but - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Caproic acid (VMH ID: <http://vmh.life/#metabolite/caproic caproic>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_caproic[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_caproic[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'caproic - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '35.25';
k = k+1; clear FBA
%% Carbon source: Caproic acid (VMH ID: <http://vmh.life/#metabolite/caproic caproic>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_caproic[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_caproic[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'caproic - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Octanoate (VMH ID: <http://vmh.life/#metabolite/octa octa>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_octa[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_octa[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'octa - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '49';
k = k+1; clear FBA

%% Carbon source: Octanoate (VMH ID: <http://vmh.life/#metabolite/octa octa>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, modelClosed.rxns(modelexchanges)))) = 0;
modelClosed.c = zeros(length(modelClosed.rxns), 1);
modelClosed = changeObjective(modelClosed, 'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_octa[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_octa[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'octa - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Decanoate (VMH ID: <http://vmh.life/#metabolite/dca dca>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, modelClosed.rxns(modelexchanges))))=0;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed, 'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_dca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_dca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'dca - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '62.75';
k = k+1; clear FBA
%% Carbon source: Decanoate (VMH ID: <http://vmh.life/#metabolite/dca dca>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_dca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_dca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');

Table_csources{1, k} = 'dca - anaerobic';
% fill in only when the LP problem was feasible
Table_csources(2, k) = num2cell(FBA.f);
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA

%% Carbon source: Laureate (VMH ID: <http://vmh.life/#metabolite/ddca ddca>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.c = zeros(length(modelClosed.rxns), 1);
modelClosed = changeObjective(modelClosed, 'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ddca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ddca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ddca - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '76.5';
k = k+1; clear FBA
%% Carbon source: Laureate (VMH ID: <http://vmh.life/#metabolite/ddca ddca>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ddca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ddca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ddca - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x)>0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
k = k+1; clear FBA
%% Carbon source: Tetradecanoate (VMH ID: <http://vmh.life/#metabolite/ttdca ttdca>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ttdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ttdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ttdca - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '90.25';
k = k+1; clear FBA
%% Carbon source: Tetradecanoate (VMH ID: <http://vmh.life/#metabolite/ttdca ttdca>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ttdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ttdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ttdca - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x)>0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Hexadecanoate (VMH ID: <http://vmh.life/#metabolite/hdca hdca>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_hdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_hdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'hdca - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '104';
k = k+1; clear FBA
%% Carbon source: Hexadecanoate (VMH ID: <http://vmh.life/#metabolite/hdca hdca>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_hdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_hdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'hdca - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Octadecanoate (VMH ID: <http://vmh.life/#metabolite/ocdca ocdca>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ocdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ocdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ocdca - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '117.75';
k = k+1; clear FBA
%% Carbon source: Octadecanoate (VMH ID: <http://vmh.life/#metabolite/ocdca ocdca>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_ocdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_ocdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'ocdca - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Arachidate (VMH ID: <http://vmh.life/#metabolite/arach arach>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_arach[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_arach[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'arach - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '131.5';
k = k+1; clear FBA
%% Carbon source: Arachidate (VMH ID: <http://vmh.life/#metabolite/arach arach>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_arach[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_arach[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'arach - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end

Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Behenic acid (VMH ID: <http://vmh.life/#metabolite/docosac docosac>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_docosac[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_docosac[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'docosac - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '145.25';
k = k+1; clear FBA
%% Carbon source: Behenic acid (VMH ID: <http://vmh.life/#metabolite/docosac docosac>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_docosac[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_docosac[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'docosac - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Lignocerate (VMH ID: <http://vmh.life/#metabolite/lgnc lgnc>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_lgnc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_lgnc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'lgnc - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3 ,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '159';
k = k+1; clear FBA
%% Carbon source: Lignocerate (VMH ID: <http://vmh.life/#metabolite/lgnc lgnc>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_lgnc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_lgnc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'lgnc - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA
%% Carbon source: Cerotate (VMH ID: <http://vmh.life/#metabolite/hexc hexc>), Oxygen: Yes

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_hexc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_hexc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'hexc - aerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3, k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '172.75';
k = k+1; clear FBA
%% Carbon source: Cerotate (VMH ID: <http://vmh.life/#metabolite/hexc hexc>), Oxygen: No

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns, 'EX_hexc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns, 'EX_hexc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed, 'max');
Table_csources{1, k} = 'hexc - anaerobic';
Table_csources(2, k) = num2cell(FBA.f);
% fill in only when the LP problem was feasible
if length(FBA.x) > 0
    % set all flux values less than tol to 0
    FBA.x(find(abs(FBA.x)<=tol)) = 0;
    Table_csources(3 ,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns, 'ATPS4m'))));
end
Table_csources{4, k} = '0';
k = k+1; clear FBA

%% The table contains all computed ATP yields.

Table_csources = Table_csources'
%% TIMING
% This tutorial takes only a few minutes.
%% REFERENCES
%  [1] Brunk, E. et al. Recon 3D: A Three-Dimensional View of Human Metabolism 
% and Disease. Submited
% 
%
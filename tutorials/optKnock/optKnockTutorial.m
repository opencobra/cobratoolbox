function optKnockTutorial
%% DESCRIPTION
% This script shows 6 examples for using optKnock based on the paper
% Burgard, A. P., Pharkya, P. & Maranas, C. D. (2003). OptKnock: A Bilevel
% Programming Framework for Identifying Gene Knockout Strategies for
% Microbial Strain Optimization. Biotechnology and Bioengineering, 84(6),
% 647�657. http://doi.org/10.1002/bit.10803.
%
% Examples for optimice the production of succinate and D-lactate are shown
% in section I and II, respectively
%
% Author: Sebasti�n Mendoza. 27/07/2016. snmendoz@uc.cl
%

%% CODE

global TUTORIAL_INIT_CB;
global CBT_MILP_SOLVER;
if ~isempty(TUTORIAL_INIT_CB) && TUTORIAL_INIT_CB == 1
    initCobraToolbox
    changeCobraSolver('gurobi', 'all');
end
if isempty(CBT_MILP_SOLVER)
    changeCobraSolver('gurobi', 'all');
    CBT_MILP_SOLVER = 'gurobi';
end

fullPath = which('optKnockTutorial');
folder = fileparts(fullPath);
currectDirectory = pwd;
cd(folder);

% loading iJO1366
threshold = 5;
load('iJO1366')
model = iJO1366;
biomass = 'BIOMASS_Ec_iJO1366_core_53p95M';

% prespecified amount of glucose uptake 10 mmol/grDW*hr
model = changeRxnBounds(model, 'EX_glc__D_e', -10, 'b');

% Unconstrained uptake routes for inorganic phosphate, sulfate and
% ammonia
model = changeRxnBounds(model, 'EX_o2_e', 0, 'l');
model = changeRxnBounds(model, 'EX_pi_e', -1000, 'l');
model = changeRxnBounds(model, 'EX_so4_e', -1000, 'l');
model = changeRxnBounds(model, 'EX_nh4_e', -1000, 'l');

% The optimization step could opt for or against the phosphotransferase
% system, glucokinase, or both mechanisms for the uptake of glucose

model = changeRxnBounds(model, 'GLCabcpp', -1000, 'l');
model = changeRxnBounds(model, 'GLCptspp', -1000, 'l');
model = changeRxnBounds(model, 'GLCabcpp', 1000, 'u');
model = changeRxnBounds(model, 'GLCptspp', 1000, 'u');
model = changeRxnBounds(model, 'GLCt2pp', 0, 'b');

% Secretion routes  for acetate, carbon dioxide, ethanol, formate, lactate
% and succinate are enabled
model = changeRxnBounds(model, 'EX_ac_e', 1000, 'u');
model = changeRxnBounds(model, 'EX_co2_e', 1000, 'u');
model = changeRxnBounds(model, 'EX_etoh_e', 1000, 'u');
model = changeRxnBounds(model, 'EX_for_e', 1000, 'u');
model = changeRxnBounds(model, 'EX_lac__D_e', 1000, 'u');
model = changeRxnBounds(model, 'EX_succ_e', 1000, 'u');

%% WILD-TYPE

% determine succinate production and growth rate before optimizacion
fbaWT = optimizeCbModel(model);
% EscribirSolucionEnExcel(model,fbaWT.x, 'ColiOptKnock', '', 0); % sacar despu�s
succFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_succ_e'));
etohFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_etoh_e'));
formFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_for_e'));
lactFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_lac__D_e'));
acetFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_ac_e'));
growthRateWT = fbaWT.f;
fprintf('The production of succinate before optimization is %.1f \n', succFluxWT);
fprintf('The growth rate before optimization is %.1f \n', growthRateWT);
fprintf('The production of other products such as ethanol, formate, lactate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxWT, formFluxWT, lactFluxWT, acetFluxWT);

%% OPTKNOCK SETTING

% use prespecified reactions. run time ~1 minute
selectedRxnList = {'GLCabcpp'; 'GLCptspp'; 'HEX1'; 'PGI'; 'PFK'; 'FBA'; 'TPI'; 'GAPD'; 'PGK'; 'PGM'; 'ENO'; 'PYK'; 'LDH_D'; 'PFL'; 'ALCD2x'; 'PTAr'; 'ACKr'; 'G6PDH2r'; 'PGL'; 'GND'; 'RPI'; 'RPE'; 'TKT1'; 'TALA'; 'TKT2'; 'FUM'; 'FRD2'; 'SUCOAS'; 'AKGDH'; 'ACONTa'; 'ACONTb'; 'ICDHyr'; 'CS'; 'MDH'; 'MDH2'; 'MDH3'; 'ACALD'};

%% I) SUCCINATE OVERPRODUCTION

fprintf('\n...EXAMPLE 1: Finding optKnock sets of large 2 or less...\n\n')

% EXAMPLE 1: finding optKnock reactions sets of large 2
% Set optKnock options
% The exchange of succinate will be the objective of the outer problem
options = struct('targetRxn', 'EX_succ_e', 'numDel', 2);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
previousSolutions = cell(10,1);
contPreviousSolutions = 1;
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...\n')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model,selectedRxnList,options,constrOpt,previousSolutions,1);
    end
    
    % determine succinate production and growth rate after optimizacion
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, 'BIOMASS_Ec_iJO1366_core_53p95M'));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of succinate after optimization is %.2f \n', succFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, lactate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, lactFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_succ_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
        fprintf('The maximun and minimun production of succinate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        if strcmp(type, 'growth coupled')
            singleProductionEnvelope(model, setM1, 'EX_succ_e',  biomass, 'savePlot',  1, 'fileName',  ['succ_ex1_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
        end, 
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end

fprintf('\n...EXAMPLE 2: Finding optKnock sets of large 3...\n\n')

% EXAMPLE 2: finding optKnock reactions sets of large 3
% Set optKnock options
% The exchange of succinate will be the objective of the outer problem
options = struct('targetRxn', 'EX_succ_e', 'numDel', 3);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions);
    end
    
    % determine succinate production and growth rate after optimizacion
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, biomass));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of succinate after optimization is %.2f \n', succFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, lactate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, lactFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_succ_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
        fprintf('The maximun and minimun production of succinate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        if strcmp(type, 'growth coupled')
            singleProductionEnvelope(model, setM1, 'EX_succ_e',  biomass, 'savePlot',  1, 'fileName',  ['succ_ex2_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
        end
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end



% EXAMPLE 3: finding optKnock reactions sets of large 4
fprintf('\n...EXAMPLE 3: Finding optKnock sets of large 4...\n\n')
% Set optKnock options
% The exchange of succinate will be the objective of the outer problem
options = struct('targetRxn', 'EX_succ_e', 'numDel', 10);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions);
    end
    
    % determine succinate production and growth rate after optimizacion
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, biomass));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of succinate after optimization is %.2f \n', succFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, lactate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, lactFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_succ_e');
        fprintf('The solution is of type: %s\n', type);
        if strcmp(type, 'growth coupled')
            fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
            fprintf('The maximun and minimun production of succinate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
            singleProductionEnvelope(model, setM1, 'EX_succ_e',  biomass, 'savePlot',  1, 'fileName',  ['succ_ex3_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
        end
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end

%% II) LACTATE OVERPRODUCTION

% EXAMPLE 1: finding optKnock reactions sets of large 3

fprintf('\n...EXAMPLE 1: Finding optKnock sets of large 3...\n\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options = struct('targetRxn', 'EX_lac__D_e', 'numDel', 3);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
previousSolutions = cell(100,1);
contPreviousSolutions = 1;
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions);
    end
    
    % determine lactate production and growth rate after optimizacion
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, biomass));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n', lactFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, succFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_lac__D_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
        fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        singleProductionEnvelope(model, setM1, 'EX_lac__D_e',  biomass, 'savePlot',  1, 'fileName',  ['lact_ex1_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end

% EXAMPLE 2: finding optKnock reactions sets of large 4
fprintf('\n...EXAMPLE 2: Finding optKnock sets of large 4...\n\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options = struct('targetRxn', 'EX_lac__D_e', 'numDel', 4);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions);
    end
    
    % determine lactate production and growth rate after optimizacion
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, biomass));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n', lactFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, succFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_lac__D_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
        fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        singleProductionEnvelope(model, setM1, 'EX_lac__D_e',  biomass, 'savePlot',  1, 'fileName',  ['lact_ex2_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end

% EXAMPLE 3: finding optKnock reactions sets of large 6
fprintf('...EXAMPLE 3: Finding optKnock sets of large 6...\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options = struct('targetRxn', 'EX_lac__D_e', 'numDel', 6);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions);
    end
    
    % determine lactate production and growth rate after optimizacion
    lactFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_lac__D_e'));
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns, biomass));
    etohFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_etoh_e'));
    formFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_for_e'));
    succFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_succ_e'));
    acetFluxM1 = optKnockSol.fluxes(strcmp(model.rxns, 'EX_ac_e'));
    setM1 = optKnockSol.rxnList;
    
    if ~isempty(setM1)
        previousSolutions{contPreviousSolutions} = setM1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ', length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s ', setM1{j});
            elseif j == length(setM1)
                fprintf('and %s', setM1{j});
            else
                fprintf(',  %s ', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n', lactFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n', etohFluxM1, formFluxM1, succFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_lac__D_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n',  maxGrowth);
        fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        singleProductionEnvelope(model, setM1, 'EX_lac__D_e',  biomass, 'savePlot',  1, 'fileName',  ['lact_ex3_' num2str(nIter)], 'outputFolder',  'OptKnockResults');
    else
        if nIter == 1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter = nIter + 1;
end

cd(currectDirectory);
end
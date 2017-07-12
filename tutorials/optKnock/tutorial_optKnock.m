%% OptKnock Tutorial
%% Author: Sebastián N. Mendoza,  Center for Mathematical Modeling, University of Chile. snmendoz@uc.cl
%% *Reviewer(s): Thomas Pfau, Sylvian Arreckx, Laurent Heirendt, Ronan Fleming, John Sauls*
%% *INTRODUCTION:*
% In this tutorial we will run optKnock. For a detailed description of the procedure, 
% please see [1]. Briefly, the problem is to find a set of reactions of size "numDel" 
% such that when these reactions are deleted from the network, the mutant created 
% will produce a particular target of interest in a higher rate than the wild-type 
% strain. 
% 
% For example, imagine that we would like to increase the production of succinate 
% or lactate in Escherichia coli. Which are the knock-outs needed to increase 
% the production of these products? We will approach these problems in this tutorial.
%% MATERIALS
%% EQUIPMENT
% # MATLAB
% # A solver for Mixed Integer Linear Programming (MILP) problems. For example, 
% Gurobi.
%% *EQUIPMENT SETUP*
% Use changeCobraSolver to choose the solver for MILP problems. 
%% PROCEDURE
% The proceduce consists on the following steps
% 
% 1) Define contraints.
% 
% 2) Define a set of reactions to search knockouts. Only reactions in this 
% set will be deleted. 
% 
% 3) Define the number of reactions to be deleted, the target reaction and 
% some constraints to be accomplish.
% 
% 4) Run optKnock. 
% 
% *TIMING: *This task should take from a few seconds to a few hours depending 
% on the size of your reconstruction.
% 
% We verify that cobratoolbox has been initialized and that the solver has 
% been set.

global TUTORIAL_INIT_CB;
if ~isempty(TUTORIAL_INIT_CB) && TUTORIAL_INIT_CB==1
    initCobraToolbox
end

changeCobraSolver('gurobi','all');
fullPath = which('tutorial_optKnock');
folder = fileparts(fullPath);
currectDirectory = pwd;
cd(folder);

%% 
% We load the model of E. coli [2].

model = readCbModel('iJO1366.mat')
biomass = 'BIOMASS_Ec_iJO1366_core_53p95M';
%% 
% We define the maximum number of solutions to find

threshold = 5;
%% 
% First, we define the set for reactions which could be deleted from the 
% network. Reactions not in this list are not going to be deleted.

selectedRxnList = {'GLCabcpp'; 'GLCptspp'; 'HEX1'; 'PGI'; 'PFK'; 'FBA'; 'TPI'; 'GAPD'; ...
                   'PGK'; 'PGM'; 'ENO'; 'PYK'; 'LDH_D'; 'PFL'; 'ALCD2x'; 'PTAr'; 'ACKr'; ...
                   'G6PDH2r'; 'PGL'; 'GND'; 'RPI'; 'RPE'; 'TKT1'; 'TALA'; 'TKT2'; 'FUM'; ...
                   'FRD2'; 'SUCOAS'; 'AKGDH'; 'ACONTa'; 'ACONTb'; 'ICDHyr'; 'CS'; 'MDH'; ...
                   'MDH2'; 'MDH3'; 'ACALD'};

%% 
% Then, we define some constraints

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
%% 
% Then, we calculates the production of metabolites before running optKnock.

% determine succinate production and growth rate before optimizacion
fbaWT = optimizeCbModel(model);
succFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_succ_e'));
etohFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_etoh_e'));
formFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_for_e'));
lactFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_lac__D_e'));
acetFluxWT = fbaWT.x(strcmp(model.rxns, 'EX_ac_e'));
growthRateWT = fbaWT.f;
fprintf('The production of succinate before optimization is %.1f \n', succFluxWT);
fprintf('The growth rate before optimization is %.1f \n', growthRateWT);
fprintf(['The production of other products such as ethanol, formate, lactate and'...
         'acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n'], ...
        etohFluxWT, formFluxWT, lactFluxWT, acetFluxWT);
%% 
% *I) SUCCINATE OVERPRODUCTION*
% 
% *EXAMPLE 1:* *finding optKnock reactions sets of size 2 for increasing 
% production of succinate*

fprintf('\n...EXAMPLE 1: Finding optKnock sets of size 2 or less...\n\n')
% Set optKnock options
% The exchange of succinate will be the objective of the outer problem
options = struct('targetRxn', 'EX_succ_e', 'numDel', 2);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}},'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 2
previousSolutions = cell(10, 1);
contPreviousSolutions = 1;
nIter = 1;
while nIter < threshold
    fprintf('...Performing optKnock analysis...\n')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt);
    else
        optKnockSol = OptKnock(model, selectedRxnList, options, constrOpt, previousSolutions, 1);
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
                fprintf('%s', setM1{j});
            elseif j == length(setM1)
                fprintf(' and %s', setM1{j});
            else
                fprintf(', %s', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of succinate after optimization is %.2f \n', succFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf(['The production of other products such as ethanol, formate, lactate and acetate are' ...
                 '%.1f, %.1f, %.1f and %.1f, respectively. \n'], etohFluxM1, formFluxM1, lactFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_succ_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf(['The maximun and minimun production of succinate given the optKnock set is ' ...
                 '%.2f and %.2f, respectively \n\n'], minProd, maxProd);
        if strcmp(type, 'growth coupled')
            singleProductionEnvelope(model, setM1, 'EX_succ_e', biomass, 'savePlot', 1, 'showPlot', 1, ...
                                     'fileName', ['succ_ex1_' num2str(nIter)], 'outputFolder', 'OptKnockResults');
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


%% 
% *TROUBLESHOOTING 1*:  "The algorithm takes a long time to find a solution"
% 
% *TROUBLESHOOTING 2*:  "The algorithm finds a set of knockouts too big"
% 
% *TROUBLESHOOTING 3*:  "The algorithm found a solution that is not useful 
% for me"
% 
% *EXAMPLE 2:* *finding optKnock reactions sets of size 3 for increasing 
% production of succinate*

fprintf('\n...EXAMPLE 1: Finding optKnock sets of size 3...\n\n')
% Set optKnock options
% The exchange of succinate will be the objective of the outer problem
options = struct('targetRxn', 'EX_succ_e', 'numDel', 3);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 3
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
        contPreviousSolutions=contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ',length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s',setM1{j});
            elseif j == length(setM1)
                fprintf(' and %s',setM1{j});
            else
                fprintf(', %s',setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of succinate after optimization is %.2f \n', succFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf(['The production of other products such as ethanol, formate, lactate and acetate are ' ...
                 '%.1f, %.1f, %.1f and %.1f, respectively. \n'], etohFluxM1, formFluxM1, lactFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_succ_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf(['The maximun and minimun production of succinate given the optKnock set is ' ...
                 '%.2f and %.2f, respectively \n\n'], minProd, maxProd);
        if strcmp(type,'growth coupled')
            singleProductionEnvelope(model, setM1, 'EX_succ_e', biomass, 'savePlot', 1, 'showPlot', 1, ...
                                     'fileName', ['succ_ex2_' num2str(nIter)], 'outputFolder', 'OptKnockResults');
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

%% 
% *II) LACTATE OVERPRODUCTION*
% 
% *EXAMPLE 1: finding optKnock reactions sets of size 3 for increasing production 
% of lactate*

fprintf('\n...EXAMPLE 1: Finding optKnock sets of size 3...\n\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options = struct('targetRxn', 'EX_lac__D_e', 'numDel', 3);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt = struct('rxnList', {{biomass}}, 'values', 0.5*fbaWT.f, 'sense', 'G');
% We will try to find 10 optKnock sets of a maximun length of 6
previousSolutions = cell(100, 1);
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
        contPreviousSolutions=contPreviousSolutions + 1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ',length(setM1));
        for j = 1:length(setM1)
            if j == 1
                fprintf('%s', setM1{j});
            elseif j == length(setM1)
                fprintf(' and %s', setM1{j});
            else
                fprintf(', %s', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n', lactFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf(['The production of other products such as ethanol, formate, succinate and acetate are ' ...
                 '%.1f, %.1f, %.1f and %.1f, respectively. \n'], etohFluxM1, formFluxM1, succFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_lac__D_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf(['The maximun and minimun production of lactate given the optKnock set is ' ...
                 '%.2f and %.2f, respectively \n\n'], minProd, maxProd);
        singleProductionEnvelope(model, setM1, 'EX_lac__D_e', biomass, 'savePlot', 1, 'showPlot', 1, ...
                                 'fileName', ['lact_ex1_' num2str(nIter)], 'outputFolder', 'OptKnockResults');
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

%% 
% 
% 
% *EXAMPLE 2: finding optKnock reactions sets of size 6 for increasing production 
% of lactate*

fprintf('...EXAMPLE 3: Finding optKnock sets of size 6...\n')
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
    growthRateM1 = optKnockSol.fluxes(strcmp(model.rxns,biomass));
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
                fprintf('%s', setM1{j});
            elseif j == length(setM1)
                fprintf(' and %s', setM1{j});
            else
                fprintf(', %s', setM1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n', lactFluxM1);
        fprintf('The growth rate after optimization is %.2f \n', growthRateM1);
        fprintf(['The production of other products such as ethanol, formate, succinate and acetate are ' ...
                 '%.1f, %.1f, %.1f and %.1f, respectively. \n'], etohFluxM1, formFluxM1, succFluxM1, acetFluxM1);
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, setM1, 'EX_lac__D_e');
        fprintf('The solution is of type: %s\n', type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf(['The maximun and minimun production of lactate given the optKnock set is ' ...
                 '%.2f and %.2f, respectively \n\n'], minProd, maxProd);
        singleProductionEnvelope(model, setM1, 'EX_lac__D_e', biomass, 'savePlot', 1, 'showPlot', 1, ...
                                 'fileName', ['lact_ex2_' num2str(nIter)], 'outputFolder', 'OptKnockResults');
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
%% TIMING
% # Example 1 ~ 1-2 minutes
% # Example 2 ~ 1-2 minutes
% # Example 3 ~ 1-2 minutes
% # Example 4 ~ 1-2 minutes
% # Example 5 ~ 1-2 minutes
% # Example 6 ~ 1-2 minutes
%% TROUBLESHOOTING
% 1) If the algorithm takes a long time to find a solution, it is possible that 
% the seach space is too large. You can reduce the search space using a smaller 
% set of reactions in the input variable "selectedRxnList." 
% 
% 2) The default number of deletions used by optKnock is 5. If the algorithm 
% is returning more deletions than what you want, you can change the number of 
% deletions using the input variable "numDel."
% 
% 3) optKnock could find a solution that it is not useful for you. For example, 
% you may think that a solution is very obvious or that it breaks some important 
% biological contraints. If optKnock found a solution that you don't want to find, 
% use the input variable "prevSolutions" to prevent that solution to be found. 
%% ANTICIPATED RESULTS
% The optKnock algorithm will find sets of reactions that, when removed from 
% the model, will improve the production of succinate and lactate respectively. 
% In this tutorial, once optKnock finds a solution, then the type of solution 
% is determined (if the product is coupled with biomass formation or not). Some 
% of the sets will generate a coupled solution, i.e., the production rate will 
% increase as biomass formation increases. For these kind of reactions a plot 
% will be generated using the function singleProductionEnvelope and will be saved 
% in the folder tutoriales/optKnock/optKnockResults
% 
% When you find a solution with OptKnock, you should always verify the minumum 
% and maximum production rate using the function analizeOptKnock. 
%% References
% [1] Burgard, A. P., Pharkya, P. & Maranas, C. D. (2003). OptKnock: A Bilevel 
% Programming Framework for Identifying Gene Knockout Strategies for Microbial 
% Strain Optimization. Biotechnology and Bioengineering, 84(6), 647?657. http://doi.org/10.1002/bit.10803.
% 
% [2] Orth, J. D., Conrad, T. M., Na, J., Lerman, J. A., Nam, H., Feist, 
% A. M., & Palsson, B. Ø. (2011). A comprehensive genome?scale reconstruction 
% of Escherichia coli metabolism?2011. _Molecular systems biology_, _7_(1), 535.
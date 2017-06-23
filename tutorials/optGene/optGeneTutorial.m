function optGeneTutorial
%% DESCRIPTION
% This script shows 6 examples for using optGene. These examples are
% exposed on the paper Burgard, A. P., Pharkya, P. & Maranas, C. D. (2003).
% OptKnock: A Bilevel Programming Framework for Identifying Gene Knockout
% Strategies for Microbial Strain Optimization. Biotechnology and
% Bioengineering, 84(6), 647–657. http://doi.org/10.1002/bit.10803.
%
% Examples for optimice the production of succinate and D-lactate are shown
% in section I and II, respectively
%
% Author: Sebastián Mendoza. 20/11/2016. snmendoz@uc.cl
%
%% INPUTS

%% CODE
% loading iJO1366
global TUTORIAL_INIT_CB;
global CBT_LP_SOLVER;
if ~isempty(TUTORIAL_INIT_CB) && TUTORIAL_INIT_CB  ==  1
    initCobraToolbox
    changeCobraSolver('gurobi', 'all');
end
if isempty(CBT_LP_SOLVER)
    changeCobraSolver('gurobi', 'all');
    CBT_LP_SOLVER = 'gurobi';
end

fullPath = which ('tutorial_optGene.mlx');
folder = fileparts(fullPath);
cd(folder);

threshold = 3; 

load('iJO1366')
model = iJO1366;
biomass = 'BIOMASS_Ec_iJO1366_core_53p95M';

%SETTING SPECIFIC CONSTRAINTS
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

% FINDING RATES IN WILD-TYPE
% The follling rates are those calculated in the wild-type without any
% mutation.

% determine succinate production and growth rate before optimizacion
fbaWT = optimizeCbModel(model);
growthRateWT = fbaWT.f;

model = changeObjective(model, 'EX_succ_e'); 
fbaWTMin = optimizeCbModel(model, 'min');
fbaWTMax = optimizeCbModel(model, 'max');
minSuccFluxWT = fbaWTMin.f;
maxSuccFluxWT = fbaWTMax.f;

model = changeObjective(model, biomass);

fprintf('The minimum and maximum production of succinate before optimization is %.1f and %.1f respectively\n', minSuccFluxWT, maxSuccFluxWT);
fprintf('The growth rate before optimization is %.2f \n', growthRateWT);

% OPTGENE SETTING
selectedGeneList = {};
% use prespecified reactions. Faster option
selectedRxnList = {'GLCabcpp'; 'GLCptspp'; 'HEX1'; 'PGI'; 'PFK'; 'FBA'; 'TPI'; 'GAPD'; 'PGK'; 'PGM'; 'ENO'; 'PYK'; 'LDH_D'; 'PFL'; 'ALCD2x'; 'PTAr'; 'ACKr'; 'G6PDH2r'; 'PGL'; 'GND'; 'RPI'; 'RPE'; 'TKT1'; 'TALA'; 'TKT2'; 'FUM'; 'FRD2'; 'SUCOAS'; 'AKGDH'; 'ACONTa'; 'ACONTb'; 'ICDHyr'; 'CS'; 'MDH'; 'MDH2'; 'MDH3'; 'ACALD'};
genesByReaction = regexp(regexprep(model.grRules(ismember(model.rxns, selectedRxnList)), '\or|and|\(|\)', ''), '\  ', 'split');
for i = 1:length(genesByReaction)
    selectedGeneList = union(selectedGeneList, genesByReaction{i});
end

%% I) SUCCINATE OVERPRODUCTION

% EXAMPLE 1: finding reaction knockouts sets of large 2 or less

fprintf('\n...EXAMPLE 1: Finding optGene sets\n\n')
previousSolutions = cell(10, 1);
contPreviousSolutions = 1;
nIter = 0;
while nIter < threshold
    fprintf('...Performing optGene analysis...\n')
    %optGene algorithm is run with the following options: target: 'EX_lac__D_e'
    [~, ~, ~, optGeneSol] = optGene(model, 'EX_succ_e', 'EX_glc__D_e', selectedGeneList, 'MaxKOs', 2, 'TimeLimit', 120, 'saveFile', 1);
    
    SET_M1 = optGeneSol.geneList;
    
    if ~isempty(SET_M1)
        previousSolutions{contPreviousSolutions} = SET_M1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optGene found a knockout set of large %d composed by ', length(SET_M1));
        for j = 1:length(SET_M1)
            if j == 1
                fprintf('%s ',SET_M1{j});
            elseif j == length(SET_M1)
                fprintf('and %s',SET_M1{j});
            else
                fprintf(', %s ',SET_M1{j});
            end
        end
        fprintf('\n');
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, optGeneSol.geneList, 'EX_succ_e', biomass, 1);
        fprintf('The solution is of type: %s\n',type);
        fprintf('The maximun growth rate after optimizacion is %.2f\n', maxGrowth);
        fprintf('The maximun and minimun production of succinate after optimization is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        
    else
        if nIter  ==  1
            fprintf('optGene was not able to found an optGene set\n');
        else
            fprintf('optGene was not able to found additional optGene sets\n');
        end
        break;
    end
    nIter = nIter + 1;
    
end

fprintf('\n...EXAMPLE 2: Finding optGene sets\n\n')
previousSolutions = cell(10, 1);
contPreviousSolutions = 1;
nIter = 0;
while nIter < threshold
    fprintf('...Performing optGene analysis...\n')
    %optGene algorithm is run with the following options: target: 'EX_lac__D_e'
    [~, ~, ~, optGeneSol] = optGene(model, 'EX_succ_e', 'EX_glc__D_e', selectedGeneList, 'MaxKOs', 2, 'Generations', 20);
    
    SET_M1 = optGeneSol.geneList;
    
    if ~isempty(SET_M1)
        previousSolutions{contPreviousSolutions} = SET_M1;
        contPreviousSolutions = contPreviousSolutions + 1;
        %printing results
        fprintf('optGene found a knockout set of large %d composed by ', length(SET_M1));
        for j = 1:length(SET_M1)
            if j == 1
                fprintf('%s ',SET_M1{j});
            elseif j == length(SET_M1)
                fprintf('and %s',SET_M1{j});
            else
                fprintf(', %s ',SET_M1{j});
            end
        end
        fprintf('\n');
        fprintf('...Performing coupling analysis...\n');
        [type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model, optGeneSol.geneList, 'EX_succ_e', biomass, 1);
        fprintf('The solution is of type: %s\n',type);
        fprintf('The maximun growth rate after optimizacion is %.2f\n', maxGrowth);
        fprintf('The maximun and minimun production of succinate after optimization is %.2f and %.2f, respectively \n\n', minProd, maxProd);
        
    else
        if nIter  ==  1
            fprintf('optGene was not able to found an optGene set\n');
        else
            fprintf('optGene was not able to found additional optGene sets\n');
        end
        break;
    end
    nIter = nIter + 1;
    
end


end
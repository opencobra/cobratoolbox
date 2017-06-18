function optGeneTutorial(mode,threshold)
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
if nargin<1
    mode=1;
end
if nargin<2;
    threshold=20;
end

load('iJO1366')
model=iJO1366;

biomass='BIOMASS_Ec_iJO1366_core_53p95M';

%SETTING SPECIFIC CONSTRAINTS
% prespecified amount of glucose uptake 10 mmol/grDW*hr
model=changeRxnBounds(model,'EX_glc__D_e',-10,'b');

% Unconstrained uptake routes for inorganic phosphate, sulfate and
% ammonia
model=changeRxnBounds(model,'EX_o2_e',0,'l');
model=changeRxnBounds(model,'EX_pi_e',-1000,'l');
model=changeRxnBounds(model,'EX_so4_e',-1000,'l');
model=changeRxnBounds(model,'EX_nh4_e',-1000,'l');

% The optimization step could opt for or against the phosphotransferase
% system, glucokinase, or both mechanisms for the uptake of glucose
model=changeRxnBounds(model,'GLCabcpp',-1000,'l');
model=changeRxnBounds(model,'GLCptspp',-1000,'l');
model=changeRxnBounds(model,'GLCabcpp',1000,'u');
model=changeRxnBounds(model,'GLCptspp',1000,'u');
model=changeRxnBounds(model,'GLCt2pp',0,'b');

% Secretion routes  for acetate, carbon dioxide, ethanol, formate, lactate
% and succinate are enabled
model=changeRxnBounds(model,'EX_ac_e',1000,'u');
model=changeRxnBounds(model,'EX_co2_e',1000,'u');
model=changeRxnBounds(model,'EX_etoh_e',1000,'u');
model=changeRxnBounds(model,'EX_for_e',1000,'u');
model=changeRxnBounds(model,'EX_lac__D_e',1000,'u');
model=changeRxnBounds(model,'EX_succ_e',1000,'u');

% FINDING RATES IN WILD-TYPE
% The follling rates are those calculated in the wild-type without any
% mutation. 

% determine succinate production and growth rate before optimizacion
FBA_WT=optimizeCbModel(model);
SUCC_FLUX_WT=FBA_WT.x(strcmp(model.rxns,'EX_succ_e'));
ETOH_FLUX_WT=FBA_WT.x(strcmp(model.rxns,'EX_etoh_e'));
FORM_FLUX_WT=FBA_WT.x(strcmp(model.rxns,'EX_for_e'));
LACT_FLUX_WT=FBA_WT.x(strcmp(model.rxns,'EX_lac__D_e'));
ACET_FLUX_WT=FBA_WT.x(strcmp(model.rxns,'EX_ac_e'));
BIOMASS_WT=FBA_WT.f;
fprintf('The production of succinate before optimization is %.1f \n',SUCC_FLUX_WT);
fprintf('The growth rate before optimization is %.1f \n',BIOMASS_WT);
fprintf('The production of other products such as ethanol, formate, lactate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n',ETOH_FLUX_WT,FORM_FLUX_WT,LACT_FLUX_WT,ACET_FLUX_WT);

% OPTGENE SETTING
selectedGeneList={};
switch mode
    case 1
        % use prespecified reactions. Faster option
        selectedRxnList={'GLCabcpp';'GLCptspp';'HEX1';'PGI';'PFK';'FBA';'TPI';'GAPD';'PGK';'PGM';'ENO';'PYK';'LDH_D';'PFL';'ALCD2x';'PTAr';'ACKr';'G6PDH2r';'PGL';'GND';'RPI';'RPE';'TKT1';'TALA';'TKT2';'FUM';'FRD2';'SUCOAS';'AKGDH';'ACONTa';'ACONTb';'ICDHyr';'CS';'MDH';'MDH2';'MDH3';'ACALD'};
    case 2
        % restrict reactions for optKnock only for those occurring in
        % cytosol. More Comprehensive option
        [~,pos_reactionsNotInCytosol]=find(model.S(ismember(model.mets,union(model.mets(cellfun(@isempty,strfind(model.mets,'_p'))==0),model.mets(cellfun(@isempty,strfind(model.mets,'_e'))==0))),:));
        selectedRxnList=model.rxns(setdiff(1:length(model.rxns),pos_reactionsNotInCytosol));
end
genes_Involucrados_por_Rxn=regexp(regexprep(model.grRules(find(ismember(model.rxns,selectedRxnList))),'\or|and|\(|\)',''),'\  ','split');
for i=1:length(genes_Involucrados_por_Rxn); selectedGeneList=union(selectedGeneList,genes_Involucrados_por_Rxn{i}); end;

% OPTGENE PRE-PROCESSING
% It is recommended to verify consistency between bounds and logical
% indices of reversability.
nRxns=length(model.rxns);
for i = 1:nRxns
    % Check if reaction is declared as irreversible, but bounds suggest
    % reversible (i.e., having both positive and negative bounds
    if (model.ub(i) > 0 && model.lb(i) < 0) && model.rev(i) == false
        model.rev(i) = true;
        warning(cat(2,'Reaction: ',model.rxns{i},' is classified as irreversible, but bounds indicate reversible. Reversible flag changed to true'))
    end
end


%% I) LACTATE OVERPRODUCTION

% EXAMPLE 1: finding reaction knockouts sets of large 3

fprintf('\n...EXAMPLE 1: Finding optGene sets\n\n')
fprintf('...Performing optGene analysis...\n')
%optGene algorithm is run with the following options: target: 'EX_lac__D_e'
[x, population, scores, optGeneSol] = optGene(model, 'EX_succ_e', 'EX_glc__D_e', selectedGeneList, 2);

[type, maxGrowth, maxProd, minProd] = analyzeOptKnock(model,optGeneSol.geneList,'EX_succ_e','BIOMASS_Ec_iJO1366_core_53p95M',1);

SET_M1=optGeneSol.geneList;
contPreviousSolutions
if ~isempty(SET_M1)
    previousSolutions{contPreviousSolutions}=SET_M1;
    contPreviousSolutions=contPreviousSolutions+1;
    %printing results
    fprintf('optKnock found a optKnock set of large %d composed by ',length(SET_M1));
    for j=1:length(SET_M1)
        if j==1
            fprintf('%s ',SET_M1{j});
        elseif j==length(SET_M1)
            fprintf('and %s',SET_M1{j});
        else
            fprintf(', %s ',SET_M1{j});
        end
    end
    fprintf('\n');
    fprintf('The production of lactate after optimization is %.2f \n',LACT_FLUX_M1);
    fprintf('The growth rate after optimization is %.2f \n',BIOMASS_M1);
    fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n',ETOH_FLUX_M1,FORM_FLUX_M1,SUCC_FLUX_M1,ACET_FLUX_M1);
    fprintf('...Performing coupling analysis...\n');
    [type,maxGrowth,maxProd,minProd] = analyzeOptKnock(model,SET_M1,'EX_lac__D_e');
    fprintf('The solution is of type: %s\n',type);
    fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
    fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n',minProd,maxProd);
    singleProductionEnvelope(model,SET_M1,'EX_lac__D_e',biomass,['lact_ex1_' num2str(nIter)]);
else
    fprintf('optKnock was not able to found an optKnock set\n');
end

% EXAMPLE 2: finding optKnock reactions sets of large 4
fprintf('\n...EXAMPLE 2: Finding optKnock sets of large 4...\n\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options=struct('targetRxn','EX_lac__D_e','numDel',4);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt=struct('rxnList',{{biomass}},'values',0.5*FBA_WT.f,'sense','G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter=1;
while nIter<threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model,selectedRxnList,options,constrOpt);
    else
        optKnockSol = OptKnock(model,selectedRxnList,options,constrOpt,previousSolutions);
    end
    
    % determine lactate production and growth rate after optimizacion
    LACT_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_lac__D_e'));
    BIOMASS_M1=optKnockSol.fluxes(strcmp(model.rxns,biomass));
    ETOH_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_etoh_e'));
    FORM_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_for_e'));
    SUCC_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_succ_e'));
    ACET_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_ac_e'));
    SET_M1=optKnockSol.rxnList;
    
    if ~isempty(SET_M1)
        previousSolutions{contPreviousSolutions}=SET_M1;
        contPreviousSolutions=contPreviousSolutions+1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ',length(SET_M1));
        for j=1:length(SET_M1)
            if j==1
                fprintf('%s ',SET_M1{j});
            elseif j==length(SET_M1)
                fprintf('and %s',SET_M1{j});
            else
                fprintf(', %s ',SET_M1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n',LACT_FLUX_M1);
        fprintf('The growth rate after optimization is %.2f \n',BIOMASS_M1);
        fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n',ETOH_FLUX_M1,FORM_FLUX_M1,SUCC_FLUX_M1,ACET_FLUX_M1);
        fprintf('...Performing coupling analysis...\n');
        [type,maxGrowth,maxProd,minProd] = analyzeOptKnock(model,SET_M1,'EX_lac__D_e');
        fprintf('The solution is of type: %s\n',type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n',minProd,maxProd);
        singleProductionEnvelope(model,SET_M1,'EX_lac__D_e',biomass,['lact_ex2_' num2str(nIter)]);
    else
        if nIter==1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter=nIter+1;
end

% EXAMPLE 3: finding optKnock reactions sets of large 6
fprintf('...EXAMPLE 3: Finding optKnock sets of large 6...\n')
% Set optKnock options
% The exchange of lactate will be the objective of the outer problem
options=struct('targetRxn','EX_lac__D_e','numDel',6);
% We will impose that biomass be at least 50% of the biomass of wild-type
constrOpt=struct('rxnList',{{biomass}},'values',0.5*FBA_WT.f,'sense','G');
% We will try to find 10 optKnock sets of a maximun length of 2
nIter=1;
while nIter<threshold
    fprintf('...Performing optKnock analysis...')
    if isempty(previousSolutions{1})
        optKnockSol = OptKnock(model,selectedRxnList,options,constrOpt);
    else
        optKnockSol = OptKnock(model,selectedRxnList,options,constrOpt,previousSolutions);
    end
    
    % determine lactate production and growth rate after optimizacion
    LACT_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_lac__D_e'));
    BIOMASS_M1=optKnockSol.fluxes(strcmp(model.rxns,biomass));
    ETOH_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_etoh_e'));
    FORM_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_for_e'));
    SUCC_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_succ_e'));
    ACET_FLUX_M1=optKnockSol.fluxes(strcmp(model.rxns,'EX_ac_e'));
    SET_M1=optKnockSol.rxnList;
    
    if ~isempty(SET_M1)
        previousSolutions{contPreviousSolutions}=SET_M1;
        contPreviousSolutions=contPreviousSolutions+1;
        %printing results
        fprintf('optKnock found a optKnock set of large %d composed by ',length(SET_M1));
        for j=1:length(SET_M1)
            if j==1
                fprintf('%s ',SET_M1{j});
            elseif j==length(SET_M1)
                fprintf('and %s',SET_M1{j});
            else
                fprintf(', %s ',SET_M1{j});
            end
        end
        fprintf('\n');
        fprintf('The production of lactate after optimization is %.2f \n',LACT_FLUX_M1);
        fprintf('The growth rate after optimization is %.2f \n',BIOMASS_M1);
        fprintf('The production of other products such as ethanol, formate, succinate and acetate are %.1f, %.1f, %.1f and %.1f, respectively. \n',ETOH_FLUX_M1,FORM_FLUX_M1,SUCC_FLUX_M1,ACET_FLUX_M1);
        fprintf('...Performing coupling analysis...\n');
        [type,maxGrowth,maxProd,minProd] = analyzeOptKnock(model,SET_M1,'EX_lac__D_e');
        fprintf('The solution is of type: %s\n',type);
        fprintf('The maximun growth rate given the optKnock set is %.2f\n', maxGrowth);
        fprintf('The maximun and minimun production of lactate given the optKnock set is %.2f and %.2f, respectively \n\n',minProd,maxProd);
        singleProductionEnvelope(model,SET_M1,'EX_lac__D_e',biomass,['lact_ex3_' num2str(nIter)]);
    else
        if nIter==1
            fprintf('optKnock was not able to found an optKnock set\n');
        else
            fprintf('optKnock was not able to found additional optKnock sets\n');
        end
        break;
    end
    nIter=nIter+1;
end




end
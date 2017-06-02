function [optForceSets, posOptForceSets, typeRegOptForceSets, flux_optForceSets] = optForce(model,...
    targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k,...
    nSets, constrOpt, excludedRxns, runID, outputFolder, outputFileName,... 
    printExcel, printText, printReport, keepInputs, verbose)
%% DESCRIPTION
% This function runs the third step of optForce, a procedure published in
% the article: Ranganathan S, Suthers PF, Maranas CD (2010) OptForce: An
% Optimization Procedure for Identifying All Genetic Manipulations Leading
% to Targeted Overproductions. PLOS Computational Biology 6(4): e1000744.
% https://doi.org/10.1371/journal.pcbi.1000744. This script is based in the
% GAMS files written by Sridhar Ranganathan which were provided by the
% research group of Costas D. Maranas.

% Created by Sebastian Mendoza on 29/May/2017. snmendoz@uc.cl

%% INPUTS
% model (obligatory):       Type: struct (COBRA model)
%                           Description: a metabolic model with at least
%                           the following fields:
%                           rxns            Reaction IDs in the model
%                           mets            Metabolite IDs in the model
%                           S               Stoichiometric matrix (sparse)
%                           b               RHS of Sv = b (usually zeros)
%                           c               Objective coefficients
%                           lb              Lower bounds for fluxes
%                           ub              Upper bounds for fluxes
%                           rev             Reversibility flag
%
% targetRxn (obligatory):   Type: string
%                           Description: string containing the ID for the
%                           reaction whose flux is intented to be increased.
%                           For example, if the production of succionate is
%                           desired to be increased, 'EX_suc' should be
%                           chosen as the target reaction
%                           Example: targetRxn='EX_suc';
%
% mustU (obligatory):       Type: cell array.
%                           Description: List of reactions in the MustU set
%                           This input can be obtained by running the
%                           script findMustU.m
%                           Alternatively, there is a second usage of this
%                           input:
%                           Type: string.
%                           Description: name of the .xls file containing
%                           the list of the reactions in the MustU set
%                           Example first usage: mustU={'R21_f';'R22_f'};
%                           Example second usage: mustU='MustU';
%
% mustL (obligatory):       Type: cell array.
%                           Description: List of reactions in the MustL set
%                           This input can be obtained by running the
%                           script findMustL.m
%                           Alternatively, there is a second usage of this
%                           input:
%                           Type: string.
%                           Description: name of the .xls file containing
%                           the list of the reactions in the MustU set
%                           Example first usage: mustL={'R11_f';'R26_f'};
%                           Example second usage: mustL='MustL';
%
% minFluxesW (obligatory):   Type: double array of size n_rxns x1
%                            Description: Minimum fluxes for each reaction
%                            in the model for wild-type strain
%                            Example: minFluxesW=[-90; -56];
%
% maxFluxesW (obligatory):   Type: double array of size n_rxnsx1
%                            Description: Maximum fluxes for each reaction
%                            in the model for wild-type strain
%                            Example: maxFluxesW=[92; -86];
%
% minFluxesM (obligatory):   Type: double array of size n_rxnsx1
%                            Description: Minimum fluxes for each reaction
%                            in the model for mutant strain
%                            Example: minFluxesW=[-90; -56];
%
% maxFluxesM (obligatory):   Type: double array of size n_rxnsx1
%                            Description: Maxmum fluxes for each reaction
%                            in the model for mutant strain
%                            Example: maxFluxesW=[92; -86];
%
% k(optional):              Type: double
%                           Description: number of intervations to be
%                           found
%                           Default k=1;
%
% nSets(optional):          Type: double
%                           Description: maximum number of force sets
%                           returned by optForce.
%                           Default nSets=1;
%
% constrOpt (optional):     Type: structure
%                           Description: structure containing constrained
%                           reactions with fixed values. The structure has
%                           the following fields:
%                           rxnList: (Type: cell array)      Reaction list
%                           values:  (Type: double array)    Values for constrained reactions
%                           Example: constrOpt=struct('rxnList',{{'EX_for_e','EX_etoh_e'}},'values',[1,5]);
%                           Default: empty.
%
% excludedRxns(optional):   Type: structure
%                           Description: Reactions to be excluded. This
%                           structure has the following fields
%                           rxnList: (Type: cell array)      Reaction list
%                           typeReg: (Type: char array)      set from which reaction is excluded
%                                                            (U: Set of upregulared reactions; 
%                                                            D: set of downregulared reations; 
%                                                            K: set of knockout reactions)
%                           Example: excludedRxns=struct('rxnList',{{'SUCt','R68_b'}},'typeReg','UD')
%                           In this example SUCt is prevented to appear in
%                           the set of upregulated reactions and R68_b is
%                           prevented to appear in the downregulated set of
%                           reactions.
%                           Default: empty.
%
% runID (optional):         Type: string
%                           Description: ID for identifying this run
%
% outputFolder (optional):  Type: string
%                           Description: name for folder in which results
%                           will be stored
% 
% outputFileName (optional):Type: string
%                           Description: name for files in which results
%                           will be stored
%
% printExcel(optional):     Type: double
%                           Description: Boolean for printing results into
%                           an excel file. 1 for printing. 0 otherwise.
%                           Default: 1
%
% printText(optional):      Type: double
%                           Description: Boolean for printing results into
%                           a plaint text file. 1 for printing. 0 otherwise.
%                           Default: 1
%
% printReport(optional):    Type: double
%                           Description: Boolean for creating a file with a
%                           report of the running, including inputs for
%                           running optForce and results.
%                           Default: 1
%
% keepInputs(optional):     Type: double
%                           Description: Boolean for showing files used as
%                           input for running OptForce in GAMS. 1 for
%                           showing. 0 otherwise
%                           Default: 0
%
% verbose (optional):       Type: double
%                           Description: 1 to print results in console.
%   

%% OUTPUTS
% optForceSets:             Type: cell array
%                           Description: cell array of size  n x m, where
%                           n = number of sets found and m = size of sets
%                           found (k). Element in position i,j is reaction
%                           j in set i.
%                           Example:
%                                    rxn1  rxn2    
%                                     __    __
%                           set 1   | R4    R2
%                           set 2   | R3    R1
%
% posOptForceSets           Type: double array
%                           Description: double array of size  n x m, where
%                           n = number of sets found and m = size of sets
%                           found (k). Element in position i,j is the 
%                           position of reaction in optForceSets(i,j) in 
%                           model.rxns
%                           Example:
%                                    rxn1  rxn2    
%                                     __   __
%                           set 1   | 4    2
%                           set 2   | 3    1
%
% typeRegOptForceSets       Type: cell array
%                           Description: cell array of size  n x m, where
%                           n = number of sets found and m = size of sets
%                           found (k). Element in position i,j is the kind
%                           of intervention for reaction in 
%                           optForceSets(i,j)
%                           Example:
%                                        rxn1            rxn2    
%                                     ____________    ______________
%                           set 1   | upregulation    downregulation
%                           set 2   | upregulation    knockout
%
% outputFileName.xls        Type: file
%                           Description: file containing 11 columns.
%                           C1: Number of invervetions (k)
%                           C2: Set Number
%                           C3: Identifiers for reactions in the force set
%                           C4: Type of regulations for each reaction in
%                           the force set
%                           C5: min flux of each reaction in force set,
%                           according to FVA
%                           C6: max flux of each reaction in force set,
%                           according to FVA
%                           C7: achieved flux of each of the reactions in
%                           the force set after applying the inverventions
%                           C8: objetive function achieved by OptForce.gms
%                           C9: Minimum flux fot target when applying the
%                           interventions
%                           C10: Maximum flux fot target when applying the
%                           interventions
%                           C11: Maximum growth rate when applying the
%                           interventions.
%                           In the rows, the user can see each of the
%                           optForce sets found.
%
% outputFileName.txt        Same as outputFileName.xls but in a .txt file,
%                           separated by tabs.

%% CODE

% inputs handling
if nargin < 1 || isempty(model)
    error('OptForce: No model specified');
else
    if ~isfield(model,'S'), error('OptForce: Missing field S in model');  end
    if ~isfield(model,'rxns'), error('OptForce: Missing field rxns in model');  end
    if ~isfield(model,'mets'), error('OptForce: Missing field mets in model');  end
    if ~isfield(model,'lb'), error('OptForce: Missing field lb in model');  end
    if ~isfield(model,'ub'), error('OptForce: Missing field ub in model');  end
    if ~isfield(model,'c'), error('OptForce: Missing field c in model'); end
    if ~isfield(model,'b'), error('OptForce: Missing field b in model'); end
end

if nargin < 2 || isempty(targetRxn)
    error('OptForce: No target specified');
else
    if ~ischar(targetRxn)
    end
end

if nargin < 3 || isempty(mustU);
    error('OptForce: No MustU set specified');
else
    if iscell(mustU)
    elseif ischar(mustU)
        [~,mustU] = xlsread(mustU);
    else
        error('OptForce: Incorrect format for input MustU') ;
    end
end

if nargin < 4 || isempty(mustL);
    error('OptForce: No MustU set specified')
else
    if iscell(mustL)
    elseif ischar(mustL)
        [~,mustL] = xlsread(mustL);
    else
        error('OptForce: Incorrect format for input MustU');
    end
end

if nargin < 5 || isempty(minFluxesW);
    error('OptForce: input minFluxesW not specified');
else
    if length(minFluxesW) ~= length(model.rxns)
        error('OptForce: wrong length of minFluxesW');
    end
end

if nargin < 6 || isempty(maxFluxesW);
    error('OptForce: input maxFluxesW not specified');
else
    if length(maxFluxesW) ~= length(model.rxns)
        error('OptForce: wrong length of maxFluxesW');
    end
end

if nargin < 7 || isempty(minFluxesM);
    error('OptForce: input minFluxesM not specified');
else
    if length(minFluxesM) ~= length(model.rxns)
        error('OptForce: wrong length of minFluxesM');
    end
end

if nargin < 8 || isempty(maxFluxesM);
    error('OptForce: input maxFluxesM not specified');
else
    if length(maxFluxesM)~=length(model.rxns)
        error('OptForce: wrong length of maxFluxesM');
    end
end

if nargin < 9 || isempty(k)
    k = 1;
else
    if ~isnumeric(k)
        error('OptForce: wrong class for k');
    end
end

if nargin < 10 || isempty(nSets)
    nSets = 1;
else
    if ~isnumeric(nSets)
        error('OptForce: wrong class for nSets');
    end
end

if nargin < 11
    constrOpt={};
else
    if ~isstruct(constrOpt); error('OptForce: Incorrect format for input constrOpt'); end;
    %check correct fields and correct size.
    if ~isfield(constrOpt,'rxnList'), error('OptForce: Missing field rxnList in constrOpt');  end
    if ~isfield(constrOpt,'values'), error('OptForce: Missing field values in constrOpt');  end
    if ~isfield(constrOpt,'sense'), error('OptForce: Missing field sense in constrOpt');  end
    
    if length(constrOpt.rxnList) == length(constrOpt.values) && length(constrOpt.rxnList) == length(constrOpt.sense)
        if size(constrOpt.rxnList,1) > size(constrOpt.rxnList,2); constrOpt.rxnList = constrOpt.rxnList'; end;
        if size(constrOpt.values,1) > size(constrOpt.values,2); constrOpt.values = constrOpt.values'; end;
        if size(constrOpt.sense,1) > size(constrOpt.sense,2); constrOpt.sense = constrOpt.sense'; end;
    else
        error('OptForce: Incorrect size of fields in constrOpt');
    end
end

if nargin < 12
    excludedRxns = {};
else
    if ~isstruct(excludedRxns); error('OptForce: Incorrect format for input excludedRxns'); end;
    %check correct fields and correct size.
    if ~isfield(excludedRxns,'rxnList'), error('OptForce: Missing field rxnList in excludedRxns');  end
    if ~isfield(excludedRxns,'typeReg'), error('OptForce: Missing field typeReg in excludedRxns');  end
    
    if length(excludedRxns.rxnList) == length(excludedRxns.typeReg)
        if size(excludedRxns.rxnList,1) > size(excludedRxns.rxnList,2); excludedRxns.rxnList = excludedRxns.rxnList'; end;
        if size(excludedRxns.typeReg,1) > size(excludedRxns.typeReg,2); excludedRxns.typeReg = excludedRxns.typeReg'; end;
    else
        error('OptForce: Incorrect size of fields in excludedRxns');
    end
end

if nargin < 13 || isempty(runID)
    hour=clock; runID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
else
    if ~ischar(runID); error('OptForce: runID must be an string');  end
end
if nargin < 14 || isempty(outputFolder)
    outputFolder='OutputsOptForce';
else
    if ~ischar(outputFolder); error('OptForce: outputFolder must be an string');  end
end
if nargin < 15 || isempty(outputFileName)
    outputFileName = 'OptForce';
else
    if ~ischar(outputFileName); error('OptForce: outputFileName must be an string');  end
end
if nargin < 16
    printExcel=1;
else
    if ~isnumeric(printExcel); error('OptForce: printExcel must be a number');  end
    if printExcel ~= 0 && printExcel ~= 1; error('OptForce: printExcel must be 0 or 1');  end
end
if nargin < 17
    printText=1;
else
    if ~isnumeric(printText); error('OptForce: printText must be a number');  end
    if printText ~= 0 && printText ~= 1; error('OptForce: printText must be 0 or 1');  end
end
if nargin < 18
    printReport=1;
else
    if ~isnumeric(printReport); error('OptForce: printReport must be a number');  end
    if printReport ~= 0 && printReport ~= 1; error('OptForce: printReportl must be 0 or 1');  end
end
if nargin < 19
    keepInputs=1;
else
    if ~isnumeric(keepInputs); error('OptForce: keepInputs must be a number');  end
    if keepInputs ~= 0 && keepInputs ~= 1; error('OptForce: keepInputs must be 0 or 1');  end
end
if nargin < 20
    verbose=0;
else
    if ~isnumeric(verbose); error('OptForce: verbose must be a number');  end
    if verbose ~= 0 && verbose ~= 1; error('OptForce: verbose must be 0 or 1');  end
end

%current path
workingPath = pwd;
%go to the path associate to the ID for this run.
if ~isdir(runID); mkdir(runID); end; cd(runID); 

% if the user wants to generate a report. 
if printReport
    %create name for file. 
    hour = clock;
    reportFileName = ['report-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm.txt'];
    freport = fopen(reportFileName, 'w');
    % print date of running. 
    fprintf(freport, ['optForce executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
    % print matlab version. 
    fprintf(freport, ['MATLAB: Release R' version('-release') '\n']);
    
    %print each of the inputs used in this running.
    fprintf(freport, '\nThe following inputs were used to run OptForce: \n');
    fprintf(freport, '\n------INPUTS------\n');
    %print model.
    fprintf(freport, 'Model:\n');
    for i = 1:length(model.rxns)
        rxn = printRxnFormula(model, model.rxns{i}, false);
        fprintf(freport, [model.rxns{i} ': ' rxn{1} '\n']);
    end
    %print lower and upper bounds, minimum and maximum values for each of
    %the reactions in wild-type and mutant strain
    fprintf(freport, '\nLB\tUB\tMin_WT\tMax_WT\tMin_MT\tMax_MT\n');
    for i = 1:length(model.rxns)
        fprintf(freport, '%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\t%6.4f\n', model.lb(i), model.ub(i),...
            minFluxesW(i), maxFluxesW(i), minFluxesM(i), maxFluxesM(i));
    end
    %print target reaction.
    fprintf(freport, ['\nTarget reaction:\n' targetRxn '\n'] );
    %print must U set
    fprintf(freport, '\nMust U Set:\n');
    for i = 1:length(mustU)
        fprintf(freport, [mustU{i} '\n']);
    end
    %print must L set
    fprintf(freport, '\nMust L Set:\n');
    for i = 1:length(mustL)
        fprintf(freport, [mustL{i} '\n']);
    end
    %print constraints
    fprintf(freport, '\nConstrained reactions:\n');
    for i = 1:length(constrOpt.rxnList)
        fprintf(freport, '%s: fixed in %6.4f\n', constrOpt.rxnList{i}, constrOpt.values(i));
    end
    %print excludad reactions
    fprintf(freport, '\nExcluded reactions:\n');
    for i = 1:length(excludedRxns.rxnList)
        fprintf(freport, '%s: Excluded from %s\n', excludedRxns.rxnList{i}, ...
            regexprep(excludedRxns.typeReg(i), {'U','L','K'}, {'Upregulations','Downregulations','Knockouts'}));
    end
    fprintf(freport, '\nrunID(Main Folder): %s \n\noutputFolder: %s \n\noutputFileName: %s \n',...
        runID, outputFolder, outputFileName);
    
    
    fprintf(freport, '\nprintExcel: %1.0f \n\nprintText: %1.0f \n\nprintReport: %1.0f \n\nkeepInputs: %1.0f \n\nverbose: %1.0f \n',...
        printExcel, printText, printReport, keepInputs, verbose);
end

%initialize arrays for excluding reactions.
excludedURxns = {};
excludedLRxns = {};
excludedKRxns = {};
for i = 1:length(excludedRxns.rxnList)
    if strcmp(excludedRxns.typeReg(i), 'U')
        excludedURxns = union(excludedURxns, excludedRxns.rxnList(i));
    elseif strcmp(excludedRxns.typeReg(i), 'L')
        excludedLRxns = union(excludedLRxns, excludedRxns.rxnList(i));
    elseif strcmp(excludedRxns.typeReg(i), 'K')
        excludedKRxns = union(excludedKRxns, excludedRxns.rxnList(i));
    end
end

if keepInputs
    %export inputs to GAMS
    inputFolder = 'InputsOptForce';
    saveInputsOptForce(model, {targetRxn}, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets,...
    constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder);
end
% if the user wants to generate a report, print results.
if printReport; fprintf(freport, '\n------RESULTS------:\n'); end;

n_int=length(model.rxns);
nSolsFound=0;
solutions=cell(nSets,1);

%initialize empty array for saving info related to optForce
%sets
optForceSets = cell(nSolsFound, k);
posOptForceSets = zeros(size(optForceSets));
flux_optForceSets = zeros(size(optForceSets));
typeRegOptForceSets = cell(nSolsFound, k);


while nSolsFound < nSets
    
    bilevelMILPproblem = buildBilevelMILPproblemForOptForce(model, constrOpt, targetRxn, excludedRxns, k, minFluxesM, maxFluxesM, mustU, mustL, solutions);
    % Solve problem
    Force = solveCobraMILP(bilevelMILPproblem, 'printLevel', 1);
    if Force.stat==1
        nSolsFound=nSolsFound+1;
        disp(nSolsFound)
        pos_bin=find(Force.int>0.999999 | Force.int>1.000001);
        prev=cell(k,1);
        flux=zeros(k,1);
        type=cell(k,1);
        pos=zeros(k,1);
        posbl=zeros(k,1);
        for i=1:length(pos_bin)
            posbl(i)=pos_bin(i);
            if pos_bin(i)<=n_int
                pos(i)=pos_bin(i);
                prev(i)=model.rxns(pos_bin(i));
                flux(i)=Force.cont(pos_bin(i));
                type{i}='upregulation';
            elseif pos_bin(i)<=2*n_int
                pos(i)=pos_bin(i)-n_int;
                prev(i)=model.rxns(pos_bin(i)-n_int);
                flux(i)=Force.cont(pos_bin(i)-n_int);
                type{i}='downregulation';
            else
                pos(i)=pos_bin(i)-2*n_int;
                prev(i)=model.rxns(pos_bin(i)-2*n_int);
                flux(i)=Force.cont(pos_bin(i)-2*n_int);
                type{i}='knockout';
            end
        end
             
        solution.reactions=prev;
        solution.type=type;
        solution.pos=pos;
        solution.posbl=posbl;
        solution.flux=flux;
        solution.obj=Force.obj;
        [maxGrowthRate,minTarget,maxTarget] = testOptForceSol(model,targetRxn,solution);
        solution.growth=maxGrowthRate;
        solution.minTarget=minTarget;
        solution.maxTarget=maxTarget;
        solutions{nSolsFound}=solution;
    else
        break;
    end
end

if nSolsFound > 0
    if printReport; fprintf(freport, ['\noptForce found ' num2str(nSolsFound) ' sets \n']); end;
    if verbose; fprintf(['\noptForce found ' num2str(nSolsFound) ' sets \n']); end;
    
    for i = 1:nSolsFound
        %incorporte info of set i into general matrices.
        optForceSets(i,:) = solutions{i}.reactions;
        posOptForceSets(i,:) = solutions{i}.pos;
        typeRegOptForceSets(i,:) = solutions{i}.type;
        flux_optForceSets(i,:) = solutions{i}.flux;
    end
else
    %in case that none set was found, initialize empty arrays
    if printReport; fprintf(freport, '\n optForce did not find any set \n'); end;
    if verbose; fprintf('\n optForce did not find any set \n'); end;
    optForceSets = {};
    posOptForceSets = [];
    typeRegOptForceSets = {};
    flux_optForceSets=[];
    
end

%initialize name for files in which information will be printed
hour = clock;
if isempty(outputFileName);
    outputFileName = ['optForceSolution-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
end

% print info into an excel file if required by the user
if printExcel
    if nSolsFound > 0
        if ~isdir(outputFolder); mkdir(outputFolder); end;
        cd(outputFolder);
        Info=cell(2*nSolsFound+1,11);
        Info(1,:)=[{'Number of interventions'}, {'Set number'},{'Force Set'}, {'Type of regulation'},{'Min flux in Wild Type (mmol/gDW hr)'},{'Max flux in Wild Type (mmol/gDW hr)'},{'Achieved flux (mmol/gDW hr)'},{'Objective function (mmol/gDW hr)'},{'Minimum guaranteed for target (mmol/gDW hr)'},{'Maximum guaranteed for target (mmol/gDW hr)'},{'Maximum growth rate (1/hr)'}];
        for i=1:nSolsFound
            Info(2*i:2*i+1,:)=[[{k};cell(k-1,1)], [{i};cell(k-1,1)], solutions{i}.reactions solutions{i}.type num2cell(minFluxesM(solutions{i}.pos)) num2cell(maxFluxesM(solutions{i}.pos)) num2cell(solutions{i}.flux), [{solutions{i}.obj};cell(k-1,1)] [{solutions{i}.minTarget};cell(k-1,1)] [{solutions{i}.maxTarget};cell(k-1,1)] [{solutions{i}.growth};cell(k-1,1)]];
        end
        xlswrite(outputFileName,Info)
        cd([workingPath '/' runID]);
        if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileName '.xls  \n']); end;
        if verbose; fprintf(['Sets found by optForce were printed in ' outputFileName '.xls  \n']); end;
    else
        if printReport; fprintf(freport, '\nNo solution to optForce was found. Therefore, no excel file was generated\n'); end;
        if verbose; fprintf('No solution to optForce was found. Therefore, no excel file was generated\n'); end;
    end
end

% print info into a plain text file if required by the user
if printText
    if nSolsFound > 0
        if ~isdir(outputFolder); mkdir(outputFolder); end;
        cd(outputFolder);
        f = fopen([outputFileName '.txt'],'w');
        fprintf(f,'Reactions\tMin Flux in Wild-type strain\tMax Flux in Wild-type strain\tMin Flux in Mutant strain\tMax Flux in Mutant strain\n');
        for i=1:nSolsFound
            sols = strjoin(solutions{i}.reactions', ', ');
            type = strjoin(solutions{i}.type', ', ');
            min_str = cell(1, k);
            max_str = cell(1, k);
            flux_str = cell(1, k);
            min = minFluxesM(solutions{i}.pos);
            max = maxFluxesM(solutions{i}.pos);
            flux = solutions{i}.flux;
            for j = 1:k
                min_str{j} = num2str(min(j));
                max_str{j} = num2str(max(j));
                flux_str{j} = num2str(flux(j));
            end
            MinFlux = strjoin(min_str, ', ');
            MaxFlux = strjoin(max_str, ', ');
            achieved = strjoin(flux_str, ', ');
            fprintf(f, '%1.0f\t%1.0f\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', k, i, sols, type, MinFlux,...
                MaxFlux, achieved, solutions{i}.obj, solutions{i}.minTarget, solutions{i}.maxTarget, solutions{i}.growth);
        end
        fclose(f);
        cd([workingPath '/' runID]);
        if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileName '.txt  \n']); end;
        if verbose; fprintf(['Sets found by optForce were printed in ' outputFileName '.txt  \n']); end;
    else
        if printReport; fprintf(freport, '\nNo solution to optForce was found. Therefore, no plain text file was generated\n'); end;
        if verbose; fprintf('No solution to optForce was found. Therefore, no plain text file was generated\n'); end;
    end
end

%close file for saving report
if printReport; fclose(freport); end;
if printReport; movefile(reportFileName, outputFolder); end;

cd(workingPath);

end


function bilevelMILPproblem = buildBilevelMILPproblemForOptForce(model, constrOpt, target, excludedRxns, k, minFluxesM, maxFluxesM, mustU, mustL, solutions)

if isempty(constrOpt)
    ind_ic = [];
    b_ic = [];
    csense_ic = [];
    sel_ic = zeros(length(model.rxns), 1);
    sel_ic_b = zeros(length(model.rxns) ,1);
else
    %get indices of rxns
    [~, ind_a, ind_b] = intersect(model.rxns, constrOpt.rxnList);
    aux = constrOpt.values(ind_b);
    aux2 = constrOpt.sense(ind_b);
    %sort for rxn index
    [sorted, ind_sorted] = sort(ind_a);
    ind_ic = sorted;
    b_ic = aux(ind_sorted);
    csense_ic = aux2(ind_sorted);
    sel_ic = zeros(length(model.rxns), 1);
    sel_ic(ind_ic) = 1;
    sel_ic_b = zeros(length(model.rxns), 1);
    sel_ic_b(ind_ic) = b_ic;
end

if isempty(excludedRxns)
    ind_excludedRxns = [];
    typeReg = [];
else
    %get indices of rxns
    [~, ind_a, ind_b] = intersect(model.rxns, excludedRxns.rxnList);
    aux = excludedRxns.typeReg(ind_b);
    %sort for rxn index
    [sorted, ind_sorted] = sort(ind_a);
    ind_excludedRxns = sorted;
    typeReg = aux(ind_sorted);
end

bigM = 1000;

S = model.S;
lb = model.lb;
ub = model.ub;
[n_mets, n_rxns] = size(S);

% indices of not contrained variables
ind_nic = setdiff(1:n_rxns, ind_ic);
%indices of target reaction
ind_target = find(strcmp(model.rxns, target));
%indices of int variables
ind_int = 1:length(model.rxns);

%bolean vector for mustU
[~, sel_mustU] = ismember(model.rxns, mustU);
%bolean vector for ~mustU
sel_not_mustU =~ sel_mustU;
ind_not_mustU = find(sel_not_mustU);
%bolean vector for mustL
[~, sel_mustL] = ismember(model.rxns, mustL);
%bolean vector for ~mustL
sel_not_mustL =~ sel_mustL;
ind_not_mustL = find(sel_not_mustL);
% boolean vector for not constrained variables
sel_nic = zeros(n_rxns, 1);
sel_nic(ind_nic) = 1;
% boolean vector for not constrained variables not target
sel_nic_nt = sel_nic;
sel_nic_nt(ind_target) = 0;
ind_nic_nt = find(sel_nic_nt);
% boolean vector for integer variables
sel_int = ones(size(model.rxns));
% boolean vector for integer variables
sel_target = zeros(n_rxns, 1);
sel_target(ind_target) = 1;

% Number of integer variables
n_int = sum(sel_int);
% Number of inner  constraints
n_ic = length(ind_ic);
% Number of inner variables not constrained not target
n_nic_nt = length(find(sel_nic_nt));

% Iic
Iic = selMatrix(sel_ic);
% Inicnt
Inicnt=selMatrix(sel_nic_nt);
% Ilb
Ilb = zeros(n_rxns, n_rxns);
for i = 1:n_rxns
    Ilb(i,i) = (lb(i));
end
% Ilb_min
Ilb_min = zeros(n_rxns, n_rxns);
for i = 1:n_rxns
    Ilb_min(i,i) = (lb(i) - minFluxesM(i));
end
% Iub
Iub = zeros(n_rxns, n_rxns);
for i = 1:length(ind_int)
    Iub(i,i) = (ub(i));
end
% Iub_max
Iub_max = zeros(n_rxns, n_rxns);
for i = 1:n_rxns
    Iub_max(i,i) = (ub(i) - maxFluxesM(i));
end

% Set variable types
vartype_bl(1:10 * n_rxns + 3 * n_int + n_mets + 1) = 'C';
vartype_bl(n_rxns + 1:n_rxns + 3 * n_int) = 'B';

% Set lower and upper Bounds
H = 1000;
L = -1000;
lb_bl = [lb; zeros(9 * n_rxns + 3 * n_int + n_mets + 1, 1)]; %v(j)
ub_bl = [ub; H * ones(9 * n_rxns + 3 * n_int + n_mets + 1, 1)]; %v(j)
lb_bl(n_rxns + ind_not_mustU) = 0; ub_bl(n_rxns + ind_not_mustU) = 0;   %yu(j)
lb_bl(n_rxns + n_int + ind_not_mustL)=0; ub_bl(n_rxns + n_int + ind_not_mustL)=0;%yl(j)
lb_bl(n_rxns + 3 * n_int + 1:n_rxns + 3 * n_int + n_rxns)=L; %mu(j)
lb_bl(3 * n_rxns + 3 * n_int + 1:3 * n_rxns + 3 * n_int + n_rxns)=L; %wdeltam(j)
lb_bl(5 * n_rxns + 3 * n_int + 1:5 * n_rxns + 3 * n_int + n_rxns)=L; %wtheta(j)
lb_bl(7 * n_rxns + 3 * n_int + 1:7 * n_rxns + 3 * n_int + n_rxns)=L; %wphi(j)
lb_bl(9 * n_rxns + 3 * n_int + 1:9 * n_rxns + 3 * n_int + n_rxns)=L; %wdeltap(j)
lb_bl(10 * n_rxns + 3 * n_int + 1:10 * n_rxns + 3 * n_int + n_mets)=L; %lambda(i)
lb_bl(10 * n_rxns + 3 * n_int + n_mets + 1)=0; %z
for i=1:length(ind_excludedRxns)
    if strcmp(typeReg(i),'U')
        lb_bl(n_rxns + ind_excludedRxns(i))=0; ub_bl(n_rxns + ind_excludedRxns(i))=0;
    elseif strcmp(typeReg(i),'D')
        lb_bl(2 * n_rxns + ind_excludedRxns(i))=0; ub_bl(2 * n_rxns + ind_excludedRxns(i))=0;
    elseif strcmp(typeReg(i),'K')
        lb_bl(3 * n_rxns + ind_excludedRxns(i))=0; ub_bl(3 * n_rxns + ind_excludedRxns(i))=0;
    elseif strcmp(typeReg(i),'A')
        lb_bl(n_rxns + ind_excludedRxns(i))=0; ub_bl(n_rxns + ind_excludedRxns(i))=0;
        lb_bl(2 * n_rxns + ind_excludedRxns(i))=0; ub_bl(2 * n_rxns + ind_excludedRxns(i))=0;
        lb_bl(3 * n_rxns + ind_excludedRxns(i))=0; ub_bl(3 * n_rxns + ind_excludedRxns(i))=0;
    else
        error('OptForce: incorrect type of regulation assigned') 
    end 
end


%   v(j)      yu(j)      yl(j)     y0(j)     mu(j)  deltam(j) wdeltam(j) theta(j) wtheta(j)  phi(j)    wphi(j)  deltap(j) wdeltap(j) labmda(i)    z
%|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
%   n         n_int     n_int     n_int       n        n         n          n         n         n         n         n         n         m        1

% primal1 (n_mets equation)
%  S * v=0
A_bl=[S zeros(n_mets, n_rxns * 9 + 3 * n_int + n_mets + 1)];
b_bl = zeros(n_mets, 1);
csense_bl(1:n_mets)='E';

% primal2 and 7
% v_ic = b_ic (n_ic equations)
A_bl=[A_bl; Iic zeros(n_ic, n_rxns * 9 + 3 * n_int + n_mets + 1)];
b_bl =[b_bl; b_ic'];
csense_bl(end + 1:end + n_ic) = csense_ic;

% primal3 (n_rxns equations)
% v(j)  +  (lb(j)-minFluxesM(j)) * yu(j) >= lb(j)
A_bl=[A_bl; speye(n_rxns) Ilb_min zeros(n_rxns, 9 * n_rxns + 2 * n_int + n_mets + 1)];
b_bl =[b_bl; lb];
csense_bl(end + 1:end + n_rxns) = 'G';

% primal4 (n_rxns equations)
% v(j) + (ub(j)-maxFluxesM) * yl(j) <= ub(j)
A_bl=[A_bl; speye(n_rxns) zeros(n_rxns, n_int) Iub_max zeros(n_rxns, 9 * n_rxns + 1 * n_int + n_mets + 1)];
b_bl =[b_bl; ub];
csense_bl(end + 1:end + n_rxns) = 'L';

% primal5 (n_rxns equations)
% v(j) +lb(j) * y0(j) >= lb(j)
A_bl=[A_bl; speye(n_rxns) zeros(n_rxns, 2 * n_int) Ilb zeros(n_rxns, 9 * n_rxns + n_mets + 1)];
b_bl =[b_bl; lb];
csense_bl(end + 1:end + n_rxns) = 'G';

% primal6 (n_rxns equations)
% v(j) +ub(j) * y0(j) <= ub(j
A_bl=[A_bl; speye(n_rxns) zeros(n_rxns, 2 * n_int) Iub zeros(n_rxns, 9 * n_rxns + n_mets + 1)];
b_bl =[b_bl; ub];
csense_bl(end + 1:end + n_rxns) = 'L';

% dual1 (1 equation)
% sum(lambda(i) * (S(i,j_target) + theta(j_target) -phi(j_target) + delltap(j_target) - deltam(j_target) = 1
A_bl=[A_bl; zeros(1, 2 * n_rxns + 3 * n_int) -sel_target' zeros(1, n_rxns) sel_target' zeros(1, n_rxns) -sel_target' zeros(1, n_rxns) sel_target' zeros(1, n_rxns) S(:,ind_target)' zeros(1,1) ];
b_bl =[b_bl; 1];
csense_bl(end + 1) = 'E';

% dual2 and 4 (n_ic_equations)
% sum(lambda(i) * (S(i,j_ic)) + mu(j_ic) + theta(j_ic) - phi(j_ic) + deltap(j_ic) -deltam(j_ic) = 0
A_bl=[A_bl; zeros(n_ic, n_rxns + 3 * n_int) Iic -Iic zeros(n_ic, n_rxns) Iic zeros(n_ic, n_rxns) -Iic zeros(n_ic, n_rxns) Iic zeros(n_ic, n_rxns) S(:,ind_ic)' zeros(n_ic, 1) ];
b_bl =[b_bl; zeros(n_ic, 1)];
csense_bl(end + 1:end + n_ic) = 'E';

% % dual3 (n_ic equations)
% % sum(lambda(i) * (S(i,j_nic)) + theta(j_nic) - phi(j_nic) + deltap(j_nic) -deltam(j_nic) = 0
A_bl=[A_bl; zeros(n_nic_nt, 2 * n_rxns + 3 * n_int) -Inicnt zeros(n_nic_nt, n_rxns) Inicnt zeros(n_nic_nt, n_rxns) -Inicnt zeros(n_nic_nt, n_rxns) Inicnt zeros(n_nic_nt, n_rxns) S(:, ind_nic_nt)' zeros(n_nic_nt, 1) ];
b_bl =[b_bl; zeros(n_nic_nt, 1)];
csense_bl(end + 1:end + n_nic_nt) = 'E';

% outer
%z = v_target -> z - v_target = 0
A_bl=[A_bl; -sel_target' zeros(1, 9 * n_rxns + 3 * n_int + n_mets) 1];
b_bl =[b_bl; 0];
csense_bl(end + 1) = 'E';

% outer1 (1 equation)
% sum(yu(j) + yl(j) + y0(j)) = k
A_bl=[A_bl; zeros(1, n_rxns) ones(1, 3 * n_int) zeros(1, 9 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; k];
csense_bl(end + 1) = 'E';

% outer2 (n_rxns equations)
% yu(j) + yl(j) + y0(j) <= 1
A_bl=[A_bl; zeros(n_rxns, n_rxns) speye(n_rxns) speye(n_rxns) speye(n_rxns) zeros(n_rxns, 9 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer3 (1 equation)
% v(j_target) - b_ic * mu(j_ic)
% - sum(wtheta(j) * minFluxesM(j) + theta(j) * lb(j)- wtheta(j) * lb(j))
% + sum(whi(j) * maxFluxesM(j) + phi(j) * ub(j) -whi(j) * ub(j))
% - sum(deltap(j) * lb(j) -wdeltap(j) * lb(j)-deltam(j) * ub(j) + wdeltam(j) * ub(j)) = 0
A_bl=[A_bl; sel_target' zeros(1, 3 * n_int) -sel_ic_b' ub' -ub' -lb' (lb - minFluxesM)' ub' (maxFluxesM - ub)' -lb' lb' zeros(1, n_mets + 1) ];
b_bl =[b_bl; 0];
csense_bl(end + 1) = 'E';

% outer4 (n_rxn equations)
% wtheta(j) -bigM * yu(j) <= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns) -bigM * speye(n_rxns) zeros(n_rxns, 2 * n_int + 4 * n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer5
% wtheta(j) +bigM * yu(j) >= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns) bigM * speye(n_rxns) zeros(n_rxns, 2 * n_int + 4 * n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer6
% wtheta(j) -theta(j) +bigM * yu(j) <= bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns) bigM * speye(n_rxns) zeros(n_rxns, 2 * n_int + 3 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer7
% wtheta(j) -theta(j) -bigM * yu(j) >= -bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns) -bigM * speye(n_rxns) zeros(n_rxns, 2 * n_int + 3 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; -bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer8
% wphi(j) -bigM * yl(j) <= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + n_int) -bigM * speye(n_rxns) zeros(n_rxns, n_int + 6 * n_rxns) speye(n_rxns) zeros(n_rxns, 2 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer9
% wphi(j)  + bigM * yl(j) >= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + n_int) bigM * speye(n_rxns) zeros(n_rxns, n_int + 6 * n_rxns) speye(n_rxns) zeros(n_rxns, 2 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer10
% wphi(j) -phi(j) +bigM * yl(j) <= bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + n_int) bigM * speye(n_rxns) zeros(n_rxns, n_int + 5 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 2 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer11
% wphi(j) -phi(j) -bigM * yl(j) >= -bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + n_int) -bigM * speye(n_rxns) zeros(n_rxns, n_int + 5 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 2 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; -bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer12
% wdeltap(j) -bigM * y0(j) <= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) -bigM * speye(n_rxns) zeros(n_rxns, 8 * n_rxns) speye(n_rxns) zeros(n_rxns, n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer13
% wdeltap(j) +bigM * y0(j) >= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) bigM * speye(n_rxns) zeros(n_rxns, 8 * n_rxns) speye(n_rxns) zeros(n_rxns, n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer14
% wdeltap(j) -deltap(j) +bigM * y0(j) <= bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) bigM * speye(n_rxns) zeros(n_rxns, 7 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, n_mets + 1) ];
b_bl =[b_bl; bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer15
% wdeltap(j) -deltap(j) -bigM * y0(j) >= -bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) -bigM * speye(n_rxns) zeros(n_rxns, 7 * n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, n_mets + 1) ];
b_bl =[b_bl; -bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer16
% wdeltam(j) -bigM * y0(j) <= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) -bigM * speye(n_rxns) zeros(n_rxns, 2 * n_rxns) speye(n_rxns) zeros(n_rxns, 6 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer17
% wdeltam(j) +bigM * y0(j) >= 0
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) bigM * speye(n_rxns) zeros(n_rxns, 2 * n_rxns) speye(n_rxns) zeros(n_rxns, 6 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% outer18
% wdeltam(j) -deltam(j) +bigM * y0(j) <= bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) bigM * speye(n_rxns) zeros(n_rxns, n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 6 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% outer19
% wdeltam(j) -deltam(j) -bigM * y0(j) >= -bigM
A_bl=[A_bl; zeros(n_rxns, n_rxns + 2 * n_int) -bigM * speye(n_rxns) zeros(n_rxns, n_rxns) -speye(n_rxns) speye(n_rxns) zeros(n_rxns, 6 * n_rxns + n_mets + 1) ];
b_bl =[b_bl; -bigM * ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

%prevent previous solutions to be found
for i=1:length(solutions)
    if isempty(solutions{i});  break; end;
    sel_prev = zeros(1, 3 * n_int);
    sel_prev(solutions{i}.posbl) = 1;
    A_bl = [A_bl; zeros(1,n_rxns) sel_prev zeros(1, 9 * n_rxns + n_mets + 1)];
    b_bl = [b_bl; k-1];
    csense_bl(end + 1) = 'L';
end

%objective function
c_bl = zeros(10 * n_rxns + 3 * n_int + n_mets + 1,1); c_bl(end) = 1;

% Helper arrays for extracting solutions
sel_cont_sol = 1:n_rxns;
sel_int_sol = n_rxns + 1:n_rxns + 3 * n_int;

% Construct problem structure
bilevelMILPproblem.A = A_bl;
bilevelMILPproblem.b = b_bl;
bilevelMILPproblem.c = c_bl;
bilevelMILPproblem.csense = csense_bl;
bilevelMILPproblem.lb = lb_bl;
bilevelMILPproblem.ub = ub_bl;
bilevelMILPproblem.vartype = vartype_bl;
bilevelMILPproblem.contSolInd = sel_cont_sol;
bilevelMILPproblem.intSolInd = sel_int_sol;
% Initialize initial solution x0
bilevelMILPproblem.x0 = [];

% Maximize
bilevelMILPproblem.osense = -1;

% Set model for MILP problem
bilevelMILPproblem.model = model;

end
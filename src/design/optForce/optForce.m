function [optForceSets, posOptForceSets, typeRegOptForceSets, fluxOptForceSets] = optForce(model, targetRxn, biomassRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, varargin)
% This function runs the third step of `optForce` that is to solve a
% bilevel mixed integer linear programming problem to find sets of
% interventions that lead to an increased production of a particular target
%
%
% USAGE:
%
%    [optForceSets, posOptForceSets, typeRegOptForceSets, fluxOptForceSets] = optForce(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, varargin)
%
% INPUTS:
%    model:                  (structure) COBRA metabolic model
%                            with at least the following fields:
%
%                              * .rxns - Reaction IDs in the model
%                              * .mets - Metabolite IDs in the model
%                              * .S -    Stoichiometric matrix (sparse)
%                              * .b -    RHS of `Sv = b` (usually zeros)
%                              * .c -    Objective coefficients
%                              * .lb -   Lower bounds for fluxes
%                              * .ub -   Upper bounds for fluxes
%    targetRxn:              (string) string containing the ID for the
%                            reaction whose flux is intented to be increased.
%                            For E.g., if the production of succionate is
%                            desired to be increased, 'EX_suc' should be
%                            chosen as the target reaction.
%                            E.g.: `targetRxn = 'EX_suc';`
%    mustU:                  (cell array) List of reactions in the `MustU` set
%                            This input can be obtained by running the
%                            script `findMustU.m`.
%                            E.g. `mustU = {'R21_f';'R22_f'};`
%    mustL:                  (cell array) List of reactions in the `MustL` set
%                            This input can be obtained by running the
%                            script `findMustL.m`.
%                            E.g. first usage: `mustL = {'R11_f';'R26_f'};`
%    minFluxesW:             (double array) of size `n_rxns x 1`. Minimum fluxes for each
%                            reaction in the model for wild-type strain.
%                            This can be obtained by running the
%                            function `FVAOptForce`.
%                            E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:             (double array) of size `n_rxns x 1`. Maximum fluxes for each
%                            reaction in the model for wild-type strain.
%                            This can be obtained by running the
%                            function `FVAOptForce`.
%                            E.g.: `maxFluxesW = [90; 56];`
%    minFluxesM:             (double array) of size `n_rxns x 1`. Minimum fluxes for each
%                            reaction in the model for mutant strain.
%                            This can be obtained by running the
%                            function `FVAOptForce`.
%                            E.g.: `minFluxesM = [-90; -56];`
%    maxFluxesM:             (double array) of size n_rxns x1. Maximum fluxes for each
%                            reaction in the model for mutant strain.
%                            This can be obtained by running the
%                            function `FVAOptForce`.
%                            E.g.: `maxFluxesM = [90; 56];`
%
% OPTIONAL INPUTS:
%    k:                      (double) number of intervations to be found
%                            Default `k = 1`;
%
%    nSets:                  (double) maximum number of force sets
%                            returned by `optForce`.
%                            Default `nSets = 1`;
%
%    constrOpt:              (structure) structure containing
%                            additional contraints. Include here only
%                            reactions whose flux is fixed, i.e.,
%                            reactions whose lower and upper bounds have
%                            the same value. Do not include here
%                            reactions whose lower and upper bounds have
%                            different values. Such contraints should be
%                            defined in the lower and upper bounds of
%                            the model. The structure has the following
%                            fields:
%
%                              * .rxnList - Reaction list (cell array)
%                              * .values -  Values for constrained
%                                reactions (double array)
%                                E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    excludedRxns:           (structure) Reactions to be excluded. This
%                            structure has the following fields:
%
%                              * .rxnList - Reaction list (cell array)
%                              * .typeReg - set from which reaction is
%                                excluded (char array) (U: Set of
%                                upregulared reactions, D: set of
%                                downregulared reations, K: set of knockout
%                                reactions)
%                            E.g.: `excludedRxns = struct('rxnList', {{'SUCt', 'R68_b'}}, 'typeReg', 'UD')`
%                            In this E.g. 'SUCt' is prevented to appear in
%                            the set of upregulated reactions and 'R68_b' is
%                            prevented to appear in the downregulated set of
%                            reactions.
%                            Default: empty.
%    runID:                  (string) ID for identifying this run.
%                            Default: ['run' date hour].
%    outputFolder:           (string) name for folder in which
%                            results will be stored.
%                            Default: 'OutputsFindMustLL'.
%    outputFileName:         (string) name for files in which
%                            results. will be stored.
%                            Default: 'MustLLSet'.
%    printExcel:             (double) boolean to describe wheter
%                            data must be printed in an excel file or not.
%                            Default: 1
%    printText:              (double) boolean to describe wheter
%                            data must be printed in an plaint text file or not.
%                            Default: 1
%    printReport:            (double) 1 to generate a report in a
%                            plain text file. 0 otherwise.
%                            Default: 1
%    keepInputs:             (double) 1 to mantain folder with
%                            inputs to run `findMustLL.gms`. 0 otherwise.
%                            Default: 1
%    printLevel:             (double) 1 to print results in console.
%                            0 otherwise.
%                            Default: 0
%
% OUTPUTS:
%    optForceSets:           (cell array) cell array of size  `n x m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`) Element in position `i`, `j` is reaction
%                            `j` in set `i`.
%                            E.g.:
%
%                            =====    ====    ====
%                            \        rxn1    rxn2
%                            set 1    R4      R2
%                            set 2    R3      R1
%                            =====    ====    ====
%
%    posOptForceSets:        (double array) double array of size  `n x m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`) Element in position `i`, `j` is the
%                            position of reaction in `optForceSets(i,j)` in
%                            `model.rxns`
%                            E.g.:
%
%                            =====    ====    ====
%                            \        rxn1    rxn2
%                            set 1    4       2
%                            set 2    3       1
%                            =====    ====    ====
%
%    typeRegOptForceSets:    (cell array) cell array of size  `n x m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`) Element in position `i`, `j` is the kind
%                            of intervention for reaction in
%                            `optForceSets(i,j)`
%                            E.g.:
%
%                            =====    ============    ==============
%                            \        rxn1            rxn2
%                            set 1    upregulation    downregulation
%                            set 2    upregulation    knockout
%                            =====    ============    ==============
%
%    fluxOptForceSets:       (double) matrix Matrix of size `n + m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`) The number in `(i,j)` is the flux
%                            achieved for the reaction in `optForceSets(i,j)`
%    outputFileName.xls:     file containing 11 columns.
%
%                              * C1: Number of interventions (`k`)
%                              * C2: Set Number
%                              * C3: Identifiers for reactions in the force set
%                              * C4: Type of regulations for each reaction in
%                                the force set
%                              * C5: min flux of each reaction in force set,
%                                according to FVA
%                              * C6: max flux of each reaction in force set,
%                                according to FVA
%                              * C7: achieved flux of each of the reactions in
%                                the force set after applying the inverventions
%                              * C8: objetive function achieved by `OptForce.gms`
%                              * C9: Minimum flux fot target when applying the
%                                interventions
%                              * C10: Maximum flux fot target when applying the
%                                interventions
%                              * C11: Maximum growth rate when applying the
%                                interventions.
%                              * In the rows, the user can see each of the
%                                `optForce` sets found.
%    outputFileName.txt:     Same as outputFileName.xls but in a .txt file,
%                            separated by tabs.
%
% NOTE:
%
%    This function is based in the GAMS files written by Sridhar
%    Ranganathan which were provided by the research group of Costas D.
%    Maranas. For a detailed description of the `optForce` procedure, please
%    see: `Ranganathan S, Suthers PF, Maranas CD (2010) OptForce: An
%    Optimization Procedure for Identifying All Genetic Manipulations
%    Leading to Targeted Overproductions. PLOS Computational Biology 6(4):
%    e1000744`. https://doi.org/10.1371/journal.pcbi.1000744
%
% .. Author: - Sebastian Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

if isfield(model,'C') || isfield(model,'E')
    issueConfirmationWarning('optForce does not handle the additional constraints and variables defined in the model structure (fields .C and .E.)\n It will only use the stoichiometry provided.');
end

parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('targetRxn', @ischar)
parser.addRequired('biomassRxn', @ischar)
parser.addRequired('mustU', @iscell)
parser.addRequired('mustL', @iscell)
parser.addRequired('minFluxesW', @isnumeric)
parser.addRequired('maxFluxesW', @isnumeric)
parser.addRequired('minFluxesM', @isnumeric)
parser.addRequired('maxFluxesM', @isnumeric)
parser.addParamValue('k', 1, @isnumeric)
parser.addParamValue('nSets', 1, @isnumeric)
parser.addParamValue('constrOpt', struct('rxnList', {{}}, 'values', []) ,@(x) isstruct(x) && isfield(x, 'rxnList') && isfield(x, 'values') ...
    && length(x.rxnList) == length(x.values) && length(intersect(x.rxnList, model.rxns)) == length(x.rxnList))
parser.addParamValue('excludedRxns', struct('rxnList', {{}}, 'typeReg', ''),@(x) isstruct(x) && isfield(x, 'rxnList') && isfield(x, 'typeReg') ...
    && length(x.rxnList) == length(x.typeReg) && length(intersect(x.rxnList, model.rxns)) == length(x.rxnList))
hour = clock; defaultRunID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
parser.addParamValue('runID', defaultRunID, @(x) ischar(x))
parser.addParamValue('outputFolder', 'OutputsOptForce', @(x) ischar(x))
parser.addParamValue('outputFileName', 'OptForce', @(x) ischar(x))
if strcmp(filesep,'\')
    defaultPrintExcel = 1;
else
    defaultPrintExcel = 0;
end
parser.addParamValue('printExcel', defaultPrintExcel, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printText', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printReport', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepInputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('verbose', 0, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printLevel', 0, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('loop', 0, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('kMin', 1, @(x) isnumeric(x));

parser.parse(model, targetRxn, biomassRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, varargin{:})
model = parser.Results.model;
targetRxn = parser.Results.targetRxn;
biomassRxn = parser.Results.biomassRxn;
mustU = parser.Results.mustU;
mustL = parser.Results.mustL;
minFluxesW = parser.Results.minFluxesW;
maxFluxesW = parser.Results.maxFluxesW;
minFluxesM = parser.Results.minFluxesM;
maxFluxesM = parser.Results.maxFluxesM;
k = parser.Results.k;
nSets = parser.Results.nSets;
constrOpt= parser.Results.constrOpt;
excludedRxns= parser.Results.excludedRxns;
runID = parser.Results.runID;
outputFolder = parser.Results.outputFolder;
outputFileName = parser.Results.outputFileName;
printExcel = parser.Results.printExcel;
printText = parser.Results.printText;
printReport = parser.Results.printReport;
keepInputs = parser.Results.keepInputs;
printFlags = {'printLevel','verbose'};
%get the printLevel.
if all(~ismember(printFlags,parser.UsingDefaults))
    error('Either supply printLevel or verbose optional parameter')
else    
    if any(~ismember(printFlags,parser.UsingDefaults))
        selected = ~ismember(printFlags,parser.UsingDefaults);
        printLevel = parser.Results.(printFlags{selected});
    else
        printLevel = parser.Results.printLevel;
    end
end

loop = parser.Results.loop;
kMin = parser.Results.kMin;

% correct size of constrOpt
if ~isempty(constrOpt.rxnList)
    if size(constrOpt.rxnList, 1) > size(constrOpt.rxnList,2); constrOpt.rxnList = constrOpt.rxnList'; end;
    if size(constrOpt.values, 1) > size(constrOpt.values,2); constrOpt.values = constrOpt.values'; end;
end
if ~isempty(excludedRxns.rxnList)
    if size(excludedRxns.rxnList,1) > size(excludedRxns.rxnList,2); excludedRxns.rxnList = excludedRxns.rxnList'; end;
    if size(excludedRxns.typeReg,1) > size(excludedRxns.typeReg,2); excludedRxns.typeReg = excludedRxns.typeReg'; end;
end

%current path
workingPath = pwd;
runID = [workingPath filesep runID];
%go to the path associate to the ID for this run.
if exist(runID, 'dir')~=7
    mkdir(runID);
end
cd(runID);
outputFolder = [runID filesep outputFolder];

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
        printExcel, printText, printReport, keepInputs, printLevel);
end

%initialize arrays for excluding reactions.
excludedURxns = {};
excludedLRxns = {};
excludedKRxns = {};
if ~isempty(excludedRxns)
    for i = 1:length(excludedRxns.rxnList)
        if strcmp(excludedRxns.typeReg(i), 'U')
            excludedURxns = union(excludedURxns, excludedRxns.rxnList(i));
        elseif strcmp(excludedRxns.typeReg(i), 'L')
            excludedLRxns = union(excludedLRxns, excludedRxns.rxnList(i));
        elseif strcmp(excludedRxns.typeReg(i), 'K')
            excludedKRxns = union(excludedKRxns, excludedRxns.rxnList(i));
        end
    end
end

if loop % if k = kMin:k
    % if the user wants to generate a report, print results.
    if printReport; fprintf(freport, '\n------RESULTS------:\n'); end;

    noSolution = 1;
    currentK = kMin;

    while noSolution && currentK <= k

        if keepInputs
            %save inputs
            inputFolder = [runID filesep 'InputsOptForce_k' num2str(currentK)];
            saveInputsOptForce(model, {targetRxn}, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets,...
                constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder);
        end

        n_int=length(model.rxns);
        nSolsFound=0;
        solutions=cell(nSets,1);

        %initialize empty array for saving info related to optForce
        %sets
        optForceSets = cell(nSolsFound, k);
        posOptForceSets = zeros(size(optForceSets));
        fluxOptForceSets = zeros(size(optForceSets));
        typeRegOptForceSets = cell(nSolsFound, k);


        while nSolsFound < nSets

            bilevelMILPproblem = buildBilevelMILPproblemForOptForce(model, constrOpt, targetRxn, excludedRxns, k, minFluxesM, maxFluxesM, mustU, mustL, solutions);
            % Solve problem
            Force = solveCobraMILP(bilevelMILPproblem, 'printLevel', printLevel);
            if Force.stat == 1
                nSolsFound = nSolsFound + 1;
                if printLevel; fprintf('set n %1.0f was found\n', nSolsFound), end;
                pos_bin = find(Force.int>0.999999 | Force.int>1.000001);
                prev = cell(k, 1);
                flux = zeros(k, 1);
                type = cell(k, 1);
                pos = zeros(k, 1);
                posbl = zeros(k, 1);
                for i = 1:length(pos_bin)
                    posbl(i) = pos_bin(i);
                    if pos_bin(i) <= n_int
                        pos(i) = pos_bin(i);
                        prev(i) = model.rxns(pos_bin(i));
                        flux(i) = Force.cont(pos_bin(i));
                        type{i} = 'upregulation';
                    elseif pos_bin(i) <= 2 * n_int
                        pos(i) = pos_bin(i) - n_int;
                        prev(i) = model.rxns(pos_bin(i) - n_int);
                        flux(i) = Force.cont(pos_bin(i) - n_int);
                        type{i} = 'downregulation';
                    else
                        pos(i) = pos_bin(i) - 2 * n_int;
                        prev(i) = model.rxns(pos_bin(i) - 2 * n_int);
                        flux(i) = Force.cont(pos_bin(i) - 2 * n_int);
                        type{i} = 'knockout';
                    end
                end

                solution.reactions = prev;
                solution.type = type;
                solution.pos = pos;
                solution.posbl = posbl;
                solution.flux = flux;
                solution.obj = Force.obj;
                [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, targetRxn, solution);
                solution.growth = maxGrowthRate;
                solution.minTarget = minTarget;
                solution.maxTarget = maxTarget;
                solutions{nSolsFound} = solution;
            else
                break;
            end
        end

        if nSolsFound > 0
            % a solution was found so this ends the loop
            noSolution = 0;

            if printReport; fprintf(freport, ['\noptForce found ' num2str(nSolsFound) ' sets using k = ' num2str(currentK) '\n']); end;
            if printLevel; fprintf(['\noptForce found ' num2str(nSolsFound) ' sets using k = ' num2str(currentK) '\n']); end;

            for i = 1:nSolsFound
                %incorporte info of set i into general matrices.
                optForceSets(i,:) = solutions{i}.reactions;
                posOptForceSets(i,:) = solutions{i}.pos;
                typeRegOptForceSets(i,:) = solutions{i}.type;
                fluxOptForceSets(i,:) = solutions{i}.flux;
            end

            outputFolderK = [outputFolder '_k' num2str(currentK)];
            outputFileNameK = [outputFileName '_k' num2str(currentK)];

            % print info into an excel file if required by the user
            if printExcel

                if ~isdir(outputFolderK); mkdir(outputFolderK); end;
                cd(outputFolderK);
                Info = cell( 2 * nSolsFound + 1, 13);
                Info(1,:) = [{'Number of interventions'}, {'Set number'},{'Force Set'}, {'Type of regulation'},...
                    {'Min flux in Wild Type (mmol/gDW hr)'}, {'Max flux in Wild Type (mmol/gDW hr)'}, ...
                    {'Min flux in Mutant (mmol/gDW hr)'}, {'Max flux in Mutant (mmol/gDW hr)'},{'Achieved flux (mmol/gDW hr)'},...
                    {'Objective function (mmol/gDW hr)'}, {'Minimum guaranteed for target (mmol/gDW hr)'},...
                    {'Maximum guaranteed for target (mmol/gDW hr)'},{'Maximum growth rate (1/hr)'}];
                for i=1:nSolsFound
                    Info(k * (i - 1) + 2:k * (i) + 1,:) = [[{k}; cell(k-1,1)], [{i};cell(k-1,1)], solutions{i}.reactions ...
                        solutions{i}.type num2cell(minFluxesW(solutions{i}.pos)) num2cell(maxFluxesW(solutions{i}.pos))...
                        num2cell(minFluxesM(solutions{i}.pos)) num2cell(maxFluxesM(solutions{i}.pos))...
                        num2cell(solutions{i}.flux), [{solutions{i}.obj};cell(k-1,1)] [{solutions{i}.minTarget};cell(k-1,1)] ...
                        [{solutions{i}.maxTarget};cell(k-1,1)] [{solutions{i}.growth};cell(k-1,1)]];
                end     
                setupxlwrite();
                xlwrite(outputFileNameK,Info)                
                cd(runID);
                if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileNameK '.xls  \n']); end;
                if printLevel; fprintf(['Sets found by optForce were printed in ' outputFileNameK '.xls  \n']); end;
            end

            if printText
                if ~isdir(outputFolderK); mkdir(outputFolderK); end;
                cd(outputFolderK);
                f = fopen([outputFileNameK '.txt'],'w');
                fprintf(f,'Number of interventions\tSet number\tForce Set\tType of regulation\tMin Flux in Wild-type(mmol/gDW hr)\tMax Flux in Wild-type (mmol/gDW hr)\tMin Flux in Mutant (mmol/gDW hr)\tMax Flux in Mutant (mmol/gDW hr)\tAchieved flux (mmol/gDW hr)\tObjective function (mmol/gDW hr)\tMinimum guaranteed for target (mmol/gDW hr)\tMaximum guaranteed for target (mmol/gDW hr)\tMaximum growth rate (1/hr)\n');
                for i=1:nSolsFound
                    sols = strjoin(solutions{i}.reactions', ', ');
                    type = strjoin(solutions{i}.type', ', ');
                    minW_str = cell(1, k);
                    maxW_str = cell(1, k);
                    minM_str = cell(1, k);
                    maxM_str = cell(1, k);
                    flux_str = cell(1, k);
                    minM = minFluxesM(solutions{i}.pos);
                    maxM = maxFluxesM(solutions{i}.pos);
                    minW = minFluxesW(solutions{i}.pos);
                    maxW = maxFluxesW(solutions{i}.pos);
                    flux = solutions{i}.flux;
                    for j = 1:k
                        minW_str{j} = num2str(minW(j));
                        maxW_str{j} = num2str(maxW(j));
                        minM_str{j} = num2str(minM(j));
                        maxM_str{j} = num2str(maxM(j));
                        flux_str{j} = num2str(flux(j));
                    end
                    MinFluxM = strjoin(minM_str,', ');
                    MaxFluxM = strjoin(maxM_str,', ');
                    MinFluxW = strjoin(minW_str,', ');
                    MaxFluxW = strjoin(maxW_str,', ');
                    achieved = strjoin(flux_str, ', ');
                    fprintf(f, '%1.0f\t%1.0f\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', k, i, sols, type, MinFluxW, MaxFluxW, MinFluxM,...
                        MaxFluxM, achieved, solutions{i}.obj, solutions{i}.minTarget, solutions{i}.maxTarget, solutions{i}.growth);
                end
                fclose(f);
                cd(runID);
                if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileNameK '.txt  \n']); end;
                if printLevel; fprintf(['Sets found by optForce were printed in ' outputFileNameK '.txt  \n']); end;
            end

            %close file for saving report
            if printReport; fclose(freport); end;
            cd(workingPath);

        else
            %in case that none set was found, initialize empty arrays
            if printReport
                fprintf(freport, '\n optForce did not find any set using k = %1.0f \n', currentK);
                if currentK < k -1
                    fprintf(freport, '\n increasing k to %1.0f \n', currentK + 1);
                end
            end
            if printLevel
                fprintf('\n optForce did not find any set using k = %1.0f \n', currentK);
                if currentK < k -1
                    fprintf(freport, '\n increasing k to %1.0f \n', currentK + 1);
                end
            end

            currentK = currentK + 1;
            if currentK > k
                optForceSets = {};
                posOptForceSets = [];
                typeRegOptForceSets = {};
                fluxOptForceSets=[];
            end

        end

    end

    if noSolution
        %close file for saving report
        if printReport; fclose(freport); end;
        cd(workingPath);
    end

else

    if keepInputs
        %save inputs
        inputFolder = [runID filesep 'InputsOptForce'];
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
    fluxOptForceSets = zeros(size(optForceSets));
    typeRegOptForceSets = cell(nSolsFound, k);

    while nSolsFound < nSets

        bilevelMILPproblem = buildBilevelMILPproblemForOptForce(model, constrOpt, targetRxn, excludedRxns, k, minFluxesM, maxFluxesM, mustU, mustL, solutions);
        % Solve problem
        Force = solveCobraMILP(bilevelMILPproblem, 'printLevel', printLevel);
        if Force.stat == 1
            nSolsFound = nSolsFound + 1;
            if printLevel; fprintf('set n %1.0f was found\n', nSolsFound), end;
            pos_bin = find(Force.int>0.999999 | Force.int>1.000001);
            prev = cell(k, 1);
            flux = zeros(k, 1);
            type = cell(k, 1);
            pos = zeros(k, 1);
            posbl = zeros(k, 1);
            for i = 1:length(pos_bin)
                posbl(i) = pos_bin(i);
                if pos_bin(i) <= n_int
                    pos(i) = pos_bin(i);
                    prev(i) = model.rxns(pos_bin(i));
                    flux(i) = Force.cont(pos_bin(i));
                    type{i} = 'upregulation';
                elseif pos_bin(i) <= 2 * n_int
                    pos(i) = pos_bin(i) - n_int;
                    prev(i) = model.rxns(pos_bin(i) - n_int);
                    flux(i) = Force.cont(pos_bin(i) - n_int);
                    type{i} = 'downregulation';
                else
                    pos(i) = pos_bin(i) - 2 * n_int;
                    prev(i) = model.rxns(pos_bin(i) - 2 * n_int);
                    flux(i) = Force.cont(pos_bin(i) - 2 * n_int);
                    type{i} = 'knockout';
                end
            end

            solution.reactions = prev;
            solution.type = type;
            solution.pos = pos;
            solution.posbl = posbl;
            solution.flux = flux;
            solution.obj = Force.obj;
            [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, targetRxn, biomassRxn, solution);
            solution.growth = maxGrowthRate;
            solution.minTarget = minTarget;
            solution.maxTarget = maxTarget;
            solutions{nSolsFound} = solution;
        else
            break;
        end
    end

    if nSolsFound > 0
        if printReport; fprintf(freport, ['\noptForce found ' num2str(nSolsFound) ' sets \n']); end;
        if printLevel; fprintf(['\noptForce found ' num2str(nSolsFound) ' sets \n']); end;

        for i = 1:nSolsFound
            %incorporte info of set i into general matrices.
            optForceSets(i,:) = solutions{i}.reactions;
            posOptForceSets(i,:) = solutions{i}.pos;
            typeRegOptForceSets(i,:) = solutions{i}.type;
            fluxOptForceSets(i,:) = solutions{i}.flux;
        end
    else
        %in case that none set was found, initialize empty arrays
        if printReport; fprintf(freport, '\n optForce did not find any set \n'); end;
        if printLevel; fprintf('\n optForce did not find any set \n'); end;
        optForceSets = {};
        posOptForceSets = [];
        typeRegOptForceSets = {};
        fluxOptForceSets=[];

    end

    %initialize name for files in which information will be printed
    hour = clock;
    if isempty(outputFileName);
        outputFileName = ['optForceSolution-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
    end

    % print info into an excel file if required by the user
    if printExcel && ~isunix
        if nSolsFound > 0
            if ~isdir(outputFolder); mkdir(outputFolder); end;
            cd(outputFolder);
            Info = cell( 2 * nSolsFound + 1, 13);
            Info(1,:) = [{'Number of interventions'}, {'Set number'},{'Force Set'}, {'Type of regulation'},...
                {'Min flux in Wild Type (mmol/gDW hr)'}, {'Max flux in Wild Type (mmol/gDW hr)'}, ...
                {'Min flux in Mutant (mmol/gDW hr)'}, {'Max flux in Mutant (mmol/gDW hr)'},{'Achieved flux (mmol/gDW hr)'},...
                {'Objective function (mmol/gDW hr)'}, {'Minimum guaranteed for target (mmol/gDW hr)'},...
                {'Maximum guaranteed for target (mmol/gDW hr)'},{'Maximum growth rate (1/hr)'}];
            for i=1:nSolsFound
                Info(k * (i - 1) + 2:k * (i) + 1,:) = [[{k}; cell(k-1,1)], [{i};cell(k-1,1)], solutions{i}.reactions ...
                    solutions{i}.type num2cell(minFluxesW(solutions{i}.pos)) num2cell(maxFluxesW(solutions{i}.pos))...
                    num2cell(minFluxesM(solutions{i}.pos)) num2cell(maxFluxesM(solutions{i}.pos))...
                    num2cell(solutions{i}.flux), [{solutions{i}.obj};cell(k-1,1)] [{solutions{i}.minTarget};cell(k-1,1)] ...
                    [{solutions{i}.maxTarget};cell(k-1,1)] [{solutions{i}.growth};cell(k-1,1)]];
            end
            setupxlwrite();
            xlwrite(outputFileName,Info)
            cd(runID);
            if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileName '.xls  \n']); end;
            if printLevel; fprintf(['Sets found by optForce were printed in ' outputFileName '.xls  \n']); end;
        else
            if printReport; fprintf(freport, '\nNo solution to optForce was not found. Therefore, no excel file was generated\n'); end;
            if printLevel; fprintf('No solution to optForce was not found. Therefore, no excel file was generated\n'); end;
        end
    end

    % print info into a plain text file if required by the user
    if printText
        if nSolsFound > 0
            if ~isdir(outputFolder); mkdir(outputFolder); end;
            cd(outputFolder);
            f = fopen([outputFileName '.txt'],'w');
            fprintf(f,'Number of interventions\tSet number\tForce Set\tType of regulation\tMin Flux in Wild-type(mmol/gDW hr)\tMax Flux in Wild-type (mmol/gDW hr)\tMin Flux in Mutant (mmol/gDW hr)\tMax Flux in Mutant (mmol/gDW hr)\tAchieved flux (mmol/gDW hr)\tObjective function (mmol/gDW hr)\tMinimum guaranteed for target (mmol/gDW hr)\tMaximum guaranteed for target (mmol/gDW hr)\tMaximum growth rate (1/hr)\n');
            for i=1:nSolsFound
                sols = strjoin(solutions{i}.reactions', ', ');
                type = strjoin(solutions{i}.type', ', ');
                minW_str = cell(1, k);
                maxW_str = cell(1, k);
                minM_str = cell(1, k);
                maxM_str = cell(1, k);
                flux_str = cell(1, k);
                minM = minFluxesM(solutions{i}.pos);
                maxM = maxFluxesM(solutions{i}.pos);
                minW = minFluxesW(solutions{i}.pos);
                maxW = maxFluxesW(solutions{i}.pos);
                flux = solutions{i}.flux;
                for j = 1:k
                    minW_str{j} = num2str(minW(j));
                    maxW_str{j} = num2str(maxW(j));
                    minM_str{j} = num2str(minM(j));
                    maxM_str{j} = num2str(maxM(j));
                    flux_str{j} = num2str(flux(j));
                end
                MinFluxM = strjoin(minM_str,', ');
                MaxFluxM = strjoin(maxM_str,', ');
                MinFluxW = strjoin(minW_str,', ');
                MaxFluxW = strjoin(maxW_str,', ');
                achieved = strjoin(flux_str, ', ');
                fprintf(f, '%1.0f\t%1.0f\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', k, i, sols, type, MinFluxW, MaxFluxW, MinFluxM,...
                    MaxFluxM, achieved, solutions{i}.obj, solutions{i}.minTarget, solutions{i}.maxTarget, solutions{i}.growth);
            end
            fclose(f);
            cd(runID);
            if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileName '.txt  \n']); end;
            if printLevel; fprintf(['Sets found by optForce were printed in ' outputFileName '.txt  \n']); end;
        else
            if printReport; fprintf(freport, '\nNo solution to optForce was not found. Therefore, no plain text file was generated\n'); end;
            if printLevel; fprintf('No solution to optForce was not found. Therefore, no plain text file was generated\n'); end;
        end
    end

    %close file for saving report
    if printReport; fclose(freport); end;
    if printReport; movefile(reportFileName, outputFolder); end;

    cd(workingPath);
end

end


function bilevelMILPproblem = buildBilevelMILPproblemForOptForce(model, constrOpt, target, excludedRxns, k, minFluxesM, maxFluxesM, mustU, mustL, solutions)

if isempty(constrOpt.rxnList)
    ind_ic = [];
    b_ic = [];
    sel_ic = zeros(length(model.rxns), 1);
    sel_ic_b = zeros(length(model.rxns) ,1);
else
    %get indices of rxns
    [~, ind_a, ind_b] = intersect(model.rxns, constrOpt.rxnList);
    aux = constrOpt.values(ind_b);
    %sort for rxn index
    [sorted, ind_sorted] = sort(ind_a);
    ind_ic = sorted;
    b_ic = aux(ind_sorted);
    sel_ic = zeros(length(model.rxns), 1);
    sel_ic(ind_ic) = 1;
    sel_ic_b = zeros(length(model.rxns), 1);
    sel_ic_b(ind_ic) = b_ic;
end

if isempty(excludedRxns.rxnList)
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
csense_bl(end + 1:end + n_ic) = 'E';

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

% Set model for MILP problems
bilevelMILPproblem.model = model;

end

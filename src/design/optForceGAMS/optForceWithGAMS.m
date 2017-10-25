function [optForceSets, posOptForceSets, typeRegOptForceSets, fluxOptForceSets] = optForceWithGAMS(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets, constrOpt, excludedRxns, runID, outputFolder, outputFileName, solverName, printExcel, printText, printReport, keepInputs, keepGamsOutputs, verbose)
% This function runs the third step of `optForce` that is to solve a
% bilevel mixed integer linear programming problem to find sets of
% interventions that lead to an increased production of a particular target
%
% USAGE:
%
%    [optForceSets, posOptForceSets, typeRegOptForceSets, fluxOptForceSets] = optForceWithGAMS(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, varargin)
%
% INPUTS:
%    model:                  (structure) a metabolic model with at least
%                            the following fields:
%
%                              * .rxns - Reaction IDs in the model
%                              * .mets - Metabolite IDs in the model
%                              * .S - Stoichiometric matrix (sparse)
%                              * .b - RHS of `Sv = b` (usually zeros)
%                              * .c - Objective coefficients
%                              * .lb - Lower bounds for fluxes
%                              * .ub - Upper bounds for fluxes
%    targetRxn:              (string) string containing the ID for the
%                            reaction whose flux is intented to be
%                            increased. For E.g., if the production of
%                            succionate is desired to be increased,
%                            'EX_suc' should be chosen as the target
%                            reaction E.g.: `targetRxn = 'EX_suc';`
%    mustU:                  (cell array) List of reactions in the `MustU`
%                            set. This input can be obtained by running the
%                            script `findMustU.m` E.g.
%                            `mustU = {'R21_f';'R22_f'};`
%    mustL:                  (cell array) List of reactions in the `MustL`
%                            set. This input can be obtained by running the
%                            script `findMustL.m` E.g.
%                            `mustL = {'R11_f';'R26_f'};`
%    minFluxesW:             (double array of size `n_rxns x 1`) minimum
%                            fluxes for each reaction in the model for
%                            wild-type strain. This can be obtained by
%                            running the function `FVAOptForce`.
%                            E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:             (double array of size `n_rxns x 1`) maximum
%                            fluxes for each reaction in the model for
%                            wild-type strain. This can be obtained by
%                            running the function `FVAOptForce`.
%                            E.g.: `maxFluxesW = [90; 56];`
%    minFluxesM:             (double array of size `n_rxns x 1`) minimum
%                            fluxes for each reaction in the model for
%                            mutant strain. This can be obtained by running
%                            the function `FVAOptForce`. E.g.: `minFluxesM = [-90; -56];`
%    maxFluxesM:             (double array of size `n_rxns x 1`)
%                            Description: Maximum fluxes for each reaction
%                            in the model for mutant strain. This can be
%                            obtained by running the function `FVAOptForce`.
%                            E.g.: `maxFluxesM = [90; 56];`
%
% OPTIONAL INPUTS:
%    k:                      (double) number of intervations to be
%                            found. Default `k = 1`;
%    nSets:                  (double) maximum number of force sets
%                            returned by optForce. Default `nSets = 1`;
%    constrOpt:              (Structure) structure containing
%                            additional contraints. Include here only
%                            reactions whose flux is fixed, i.e., reactions
%                            whose lower and upper bounds have the same
%                            value. Do not include here reactions whose
%                            lower and upper bounds have different values.
%                            Such contraints should be defined in the lower
%                            and upper bounds of the model. The structure
%                            has the following fields:
%
%                              * .rxnList - Reaction list (cell array)
%                              * .values -  Values for constrained
%                                reactions (double array)
%                                E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    excludedRxns:           (structure) Reactions to be excluded. This
%                            structure has the following fields
%
%                              * .rxnList - Reaction list (cell array)
%                              * .typeReg - set from which reaction is
%                                excluded (char array) (U: Set of
%                                upregulared reactions, D: set of
%                                downregulared reations, K: set of knockout
%                                reactions)
%                            E.g.: `excludedRxns = struct('rxnList', {{'SUCt', 'R68_b'}}, 'typeReg', 'UD')` In this
%                            E.g. 'SUCt' is prevented to appear in the set of
%                            upregulated reactions and 'R68_b' is prevented
%                            to appear in the downregulated set of
%                            reactions. Default = empty.
%    solverName:             (string) Name of the solver used in
%                            GAMS. Default = 'cplex'.
%    runID:                  (string) ID for identifying this run.
%                            Default = ['run' date hour].
%    outputFolder:           (string) name for folder in which
%                            results will be stored. Default =
%                            'OutputsFindMustLL'.
%    outputFileName:         (string) name for files in which
%                            results. will be stored Default = 'MustLLSet'.
%    printExcel:             (double) boolean to describe wheter
%                            data must be printed in an excel file or not.
%                            Default = 1
%    printText:              (double) boolean to describe wheter
%                            data must be printed in an plaint text file or
%                            not. Default = 1
%    printReport:            (double) 1 to generate a report in a
%                            plain text file. 0 otherwise. Default = 1
%    keepInputs:             (double) 1 to mantain folder with
%                            inputs to run `findMustLL.gms`. 0 otherwise.
%                            Default = 1
%    keepGamsOutputs:        (double) 1 to mantain files returned by
%                            `findMustLL.gms`. 0 otherwise. Default = 1
%    verbose:                (double) 1 to print results in console.
%                            0 otherwise. Default = 0
%
% OUTPUTS:
%    optForceSets:           (cell array) cell array of size  `n x m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`). Element in position `i`, `j` is reaction
%                            `j` in set `i`.
%                            E.g.
%
%                            =====    ====    ====
%                            \        rxn1    rxn2
%                            set 1    R4      R2
%                            set 2    R3      R1
%                            =====    ====    ====
%
%    posOptForceSets:        (double array) double array of size  `n x m`,
%                            where `n` = number of sets found and `m` = size of
%                            sets found (`k`). Element in position `i`, `j` is the
%                            position of reaction in `optForceSets(i, j)` in
%                            `model.rxns`
%                            E.g.
%
%                            =====    ====    ====
%                            \        rxn1    rxn2
%                            set 1    4       2
%                            set 2    3       1
%                            =====    ====    ====
%
%    typeRegOptForceSets:    (cell array) cell array of size `n x m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`). Element in position `i`, `j` is the kind
%                            of intervention for reaction in
%                            `optForceSets(i,j)`
%                            E.g.
%
%                            =====    ============    ==============
%                            \        rxn1            rxn2
%                            set 1    upregulation    downregulation
%                            set 2    upregulation    knockout
%                            =====    ============    ==============
%
%    fluxOptForceSets:       (double matrix) Matrix of size `n + m`, where
%                            `n` = number of sets found and `m` = size of sets
%                            found (`k`). The number in `(i,j)` is the flux
%                            achieved for the reaction in `optForceSets(i, j)`
%    outputFileName.xls:     (file) file containing 11 columns.
%
%                              * C1: Number of invervetions (`k`)
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
%                            In the rows, the user can see each of the
%                            `optForce` sets found.
%    outputFileName.txt:     Same as outputFileName.xls but in a .txt file,
%                            separated by tabs.
%    optForce.lst:           (file) file generated automatically by
%                            GAMS when running `optForce`. Contains
%                            information about the running.
%    GtoMOF.gdx:             (file) file generated by GAMS containing
%                            variables, parameters and equations of the
%                            `optForce` problem.
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

parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('targetRxn', @ischar)
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
solvers = checkGAMSSolvers('MIP');
if isempty(solvers)
    error('there is no GAMS solvers available to solver Mixed Integer Programming problems') ;
else
    if ismember('cplex', lower(solvers))
        defaultSolverName = 'cplex';
    else
        defaultSolverName = lower(solvers(1));
    end
end
parser.addParamValue('solverName', defaultSolverName, @(x) ischar(x))
if strcmp(filesep,'\')
    defaultPrintExcel = 1;
else
    defaultPrintExcel = 0;
end
parser.addParamValue('printExcel', defaultPrintExcel, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printText', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printReport', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepInputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepGamsOutputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('verbose', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('loop', 0, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('kMin', 1, @(x) isnumeric(x));

parser.parse(model, targetRxn, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, varargin{:})
model = parser.Results.model;
targetRxn = parser.Results.targetRxn;
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
solverName = parser.Results.solverName;
printExcel = parser.Results.printExcel;
printText = parser.Results.printText;
printReport = parser.Results.printReport;
keepInputs = parser.Results.keepInputs;
keepGamsOutputs = parser.Results.keepGamsOutputs;
verbose = parser.Results.verbose;
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

% first, verify that GAMS is installed in your system
gamsPath = which('gams');
if isempty(gamsPath); error('OptForce: GAMS is not installed in your system. Please install GAMS.'); end;

%name of the function to solve optForce in GAMS
optForceFunction = 'optForce.gms';
%path of that function
pathOFG = which(optForceFunction);
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
    fprintf(freport, ['optForce_GAMS executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
    % print matlab version.
    fprintf(freport, ['MATLAB: Release R' version('-release') '\n']);
    % print gams version.
    gams = which('gams');
    fprintf(freport, ['GAMS: ' regexprep(gams,'\\','\\\') '\n']);
    % print solver used in GAMS to solve optForce.
    fprintf(freport, ['GAMS solver: ' solverName '\n']);

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
    if ~isempty(excludedRxns)
        for i = 1:length(excludedRxns.rxnList)
            fprintf(freport, '%s: Excluded from %s\n', excludedRxns.rxnList{i}, ...
                regexprep(excludedRxns.typeReg(i), {'U','L','K'}, {'Upregulations','Downregulations','Knockouts'}));
        end
    end
    fprintf(freport, '\nrunID(Main Folder): %s \n\noutputFolder: %s \n\noutputFileName: %s \n',...
        runID, outputFolder, outputFileName);


    fprintf(freport, '\nprintExcel: %1.0f \n\nprintText: %1.0f \n\nprintReport: %1.0f \n\nkeepInputs: %1.0f  \n\nkeepGamsOutputs: %1.0f \n\nverbose: %1.0f \n\nloop: %1.0f \n',...
        printExcel, printText, printReport, keepInputs, keepGamsOutputs, verbose, loop);
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

%copy the file for running optForce in GAMS
copyfile(pathOFG);

if loop % if k = kMin:k

    % if the user wants to generate a report, print results.
    if printReport; fprintf(freport, '\n------RESULTS------:\n'); end;

    noSolution = 1;
    currentK = kMin;

    while noSolution && currentK < k;

        %export inputs to GAMS
        inputFolder = ['InputsOptForce_k' num2str(currentK)];
        exportInputsOptForceToGAMS(model, {targetRxn}, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets,...
            constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)
        %run optForce in GAMS.
        if verbose;
            run = system(['gams ' optForceFunction ' lo=3 --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMOF --gdxin=MtoGOF']);
        else
            run = system(['gams ' optForceFunction ' --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMOF --gdxin=MtoGOF']);
        end
        %if user decide not to show inputs files for optForce
        if ~keepInputs;    rmdir(inputFolder,'s'); end;

        %if the GAMS file for optForce was executed correctly "run" should be 0
        if run == 0
            if printReport; fprintf(freport, '\nGAMS was executed correctly\n'); end;
            if verbose; fprintf('GAMS was executed correctly\nSummary of information exported by GAMS:\n'); end;
            %show GAMS report in MATLAB console
            if verbose; gdxWhos GtoMOF; end;

            %if the problem was solved correctly, a variable named optForce should be
            %inside of GtoMOF. Otherwise, the wrong file is being read.
            try
                optForce.name = 'optForce';
                rgdx('GtoMOF', optForce);
                if printReport; fprintf(freport, '\nGAMS variables were read by MATLAB correctly\n'); end;
                if verbose; fprintf('GAMS variables were read by MATLAB correctly\n'); end;

                %Using GDXMRW to read number of solutions found by optForce
                counter.name = 'counter';
                counter.compress = 'true';
                counter = rgdx('GtoMOF', counter);
                n_sols = counter.val;

                if n_sols > 0
                    % a solution was found so this ends the loop
                    noSolution = 0;
                    % if the user wants to generate a report, print number of sets
                    % found.
                    if printReport; fprintf(freport, ['\noptForce found ' num2str(n_sols) ' sets \n']); end;
                    if verbose; fprintf(['\noptForce found ' num2str(n_sols) ' sets \n']); end;

                    %Using GDXMRW to read variables generated by GAMS
                    m1.name = 'matrix1';
                    m1.compress = 'true';
                    m1 = rgdx('GtoMOF', m1);
                    uels1_m1 = m1.uels{1};
                    uels2_m1 = m1.uels{2};

                    m2.name = 'matrix2';
                    m2.compress = 'true';
                    m2 = rgdx('GtoMOF', m2);
                    uels1_m2 = m2.uels{1};
                    uels2_m2 = m2.uels{2};

                    m3.name = 'matrix3';
                    m3.compress = 'true';
                    m3 = rgdx('GtoMOF', m3);
                    uels1_m3 = m3.uels{1};
                    uels2_m3 = m3.uels{2};

                    m1_f.name = 'matrix1_flux';
                    m1_f.compress = 'true';
                    m1_f = rgdx('GtoMOF', m1_f);
                    uels1_m1_f = m1_f.uels{1};
                    uels2_m1_f = m1_f.uels{2};

                    m2_f.name = 'matrix2_flux';
                    m2_f.compress = 'true';
                    m2_f = rgdx('GtoMOF', m2_f);
                    uels1_m2_f = m2_f.uels{1};
                    uels2_m2_f = m2_f.uels{2};

                    m3_f.name = 'matrix3_flux';
                    m3_f.compress = 'true';
                    m3_f = rgdx('GtoMOF', m3_f);
                    uels1_m3_f = m3_f.uels{1};
                    uels2_m3_f = m3_f.uels{2};

                    obj.name = 'objective';
                    obj.compress = 'true';
                    obj = rgdx('GtoMOF', obj);
                    uels_obj = obj.uels{1};


                    %find values for matrices and vectors extracted from GAMS
                    if ~isempty(uels2_m1)
                        val_m1 = m1.val;
                        m1_full = full(sparse(val_m1(:,1), val_m1(:,2:end - 1), val_m1(:,3)));
                    end
                    if ~isempty(uels2_m2)
                        val_m2 = m2.val;
                        m2_full = full(sparse(val_m2(:,1), val_m2(:,2:end - 1), val_m2(:,3)));
                    end
                    if ~isempty(uels2_m3)
                        val_m3 = m3.val;
                        m3_full = full(sparse(val_m3(:,1), val_m3(:,2:end - 1), val_m3(:,3)));
                    end
                    if ~isempty(uels2_m1_f)
                        val_m1_f = m1_f.val;
                        m1_f_full = full(sparse(val_m1_f(:,1), val_m1_f(:,2:end - 1), val_m1_f(:,3)));
                    end
                    if ~isempty(uels2_m2_f)
                        val_m2_f = m2_f.val;
                        m2_f_full = full(sparse(val_m2_f(:,1), val_m2_f(:,2:end - 1), val_m2_f(:,3)));
                    end
                    if ~isempty(uels2_m3_f)
                        val_m3_f = m3_f.val;
                        m3_f_full = full(sparse(val_m3_f(:,1), val_m3_f(:,2:end - 1), val_m3_f(:,3)));
                    end
                    if ~isempty(uels_obj);
                        val_obj = obj.val(:,2);
                    end

                    %initialize empty array for saving info related to optForce
                    %sets
                    optForceSets = cell(n_sols, k);
                    posOptForceSets = zeros(size(optForceSets));
                    fluxOptForceSets = zeros(size(optForceSets));
                    typeRegOptForceSets = cell(n_sols, k);
                    solutions = cell(n_sols, 1);

                    %for each set found by optForce
                    for i = 1:n_sols
                        %find objective value achieved in the optimization problem
                        %solved by GAMS
                        if ~isempty(uels_obj) && ismember(num2str(i), uels_obj)
                            objective_value = val_obj(strcmp(num2str(i), uels_obj) == 1);
                        else
                            objective_value = 0;
                        end

                        % initialize empty array for saving info related to set i.
                        optForceSet_i = cell(k, 1);
                        pos_optForceSet_i = zeros(k, 1);
                        flux_optForceSet_i = zeros(k, 1);
                        type = cell(k, 1);
                        cont = 0;

                        % for upregulations
                        if ismember(num2str(i), uels1_m1)
                            %extract reactions in set i.
                            rxns = uels2_m1(m1_full(strcmp(num2str(i), uels1_m1) == 1,:) > 0.99)';
                            optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                            %extract positions for reactions in model.rxn.
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                            pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                            %extract type of regulations for reactions.
                            type(cont + 1:cont + length(rxns)) = {'upregulation'};
                            cont = cont + length(rxns);

                        end
                        % for downregulations
                        if ismember(num2str(i), uels1_m2)
                            rxns = uels2_m2(m2_full(strcmp(num2str(i), uels1_m2) == 1,:) > 0.99)';
                            optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                            pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                            type(cont + 1:cont + length(rxns)) = {'downregulation'};
                            cont = cont + length(rxns);
                        end
                        % for knockouts
                        if ismember(num2str(i), uels1_m3)
                            rxns = uels2_m3(m3_full(strcmp(num2str(i), uels1_m3) == 1,:) > 0.99)';
                            optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                            pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                            type(cont + 1:cont + length(rxns)) = {'knockout'};
                        end

                        %extracting fluxes achieved by upregulated reactions
                        if ismember(num2str(i), uels1_m1_f)
                            rxns = uels2_m1_f((m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,:) > 10^-6) == 1);
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x, optForceSet_i)), rxns, 'UniformOutput', false))';
                            flux_optForceSet_i(pos) = m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,(m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,:) > 10^-6) == 1);
                        end
                        %extracting fluxes achieved by downregulated reactions
                        if ismember(num2str(i),uels1_m2_f)
                            rxns = uels2_m2_f((m2_f_full(strcmp(num2str(i),uels1_m2_f) == 1,:) > 10^-6) == 1);
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x, optForceSet_i)), rxns, 'UniformOutput', false))';
                            flux_optForceSet_i(pos) = m2_f_full(strcmp(num2str(i), uels1_m2_f) == 1,(m2_f_full(strcmp(num2str(i), uels1_m2_f) == 1,:) > 10^-6) == 1);
                        end
                        %extracting fluxes achieved by deleted reactions
                        if ismember(num2str(i), uels1_m3_f)
                            rxns = uels2_m3_f((m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,:) > 10^-6) == 1);
                            pos = cell2mat(arrayfun(@(x)find(strcmp(x,optForceSet_i)), rxns, 'UniformOutput', false))';
                            flux_optForceSet_i(pos) = m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,(m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,:) > 10^-6) == 1);
                        end

                        %incorporte info of set i into general matrices.
                        optForceSets(i,:) = optForceSet_i';
                        posOptForceSets(i,:) = pos_optForceSet_i';
                        typeRegOptForceSets(i,:) = type';
                        fluxOptForceSets(i,:) = flux_optForceSet_i';

                        %export info to structures in order to print information later
                        solution.reactions = optForceSet_i;
                        solution.type = type;
                        solution.pos = pos_optForceSet_i;
                        solution.flux = flux_optForceSet_i;
                        solution.obj = objective_value;
                        [maxGrowthRate,minTarget,maxTarget]  =  analyzeOptForceSol(model, targetRxn, solution, 1);
                        solution.growth = maxGrowthRate;
                        solution.minTarget = minTarget;
                        solution.maxTarget = maxTarget;
                        solutions{i} = solution;
                    end
                else
                    %in case that none set was found, initialize empty arrays
                    if printReport;
                        fprintf(freport, '\n optForce did not find any set using k = %1.0f \n', currentK);
                        if currentK < k -1
                            fprintf(freport, '\n increasing k to %1.0f \n', currentK + 1);
                        end
                    end;
                    if verbose;
                        fprintf('\n optForce did not find any set using k = %1.0f \n', currentK);
                        if currentK < k -1
                            fprintf(freport, '\n increasing k to %1.0f \n', currentK + 1);
                        end
                    end;
                    optForceSets = {};
                    posOptForceSets = [];
                    typeRegOptForceSets = {};
                    fluxOptForceSets = {};
                end

                outputFolderK = [outputFolder '_k' num2str(currentK)];

                %remove or move additional files that were generated during running
                if keepGamsOutputs
                    if ~isdir(outputFolderK); mkdir(outputFolderK); end;
                    movefile('GtoMOF.gdx', outputFolderK);
                    movefile(regexprep(optForceFunction, 'gms', 'lst'), outputFolderK);
                else
                    delete('GtoMOF.gdx');
                    delete(regexprep(optForceFunction, 'gms', 'lst'));
                end

                %initialize name for files in which information will be printed
                hour = clock;
                if isempty(outputFileName);
                    outputFileName = ['optForceSolution-k' num2str(currentK) '-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
                else
                    outputFileNameK = [outputFileName '_k' num2str(currentK)];
                end

                % print info into an excel file if required by the user
                if printExcel
                    if n_sols > 0
                        if ~isdir(outputFolderK); mkdir(outputFolderK); end;
                        cd(outputFolderK);
                        Info = cell(2 * n_sols + 1,13);
                        Info(1,:) = [{'Number of interventions'}, {'Set number'},{'Force Set'}, {'Type of regulation'}, ...
                            {'Min flux in Wild Type (mmol/gDW hr)'}, {'Max flux in Wild Type (mmol/gDW hr)'},...
                            {'Min flux in Mutant (mmol/gDW hr)'}, {'Max flux in Mutant (mmol/gDW hr)'},{'Achieved flux (mmol/gDW hr)'},...
                            {'Objective function (mmol/gDW hr)'}, {'Minimum guaranteed for target (mmol/gDW hr)'}, ...
                            {'Maximum guaranteed for target (mmol/gDW hr)'}, {'Maximum growth rate (1/hr)'}];
                        for i = 1:n_sols
                            Info(k * (i - 1) + 2:k * (i) + 1,:) = [[{k};cell(k - 1,1)], [{i};cell(k - 1,1)], solutions{i}.reactions ...
                                solutions{i}.type num2cell(minFluxesW(solutions{i}.pos)) num2cell(maxFluxesW(solutions{i}.pos))...
                                num2cell(minFluxesM(solutions{i}.pos)) num2cell(maxFluxesM(solutions{i}.pos))...
                                num2cell(solutions{i}.flux), [{solutions{i}.obj};cell(k - 1,1)] [{solutions{i}.minTarget};cell(k - 1,1)]...
                                [{solutions{i}.maxTarget};cell(k - 1,1)] [{solutions{i}.growth};cell(k - 1,1)]];
                        end
                        xlswrite(outputFileNameK,Info)
                        cd([workingPath '/' runID]);
                        if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileNameK '.xls  \n']); end;
                        if verbose; fprintf(['Sets found by optForce were printed in ' outputFileNameK '.xls  \n']); end;
                    else
                        if printReport; fprintf(freport, '\nNo solution to optForce was found using k = %1.0f. Therefore, no excel file was generated\n', currentK); end;
                        if verbose; fprintf('No solution to optForce was found using k = %1.0f. Therefore, no excel file was generated\n', currentK); end;
                    end
                end

                % print info into a plain text file if required by the user
                if printText
                    if n_sols > 0
                        if ~isdir(outputFolderK); mkdir(outputFolderK); end;
                        cd(outputFolderK);
                        f = fopen([outputFileNameK '.txt'],'w');
                        fprintf(f,'Number of interventions\tSet number\tForce Set\tType of regulation\tMin Flux in Wild-type(mmol/gDW hr)\tMax Flux in Wild-type (mmol/gDW hr)\tMin Flux in Mutant (mmol/gDW hr)\tMax Flux in Mutant (mmol/gDW hr)\tAchieved flux (mmol/gDW hr)\tObjective function (mmol/gDW hr)\tMinimum guaranteed for target (mmol/gDW hr)\tMaximum guaranteed for target (mmol/gDW hr)\tMaximum growth rate (1/hr)\n');
                        for i = 1:n_sols
                            sols = strjoin(solutions{i}.reactions', ', ');
                            type = strjoin(solutions{i}.type', ', ');
                            minW_str = cell(1,k);
                            maxW_str = cell(1,k);
                            minM_str = cell(1,k);
                            maxM_str = cell(1,k);
                            flux_str = cell(1,k);
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
                            achieved = strjoin(flux_str,', ');
                            fprintf(f,'%1.0f\t%1.0f\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', k, i, sols, type, MinFluxW, MaxFluxW, MinFluxM,...
                                MaxFluxM, achieved, solutions{i}.obj, solutions{i}.minTarget, solutions{i}.maxTarget, solutions{i}.growth);
                        end
                        fclose(f);
                        cd([workingPath '/' runID]);
                        if printReport; fprintf(freport, ['\nSets found by optForce were printed in ' outputFileNameK '.txt  \n']); end;
                        if verbose; fprintf(['Sets found by optForce were printed in ' outputFileNameK '.txt  \n']); end;
                    else
                        if printReport; fprintf(freport, '\nNo solution to optForce was found using k = %1.0f. Therefore, no plain text file was generated\n', currentK); end;
                        if verbose; fprintf('No solution to optForce was found using k = %1.0f. Therefore, no plain text file was generated\n', currentK); end;
                    end
                end

                if ~noSolution
                    %close file for saving report
                    if printReport; fclose(freport); end;
                    delete(optForceFunction);
                    cd(workingPath);
                else
                    currentK = currentK + 1;

                    if currentK > k
                        optForceSets = {};
                        posOptForceSets = [];
                        typeRegOptForceSets = {};
                        fluxOptForceSets=[];
                    end

                end

            catch
                %GAMS variables were not read correctly by MATLAB
                if verbose; fprintf('GAMS variables were not read by MATLAB corretly\n'); end;
                if printReport; fprintf(freport, '\nGAMS variables were not read by MATLAB corretly\n'); fclose(freport); end;
                cd(workingPath);
                error('OptForce: GAMS variables were not read by MATLAB corretly');
            end
        else
            %if GAMS was not executed correcttly
            if printReport; fprintf(freport, '\nGAMS was not executed correctly\n'); fclose(freport); end;
            if verbose; fprintf('GAMS was not executed correctly\n'); end;
            cd(workingPath);
            error('OptForce: GAMS was not executed correctly');
        end

    end

    if noSolution
        %close file for saving report
        if printReport; fclose(freport); end;
        delete(optForceFunction);
        cd(workingPath);
    end

else % if k = fixed number

    %export inputs to GAMS
    inputFolder = 'InputsOptForce';
    exportInputsOptForceToGAMS(model, {targetRxn}, mustU, mustL, minFluxesW, maxFluxesW, minFluxesM, maxFluxesM, k, nSets,...
        constrOpt, excludedURxns, excludedLRxns, excludedKRxns, inputFolder)

    % if the user wants to generate a report, print results.
    if printReport; fprintf(freport, '\n------RESULTS------:\n'); end;

    %run optForce in GAMS.
    if verbose;
        run = system(['gams ' optForceFunction ' lo=3 --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMOF --gdxin=MtoGOF']);
    else
        run = system(['gams ' optForceFunction ' --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMOF --gdxin=MtoGOF']);
    end

    %if user decide not to show inputs files for optForce
    if ~keepInputs;    rmdir(inputFolder,'s'); end;

    %if the GAMS file for optForce was executed correctly "run" should be 0
    if run == 0
        if printReport; fprintf(freport, '\nGAMS was executed correctly\n'); end;
        if verbose; fprintf('GAMS was executed correctly\nSummary of information exported by GAMS:\n'); end;
        %show GAMS report in MATLAB console
        if verbose; gdxWhos GtoMOF; end;

        %if the problem was solved correctly, a variable named optForce should be
        %inside of GtoMOF. Otherwise, the wrong file is being read.
        try
            optForce.name = 'optForce';
            rgdx('GtoMOF', optForce);
            if printReport; fprintf(freport, '\nGAMS variables were read by MATLAB correctly\n'); end;
            if verbose; fprintf('GAMS variables were read by MATLAB correctly\n'); end;

            %Using GDXMRW to read number of solutions found by optForce
            counter.name = 'counter';
            counter.compress = 'true';
            counter = rgdx('GtoMOF', counter);
            n_sols = counter.val;

            if n_sols > 0
                % if the user wants to generate a report, print number of sets
                % found.
                if printReport; fprintf(freport, ['\noptForce found ' num2str(n_sols) ' sets \n']); end;
                if verbose; fprintf(['\noptForce found ' num2str(n_sols) ' sets \n']); end;

                %Using GDXMRW to read variables generated by GAMS
                m1.name = 'matrix1';
                m1.compress = 'true';
                m1 = rgdx('GtoMOF', m1);
                uels1_m1 = m1.uels{1};
                uels2_m1 = m1.uels{2};

                m2.name = 'matrix2';
                m2.compress = 'true';
                m2 = rgdx('GtoMOF', m2);
                uels1_m2 = m2.uels{1};
                uels2_m2 = m2.uels{2};

                m3.name = 'matrix3';
                m3.compress = 'true';
                m3 = rgdx('GtoMOF', m3);
                uels1_m3 = m3.uels{1};
                uels2_m3 = m3.uels{2};

                m1_f.name = 'matrix1_flux';
                m1_f.compress = 'true';
                m1_f = rgdx('GtoMOF', m1_f);
                uels1_m1_f = m1_f.uels{1};
                uels2_m1_f = m1_f.uels{2};

                m2_f.name = 'matrix2_flux';
                m2_f.compress = 'true';
                m2_f = rgdx('GtoMOF', m2_f);
                uels1_m2_f = m2_f.uels{1};
                uels2_m2_f = m2_f.uels{2};

                m3_f.name = 'matrix3_flux';
                m3_f.compress = 'true';
                m3_f = rgdx('GtoMOF', m3_f);
                uels1_m3_f = m3_f.uels{1};
                uels2_m3_f = m3_f.uels{2};

                obj.name = 'objective';
                obj.compress = 'true';
                obj = rgdx('GtoMOF', obj);
                uels_obj = obj.uels{1};


                %find values for matrices and vectors extracted from GAMS
                if ~isempty(uels2_m1)
                    val_m1 = m1.val;
                    m1_full = full(sparse(val_m1(:,1), val_m1(:,2:end - 1), val_m1(:,3)));
                end
                if ~isempty(uels2_m2)
                    val_m2 = m2.val;
                    m2_full = full(sparse(val_m2(:,1), val_m2(:,2:end - 1), val_m2(:,3)));
                end
                if ~isempty(uels2_m3)
                    val_m3 = m3.val;
                    m3_full = full(sparse(val_m3(:,1), val_m3(:,2:end - 1), val_m3(:,3)));
                end
                if ~isempty(uels2_m1_f)
                    val_m1_f = m1_f.val;
                    m1_f_full = full(sparse(val_m1_f(:,1), val_m1_f(:,2:end - 1), val_m1_f(:,3)));
                end
                if ~isempty(uels2_m2_f)
                    val_m2_f = m2_f.val;
                    m2_f_full = full(sparse(val_m2_f(:,1), val_m2_f(:,2:end - 1), val_m2_f(:,3)));
                end
                if ~isempty(uels2_m3_f)
                    val_m3_f = m3_f.val;
                    m3_f_full = full(sparse(val_m3_f(:,1), val_m3_f(:,2:end - 1), val_m3_f(:,3)));
                end
                if ~isempty(uels_obj);
                    val_obj = obj.val(:,2);
                end

                %initialize empty array for saving info related to optForce
                %sets
                optForceSets = cell(n_sols, k);
                posOptForceSets = zeros(size(optForceSets));
                fluxOptForceSets = zeros(size(optForceSets));
                typeRegOptForceSets = cell(n_sols, k);
                solutions = cell(n_sols, 1);

                %for each set found by optForce
                for i = 1:n_sols
                    %find objective value achieved in the optimization problem
                    %solved by GAMS
                    if ~isempty(uels_obj) && ismember(num2str(i), uels_obj)
                        objective_value = val_obj(strcmp(num2str(i), uels_obj) == 1);
                    else
                        objective_value = 0;
                    end

                    % initialize empty array for saving info related to set i.
                    optForceSet_i = cell(k, 1);
                    pos_optForceSet_i = zeros(k, 1);
                    flux_optForceSet_i = zeros(k, 1);
                    type = cell(k, 1);
                    cont = 0;

                    % for upregulations
                    if ismember(num2str(i), uels1_m1)
                        %extract reactions in set i.
                        rxns = uels2_m1(m1_full(strcmp(num2str(i), uels1_m1) == 1,:) > 0.99)';
                        optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                        %extract positions for reactions in model.rxn.
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                        pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                        %extract type of regulations for reactions.
                        type(cont + 1:cont + length(rxns)) = {'upregulation'};
                        cont = cont + length(rxns);

                    end
                    % for downregulations
                    if ismember(num2str(i), uels1_m2)
                        rxns = uels2_m2(m2_full(strcmp(num2str(i), uels1_m2) == 1,:) > 0.99)';
                        optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                        pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                        type(cont + 1:cont + length(rxns)) = {'downregulation'};
                        cont = cont + length(rxns);
                    end
                    % for knockouts
                    if ismember(num2str(i), uels1_m3)
                        rxns = uels2_m3(m3_full(strcmp(num2str(i), uels1_m3) == 1,:) > 0.99)';
                        optForceSet_i(cont + 1:cont + length(rxns)) = rxns;
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), rxns, 'UniformOutput', false))';
                        pos_optForceSet_i(cont + 1:cont + length(rxns)) = pos;
                        type(cont + 1:cont + length(rxns)) = {'knockout'};
                    end

                    %extracting fluxes achieved by upregulated reactions
                    if ismember(num2str(i), uels1_m1_f)
                        rxns = uels2_m1_f((m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,:) > 10^-6) == 1);
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x, optForceSet_i)), rxns, 'UniformOutput', false))';
                        flux_optForceSet_i(pos) = m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,(m1_f_full(strcmp(num2str(i), uels1_m1_f) == 1,:) > 10^-6) == 1);
                    end
                    %extracting fluxes achieved by downregulated reactions
                    if ismember(num2str(i),uels1_m2_f)
                        rxns = uels2_m2_f((m2_f_full(strcmp(num2str(i),uels1_m2_f) == 1,:) > 10^-6) == 1);
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x, optForceSet_i)), rxns, 'UniformOutput', false))';
                        flux_optForceSet_i(pos) = m2_f_full(strcmp(num2str(i), uels1_m2_f) == 1,(m2_f_full(strcmp(num2str(i), uels1_m2_f) == 1,:) > 10^-6) == 1);
                    end
                    %extracting fluxes achieved by deleted reactions
                    if ismember(num2str(i), uels1_m3_f)
                        rxns = uels2_m3_f((m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,:) > 10^-6) == 1);
                        pos = cell2mat(arrayfun(@(x)find(strcmp(x,optForceSet_i)), rxns, 'UniformOutput', false))';
                        flux_optForceSet_i(pos) = m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,(m3_f_full(strcmp(num2str(i), uels1_m3_f) == 1,:) > 10^-6) == 1);
                    end

                    %incorporte info of set i into general matrices.
                    optForceSets(i,:) = optForceSet_i';
                    posOptForceSets(i,:) = pos_optForceSet_i';
                    typeRegOptForceSets(i,:) = type';
                    fluxOptForceSets(i,:) = flux_optForceSet_i';

                    %export info to structures in order to print information later
                    solution.reactions = optForceSet_i;
                    solution.type = type;
                    solution.pos = pos_optForceSet_i;
                    solution.flux = flux_optForceSet_i;
                    solution.obj = objective_value;
                    [maxGrowthRate,minTarget,maxTarget]  =  analyzeOptForceSol(model, targetRxn, solution, 1);
                    solution.growth = maxGrowthRate;
                    solution.minTarget = minTarget;
                    solution.maxTarget = maxTarget;
                    solutions{i} = solution;
                end
            else
                %in case that none set was found, initialize empty arrays
                if printReport; fprintf(freport, '\n optForce did not find any set \n'); end;
                if verbose; fprintf('\n optForce did not find any set \n'); end;
                optForceSets = {};
                posOptForceSets = [];
                typeRegOptForceSets = {};
                fluxOptForceSets = {};
            end

            %remove or move additional files that were generated during running
            if keepGamsOutputs
                if ~isdir(outputFolder); mkdir(outputFolder); end;
                movefile('GtoMOF.gdx', outputFolder);
                movefile(regexprep(optForceFunction, 'gms', 'lst'), outputFolder);
            else
                delete('GtoMOF.gdx');
                delete(regexprep(optForceFunction, 'gms', 'lst'));
            end

            %initialize name for files in which information will be printed
            hour = clock;
            if isempty(outputFileName);
                outputFileName = ['optForceSolution-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
            end

            % print info into an excel file if required by the user
            if printExcel
                if n_sols > 0
                    if ~isdir(outputFolder); mkdir(outputFolder); end;
                    cd(outputFolder);
                    Info = cell(2 * n_sols + 1,13);
                    Info(1,:) = [{'Number of interventions'}, {'Set number'},{'Force Set'}, {'Type of regulation'}, ...
                        {'Min flux in Wild Type (mmol/gDW hr)'}, {'Max flux in Wild Type (mmol/gDW hr)'},...
                        {'Min flux in Mutant (mmol/gDW hr)'}, {'Max flux in Mutant (mmol/gDW hr)'},{'Achieved flux (mmol/gDW hr)'},...
                        {'Objective function (mmol/gDW hr)'}, {'Minimum guaranteed for target (mmol/gDW hr)'}, ...
                        {'Maximum guaranteed for target (mmol/gDW hr)'}, {'Maximum growth rate (1/hr)'}];
                    for i = 1:n_sols
                        Info(k * (i - 1) + 2:k * (i) + 1,:) = [[{k};cell(k - 1,1)], [{i};cell(k - 1,1)], solutions{i}.reactions ...
                            solutions{i}.type num2cell(minFluxesW(solutions{i}.pos)) num2cell(maxFluxesW(solutions{i}.pos))...
                            num2cell(minFluxesM(solutions{i}.pos)) num2cell(maxFluxesM(solutions{i}.pos))...
                            num2cell(solutions{i}.flux), [{solutions{i}.obj};cell(k - 1,1)] [{solutions{i}.minTarget};cell(k - 1,1)]...
                            [{solutions{i}.maxTarget};cell(k - 1,1)] [{solutions{i}.growth};cell(k - 1,1)]];
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
                if n_sols > 0
                    if ~isdir(outputFolder); mkdir(outputFolder); end;
                    cd(outputFolder);
                    f = fopen([outputFileName '.txt'],'w');
                    fprintf(f,'Number of interventions\tSet number\tForce Set\tType of regulation\tMin Flux in Wild-type(mmol/gDW hr)\tMax Flux in Wild-type (mmol/gDW hr)\tMin Flux in Mutant (mmol/gDW hr)\tMax Flux in Mutant (mmol/gDW hr)\tAchieved flux (mmol/gDW hr)\tObjective function (mmol/gDW hr)\tMinimum guaranteed for target (mmol/gDW hr)\tMaximum guaranteed for target (mmol/gDW hr)\tMaximum growth rate (1/hr)\n');
                    for i = 1:n_sols
                        sols = strjoin(solutions{i}.reactions', ', ');
                        type = strjoin(solutions{i}.type', ', ');
                        minW_str = cell(1,k);
                        maxW_str = cell(1,k);
                        minM_str = cell(1,k);
                        maxM_str = cell(1,k);
                        flux_str = cell(1,k);
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
                        achieved = strjoin(flux_str,', ');
                        fprintf(f,'%1.0f\t%1.0f\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t{%s}\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', k, i, sols, type, MinFluxW, MaxFluxW, MinFluxM,...
                            MaxFluxM, achieved, solutions{i}.obj, solutions{i}.minTarget, solutions{i}.maxTarget, solutions{i}.growth);
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
            delete(optForceFunction);
            cd(workingPath);

        catch
            %GAMS variables were not read correctly by MATLAB
            if verbose; fprintf('GAMS variables were not read by MATLAB corretly\n'); end;
            if printReport; fprintf(freport, '\nGAMS variables were not read by MATLAB corretly\n'); fclose(freport); end;
            cd(workingPath);
            error('OptForce: GAMS variables were not read by MATLAB corretly');
        end
    else
        %if GAMS was not executed correcttly
        if printReport; fprintf(freport, '\nGAMS was not executed correctly\n'); fclose(freport); end;
        if verbose; fprintf('GAMS was not executed correctly\n'); end;
        cd(workingPath);
        error('OptForce: GAMS was not executed correctly');
    end

end

end

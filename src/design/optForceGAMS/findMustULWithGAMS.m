function [mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = findMustULWithGAMS(model, minFluxesW, maxFluxesW, constrOpt, excludedRxns, mustSetFirstOrder, solverName, runID, outputFolder, outputFileName, printExcel, printText, printReport, keepInputs, keepGamsOutputs, verbose)
% This function runs the second step of `optForce`, that is to solve a
% bilevel mixed integer linear programming  problem to find a second order
% MustUL set.
%
% USAGE:
%
%    [mustUL, pos_mustUL, mustUL_linear, pos_mustUL_linear] = findMustULWithGAMS(model, minFluxesW, maxFluxesW, varargin)
%
% INPUTS:
%    model:                      (structure) a metabolic model with at
%                                least the following fields:
%
%                                  * .rxns - Reaction IDs in the model
%                                  * .mets - Metabolite IDs in the model
%                                  * .S - Stoichiometric matrix (sparse)
%                                  * .b - RHS of `Sv = b` (usually zeros)
%                                  * .c - Objective coefficients
%                                  * .lb - Lower bounds for fluxes
%                                  * .ub - Upper bounds for fluxes
%    minFluxesW:                 (double array of size `n_rxns x 1`) minimum
%                                fluxes for each reaction in the model for
%                                wild-type strain. This can be obtained by
%                                running the function `FVAOptForce`. E.g.:
%                                `minFluxesW = [-90; -56];`
%    maxFluxesW:                 (double array of size n_rxns x 1) maximum
%                                fluxes for each reaction in the model for
%                                wild-type strain. This can be obtained by
%                                running the function `FVAOptForce`. E.g.:
%                                `maxFluxesW = [90; 56];`
%
% OPTIONAL INPUTS:
%    constrOpt:                  (Structure) structure containing
%                                additional contraints. Include here only
%                                reactions whose flux is fixed, i.e.,
%                                reactions whose lower and upper bounds
%                                have the same value. Do not include here
%                                reactions whose lower and upper bounds
%                                have different values. Such contraints
%                                should be defined in the lower and upper
%                                bounds of the model. The structure has the
%                                following fields:
%
%                                  * .rxnList - Reaction list (cell array)
%                                  * .values -  Values for constrained
%                                    reactions (double array)
%                                    E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    excludedRxns:               (cell array) Reactions to be excluded to
%                                the `MustUL` set. This could be used to
%                                avoid finding transporters or exchange
%                                reactions in the set. Default = empty.
%    mustSetFirstOrder:          (cell array) Reactions that belong to
%                                `MustU` and `MustL` (first order sets).
%                                Default = empty.
%    solverName:                 (string) Name of the solver used in
%                                GAMS. Default = 'cplex'.
%    runID:                      (string) ID for identifying this run.
%                                Default = ['run' date hour].
%    outputFolder:               (string) name for folder in which
%                                results will be stored.
%                                Default = 'OutputsFindMustUL'.
%    outputFileName:             (string) name for files in which
%                                results. will be stored
%                                Default = 'MustULSet'.
%    printExcel:                 (double) boolean to describe wheter
%                                data must be printed in an excel file or
%                                not. Default = 1
%    printText:                  (double) boolean to describe wheter
%                                data must be printed in an plaint text
%                                file or not. Default = 1
%    printReport:                (double) 1 to generate a report in a
%                                plain text file. 0 otherwise. Default = 1
%    keepInputs:                 (double) 1 to mantain folder with
%                                inputs to run `findMustUL.gms`. 0 otherwise.
%                                Default = 1
%    keepGamsOutputs:            (double) 1 to mantain files returned by
%                                `findMustUL.gms`. 0 otherwise. Default = 1
%    verbose:                    (double) 1 to print results in console.
%                                0 otherwise. Default = 0
%
% OUTPUTS:
%    mustUL:                     (cell array of size number of sets found X
%                                2) Cell array containing the reactions IDs
%                                which belong to the `MustUL` set. Each row
%                                contain a couple of reactions that must
%                                decrease their flux.
%    pos_mustUL:                 (double array of size number of sets found
%                                X 2) double array containing the positions
%                                of each reaction in `mustUL` with regard to
%                                model.rxns
%    mustUL_linear:              (cell array of size number of unique
%                                reactions found X 1) Cell array containing
%                                the unique reactions ID which belong to
%                                the `MustUL` Set
%    pos_mustUL_linear:          (double array of size number of unique
%                                reactions found X 1) double array
%                                containing positions for reactions in
%                                mustUL_linear. with regard to `model.rxns`
%    outputFileName.xls:         (file) File containing one column
%                                array with identifiers for reactions in
%                                MustUL. This file will only be generated
%                                if the user entered `printExcel = 1`. Note
%                                that the user can choose the name of this
%                                file entering the input `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName.txt:         (file) File containing one column
%                                array with identifiers for reactions in
%                                MustUL. This file will only be generated
%                                if the user entered `printText = 1`. Note
%                                that the user can choose the name of this
%                                file entering the input `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.xls:    (file) File containing one column
%                                array. In each row the user will find a
%                                couple of reactions. Each couple of
%                                reaction was found in one iteration of
%                                `FindMustUL.gms`. This file will only be
%                                generated if the user entered `printExcel = 1`.
%                                Note that the user can choose the name
%                                of this file entering the input
%                                `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.txt:    (file) File containing one column
%                                array. In each row the user will find a
%                                couple of reactions. Each couple of
%                                reaction was found in one iteration of
%                                `FindMustUL.gms`. This file will only be
%                                generated if the user entered `printText = 1`.
%                                Note that the user can choose the name
%                                of this file entering the input
%                                `outputFileName = 'PutYourOwnFileNameHere';`
%    findMustUL.lst:             (file) file autogenerated by GAMS. It
%                                contains information about equations,
%                                variables, parameters as well as
%                                information about the running (values at
%                                each iteration). This file only will be
%                                saved in the output folder is the user
%                                entered `keepGamsOutputs = 1`
%    GtoMUL.gdx:                 (file) file containing values for
%                                variables, parameters, etc. which were
%                                found by GAMS when solving `findMustUL.gms`.
%                                This file only will be saved in the output
%                                folder is the user entered `keepInputs = 1`
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

optionalParameters = {'constrOpt', 'excludedRxns', 'mustSetFirstOrder', 'solverName', 'runID', 'outputFolder', 'outputFileName',  ...
    'printExcel', 'printText', 'printReport', 'keepInputs', 'keepGamsOutputs', 'verbose'};

if (numel(varargin) > 0 && (~ischar(varargin{1}) || ~any(ismember(varargin{1},optionalParameters))))

    tempargin = cell(1,2*(numel(varargin)));
    for i = 1:numel(varargin)

        tempargin{2*(i-1)+1} = optionalParameters{i};
        tempargin{2*(i-1)+2} = varargin{i};
    end
    varargin = tempargin;

end

parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('minFluxesW', @isnumeric)
parser.addRequired('maxFluxesW', @isnumeric)
parser.addParamValue('constrOpt', struct('rxnList', {{}}, 'values', []),@ (x) isstruct(x) && isfield(x, 'rxnList') && isfield(x, 'values') ...
    && length(x.rxnList) == length(x.values) && length(intersect(x.rxnList, model.rxns)) == length(x.rxnList))
parser.addParamValue('excludedRxns', {}, @(x) iscell(x) && length(intersect(x, model.rxns)) == length(x))
parser.addParamValue('mustSetFirstOrder', {}, @(x) iscell(x) && length(intersect(x, model.rxns)) == length(x))
solvers = checkGAMSSolvers('MIP');
if isempty(solvers)
    error('there is no GAMS solvers available to solve Mixed Integer Programming problems') ;
else
    if ismember('cplex', lower(solvers))
        defaultSolverName = 'cplex';
    else
        defaultSolverName = lower(solvers(1));
    end
end

parser.addParamValue('solverName', defaultSolverName, @(x) ischar(x))
hour = clock; defaultRunID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
parser.addParamValue('runID', defaultRunID, @(x) ischar(x))
parser.addParamValue('outputFolder', 'OutputsFindMustUL', @(x) ischar(x))
parser.addParamValue('outputFileName', 'MustULSet', @(x) ischar(x))
parser.addParamValue('printExcel', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printText', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printReport', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepInputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepGamsOutputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('verbose', 1, @(x) isnumeric(x) || islogical(x));

parser.parse(model, minFluxesW, maxFluxesW, varargin{:})
model = parser.Results.model;
minFluxesW = parser.Results.minFluxesW;
maxFluxesW = parser.Results.maxFluxesW;
constrOpt= parser.Results.constrOpt;
excludedRxns= parser.Results.excludedRxns;
mustSetFirstOrder = parser.Results.mustSetFirstOrder;
solverName = parser.Results.solverName;
runID = parser.Results.runID;
outputFolder = parser.Results.outputFolder;
outputFileName = parser.Results.outputFileName;
printExcel = parser.Results.printExcel;
printText = parser.Results.printText;
printReport = parser.Results.printReport;
keepInputs = parser.Results.keepInputs;
keepGamsOutputs = parser.Results.keepGamsOutputs;
verbose = parser.Results.verbose;

% correct size of constrOpt
if ~isempty(constrOpt.rxnList)
    if size(constrOpt.rxnList, 1) > size(constrOpt.rxnList,2); constrOpt.rxnList = constrOpt.rxnList'; end;
    if size(constrOpt.values, 1) > size(constrOpt.values,2); constrOpt.values = constrOpt.values'; end;
end

% first, verify that GAMS is installed in your system
gamsPath = which('gams');
if isempty(gamsPath); error('OptForce: GAMS is not installed in your system. Please install GAMS.'); end;

%name of the function to solve the optimization problem in GAMS
gamsMustULFunction = 'findMustUL.gms';
%path of that function
pathGamsFunction = which(gamsMustULFunction);
if isempty(pathGamsFunction); error(['OptForce: ' gamsMustULFunction ' not in MATLAB path.']); end;
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
    reportClosed = 0;
    % print date of running.
    fprintf(freport, ['findMustULWithGAMS.m executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
    % print matlab version.
    fprintf(freport, ['MATLAB: Release R' version('-release') '\n']);
    % print gams version.
    fprintf(freport, ['GAMS: ' regexprep(gamsPath, '\\', '\\\') '\n']);
    % print solver used in GAMS to solve optForce.
    fprintf(freport, ['GAMS solver: ' solverName '\n']);

    %print each of the inputs used in this running.
    fprintf(freport, '\nThe following inputs were used to run OptForce: \n');
    fprintf(freport, '\n------INPUTS------\n');
    %print model.
    fprintf(freport, '\nModel:\n');
    for i = 1:length(model.rxns)
        rxn = printRxnFormula(model, model.rxns{i}, false);
        fprintf(freport, [model.rxns{i} ': ' rxn{1} '\n']);
    end
    %print lower and upper bounds, minimum and maximum values for each of
    %the reactions in wild-type and mutant strain
    fprintf(freport, '\nLB\tUB\tMin_WT\tMax_WT\n');
    for i = 1:length(model.rxns)
        fprintf(freport, '%6.4f\t%6.4f\t%6.4f\t%6.4f\n', model.lb(i), model.ub(i), minFluxesW(i), maxFluxesW(i));
    end

    %print constraints
    fprintf(freport,'\nConstrained reactions:\n');
    for i = 1:length(constrOpt.rxnList)
        fprintf(freport,'%s: fixed in %6.4f\n', constrOpt.rxnList{i}, constrOpt.values(i));
    end

    fprintf(freport, '\nExcluded Reactions:\n');
    for i = 1:length(excludedRxns)
        rxn = printRxnFormula(model, excludedRxns{i}, false);
        fprintf(freport, [excludedRxns{i} ': ' rxn{1} '\n']);
    end

    fprintf(freport, '\nReactions from first order sets(MustU and MustL):\n');
    for i = 1:length(mustSetFirstOrder)
        rxn = printRxnFormula(model, mustSetFirstOrder{i}, false);
        fprintf(freport, [mustSetFirstOrder{i} ': ' rxn{1} '\n']);
    end

    fprintf(freport,'\nrunID(Main Folder): %s \n\noutputFolder: %s \n\noutputFileName: %s \n',...
        runID, outputFolder, outputFileName);


    fprintf(freport,'\nprintExcel: %1.0f \n\nprintText: %1.0f \n\nprintReport: %1.0f \n\nkeepInputs: %1.0f  \n\nkeepGamsOutputs: %1.0f \n\nverbose: %1.0f \n',...
        printExcel, printText, printReport, keepInputs, keepGamsOutputs, verbose);

end

copyfile(pathGamsFunction);

% export inputs for running the optimization problem in GAMS to find the
% MustUL Set
inputFolder = 'InputsMustUL';
exportInputsMustOrder2ToGAMS(model, 'UL', minFluxesW, maxFluxesW, constrOpt, excludedRxns, mustSetFirstOrder, inputFolder)

% create a directory to save results if this don't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%run
if verbose
    run = system(['gams ' gamsMustULFunction ' lo=3 --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMUL']);
else
    run=system(['gams ' gamsMustULFunction ' --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoMUL']);
end

if printReport; fprintf(freport, '\n------RESULTS------\n'); end;

%if user decide not to show inputs files for findMustUL.gms
if ~keepInputs; rmdir(inputFolder, 's'); end;

%if findMustUL.gms was executed correctly "run" should be 0
if run == 0

    if printReport; fprintf(freport, '\nGAMS was executed correctly\n'); end;
    if verbose; fprintf('GAMS was executed correctly\nSummary of information exported by GAMS:\n'); end;
    %show GAMS report in MATLAB console
    if verbose; gdxWhos GtoMUL; end;
    try
        findMustUL.name = 'findMustUL';
        rgdx('GtoMUL', findMustUL); %if do not exist the variable findMustUL in GtoMUL, an error will ocurr.
        if printReport; fprintf(freport, '\nGAMS variables were read by MATLAB correctly\n'); end;
        if verbose; fprintf('GAMS variables were read by MATLAB correctly\n'); end;

        %Using GDXMRW to read solutions found by findMustUL.gms
        %extract matrix 1 found by findMustII.gms. This matrix contains the
        %first reaction in each couple of reactions
        m1.name = 'matrix1';
        m1.compress = 'true';
        m1 = rgdx('GtoMUL', m1);
        uels_m1 = m1.uels{2};


        if ~isempty(uels_m1)
            %if the uel array for m1 is not empty, at least 1 couple of reations was found.
            if printReport; fprintf(freport, '\na MustUL set was found\n'); end;
            if verbose; fprintf('a MustUL set was found\n'); end;

            %find values for matrix 1
            val_m1 = m1.val;
            m1_full = full(sparse(val_m1(:,1), val_m1(:,2:end-1), val_m1(:,3)));

            %find values for matrix 2
            m2.name = 'matrix2';
            m2.compress = 'true';
            m2 = rgdx('GtoMUL', m2);
            uels_m2 = m2.uels{2};
            val_m2 = m2.val;
            m2_full = full(sparse(val_m2(:,1), val_m2(:,2:end-1), val_m2(:,3)));

            %initialize empty array for storing
            n_mustSet = size(m1_full,1);
            mustUL = cell(n_mustSet, 2);
            pos_mustUL = zeros(size(mustUL));
            mustUL_linear = {};

            %write each couple of reactions.
            for i = 1:n_mustSet
                rxn1 = uels_m1(m1_full(i,:) == 1);
                rxn2 = uels_m2(m2_full(i,:) == 1);
                mustUL(i,1) = rxn1;
                mustUL(i,2) = rxn2;
                pos_mustUL(i,1) = find(strcmp(model.rxns, rxn1));
                pos_mustUL(i,2) = find(strcmp(model.rxns, rxn2));
                mustUL_linear = union(mustUL_linear, [rxn1;rxn2]);
            end
            pos_mustUL_linear = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), mustUL_linear, 'UniformOutput', false))';
        else
            %if the uel array for m1 is empty, no couple of reations was found.
            if printReport; fprintf(freport, '\na MustUL set was not found\n'); end;
            if verbose; fprintf('a MustUL set was not found\n'); end;

            %initialize arrays to be returned by this function
            mustUL = {};
            pos_mustUL = [];
            mustUL_linear = {};
            pos_mustUL_linear = [];
        end

        % print info into an excel file if required by the user
        if printExcel
            if  ~isempty(uels_m1)
                currentFolder = pwd;
                cd(outputFolder);
                must = cell(size(mustUL,1), 1);
                for i = 1:size(mustUL, 1)
                    must{i} = strjoin(mustUL(i,:), ' or ');
                end
                xlswrite([outputFileName '_Info'],[{'Reactions'};must]);
                xlswrite(outputFileName, mustUL_linear);
                cd(currentFolder);
                if verbose
                    fprintf(['MustUL set was printed in ' outputFileName '.xls  \n']);
                    fprintf(['MustUL set was also printed in ' outputFileName '_Info.xls  \n']);
                end
                if printReport
                    fprintf(freport, ['\nMustUL set was printed in ' outputFileName '.xls  \n']);
                    fprintf(freport, ['\nMustUL set was printed in ' outputFileName '_Info.xls  \n']);
                end
            else
                if verbose; fprintf('No mustUL set was found. Therefore, no excel file was generated\n'); end;
                if printReport; fprintf(freport, '\nNo mustUL set was found. Therefore, no excel file was generated\n'); end;
            end
        end

        % print info into a plain text file if required by the user
        if printText
            if ~isempty(uels_m1)
                currentFolder = pwd;
                cd(outputFolder);
                f = fopen([outputFileName '_Info.txt'], 'w');
                fprintf(f,'Reactions\n');
                for i = 1:size(mustUL,1)
                    fprintf(f, '%s or %s\n', mustUL{i,1}, mustUL{i,2});
                end
                fclose(f);

                f = fopen([outputFileName '.txt'], 'w');
                for i = 1:length(mustUL_linear)
                    fprintf(f, '%s\n', mustUL_linear{i});
                end
                fclose(f);

                cd(currentFolder);
                if verbose
                    fprintf(['MustUL set was printed in ' outputFileName '.txt  \n']);
                    fprintf(['MustUL set was also printed in ' outputFileName '_Info.txt  \n']);
                end
                if printReport
                    fprintf(freport, ['\nMustUL set was printed in ' outputFileName '.txt  \n']);
                    fprintf(freport, ['\nMustUL set was printed in ' outputFileName '_Info.txt  \n']);
                end

            else
                if verbose; fprintf('No mustUL set was found. Therefore, no plain text file was generated\n'); end;
                if printReport; fprintf(freport, '\nNo mustUL set was found. Therefore, no plain text file was generated\n'); end;
            end
        end

        %close file for saving report
        if printReport; fclose(freport); reportClosed = 1; end;
        if printReport; movefile(reportFileName, outputFolder); end;
        delete(gamsMustULFunction);

        %remove or move additional files that were generated during running
        if keepGamsOutputs
            if ~isdir(outputFolder); mkdir(outputFolder); end;
            movefile('GtoMUL.gdx', outputFolder);
            movefile(regexprep(gamsMustULFunction, 'gms', 'lst'), outputFolder);
        else
            delete('GtoMUL.gdx');
            delete(regexprep(gamsMustULFunction, 'gms', 'lst'));
        end

        %go back to the original path
        cd(workingPath);
    catch
        %GAMS variables were not read correctly by MATLAB
        if verbose; fprintf('GAMS variables were not read by MATLAB corretly\n'); end;
        if printReport && ~reportClosed; fprintf(freport, '\nGAMS variables were not read by MATLAB corretly\n'); fclose(freport); end;
        cd(workingPath);
        error('OptForce: GAMS variables were not read by MATLAB corretly');

    end

    %if findMustUL.gms was not executed correctly "run" should be different from 0
else
    %if GAMS was not executed correcttly
    if printReport && ~reportClosed; fprintf(freport, '\nGAMS was not executed correctly\n'); fclose(freport); end;
    if verbose; fprintf('GAMS was not executed correctly\n'); end;
    cd(workingPath);
    error('OptForce: GAMS was not executed correctly');

end

end

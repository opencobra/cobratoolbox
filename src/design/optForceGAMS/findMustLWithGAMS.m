function [mustLSet, posMustL] = findMustLWithGAMS(model, minFluxesW, maxFluxesW, varargin)
% This function runs the second step of `optForce`, that is to solve a
% bilevel mixed integer linear programming  problem to find a first order
% `MustL` set.
%
% USAGE:
%
%    [mustLSet, posMustL] = findMustLWithGAMS(model, minFluxesW, maxFluxesW, varargin)
%
%
% INPUTS:
%    model:                      (structure) a metabolic model with at least
%                                the following fields:
%
%                                     * .rxns - Reaction IDs in the model
%                                     * .mets - Metabolite IDs in the model
%                                     * .S - Stoichiometric matrix (sparse)
%                                     * .b - RHS of `Sv = b` (usually zeros)
%                                     * .c - Objective coefficients
%                                     * .lb - Lower bounds for fluxes
%                                     * .ub - Upper bounds for fluxes
%    minFluxesW:                 (double array of size `n_rxns x 1`) minimum
%                                fluxes for each reaction in the model for
%                                wild-type strain. This can be obtained by
%                                running the function `FVAOptForce` e.g.:
%                                `minFluxesW = [-90; -56];`
%    maxFluxesW:                 (double array of size `n_rxns x 1`) maximum
%                                fluxes for each reaction in the model for
%                                wild-type strain. This can be obtained by
%                                running the function `FVAOptForce` e.g.:
%                                `maxFluxesW=[90; 56];`
%
% OPTIONAL INPUTS:
%    constrOpt:                  (structure) structure containing additional
%                                contraints. Include here only reactions
%                                whose flux is fixed, i.e., reactions whose
%                                lower and upper bounds have the same value.
%                                Do not include here reactions whose lower
%                                and upper bounds have different values. Such
%                                contraints should be defined in the lower
%                                and upper bounds of the model. The structure
%                                has the following fields:
%
%                                     * .rxnList - Reaction list (cell array)
%                                     * .values - Values for constrained reactions (double array)
%                                       e.g.: `struct('rxnList',{{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100,0,155.5]');`
%    solverName:                 (string) Name of the solver used in GAMS.
%                                Default = 'cplex'
%    runID:                      (string) ID for identifying this run
%    outputFolder:               (string) name for folder in which
%                                results will be stored
%    outputFileName:             (string) name for files in which results
%                                will be stored
%    printExcel:                 (double) boolean to describe wheter data
%                                must be printed in an excel file or not
%    printText:                  (double) boolean to describe wheter data
%                                must be printed in an plaint text file or
%                                not
%    printReport:                (double) 1 to generate a report in a
%                                plain text file. 0 otherwise.
%    keepInputs:                 (double) 1 to mantain folder with inputs
%                                to run `findMustUU.gms`. 0 otherwise.
%    keepGamsOutputs:            (double) 1 to mantain files returned by
%                                `findMustUU.gms`. 0 otherwise.
%    verbose:                    (double) 1 to print results in console.
%                                0 otherwise.
% OUTPUTS:
%    mustLSet:                   (cell array of size number of reactions
%                                found X 1) Cell array containing the
%                                reactions ID which belong to the `Must_U` Set
%    posMustL:                   (double array of size number of reactions
%                                found X 1) double array containing the
%                                positions of reactions in the model.
%    outputFileName.xls:         (file) File containing one column array
%                                with identifiers for reactions in MustL.
%                                This file will only be generated if the user
%                                entered `printExcel = 1`. Note that the user
%                                can choose the name of this file entering
%                                the input `outputFileName =
%                                'PutYourOwnFileNameHere';`
%    outputFileName.txt:         (file) File containing one column array
%                                with identifiers for reactions in MustL.
%                                This file will only be generated if the user
%                                entered `printText = 1`. Note that the user
%                                can choose the name of this file entering
%                                the input `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.xls:    (file) File containing five column
%                                arrays.
%
%                                  * C1: identifiers for reactions in `MustL`
%                                  * C2: min fluxes for reactions according to FVA
%                                  * C3: max fluxes for reactions according to FVA
%                                  * C4: min fluxes achieved for reactions,
%                                    according to `findMustL.gms`
%                                  * C5: max fluxes achieved for reactions,
%                                    according to `findMustL.gms`
%                                This file will only be generated if the user
%                                entered `printExcel = 1`. Note that the user
%                                can choose the name of this file entering
%                                the input `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.txt:    (file) File containing five column
%                                arrays.
%
%                                  * C1: identifiers for reactions in `MustL`
%                                  * C2: min fluxes for reactions according to FVA
%                                  * C3: max fluxes for reactions according to FVA
%                                  * C4: min fluxes achieved for reactions,
%                                    according to `findMustL.gms`
%                                  * C5: max fluxes achieved for reactions,
%                                    according to `findMustL.gms`
%                                This file will only be generated if the user
%                                entered `printText = 1`. Note that the user
%                                can choose the name of this file entering
%                                the input `outputFileName = 'PutYourOwnFileNameHere';`
%    findMustL.lst:              (file) file autogenerated by GAMS. It
%                                contains information about equations,
%                                variables, parameters as well as information
%                                about the running (values at each
%                                iteration). This file only will be saved in
%                                the output folder is the user entered
%                                `keepGamsOutputs = 1`
%    GtoML.gdx:                  (file) file containing values for
%                                variables, parameters, etc. which were found
%                                by GAMS when solving `findMustL.gms`. This
%                                file only will be saved in the output folder
%                                is the user entered `keepInputs = 1`
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

optionalParameters = {'constrOpt', 'solverName', 'runID', 'outputFolder', 'outputFileName',  ...
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
parser.addRequired('model',@(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('minFluxesW',@isnumeric)
parser.addRequired('maxFluxesW',@isnumeric)
parser.addParamValue('constrOpt', struct('rxnList', {{}}, 'values', []), @(x) isstruct(x) && isfield(x, 'rxnList') && isfield(x, 'values') ...
    && length(x.rxnList) == length(x.values) && length(intersect(x.rxnList, model.rxns)) == length(x.rxnList))
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
hour = clock; defaultRunID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
parser.addParamValue('runID', defaultRunID, @(x) ischar(x))
parser.addParamValue('outputFolder', 'OutputsFindMustL', @(x) ischar(x))
parser.addParamValue('outputFileName', 'MustLSet', @(x) ischar(x))
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
gamsMustLFunction = 'findMustL.gms';
%path of that function
pathGamsFunction = which(gamsMustLFunction);
if isempty(pathGamsFunction); error(['optForce: ' gamsMustLFunction ' not in MATLAB path.']); end;
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
    fprintf(freport, ['findMustLWithGAMS.m executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
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

    fprintf(freport,'\nrunID(Main Folder): %s \n\noutputFolder: %s \n\noutputFileName: %s \n',...
        runID, outputFolder, outputFileName);


    fprintf(freport,'\nprintExcel: %1.0f \n\nprintText: %1.0f \n\nprintReport: %1.0f \n\nkeepInputs: %1.0f  \n\nkeepGamsOutputs: %1.0f \n\nverbose: %1.0f \n',...
        printExcel, printText, printReport, keepInputs, keepGamsOutputs, verbose);

end

copyfile(pathGamsFunction);

% export inputs for running the optimization problem in GAMS to find the
% MustL Set
inputFolder = 'InputsMustL';
exportInputsMustToGAMS(model, 'L', minFluxesW, maxFluxesW, constrOpt,inputFolder)

% create a directory to save results if this don't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%run
if verbose
    run = system(['gams ' gamsMustLFunction ' lo=3 --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoML']);
else
    run = system(['gams ' gamsMustLFunction ' --myroot=' inputFolder '/ --solverName=' solverName ' gdx=GtoML']);
end

if printReport; fprintf(freport, '\n------RESULTS------\n'); end;

%if user decide not to show inputs files for findMustL.gms
if ~keepInputs; rmdir(inputFolder,'s'); end;

%if findMustL.gms was executed correctly "run" should be 0
if run == 0
    if printReport; fprintf(freport, '\nGAMS was executed correctly\n'); end;
    if verbose; fprintf('GAMS was executed correctly\nSummary of information exported by GAMS:\n'); end;
    %show GAMS report in MATLAB console
    if verbose; gdxWhos GtoML; end;

    %if the problem was solved correctly, a variable named findMustL should be
    %inside of GtoML. Otherwise, the wrong file is being read.
    try
        findMustL.name = 'findMustL';
        rgdx('GtoML', findMustL);
        if printReport; fprintf(freport, '\nGAMS variables were read by MATLAB correctly\n'); end;
        if verbose; fprintf('GAMS variables were read by MATLAB correctly\n'); end;

        %Using GDXMRW to read solutions found by findMustL.gms
        %extract must L set found by findMustL.gms
        must.name = 'must';
        must.compress = 'true';
        must = rgdx('GtoML', must);
        uelsMust = must.uels{1};

        %if the set is not empty
        if ~isempty(uelsMust)
            if printReport; fprintf(freport, '\na MustL set was found\n'); end;
            if verbose; fprintf('a MustL set was found\n'); end;
            mustLSet = uelsMust';
            %find position for reactions of the MustL set in model.rxns
            posMustL = cell2mat(arrayfun(@(x)find(strcmp(x, model.rxns)), mustLSet, 'UniformOutput', false))';

            %find values of fluxes achieved by each reaction in MustL set
            minFlux = zeros(size(mustLSet));
            maxFlux = zeros(size(mustLSet));

            %extract minimum values
            vmin.name = 'vmin';
            vmin.compress = 'true';
            vmin = rgdx('GtoML', vmin);
            uels_vmin = vmin.uels{1};
            if ~isempty(uels_vmin)
                val_vmin = vmin.val(:,2);
                for i = 1:length(uels_vmin)
                    pos = strcmp(mustLSet, uels_vmin{i});
                    minFlux(pos == 1) = val_vmin(i);
                end
            end

            %extract miximum values
            vmax.name = 'vmax';
            vmax.compress = 'true';
            vmax = rgdx('GtoML', vmax);
            uels_vmax = vmax.uels{1};
            if ~isempty(uels_vmax)
                val_vmax = vmax.val(:,2);
                for i = 1:length(uels_vmax)
                    pos = strcmp(mustLSet, uels_vmax{i});
                    maxFlux(pos == 1) = val_vmax(i);
                end
            end
        else
            if printReport; fprintf(freport, '\na MustL set was not found\n'); end;
            if verbose; fprintf('a MustL set was not found\n'); end;
        end

        % print info into an excel file if required by the user
        if printExcel
            if ~isempty(mustLSet)
                currentFolder = pwd;
                cd(outputFolder);
                Info = [{'Reactions'},{'Min Flux in Wild-type strain'},{'Max Flux in Wild-type strain'},{'Min Flux in Mutant strain'},{'Max Flux in Mutant strain'}];
                Info = [Info; [mustLSet, num2cell(minFluxesW(posMustL)), num2cell(maxFluxesW(posMustL)), num2cell(minFlux) ,num2cell(maxFlux)]];
                xlswrite('MustL_Info', Info);
                xlswrite(outputFileName, mustLSet);
                cd(currentFolder);
                if verbose; fprintf(['MustL set was printed in ' outputFileName '.xls  \n']); end;
                if printReport; fprintf(freport, ['\nMustL set was printed in ' outputFileName '.xls  \n']); end;
            else
                if verbose; fprintf('No mustL set was found. Therefore, no excel file was generated\n'); end;
                if printReport; fprintf(freport, '\nNo mustL set was found. Therefore, no excel file was generated\n'); end;
            end
        end

        % print info into a plain text file if required by the user
        if printText
            if ~isempty(mustLSet)
                currentFolder = pwd;
                cd(outputFolder);
                f = fopen('MustL_Info.txt','w');
                fprintf(f, 'Reactions\tMin Flux in Wild-type strain\tMax Flux in Wild-type strain\tMin Flux in Mutant strain\tMax Flux in Mutant strain\n');
                for i = 1:length(posMustL)
                    fprintf(f, '%s\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', mustLSet{i}, minFluxesW(posMustL(i)), maxFluxesW(posMustL(i)), minFlux(i), maxFlux(i));
                end
                fclose(f);
                f = fopen([outputFileName '.txt'], 'w');
                for i = 1:length(posMustL)
                    fprintf(f, '%s\n', mustLSet{i});
                end
                fclose(f);
                cd(currentFolder);
                if verbose; fprintf(['MustL set was printed in ' outputFileName '.txt  \n']); end;
                if printReport; fprintf(freport, ['\nMustL set was printed in ' outputFileName '.txt  \n']); end;
            else
                if verbose; fprintf('No mustL set was found. Therefore, no excel file was generated\n'); end;
                if printReport; fprintf(freport, '\nNo mustL set was found. Therefore, no excel file was generated\n'); end;
            end
        end

        %close file for saving report
        if printReport; fclose(freport); reportClosed = 1; end;
        if printReport; movefile(reportFileName, outputFolder); end;
        delete(gamsMustLFunction);

        %remove or move additional files that were generated during running
        if keepGamsOutputs
            if ~isdir(outputFolder); mkdir(outputFolder); end;
            movefile('GtoML.gdx',outputFolder);
            movefile(regexprep(gamsMustLFunction, 'gms', 'lst'), outputFolder);
        else
            delete('GtoML.gdx');
            delete(regexprep(gamsMustLFunction, 'gms', 'lst'));
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
else
    %if GAMS was not executed correcttly
    if printReport && ~reportClosed; fprintf(freport, '\nGAMS was not executed correctly\n'); fclose(freport); end;
    if verbose; fprintf('GAMS was not executed correctly\n'); end;
    cd(workingPath);
    error('OptForce: GAMS was not executed correctly');
end
end

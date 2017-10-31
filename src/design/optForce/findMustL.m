function [mustLSet, posMustL] = findMustL(model, minFluxesW, maxFluxesW, varargin)
% This function runs the second step of `optForce`, that is to solve a
% bilevel mixed integer linear programming  problem to find a first order
% `MustL` set.
%
% USAGE:
%
%    [mustLSet, posMustL] = findMustL(model, minFluxesW, maxFluxesW, varargin)
%
% INPUTS:
%    model:                     (structure) COBRA metabolic model
%                               with at least the following fields:
%
%                                 * .rxns - Reaction IDs in the model
%                                 * .mets - Metabolite IDs in the model
%                                 * .S -    Stoichiometric matrix (sparse)
%                                 * .b -    RHS of `Sv = b` (usually zeros)
%                                 * .c -    Objective coefficients
%                                 * .lb -   Lower bounds for fluxes
%                                 * .ub -   Upper bounds for fluxes
%    minFluxesW:                (double array) of `size n_rxns x 1`.
%                               Minimum fluxes for each
%                               reaction in the model for wild-type strain.
%                               This can be obtained by running the
%                               function `FVAOptForce`.
%                               E.g.: `minFluxesW = [-90; -56];`
%    maxFluxesW:                (double array) of size `n_rxns x 1`.
%                               Maximum fluxes for each
%                               reaction in the model for wild-type strain.
%                               This can be obtained by running the
%                               function `FVAOptForce`.
%
% OPTIONAL INPUTS:
%    constrOpt:                 (structure) structure containing
%                               additional contraints. Include here only
%                               reactions whose flux is fixed, i.e.,
%                               reactions whose lower and upper bounds have
%                               the same value. Do not include here
%                               reactions whose lower and upper bounds have
%                               different values. Such contraints should be
%                               defined in the lower and upper bounds of
%                               the model. The structure has the following
%                               fields:
%
%                                 * .rxnList - Reaction list (cell array)
%                                 * .values -  Values for constrained
%                                   reactions (double array)
%                                   E.g.: `struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');`
%    runID:                     (string) ID for identifying this run.
%                               Default: ['run' date hour].
%    outputFolder:              (string) name for folder in which results
%                               will be stored.
%                               Default: 'OutputsFindMustL'.
%    outputFileName:            (string) name for files in which results
%                               will be stored.
%                               Default: 'MustLSet'.
%    printExcel:                (double) boolean to describe wheter data
%                               must be printed in an excel file or not.
%                               Default: 1
%    printText:                 (double) boolean to describe wheter data
%                               must be printed in an plaint text file or not.
%                               Default: 1
%    printReport:               (double) 1 to generate a report in a plain
%                               text file. 0 otherwise.
%                               Default: 1
%    keepInputs:                (double) 1 to save inputs to run
%                               `findMustL.m` 0 otherwise.
%                               Default: 1
%    printLevel:                (double) 1 to print results in console.
%                               0 otherwise.
%                               Default: 0
%
% OUTPUTS:
%    mustLSet:                  (cell array) Size: number of reactions found X 1.
%                               Cell array containing the
%                               reactions ID which belong to the `Must_U` Set
%    posMustL:                  (double array)
%                               Size: number of reactions found X 1
%                               double array containing the
%                               positions of reactions in the model.
%    outputFileName.xls         File containing one column array
%                               with identifiers for reactions in `MustL`. This
%                               file will only be generated if the user entered
%                               `printExcel = 1`. Note that the user can choose
%                               the name of this file entering the input
%                               `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName.txt         File containing one column array
%                               with identifiers for reactions in `MustL`. This
%                               file will only be generated if the user entered
%                               `printText = 1`. Note that the user can choose
%                               the name of this file entering the input
%                               `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.xls    File containing five column arrays.
%
%                                 * C1: identifiers for reactions in `MustL`
%                                 * C2: min fluxes for reactions according to FVA
%                                 * C3: max fluxes for reactions according to FVA
%                                 * C4: min fluxes achieved for reactions,
%                                   according to `findMustL`
%                                 * C5: max fluxes achieved for reactions,
%                                   according to `findMustL`
%                               This file will only be generated if the user
%                               entered `printExcel = 1`. Note that the user can
%                               choose the name of this file entering the input
%                               `outputFileName = 'PutYourOwnFileNameHere';`
%    outputFileName_Info.txt    File containing five column arrays.
%
%                                 * C1: identifiers for reactions in `MustL`.
%                                 * C2: min fluxes for reactions according to FVA
%                                 * C3: max fluxes for reactions according to FVA
%                                 * C4: min fluxes achieved for reactions,
%                                   according to `findMustL`
%                                 * C5: max fluxes achieved for reactions,
%                                   according to `findMustL`
%                               This file will only be generated if the user
%                               entered `printText = 1`. Note that the user can
%                               choose the name of this file entering the input
%                               `outputFileName = 'PutYourOwnFileNameHere';`
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

optionalParameters = {'constrOpt', 'runID', 'outputFolder', 'outputFileName',  ...
    'printExcel', 'printText', 'printReport', 'keepInputs', 'verbose', 'printLevel'};

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
hour = clock; defaultRunID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
parser.addParamValue('runID', defaultRunID, @(x) ischar(x))
parser.addParamValue('outputFolder', 'OutputsFindMustL', @(x) ischar(x))
parser.addParamValue('outputFileName', 'MustLSet', @(x) ischar(x))
parser.addParamValue('printExcel', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printText', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printReport', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('keepInputs', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('verbose', 1, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printLevel', 1, @(x) isnumeric(x) || islogical(x));


parser.parse(model, minFluxesW, maxFluxesW, varargin{:})
model = parser.Results.model;
minFluxesW = parser.Results.minFluxesW;
maxFluxesW = parser.Results.maxFluxesW;
constrOpt= parser.Results.constrOpt;
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


% correct size of constrOpt
if ~isempty(constrOpt.rxnList)
    if size(constrOpt.rxnList, 1) > size(constrOpt.rxnList,2); constrOpt.rxnList = constrOpt.rxnList'; end;
    if size(constrOpt.values, 1) > size(constrOpt.values,2); constrOpt.values = constrOpt.values'; end;
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

%go to the path associate to the ID for this run.
if ~isdir(runID); mkdir(runID); end; cd(runID);

% if the user wants to generate a report.
if printReport
    %create name for file.
    hour = clock;
    reportFileName = ['report-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm.txt'];
    freport = fopen(reportFileName, 'w');
    % print date of running.
    fprintf(freport, ['findMustL.m executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
    % print matlab version.
    fprintf(freport, ['MATLAB: Release R' version('-release') '\n']);

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


    fprintf(freport,'\nprintExcel: %1.0f \n\nprintText: %1.0f \n\nprintReport: %1.0f \n\nkeepInputs: %1.0f  \n\nverbose: %1.0f \n',...
        printExcel, printText, printReport, keepInputs, printLevel);

end

% export inputs for running the optimization problem to find the MustL Set
inputFolder = [runID filesep 'InputsMustU'];
saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt, inputFolder);

% create a directory to save results if this don't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%number of reactions
n_rxns = length(model.rxns);

% initilize sets can, must and empty arrays to store values.
can = zeros(n_rxns, 1);
can(minFluxesW ~= 0) = 1;
can(maxFluxesW ~= 0) = 1;
must = zeros(n_rxns, 1);
mustL = zeros(n_rxns, 1);
vmin = zeros(n_rxns, 1);
vmax = zeros(n_rxns, 1);

found = 0;
%while a solution is still found
while 1
    % create bilevel problem
    bilevelMILPproblem = buildBilevelMILPproblemForFindMustL(model, can, must, minFluxesW, constrOpt);
    % solve problem
    MustLSol = solveCobraMILP(bilevelMILPproblem, 'printLevel', printLevel);

    if MustLSol.stat~=1
        break;
    else
        % if there is a solution
        found = 1;
        %find which reaction was found
        pos_actives = find(MustLSol.int);
        %update must sets
        must(pos_actives) = 1;
        mustL(pos_actives) = 1;
        %find maximum value for the reaction found
        vmax(pos_actives) = MustLSol.cont(pos_actives);
        %find minimum value for the reaction found
        model2 = changeObjective(model, model.rxns(pos_actives));
        fba = optimizeCbModel(model2, 'min');
        vmin(pos_actives) = fba.f;
    end
end

%print the results now.
if printReport; fprintf(freport, '\n------RESULTS------\n'); end;

%if user decide not to show inputs files for findMustL.gms
if ~keepInputs; rmdir(inputFolder,'s'); end;

if found
    %if a solution is found
    if printReport; fprintf(freport, '\na MustL set was found\n'); end;
    if printLevel; fprintf('a MustL set was found\n'); end;
    %find mustL sets
    posMustL=find(mustL);
    mustLSet=model.rxns(posMustL);
else
    %if no solution is found
    if printReport; fprintf(freport, '\na MustL set was not found\n'); end;
    if printLevel; fprintf('a MustL set was not found\n'); end;
    %initilize empty arrays
    mustLSet = {};
    posMustL = {};
end

% print info into an excel text file if required by the user
if printExcel
    if found
        currentFolder = pwd;
        cd(outputFolder);
        Info=[{'Reactions'},{'Min Flux in Wild-type strain'},{'Max Flux in Wild-type strain'},{'Min Flux in Mutant strain'},{'Max Flux in Mutant strain'}];
        Info=[Info;[model.rxns(posMustL), num2cell(minFluxesW(posMustL)), num2cell(maxFluxesW(posMustL)), num2cell(vmin(posMustL)) ,num2cell(vmax(posMustL))]];
        setupxlwrite();
        xlwrite([outputFileName '_Info'], Info);
        xlwrite(outputFileName, mustLSet);
        cd(currentFolder);
        if printLevel; fprintf(['MustL set was printed in ' outputFileName '.xls  \n']); end;
        if printReport; fprintf(freport, ['\nMustL set was printed in ' outputFileName '.xls  \n']); end;
    else
        if printLevel; fprintf('No mustL set was not found. Therefore, no excel file was generated\n'); end;
        if printReport; fprintf(freport, '\nNo mustL set was not found. Therefore, no excel file was generated\n'); end;
    end
end

% print info into a plain text file if required by the user
if printText
    if found
        currentFolder = pwd;
        cd(outputFolder);
        f = fopen([outputFileName '_Info.txt'], 'w');
        fprintf(f,'Reactions\tMin Flux in Wild-type strain\tMax Flux in Wild-type strain\tMin Flux in Mutant strain\tMax Flux in Mutant strain\n');
        for i=1:length(posMustL)
            fprintf(f, '%s\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n', model.rxns{posMustL(i)}, minFluxesW(posMustL(i)), maxFluxesW(posMustL(i)), vmin(posMustL(i)), vmax(posMustL(i)));
        end
        fclose(f);

        f = fopen([outputFileName '.txt'], 'w');
        for i = 1:length(posMustL)
            fprintf(f, '%s\n', mustLSet{i});
        end
        fclose(f);

        cd(currentFolder);
        if printLevel; fprintf(['MustL set was printed in ' outputFileName '.txt  \n']); end;
        if printReport; fprintf(freport, ['\nMustL set was printed in ' outputFileName '.txt  \n']); end;
    else
        if printLevel; fprintf('No mustL set was not found. Therefore, no excel file was generated\n'); end;
        if printReport; fprintf(freport, '\nNo mustL set was not found. Therefore, no excel file was generated\n'); end;
    end
end

%close file for saving report
if printReport; fclose(freport); end;
if printReport; movefile(reportFileName, outputFolder); end;

%go back to the original path
cd(workingPath);

end

function bilevelMILPproblem = buildBilevelMILPproblemForFindMustL(model, can, must, minFluxesW, constrOpt)

if nargin<5 || isempty(constrOpt.rxnList)
    ind_ic = [];
    b_ic = [];
    sel_ic = zeros(length(model.rxns),1);
    sel_ic_b = zeros(length(model.rxns),1);
else
    %get indices of rxns
    [~, ind_a, ind_b] = intersect(model.rxns, constrOpt.rxnList);
    aux = constrOpt.values(ind_b);
    %sort for rxn index
    [sorted, ind_sorted] = sort(ind_a);
    ind_ic = sorted;
    b_ic = aux(ind_sorted); if size(b_ic, 1) > size(b_ic, 2); b_ic = b_ic'; end;
    sel_ic = zeros(length(model.rxns), 1);
    sel_ic(ind_ic) = 1;
    sel_ic_b = zeros(length(model.rxns), 1);
    sel_ic_b(ind_ic) = b_ic;
end

%convert inputs
S = model.S;
ub = model.ub;
lb = model.lb;
% Dimensions
[n_mets, n_rxns] = size(S);

% indices of not contrained variables
ind_nic = setdiff(1:n_rxns, ind_ic);

% boolean vector for not constrained variables
sel_nic = zeros(n_rxns, 1);
sel_nic(ind_nic) = 1;
% boolean vector for integer variables
selRxns = ones(size(model.rxns));
sel_int = selRxns;
% bolean vector for reactions in can set and not in must set and not in
% constrained set of reactions
sel_c_nm_nc = can & ~must & sel_nic;

% Number of integer variables
n_int = sum(sel_int);
% Number of inner  constraints
n_ic = length(ind_ic);
% Number of inner variables not constrained
n_nic = length(ind_nic);

% Iic
Iic = selMatrix(sel_ic);
% Inic
Inic = selMatrix(sel_nic);

% Set variable types
vartype_bl(1:7 * n_rxns + n_int + n_mets + 1) = 'C';
vartype_bl(n_rxns + 1:n_rxns + n_int) = 'B';

H = 1000;
bigM = 1000;

%   v(j)      y(j)      mu(j)     w(j)    deltam(j) deltap(j)  theta(j) thetap(j) labmda(i)    z
%|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
%   n         n_int      n         n         n         n          n         n         m        1

% Set upper/lower bounds
lb_bl = [lb; zeros(6 * n_rxns + n_int + n_mets + 1, 1)]; %v(j)
ub_bl = [ub; H * ones(6 * n_rxns + n_int + n_mets + 1, 1)]; %v(j)
lb_bl(n_rxns + n_int + 1:n_rxns + n_int + n_rxns) = -1000; %mu(j)
lb_bl(2 * n_rxns + n_int + 1:2 * n_rxns + n_int + n_rxns) = -1000; %w(j)
lb_bl(7 * n_rxns + n_int + 1:7 * n_rxns + n_int + n_mets) = -1000; %lambda(i)
lb_bl(7 * n_rxns + n_int + n_mets+1) = -1000; %z

%PRIMAL PROBLEM
%1) primal1 (n_mets equations)
%   S*v=0
A_p = [S zeros(n_mets, n_rxns * 6+n_int + n_mets + 1)];
b_p = zeros(n_mets, 1);
csense_p(1:n_mets) = 'E';

%2) primal 2, 3 and 7 (n_ic equations)
%   v_ic = b_ic
if n_ic > 0
A_p = [A_p; Iic zeros(n_ic, n_rxns * 6 + n_int + n_mets + 1)];
b_p = [b_p; b_ic'];
csense_p(end + 1:end + n_ic) = 'E';
end

%3) primal 5 (n_ic equations)
%   -v(j) >= -ub(j)
A_p = [A_p; -Inic zeros(n_nic, n_rxns * 6 + n_int + n_mets + 1)];
b_p = [b_p; -ub(ind_nic)];
csense_p(end + 1:end + n_nic) = 'G';
%
%4) primal 6 (n_ic equations)
%   v(j) >= lb(j)
A_p=[A_p; Inic zeros(n_nic, n_rxns * 6 + n_int + n_mets + 1)];
b_p =[b_p; lb(ind_nic)];
csense_p(end + 1:end + n_nic) = 'G';

%DUAL PROBLEM
%1) dualcon3 (n_nic equations)
%sum_i(lambda(i)*S(i,j)) + thetap(j) - thetam(j) - y(j) =0
A_d=[zeros(n_nic, n_rxns) -Inic zeros(n_nic, n_rxns * 4) -Inic +Inic S(:, ind_nic)' zeros(n_nic, 1)];
b_d =zeros(n_nic, 1);
csense_d(1:n_nic) = 'E';

%2) dualcon4 (n_ic equations)
%   sum_i(lambda(i)*S(i,j)) + mu(j) - y(j) =0
A_d = [A_d; zeros(n_ic, n_rxns) -Iic Iic zeros(n_ic, n_rxns) zeros(n_ic, n_rxns) zeros(n_ic, n_rxns) zeros(n_ic, n_rxns) zeros(n_ic, n_rxns) S(:, ind_ic)' zeros(n_ic, 1)];
b_d = [b_d; zeros(n_ic, 1)];
csense_d(end + 1:end + n_ic) = 'E';

%OUTER PROBLEM
% bilevel_obj_down (1 equation)
%z=sum(basemin(j)*y(j)-w(j)) -> z + sum(w(j)) - sum(basemin(j)*y(j)) = 0 for all j in can y not in must and not in
%contraint_flux
A_bl = [zeros(1, n_rxns) -(minFluxesW.*sel_c_nm_nc)' zeros(1, n_rxns) +sel_c_nm_nc' zeros(1, 4 * n_rxns + n_mets) 1];
b_bl = 0;
csense_bl = 'E';

%primal_dual_down (1 equation)
% sum(w(j)) + sum(b(j)*mu(j))  sum(-thetap(j)*UB(j) + thetam(j)*LB(j)) = 0
A_bl = [A_bl; zeros(1, n_rxns + n_int) -sel_ic_b'  ones(1, n_rxns) zeros(1, 2 * n_rxns) +lb'.*sel_nic' -ub'.*sel_nic' zeros(1, n_mets + 1)];
b_bl = [b_bl; 0];
csense_bl = [csense_bl, 'E'];

% bilevelcon0_down (1 equation)
%sum(basemin(j)*y(j)-w(j))>=0
A_bl = [A_bl; zeros(1, n_rxns) (minFluxesW.*sel_c_nm_nc)' zeros(1, n_rxns) -sel_c_nm_nc' zeros(1, 4 * n_rxns + n_mets + 1)];
b_bl = [b_bl; 0];
csense_bl = [csense_bl, 'G'];

% bilevelcon1 (j equations)
%w(j) - bigM*y(j) <= 0
A_bl = [A_bl; zeros(n_rxns, n_rxns) -bigM*speye(n_int) zeros(n_rxns, n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl = [b_bl; zeros(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% bilevelcon2 (j equations)
%w(j) + bigM*y(j) >= 0
A_bl = [A_bl; zeros(n_rxns, n_rxns) bigM*speye(n_rxns) zeros(n_rxns, n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl = [b_bl; zeros(n_rxns, 1)];
csense_bl(end+1:end+n_rxns) = 'G';

% bilevelcon3 (j equations)
%w(j) <= v(j) + bigM*(1-y(j))   ->    w(j) - v(j) + bigM*y(j)) <= bigM
A_bl = [A_bl; -speye(n_rxns) bigM*speye(n_rxns) zeros(n_rxns, n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl = [b_bl; bigM*ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'L';

% bilevelcon4 (j equations)
%w(j) >= v(j) - bigM*(1-y(j))   ->    w(j) - v(j) - bigM*y(j)) >= -bigM
A_bl = [A_bl; -speye(n_rxns) -bigM*speye(n_rxns) zeros(n_rxns, n_rxns) speye(n_rxns) zeros(n_rxns, 4 * n_rxns + n_mets + 1) ];
b_bl = [b_bl;-bigM*ones(n_rxns, 1)];
csense_bl(end + 1:end + n_rxns) = 'G';

% bilevelcon5 (1 equation)
%z >= 0.5
A_bl = [A_bl; zeros(1, 7 * n_rxns + n_int + n_mets) 1];
b_bl = [b_bl; 0.5];
csense_bl(end + 1) = 'G';

%must_bin (1 equation)
% sum(y(j))=1
A_bl = [A_bl; zeros(1, n_rxns) sel_c_nm_nc' zeros(1, 6 * n_rxns + n_mets + 1) ];
b_bl = [b_bl; 1];
csense_bl = [csense_bl, 'E'];

%blocked_bin (1 equation)
% sum(y(j))=1
A_bl = [A_bl; zeros(1, n_rxns) ones(1, n_int) zeros(1, 6 * n_rxns + n_mets + 1)];
b_bl = [b_bl; 1];
csense_bl = [csense_bl, 'E'];

%Build bilevel matrices and vectors
A_bl_down = [A_bl; A_d; A_p];
b_bl_down = [b_bl; b_d; b_p];
csense_bl_down = [csense_bl, csense_d, csense_p];
c_bl_down = zeros(7 * n_rxns + n_int + n_mets + 1, 1); c_bl_down(end) = 1;

% Helper arrays for extracting solutions
sel_cont_sol = 1:n_rxns;
sel_int_sol = n_rxns + 1:n_rxns + n_int;

% Construct problem structure
bilevelMILPproblem.A = A_bl_down;
bilevelMILPproblem.b = b_bl_down;
bilevelMILPproblem.c = c_bl_down;
bilevelMILPproblem.csense = csense_bl_down;
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

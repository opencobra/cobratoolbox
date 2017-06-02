function [mustUSet, posMustU] = findMustU(model, minFluxesW, maxFluxesW,...
    constrOpt, runID, outputFolder, outputFileName, printExcel, ...
    printText, printReport, keepInputs, verbose)
% DESCRIPTION
% This function runs the second step of optForce, that is to solve a
% bilevel mixed integer linear programming  problem to find a first order
% MustU set. This script is based in the GAMS files written by Sridhar
% Ranganathan which were provided by the research group of Costas D.
% Maranas.
%
% Ranganathan S, Suthers PF, Maranas CD (2010) OptForce: An Optimization
% Procedure for Identifying All Genetic Manipulations Leading to Targeted
% Overproductions. PLOS Computational Biology 6(4): e1000744.
% https://doi.org/10.1371/journal.pcbi.1000744

% Usage1: findMustU(model, minFluxesW, maxFluxesW)
%         basic configuration for running the optimization problem to find
%         the MustU set.

% Usage2: findMustU(model, minFluxesW, maxFluxesW, option 1, ..., option N)
%         specify additional options such as fixed reactions or if results
%         shoulds be saved in files or not.

% Created by Sebasti�n Mendoza. 30/05/2017. snmendoz@uc.cl
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
% minFluxesW (obligatory)   Type: double array of size n_rxns x1
%                           Description: Minimum fluxes for each reaction
%                           in the model for wild-type strain. This can be
%                           obtained by running the function FVA_optForce
%                           Example: minFluxesW=[-90; -56];
%
% maxFluxesW (obligatory)   Type: double array of size n_rxns x1
%                           Description: Maximum fluxes for each reaction
%                           in the model for wild-type strain. This can be
%                           obtained by running the function FVA_optForce
%                           Example: maxFluxesW=[-90; -56];
%
% constrOpt (optional):     Type: Structure
%                           Description: structure containing additional
%                           contraints. The structure has the following
%                           fields:
%                           rxnList: (Type: cell array)      Reaction list
%                           values:  (Type: double array)    Values for constrained reactions
%                           sense:   (Type: char array)      Constraint senses for constrained reactions (G/E/L)
%                                                            (G: Greater than; E: Equal to; L: Lower than)
%                           Example: struct('rxnList',{{'EX_gluc','R75','EX_suc'}},'values',[-100,0,155.5]','sense','EEE');
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
% printExcel (optional) :   Type: double
%                           Description: boolean to describe wheter data
%                           must be printed in an excel file or not
%
% printText (optional):    Type: double
%                           Description: boolean to describe wheter data
%                           must be printed in an plaint text file or not
% 
% printReport (optional):   Type: double
%                           Description: 1 to generate a report in a plain
%                           text file. 0 otherwise.
%
% keepInputs (optional):    Type: double
%                           Description: 1 to save inputs to run
%                           findMustU.m 0 otherwise.
%
% verbose (optional):       Type: double
%                           Description: 1 to print results in console.
%                           0 otherwise.

%% OUTPUT
% mustUSet:                 Type: cell array
%                           Size: number of reactions found X 1
%                           Description: Cell array containing the
%                           reactions ID which belong to the Must_U Set
%
% posMustU:                 Type: double array
%                           Size: number of reactions found X 1
%                           Description: double array containing the
%                           positions of reactions in the model.
%
% outputFileName.xls        Type: file.
%                           Description: File containing one column array
%                           with identifiers for reactions in MustU. This
%                           file will only be generated if the user entered
%                           printExcel = 1. Note that the user can choose
%                           the name of this file entering the input
%                           outputFileName = 'PutYourOwnFileNameHere';
%
% outputFileName.txt        Type: file.
%                           Description: File containing one column array
%                           with identifiers for reactions in MustU. This
%                           file will only be generated if the user entered
%                           printText = 1. Note that the user can choose
%                           the name of this file entering the input
%                           outputFileName = 'PutYourOwnFileNameHere';
%
% outputFileName_Info.xls   Type: file.
%                           Description: File containing five column
%                           arrays. 
%                           C1: identifiers for reactions in MustU
%                           C2: min fluxes for reactions according to FVA
%                           C3: max fluxes for reactions according to FVA
%                           C4: min fluxes achieved for reactions, 
%                               according to findMustU
%                           C5: max fluxes achieved for reactions, 
%                               according to findMustU
%                           This file will only be generated if the user
%                           entered printExcel = 1. Note that the user can
%                           choose the name of this file entering the input
%                           outputFileName = 'PutYourOwnFileNameHere';
%
% outputFileName_Info.txt   Type: file.
%                           Description: File containing five column
%                           arrays. 
%                           C1: identifiers for reactions in MustU
%                           C2: min fluxes for reactions according to FVA
%                           C3: max fluxes for reactions according to FVA
%                           C4: min fluxes achieved for reactions, 
%                               according to findMustU
%                           C5: max fluxes achieved for reactions, 
%                               according to findMustU
%                           This file will only be generated if the user
%                           entered printText = 1. Note that the user can
%                           choose the name of this file entering the input
%                           outputFileName = 'PutYourOwnFileNameHere';

%% CODE
% inputs handling
if nargin < 1 || isempty(model)
    error('OptForce: No model specified');
else
    if ~isfield(model, 'S'), error('OptForce: Missing field S in model');  end
    if ~isfield(model, 'rxns'), error('OptForce: Missing field rxns in model');  end
    if ~isfield(model, 'mets'), error('OptForce: Missing field mets in model');  end
    if ~isfield(model, 'lb'), error('OptForce: Missing field lb in model');  end
    if ~isfield(model, 'ub'), error('OptForce: Missing field ub in model');  end
    if ~isfield(model, 'c'), error('OptForce: Missing field c in model'); end
    if ~isfield(model, 'b'), error('OptForce: Missing field b in model'); end
end
if nargin < 2 || isempty(maxFluxesW)
    error('OptForce: Minimum values for reactions in wild-type strain not specified');
else
    if ~isa(minFluxesW, 'double'); error('OptForce: Minimum values must be a double array');end;
end
if nargin < 3 || isempty(maxFluxesW)
    error('OptForce: Maximum values for reactions in wild-type strain not specified');
else
    if ~isa(maxFluxesW, 'double'); error('OptForce: Maximum values must be a double array');end;
end
if nargin < 4
    constrOpt = {};
else
    %check correct fields and correct size.
    if ~isfield(constrOpt, 'rxnList'), error('OptForce: Missing field rxnList in constrOpt');  end
    if ~isfield(constrOpt, 'values'), error('OptForce: Missing field values in constrOpt');  end
    if ~isfield(constrOpt, 'sense'), error('OptForce: Missing field sense in constrOpt');  end
    
    if length(constrOpt.rxnList) == length(constrOpt.values)
        if size(constrOpt.rxnList, 1) > size(constrOpt.rxnList,2); constrOpt.rxnList = constrOpt.rxnList'; end;
        if size(constrOpt.values, 1) > size(constrOpt.values,2); constrOpt.values = constrOpt.values'; end;
    else
        error('OptForce: Incorrect size of fields in constrOpt');
    end
    if length(intersect(constrOpt.rxnList, model.rxns)) ~= length(constrOpt.rxnList);
        error('OptForce: identifiers for reactions in constrOpt.rxnList must be in model.rxns');
    end
end
if nargin < 5 || isempty(runID)
    hour = clock; runID = ['run-' date '-' num2str(hour(4)) 'h' '-' num2str(hour(5)) 'm'];
else
    if ~ischar(runID); error('OptForce: runID must be an string');  end
end
if nargin < 6 || isempty(outputFolder)
    outputFolder = 'OutputsFindMustU';
else
    if ~ischar(outputFolder); error('OptForce: outputFolder must be an string');  end
end
if nargin < 7 || isempty(outputFileName)
    outputFileName = 'MustUSet';
else
    if ~ischar(outputFileName); error('OptForce: outputFileName must be an string');  end
end
if nargin < 8
    printExcel = 1;
else
    if ~isnumeric(printExcel); error('OptForce: printExcel must be a number');  end
    if printExcel ~= 0 && printExcel ~= 1; error('OptForce: printExcel must be 0 or 1');  end
end
if nargin < 9
    printText = 1;
else
    if ~isnumeric(printText); error('OptForce: printText must be a number');  end
    if printText ~= 0 && printText ~= 1; error('OptForce: printText must be 0 or 1');  end
end
if nargin < 10
    printReport = 1;
else
    if ~isnumeric(printReport); error('OptForce: printReport must be a number');  end
    if printReport ~= 0 && printReport ~= 1; error('OptForce: printReportl must be 0 or 1');  end
end
if nargin < 11
    keepInputs = 1;
else
    if ~isnumeric(keepInputs); error('OptForce: keepInputs must be a number');  end
    if keepInputs ~= 0 && keepInputs ~= 1; error('OptForce: keepInputs must be 0 or 1');  end
end
if nargin < 12
    verbose = 0;
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
    fprintf(freport, ['findMustU.m executed on ' date ' at ' num2str(hour(4)) ':' num2str(hour(5)) '\n\n']);
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
        printExcel, printText, printReport, keepInputs, verbose);
    
end

% export inputs for running the optimization problem to find the MustU Set
inputFolder = 'InputsMustU';
saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt,inputFolder);

% create a directory to save results if this don't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%number of reactions
n_rxns=length(model.rxns);

% initilize sets can, must and empty arrays to store values.
can=zeros(n_rxns,1);
can(minFluxesW~=0)=1;
can(maxFluxesW~=0)=1;
must=zeros(n_rxns,1);
mustU=zeros(n_rxns,1);
vmin=zeros(n_rxns,1);
vmax=zeros(n_rxns,1);
 
found = 0; 
%while a solution is still found
while 1
    % create bilevel problem
    bilevelMILPproblem=buildBilevelMILPproblemForFindMustU(model,can,must,maxFluxesW,constrOpt);
    % solve problem
    MustUSol = solveCobraMILP(bilevelMILPproblem,'printLevel',1);
    
    if MustUSol.stat~=1
        break;
    else
        % if there is a solution
        found = 1; 
        %find which reaction was found
        pos_actives=find(MustUSol.int);
        %update must sets
        must(pos_actives)=1;
        mustU(pos_actives)=1;
        %find minimum value for the reaction found
        vmin(pos_actives)=MustUSol.cont(pos_actives);
        %find maximum value for the reaction found
        model2=changeObjective(model,model.rxns(pos_actives));
        fba=optimizeCbModel(model2);
        vmax(pos_actives)=fba.f;
    end
end

%print the results now.
if printReport; fprintf(freport, '\n------RESULTS------\n'); end;

%if user decide not to show inputs files for findMustU.gms
if ~keepInputs; rmdir(inputFolder,'s'); end;

if found
    %if a solution is found
    if printReport; fprintf(freport, '\na MustU set was found\n'); end;
    if verbose; fprintf('a MustU set was found\n'); end;
    %find mustU sets
    posMustU=find(mustU);
    mustUSet=model.rxns(posMustU); 
else
    %if no solution is found
    if printReport; fprintf(freport, '\na MustU set was not found\n'); end;
    if verbose; fprintf('a MustU set was not found\n'); end;
    %initilize empty arrays
    mustUSet = {};
    posMustU = {};
end 

% print info into an excel text file if required by the user
if printExcel
    if found
        currentFolder = pwd;
        cd(outputFolder);
        Info=[{'Reactions'},{'Min Flux in Wild-type strain'},{'Max Flux in Wild-type strain'},{'Min Flux in Mutant strain'},{'Max Flux in Mutant strain'}];
        Info=[Info;[model.rxns(posMustU),num2cell(minFluxesW(posMustU)),num2cell(maxFluxesW(posMustU)), num2cell(vmin(posMustU)) ,num2cell(vmax(posMustU))]];
        xlswrite([outputFileName '_Info'],Info);
        xlswrite(outputFileName, mustUSet);
        cd(currentFolder);
        if verbose; fprintf(['MustU set was printed in ' outputFileName '.xls  \n']); end;
        if printReport; fprintf(freport, ['\nMustU set was printed in ' outputFileName '.xls  \n']); end;
    else
        if verbose; fprintf('No mustU set was found. Therefore, no excel file was generated\n'); end;
        if printReport; fprintf(freport, '\nNo mustU set was found. Therefore, no excel file was generated\n'); end;
    end
end

% print info into a plain text file if required by the user
if printText
    if found
        currentFolder = pwd;
        cd(outputFolder);
        f = fopen([outputFileName '_Info.txt'], 'w');
        fprintf(f,'Reactions\tMin Flux in Wild-type strain\tMax Flux in Wild-type strain\tMin Flux in Mutant strain\tMax Flux in Mutant strain\n');
        for i=1:length(posMustU)
            fprintf(f,'%s\t%4.4f\t%4.4f\t%4.4f\t%4.4f\n',model.rxns{posMustU(i)},minFluxesW(posMustU(i)),maxFluxesW(posMustU(i)),vmin(posMustU(i)),vmax(posMustU(i)));
        end
        fclose(f);
        
        f = fopen([outputFileName '.txt'], 'w');
        for i = 1:length(posMustU)
            fprintf(f, '%s\n', mustUSet{i});
        end
        fclose(f);
        
        cd(currentFolder);
        if verbose; fprintf(['MustU set was printed in ' outputFileName '.txt  \n']); end;
        if printReport; fprintf(freport, ['\nMustU set was printed in ' outputFileName '.txt  \n']); end;
    else
        if verbose; fprintf('No mustU set was found. Therefore, no excel file was generated\n'); end; 
        if printReport; fprintf(freport, '\nNo mustU set was found. Therefore, no excel file was generated\n'); end;
    end
end

%close file for saving report
if printReport; fclose(freport); end;
if printReport; movefile(reportFileName, outputFolder); end;

%go back to the original path
cd(workingPath);

end

function bilevelMILPproblem=buildBilevelMILPproblemForFindMustU(model,can,must,maxFluxesW,constrOpt)

if nargin<5 || isempty(constrOpt)
    ind_ic = [];
    b_ic = [];
    csense_ic = [];
    sel_ic=zeros(length(model.rxns),1);
    sel_ic_b=zeros(length(model.rxns),1);
else
    %get indices of rxns
    [~,ind_a,ind_b]=intersect(model.rxns,constrOpt.rxnList);
    aux=constrOpt.values(ind_b);
    aux2=constrOpt.sense(ind_b);
    %sort for rxn index
    [sorted,ind_sorted]=sort(ind_a);
    ind_ic=sorted;
    b_ic=aux(ind_sorted);
    csense_ic=aux2(ind_sorted);
    sel_ic=zeros(length(model.rxns),1);
    sel_ic(ind_ic)=1;
    sel_ic_b=zeros(length(model.rxns),1);
    sel_ic_b(ind_ic)=b_ic;
end

%convert inputs
S=model.S;
ub=model.ub;
lb=model.lb;
% Dimensions
[n_mets,n_rxns]=size(S);

% indices of not contrained variables
ind_nic=setdiff(1:n_rxns,ind_ic);

% boolean vector for not constrained variables
sel_nic=zeros(n_rxns,1);
sel_nic(ind_nic)=1;
% boolean vector for integer variables
selRxns=ones(size(model.rxns));
sel_int = selRxns;
% bolean vector for reactions in can set and not in must set and not in
% constrained set of reactions
sel_c_nm_nc=can & ~must & sel_nic;

% Number of integer variables
n_int = sum(sel_int);
% Number of inner  constraints
n_ic = length(ind_ic);
% Number of inner variables not constrained
n_nic = length(ind_nic);

% Iic
Iic=selMatrix(sel_ic);
% Inic
Inic=selMatrix(sel_nic);

% Set variable types
vartype_bl(1:7*n_rxns+n_int+n_mets+1) = 'C';
vartype_bl(n_rxns+1:n_rxns+n_int) = 'B';

H=1000;
bigM=1000;

%   v(j)      y(j)      mu(j)     w(j)    deltam(j) deltap(j)  theta(j) thetap(j) labmda(i)    z
%|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
%   n         n_int      n         n         n         n          n         n         m        1

% Set upper/lower bounds
lb_bl = [lb; zeros(6*n_rxns+n_int+n_mets+1,1)]; %v(j)
ub_bl = [ub; H*ones(6*n_rxns+n_int+n_mets+1,1)]; %v(j)
lb_bl(n_rxns+n_int+1:n_rxns+n_int+n_rxns)=-1000; %mu(j)
lb_bl(2*n_rxns+n_int+1:2*n_rxns+n_int+n_rxns)=-1000; %w(j)
lb_bl(7*n_rxns+n_int+1:7*n_rxns+n_int+n_mets)=-1000; %lambda(i)
lb_bl(7*n_rxns+n_int+n_mets+1)=-1000; %z

%PRIMAL PROBLEM
%1) primal1 (n_mets equations)
%   S*v=0
A_p=[S zeros(n_mets,n_rxns*6+n_int+n_mets+1)];
b_p = zeros(n_mets,1);
csense_p(1:n_mets) = 'E';

%2) primal 2, 3 and 7 (n_ic equations)
%   v_ic = b_ic
if n_ic>0
    A_p=[A_p; Iic zeros(n_ic,n_rxns*6+n_int+n_mets+1)];
    b_p =[b_p; b_ic'];
    csense_p(end+1:end+n_ic) = csense_ic;
end

%3) primal 5 (n_ic equations)
%   -v(j) >= -ub(j)
A_p=[A_p; -Inic zeros(n_nic,n_rxns*6+n_int+n_mets+1)];
b_p =[b_p; -ub(ind_nic)];
csense_p(end+1:end+n_nic) = 'G';
%
%4) primal 6 (n_ic equations)
%   v(j) >= lb(j)
A_p=[A_p; Inic zeros(n_nic,n_rxns*6+n_int+n_mets+1)];
b_p =[b_p; lb(ind_nic)];
csense_p(end+1:end+n_nic) = 'G';

%DUAL PROBLEM
%1) dualcon1 (n_nic equations)
%   sum_i(lambda(i)*S(i,j)) + deltam(j) -deltap(j) - y(j) =0
A_d=[];
b_d =[];
A_d=[A_d; zeros(n_nic,n_rxns) -Inic zeros(n_nic,n_rxns) zeros(n_nic,n_rxns) Inic -Inic zeros(n_nic,n_rxns) zeros(n_nic,n_rxns) S(:,ind_nic)' zeros(n_nic,1)];
b_d =[b_d; zeros(n_nic,1)];
csense_d(1:n_nic) = 'E';

%2) dualcon2 (n_ic equations)
%   sum_i(lambda(i)*S(i,j)) + mu(j) - y(j) =0
A_d=[A_d; zeros(n_ic,n_rxns) -Iic Iic zeros(n_ic,n_rxns) zeros(n_ic,n_rxns) zeros(n_ic,n_rxns) zeros(n_ic,n_rxns) zeros(n_ic,n_rxns) S(:,ind_ic)' zeros(n_ic,1)];
b_d =[b_d; zeros(n_ic,1)];
csense_d(end+1:end+n_ic) = 'E';

%OUTER PROBLEM
% bilevel_obj_up (1 equation)
%z=sum(w(j)-basemax(j)*y(j)) -> z -sum(w(j)) + sum(basemax(j)*y(j)) = 0 for all j in can y not in must and not in
%contraint_flux
A_bl=[zeros(1,n_rxns) (maxFluxesW.*sel_c_nm_nc)' zeros(1,n_rxns) -sel_c_nm_nc' zeros(1,4*n_rxns+n_mets) 1];
b_bl=0;
csense_bl='E';

%primal_dual_up (1 equation)
% sum(w(j)) + sum(b(j)*mu(j))  sum(deltap(j)*UB(j) - deltam(j)*LB(j)) = 0
A_bl=[A_bl; zeros(1,n_rxns+n_int) -sel_ic_b'  ones(1,n_rxns) -lb'.*sel_nic' ub'.*sel_nic' zeros(1,2*n_rxns+n_mets+1)];
b_bl=[b_bl; 0];
csense_bl=[csense_bl, 'E'];

% bilevelcon0_up (1 equation)
%sum(w(j)-basemax(j)*y(j))>=0
A_bl=[A_bl; zeros(1,n_rxns) (-maxFluxesW.*sel_c_nm_nc)' zeros(1,n_rxns) sel_c_nm_nc' zeros(1,4*n_rxns+n_mets+1)];
b_bl=[b_bl; 0];
csense_bl=[csense_bl, 'G'];

% bilevelcon1 (j equations)
%w(j) - bigM*y(j) <= 0
A_bl=[A_bl; zeros(n_rxns,n_rxns) -bigM*speye(n_int) zeros(n_rxns,n_rxns) speye(n_rxns) zeros(n_rxns,4*n_rxns+n_mets+1) ];
b_bl=[b_bl;zeros(n_rxns,1)];
csense_bl(end+1:end+n_rxns)='L';

% bilevelcon2 (j equations)
%w(j) + bigM*y(j) >= 0
A_bl=[A_bl; zeros(n_rxns,n_rxns) bigM*speye(n_rxns) zeros(n_rxns,n_rxns) speye(n_rxns) zeros(n_rxns,4*n_rxns+n_mets+1) ];
b_bl=[b_bl;zeros(n_rxns,1)];
csense_bl(end+1:end+n_rxns)='G';

% bilevelcon3 (j equations)
%w(j) <= v(j) + bigM*(1-y(j))   ->    w(j) - v(j) + bigM*y(j)) <= bigM
A_bl=[A_bl; -speye(n_rxns) bigM*speye(n_rxns) zeros(n_rxns,n_rxns) speye(n_rxns) zeros(n_rxns,4*n_rxns+n_mets+1) ];
b_bl=[b_bl;bigM*ones(n_rxns,1)];
csense_bl(end+1:end+n_rxns)='L';

% bilevelcon4 (j equations)
%w(j) >= v(j) - bigM*(1-y(j))   ->    w(j) - v(j) - bigM*y(j)) >= -bigM
A_bl=[A_bl; -speye(n_rxns) -bigM*speye(n_rxns) zeros(n_rxns,n_rxns) speye(n_rxns) zeros(n_rxns,4*n_rxns+n_mets+1) ];
b_bl=[b_bl;-bigM*ones(n_rxns,1)];
csense_bl(end+1:end+n_rxns)='G';

% bilevelcon5 (1 equation)
%z >= 0.5
A_bl=[A_bl; zeros(1,7*n_rxns+n_int+n_mets) 1];
b_bl=[b_bl;0.5];
csense_bl(end+1)='G';

%must_bin (1 equation)
% sum(y(j))=1
A_bl=[A_bl; zeros(1,n_rxns) sel_c_nm_nc' zeros(1,6*n_rxns+n_mets+1) ];
b_bl=[b_bl; 1];
csense_bl=[csense_bl, 'E'];

%blocked_bin (1 equation)
% sum(y(j))=1
A_bl=[A_bl; zeros(1,n_rxns) ones(1,n_int) zeros(1,6*n_rxns+n_mets+1)];
b_bl=[b_bl; 1];
csense_bl=[csense_bl, 'E'];

%Build bilevel matrices and vectors
A_bl_up=[A_bl;A_d;A_p];
b_bl_up=[b_bl;b_d;b_p];
csense_bl_up=[csense_bl,csense_d,csense_p];
c_bl_up=zeros(7*n_rxns+n_int+n_mets+1,1); c_bl_up(end)=1;

% Helper arrays for extracting solutions
sel_cont_sol = 1:n_rxns;
sel_int_sol = n_rxns+1:n_rxns+n_int;

% Construct problem structure
bilevelMILPproblem.A = A_bl_up;
bilevelMILPproblem.b = b_bl_up;
bilevelMILPproblem.c = c_bl_up;
bilevelMILPproblem.csense = csense_bl_up;
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
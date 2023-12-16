function [inputs,outputs] = printFunctionIO(functionName,derivedInputNames,printLevel)
% list the inputs and outputs of a function
% e.g., when a function takes a structure as inputs
%
% It does not list outputs of nested functions, for that, see:
% displayRequiredFunctions(fullFileName)
%
% INPUTS:
%  functionName:        name of the function to print io for
%  derivedInputNames:   name of a variable derived from an input variable
%                       or a cell array of variable names
%  printLevel:          if >0 then print to terminal (default 1)
%
% OUTPUTS:
%  inputs: 
%  outputs:
%
% NOTE:
%
% Author(s):
%    - Ronan Fleming
%    - Pavan, BiSECt Lab
%
% EXAMPLE:
%     
%     [inputs,outputs] = printFunctionIO('solveCobraLP',{},1);
%     
%     Returns the following:
%     USAGE:
%       solution = solveCobraLP(LPproblem, varargin)
%     
%     INPUTS:
%      LPproblem.mat:
%      LPproblem.A          :* .A - m x n linear constraint matrix
%      LPproblem.S:
%      LPproblem.csense     :* .csense - m x 1 character array of constraint senses, one for each row in A
%                            must be either ('E', equality, 'G' greater than, 'L' less than).
%      LPproblem.b          :* .b - m x 1 right hand sider vector for constraint A*x = b
%      LPproblem.osense     :* .osense - scalar objective sense (-1 means maximise (default), 1 means minimise)
%      LPproblem.modelID:
%      LPproblem.c          :* .c - n x 1 linear objective coefficient vector
%      LPproblem.lb         :* .lb - n x 1 lower bound vector for lb <= x
%      LPproblem.ub         :* .ub - n x 1 upper bound vector for       x <= ub
%      LPproblem.basis:
%      LPproblem.LPBasis:
%      LPproblem.solve:
%      LPproblem.Solution:
%      LPproblem.Model:
%      LPproblem.Param:
%      varargin             :      Additional parameters either as parameter struct, or as
%                           parameter/value pairs. A combination is possible, if
%                           the parameter struct is either at the beginning or the
%                           end of the optional input.
%                           All fields of the struct which are not COBRA parameters
%                           (see `getCobraSolverParamsOptionsForType`) for this
%                           problem type will be passed on to the solver in a
%                           solver specific manner. Some optional parameters which
%                           can be passed to the function as parameter value pairs,
%                           or as part of the options struct are listed below:
%     
%     OUTPUTS:
%      solution.basis       :* .basis:        (optional) LP basis corresponding to solution
%      solution.solver      :* .solver:       Solver used to solve LP problem
%      solution.algorithm   :* .algorithm:    Algorithm used by solver to solve LP problem
%      solution.slack:
%      solution.obj         :* .obj:          Objective value
%      solution.rcost       :* .rcost:        Reduced costs, dual solution to :math:`lb <= v <= ub`
%      solution.dual        :* .dual:         dual solution to `A*v ('E' | 'G' | 'L') b`
%      solution.stat        :* .stat:         Solver status in standardized form
%      solution.origStat    :* .origStat:         Original status returned by the specific solver
%      solution.origStatText:* .origStatText:     Original status text returned by the specific solver
%     
%     EXAMPLE:
%     
%     
%        %Optional parameters can be entered in three different ways {A,B,C}
%     
%        %A) as a problem specific parameter followed by parameter value:
%        [solution] = solveCobraLP(LP, 'printLevel', 1);
%        [solution] = solveCobraLP(LP, 'printLevel', 1, 'feasTol', 1e-8);
%     
%        %B) as a parameters structure with field names specific to a specific solver
%        [solution] = solveCobraLP(LPCoupled, parameters);
%     
%        %C) as parameter followed by parameter value, with a parameter structure
%        %with field names specific to a particular solvers internal parameter,
%        %fields as the LAST argument
%        [solution] = solveCobraLP(LPCoupled, 'printLevel', 1, 'feasTol', 1e-6, parameters);
%     
%     
%     NOTE:
%     
%               Optional parameters can also be set through the
%               solver can be set through `changeCobraSolver('LP', value)`;
%               `changeCobraSolverParams('LP', 'parameter', value)` function. This
%               includes the minNorm and the `printLevel` flags.
%     
%     
%     Author(s):
%     
%           - Markus Herrgard, 08/29/06
%           - Ronan Fleming, 11/12/08 'cplex_direct' allows for more refined control
%           of cplex than tomlab tomrun
%           - Ronan Fleming, 04/25/09 Option to minimise the Euclidean Norm of internal
%           fluxes using either 'cplex_direct' solver or 'pdco'
%           - Jan Schellenberger, 09/28/09 Changed header to be much simpler.  All parameters
%           now accessed through changeCobraSolverParams(LP, parameter,value)
%           - Richard Que, 11/30/09 Changed handling of optional parameters to use
%           getCobraSolverParams().
%           - Ronan Fleming, 12/07/09 Commenting of input/output
%           - Ronan Fleming, 21/01/10 Not having second input, means use the parameters as specified in the
%           global paramerer variable, rather than 'default' parameters
%           - Steinn Gudmundsson, 03/03/10 Added support for the Gurobi solver
%           - Ronan Fleming, 01/24/01 Now accepts an optional parameter structure with nonstandard
%           solver specific parameter options
%           - Tim Harrington, 05/18/12 Added support for the Gurobi 5.0 solver
%           - Ronan Fleming, 07/04/13 Reinstalled support for optional parameter structure

if ~exist('functionName','var')
    functionName = 'solveCobraLP.m';
end
if ~exist('derivedInputNames','var')
    derivedInputNames = {};
end
if ~exist('printLevel','var')
    printLevel = 1;
end

str = fileread(which(functionName));
C = regexp(str, '\r\n|\r|\n', 'split')';

% to get the function descriptors
temp = find(~(startsWith(C,'%')|cellfun(@isempty,C)));
idS  = temp(1);
idE  = temp(2);
funcDes = C(idS+1:idE-1);
[inpDes,outDes,noteDes,authDes,exDes,opInpDes] = getDescriptors(funcDes);

boolHeader = contains(C,strrep(functionName,'.m',''));
if any(boolHeader)
    header = C{boolHeader};
else
    warning(['Function name in header is different than filename for file:' functionName])
end



%inputs
indL = strfind(header,'(');
indR = strfind(header,')');
inputNames = split(header(indL+1:indR-1),',');
if ischar(derivedInputNames)
    inputNames = [inputNames;{derivedInputNames}];
else
    inputNames = [inputNames;derivedInputNames];
end


n=1;
for i=1:length(inputNames)
    %https://nl.mathworks.com/help/matlab/ref/alphanumericspattern.html
    pat = pattern(sprintf(inputNames{i})) + '.' + alphanumericsPattern;
    inputInds = find(contains(C,pat));
    if isempty(inputInds)
        inputs{n,1}=strtrim(inputNames{i});
        n=n+1;
    else
        for j=1:length(inputInds)
            extractedText = extract(C{inputInds(j)},pat);
            extractedField = extract(extractedText,'.' + alphanumericsPattern);
            for k=1:length(extractedField)
                inputs{n,1} = strtrim([inputNames{i} extractedField{k}]);
                %disp(inputs{n,1})
                n=n+1;
            end
        end
    end
end
inputs = unique(inputs,'stable');

%outputs
indL = strfind(header,'[');
indR = strfind(header,']');
if ~isempty(indL) && ~isempty(indR)
    %more than one output
    outputNames = split(header(indL+1:indR-1),',');
else
    %oinly one output
    %     'function solution = solveCobraLP(LPproblem, varargin)'
    pat = pattern('function') + whitespacePattern + alphanumericsPattern + whitespacePattern + pattern('='); 
    outputNames = extract(C{1},pat);
    outputNames = strrep(outputNames,'function','');
    outputNames = strrep(outputNames,'=','');
    outputNames = strtrim(outputNames);
end
n=1;
for i=1:length(outputNames)
    %https://nl.mathworks.com/help/matlab/ref/alphanumericspattern.html
    pat = pattern([' ' sprintf(outputNames{i})]) + '.' + alphanumericsPattern;
    outputInds = find(contains(C,pat));
    if isempty(outputInds)
        outputs{n,1}=strtrim(outputNames{i});
        n=n+1;
    else
        for j=1:length(outputInds)
            extractedText = extract(C{outputInds(j)},pat);
            extractedField = extract(extractedText,'.' + alphanumericsPattern);
            for k=1:length(extractedField)
                outputs{n,1} = strtrim([outputNames{i} extractedField{k}]);
                %disp(inputs{n,1})
                n=n+1;
            end
        end
    end
end
if ~exist('outputs','var')
    outputs = {};
end
outputs = unique(outputs,'stable');
maxLength=max(cellfun('length',[outputs;inputs]));

InpVar = {};
for i=1:numel(inputs)
    var = getVariableDescriptor(inputs{i},inpDes,maxLength);
    if strcmp(['%  ',inputs{i},':'],var)
        var = getVariableDescriptor(inputs{i},opInpDes,maxLength);
    end
    InpVar{i} = var;
end

OutVar = {};
for i=1:numel(outputs)
    var = getVariableDescriptor(outputs{i},outDes,maxLength);
    OutVar{i} = var;
end

if printLevel>0
    fprintf('%s\n','%');
    fprintf('%s\n','% USAGE:')
    fprintf('%s\n',['%  ' strrep(header,'function','')])

    fprintf('%s\n','%');
    fprintf('%s\n','% INPUTS:')
    for i=1:length(inputs)
        fprintf('%s\n',InpVar{i})
    end

    fprintf('%s\n','%');
    fprintf('%s\n','% OUTPUTS:')
    for i=1:length(outputs)
        fprintf('%s\n',OutVar{i})
    end
    fprintf('%s\n','%');
    fprintf('%s\n','% EXAMPLE:')
    fprintf('%s\n','  %  ', strjoin(exDes,'\n  '))
    fprintf('%s\n','%');
    fprintf('%s\n','% NOTE:');
    fprintf('%s\n','%', strjoin(noteDes,'\n'))
    fprintf('%s\n','%');
    fprintf('%s\n','% Author(s):');
    fprintf('%s\n','%', strjoin(authDes,'\n'))
end    

end


function var = getVariableDescriptor(a,des,maxLength)
des = strrep(des,'%','');
if contains(a,'.')
    % if the variable is a field
    t = split(a,'.');
    pa = pattern('*')+(" "|"")+("."|"")+pattern(t{2});
    id = find(contains(des,pa));
    if numel(id)>1 % what if the same field is present twice
        pa2 = whitespacePattern+pattern(t{1});
        id2 = find(contains(des,pa2));
        id = id(id >id2(1));
        id = id(1);
    end
    field =1;
else
    pa = whitespacePattern +pattern(a);
    id = find(contains(des,pa));
    field =0;
end

if isempty(id)
    var = ['%  ',a,':'];
    return
end
    % to count number of leading spaces in des
    des2 = des(id:end);
    spaceCount = cellfun(@(x) numel(regexp(x, '^\s*', 'match', 'once')), des2);
    id2 = find(spaceCount<=spaceCount(1));
    id2 = id2(2)-1;
    var = des2(1:id2);
    if field
        var{1} = ['%  ',pad(a,maxLength),':',strtrim(var{1})];
        for i =2:numel(var)
            var{i}= ['%   ',pad('',maxLength),strtrim(var{i})];
        end
    else
        var{1} = ['%  ',strtrim(strrep(var{1},[a,':'],[pad(a,maxLength),':']))];
        for i =2:numel(var)
            var{i}= ['%  ',pad('',maxLength),strtrim(var{i})];
        end
    end
    if ischar(var)
        var = var;
    else
        var =strjoin(var,'\n');
    end
    
end



function [inpDes,outDes,noteDes,authDes,exDes,opInpDes] = getDescriptors(funcDes)
    % to get the input, output, notes, author, example descriptions 
    inpPat = pattern("%")+(" "|"")+("INPUT"|"INPUTS");
    outPat = pattern("%")+(" "|"")+("OUTPUT"|"OUTPUTS");
    notePat = pattern("%")+(" "|"")+("NOTE");
    authPat = pattern("%")+(" "|""|" .. ")+("Author"|"AUTHOR");
    exPat = pattern("%")+(" "|"")+("EXAMPLE");
    optInpPat = pattern("%")+(" "|"")+("OPTIONAL INPUTS");
    
    inpID = find(contains(funcDes,inpPat));
    outID = find(contains(funcDes,outPat));
    noteID = find(contains(funcDes,notePat));
    authID = find(contains(funcDes,authPat));
    exID = find(contains(funcDes,exPat));
    optInpID = find(contains(funcDes,optInpPat));
    
    temp = ~cellfun(@isempty,{inpID;outID;noteID;authID;exID;optInpID});
    
    ids=[];
    temp2 = {'inpID','outID','noteID','authID','exID','optInpID'};
    for i=1:numel(temp2)
        if eval(['~isempty(',temp2{i},')'])
            eval(['temp3 =',temp2{i},';'])
            ids = [ids;temp3(1)];
        end
    end
    [ids,B] = sort(ids);
    Names ={'inpDes','outDes','noteDes','authDes','exDes','opInpDes'};
    noNames = Names(temp==0);
    for i=1:numel(noNames)
        eval([noNames{i},'={};'])
    end
    Names = Names(temp~=0);
    Names = Names(B);
    
    for i=1:numel(ids)
        if i==numel(ids)
            eval([Names{i},'=funcDes(ids(i)+1:end);']);
        else
            eval([Names{i},'=funcDes(ids(i)+1:ids(i+1)-1);']);
        end
    end
end

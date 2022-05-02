function [inputs,outputs] = printFunctionIO(functionName,derivedInputNames,printLevel)
% list the inputs and outputs of a function
% e.g., when a function takes a structure as inputs
%
% It does not list outputs of nested functions, for that, see:
% displayRequiredFunctions(fullFileName)
%
% INPUTS:
%  functionName:        name of the function to print io for
%
% OPTIONAL INPUTS:
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
% Author(s): Ronan Fleming

% EXAMPLE:
%   [inputs,outputs] = printFunctionInputsAndOutputs('solveCobraLP',{},1);
%
% Returns the following:
% INPUTS:
%  LPproblem.A:
%  LPproblem.S:
%  LPproblem.csense:
%  LPproblem.b:
%  LPproblem.osense:
%  LPproblem.modelID:
%  LPproblem.c:
%  LPproblem.lb:
%  LPproblem.ub:
%  LPproblem.basis:
%  LPproblem.LPBasis:
%  varargin:      
%
% OUTPUTS:
%  solution.basis:
%  solution.solver:
%  solution.algorithm:
%  solution.slack:
%  solution.obj:
%  solution.rcost:
%  solution.dual:
%  solution.stat:
%  solution.origStat:
%  solution.origStatText:
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):

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
    pat = pattern([' ' sprintf(inputNames{i})]) + '.' + alphanumericsPattern;
    inputInds = find(contains(C,pat));
    if isempty(inputInds)
        inputs{n,1}=strtrim(inputNames{i});
        n=n+1;
    else
        for j=1:length(inputInds)
            extractedText = extract(C{inputInds(j)},pat);
            if any(contains(extractedText,'LPproblem.Solution')) || 0
                disp(extractedText)
            end
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
            if any(strcmp(extractedText,'LPproblem.Solution')) || 0
                disp(extractedText)
            end
            extractedField = extract(extractedText,'.' + alphanumericsPattern);
            for k=1:length(extractedField)
                outputs{n,1} = strtrim([outputNames{i} extractedField{k}]);
                %disp(inputs{n,1})
                n=n+1;
            end
        end
    end
end
outputs = unique(outputs,'stable');


maxLength=max(cellfun('length',[outputs;inputs]));
maxLength = maxLength +8;

if printLevel>0
    fprintf('%s\n','%');
    fprintf('%s\n','% USAGE:')
    fprintf('%s\n',['%  ' strrep(header,'function','')])

    fprintf('%s\n','%');
    fprintf('%s\n','% INPUTS:')
    for i=1:length(inputs)
        fprintf('%s\n',pad(['%  ' inputs{i} ':'],maxLength - length(inputs{i}) - 3))
    end

    fprintf('%s\n','%');
    fprintf('%s\n','% OUTPUTS:')
    for i=1:length(outputs)
        fprintf('%s\n',pad(['%  ' outputs{i} ':'],maxLength - length(outputs{i}) - 3))
    end
    fprintf('%s\n','%');
    fprintf('%s\n','% EXAMPLE:')
    fprintf('%s\n','%');
    fprintf('%s\n','% NOTE:');
    fprintf('%s\n','%');
    fprintf('%s\n','% Author(s):');
end    

end


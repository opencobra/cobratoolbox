function VaryingParameters = AnalyseVaryingParameters(SBMLModel)
% [analysis] = AnalyseVaryingParameters(SBMLModel)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
%
% Returns
%
% 1. a structure detailing any parameters that are not constant and how they are manipulated 
%               within the model
% 
% *EXAMPLE:*
%
%          Using the model from toolbox/Test/test-data/algebraicRules.xml
%
%            analysis = AnalyseVaryingParameters(m)
%            
%            analysis = 
%                        Name: {'s2'}
%                initialValue: 4
%           ChangedByRateRule: 0
%                    RateRule: ''
%     ChangedByAssignmentRule: 0
%              AssignmentRule: ''
%             InAlgebraicRule: 1
%               AlgebraicRule: {{1x1 cell}}
%       ConvertedToAssignRule: 1
%               ConvertedRule: '-(-S2-S3)'

%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA 
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->

if (~isValidSBML_Model(SBMLModel))
    error('AnalyseVaryingParameters(SBMLModel)\n%s', ...
        'argument must be an SBMLModel structure');
end;

VaryingParameters = [];

if length(SBMLModel.parameter) == 0
  return;
end;
  
[names, Values] = GetVaryingParameters(SBMLModel);
[n, AssignRule] = GetParameterAssignmentRules(SBMLModel);
[n, RateRule]   = GetParameterRateRules(SBMLModel);
[n, AlgRules]   = GetParameterAlgebraicRules(SBMLModel);
% create the output structure
index = 1;
for i = 1:length(SBMLModel.parameter)
    % skip constant parameters
    if SBMLModel.parameter(i).constant == 1
        continue;
    end;
    VaryingParameters(index).Name = names(index);

    VaryingParameters(index).initialValue = Values(index);
    
    if (strcmp(RateRule(i), '0'))
        VaryingParameters(index).ChangedByRateRule = 0;
        VaryingParameters(index).RateRule = '';
    else
        VaryingParameters(index).ChangedByRateRule = 1;
        VaryingParameters(index).RateRule = RateRule(i);
    end;

    if (strcmp(AssignRule(i), '0'))
        VaryingParameters(index).ChangedByAssignmentRule = 0;
        VaryingParameters(index).AssignmentRule = '';
    else
        VaryingParameters(index).ChangedByAssignmentRule = 1;
        VaryingParameters(index).AssignmentRule = AssignRule(i);
    end;

    if (strcmp(AlgRules(i), '0'))
        VaryingParameters(index).InAlgebraicRule = 0;
        VaryingParameters(index).AlgebraicRule = '';
    else
        VaryingParameters(index).InAlgebraicRule = 1;
        VaryingParameters(index).AlgebraicRule = AlgRules(i);
    end;

    if ((VaryingParameters(index).ChangedByRateRule == 0) && (VaryingParameters(index).ChangedByAssignmentRule == 0))
        if (VaryingParameters(index).InAlgebraicRule == 1)
            VaryingParameters(index).ConvertedToAssignRule = 1;
            Rule = VaryingParameters(index).AlgebraicRule{1};
            
            % need to look at whether rule contains a user definined
            % function
            FunctionIds = Model_getFunctionIds(SBMLModel);
            for f = 1:length(FunctionIds)
                if (matchFunctionName(char(Rule), FunctionIds{f}))
                    Rule = SubstituteFunction(char(Rule), SBMLModel.functionDefinition(f));
                end;
                
            end;
            
            SubsRule = SubsAssignmentRules(SBMLModel, char(Rule));
            VaryingParameters(index).ConvertedRule = Rearrange(SubsRule, names{index});
        else
            VaryingParameters(index).ConvertedToAssignRule = 0;
            VaryingParameters(index).ConvertedRule = '';
        end;
    else
        VaryingParameters(index).ConvertedToAssignRule = 0;
        VaryingParameters(index).ConvertedRule = '';

    end;

    index = index + 1;
end;


function form = SubsAssignmentRules(SBMLModel, rule)

[VaryingParameters, AssignRule] = GetParameterAssignmentRules(SBMLModel);
form = rule;
% bracket the VaryingParameters to be replaced
for i = 1:length(VaryingParameters)
    if (matchName(rule, VaryingParameters{i}))
        if (~strcmp(AssignRule{i}, '0'))
            form = strrep(form, VaryingParameters{i}, strcat('(', VaryingParameters{i}, ')'));
        end;
    end;
end;

for i = 1:length(VaryingParameters)
    if (matchName(rule, VaryingParameters{i}))
        if (~strcmp(AssignRule{i}, '0'))
            form = strrep(form, VaryingParameters{i}, AssignRule{i});
        end;
    end;
end;
function output = Arrange(formula, x, vars)


ops = '+-';
f = LoseWhiteSpace(formula);

operators = ismember(f, ops);
OpIndex = find(operators == 1);

%--------------------------------------------------
% divide formula up into elements seperated by +/-
if (OpIndex(1) == 1)
    % leading sign i.e. +x-y
    NumElements = length(OpIndex);
    j = 2;
    index = 2;
else
    NumElements = length(OpIndex) + 1;
    j = 1;
    index = 1;
end;


for i = 1:NumElements-1

    element = '';

    while (j < OpIndex(index))
        element = strcat(element, f(j));
        j = j+1;
    end;
    Elements{i} = element;
    j = j + 1;
    index = index + 1;
end;

% get last element
j = OpIndex(end)+1;
element = '';

while (j <= length(f))
    element = strcat(element, f(j));
    j = j+1;
end;
Elements{NumElements} = element;

%--------------------------------------------------
% check whether element contains x
% if does keep on lhs else move to rhs changing sign
output = '';
lhs = 1;
for i = 1:NumElements
    if (matchName(Elements{i}, x))
        % element contains x
        LHSElements{lhs} = Elements{i};

        if (OpIndex(1) == 1)
            LHSOps(lhs) = f(OpIndex(i));
        elseif (i == 1)
            LHSOps(lhs) = '+';
        else
            LHSOps(lhs) = f(OpIndex(i-1));
        end;

        lhs = lhs + 1;
    elseif (i == 1)
        % first element does not contain x

        if (OpIndex(1) == 1)
            if (strcmp(f(1), '-'))
                output = strcat(output, '+');
            else
                output = strcat(output, '-');
            end;

        else
            % no sign so +
            output = strcat(output, '-');
        end;
        output = strcat(output, Elements{i});
    else
        % element not first and does not contain x
        if (OpIndex(1) == 1)
            if (strcmp(f(OpIndex(i)), '-'))
                output = strcat(output, '+');
            else
                output = strcat(output, '-');
            end;

        else
           if (strcmp(f(OpIndex(i-1)), '-'))
                output = strcat(output, '+');
            else
                output = strcat(output, '-');
            end;
        end;
        
        output = strcat(output, Elements{i});

   end;

end;

%------------------------------------------------------
% look at remaining LHS
for i = 1:length(LHSElements)
    Mult{i} = ParseElement(LHSElements{i}, x);
end;

if (length(LHSElements) == 1)
    % only one element with x
    % check signs and multipliers
    if (strcmp(LHSOps(1), '-'))
        output = strcat('-(', output, ')');
    end;
    
    if (~strcmp(Mult{1}, '1'))
        output = strcat(output, '/', Mult{1});
    end;
else
    divisor = '';
    if (strcmp(LHSOps(1), '+'))
        divisor = strcat(divisor, '(', Mult{1});
    else
         divisor = strcat(divisor, '(-', Mult{1});
    end;
    
    for i = 2:length(LHSElements)
        divisor = strcat(divisor, LHSOps(i), Mult{i});
    end;
    divisor = strcat(divisor, ')');
    output = strcat('(', output, ')/', divisor);
end;
    
function multiplier = ParseElement(element, x)

% assumes that the element is of the form n*x/m
% and returns n/m in simplest form

if (strcmp(element, x))
    multiplier = '1';
    return;
end;

VarIndex = matchName(element, x);
MultIndex = strfind(element, '*');
DivIndex = strfind(element, '/');

if (isempty(MultIndex))
    MultIndex = 1;
end;

if (isempty(DivIndex))
    DivIndex = length(element);
end;

if ((DivIndex < MultIndex) ||(VarIndex < MultIndex) || (VarIndex > DivIndex)) 
    error('Cannot deal with formula in this form: %s', element);
end;

n = '';
m = '';

for i = 1:MultIndex-1
    n = strcat(n, element(i));
end;
if (isempty(n))
    n = '1';
end;

for i = DivIndex+1:length(element)
    m = strcat(m, element(i));
end;
if (isempty(m))
    m = '1';
end;

% if both m and n represenet numbers then they can be simplified

Num_n = str2num(n);
Num_m = str2num(m);

if (~isempty(Num_n) && ~isempty(Num_m))
    multiplier = num2str(Num_n/Num_m);
else
    if (strcmp(m, '1'))
        multiplier = n;
    else
    multiplier = strcat(n, '/', m);
    end;
end;

function y = LoseWhiteSpace(charArray)
% LoseWhiteSpace(charArray) takes an array of characters
% and returns the array with any white space removed
%
%----------------------------------------------------------------
% EXAMPLE:
%           y = LoseWhiteSpace('     exa  mp le')
%           y = 'example'
%

%------------------------------------------------------------
% check input is an array of characters
if (~ischar(charArray))
    error('LoseWhiteSpace(input)\n%s', 'input must be an array of characters');
end;

%-------------------------------------------------------------
% get the length of the array
NoChars = length(charArray);

%-------------------------------------------------------------
% create an array that indicates whether the elements of charArray are
% spaces
% e.g. WSpace = isspace('  v b') = [1, 1, 0, 1, 0]
% and determine how many

WSpace = isspace(charArray);
NoSpaces = sum(WSpace);

%-----------------------------------------------------------
% rewrite the array to leaving out any spaces
% remove any numbers from the array of symbols
if (NoSpaces > 0)
    NewArrayCount = 1;
    for i = 1:NoChars
        if (~isspace(charArray(i)))
            y(NewArrayCount) = charArray(i);
            NewArrayCount = NewArrayCount + 1;
        end;
    end;    
else
    y = charArray;
end;


% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011 November

%Use: result = LegalRxnFormula(reactions)
%Before:    formula - cell vector with reactions formulas
%           abbreviation - cell vector with reaction abbreviation
%           (optional)
%After: result true if all reactions are legal, else false.
%       msgbox lets user know which reaction is incorrect. 
%Note:  This script is just a start and only contains a few checks.
%       Add more test in near future. 

function result = LegalRxnFormula(formula,abbreviation)

if nargin == 1
    abbreviation = formula;
end
    
% Bug fix...
% ParseRxnFormula.m crashed if it is fed ' <=> '
% Check if reaction formula are 
%        ' <=> '
%        ' -> '
%        ''
result = check(find(strcmp('<=>',strtrim(formula))),abbreviation);
if result == false
    return
end

result = check(find(strcmp('->',strtrim(formula))),abbreviation);
if result == false
    return
end

%Check if reaction formula is empty
formula_empty = false(size(formula,1));
for i = 1:size(formula,1)
    if isempty(formula{i})
        formula_empty(i) = true;
    end
end

result = check(formula_empty,abbreviation);
if result == false
    return
end

function result = check(results,fields)

if(results)
    for i =1:length(results)
        if i == 1
            str = fields{results(i)};
        else
            str = [str ', ' fields{results(i)}];
        end
        
    end
    msgbox(['Reaction formula(s): '  str  ' is/are illeagal.']);
    result = false;
else
    result = true;
end

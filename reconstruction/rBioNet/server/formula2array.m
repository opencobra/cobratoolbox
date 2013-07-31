%Input: formula - valid reaction formula where metabolites have
%compartments that are specified with squer brackets "[]"
%Output: res - cell array, 
%       1. metabolite abreviation
%       2. metabolite value
%       3. metabolite compartment

function res = formula2array(formula)

[A B] = parseRxnFormula(formula);
mets =  cell(length(A),1);
values = cell(length(A),1);
comp = cell(length(A),1);
for i = 1:length(A)
    abb = A{i};
    abb = regexpi(abb,'[','split');
    c = abb{2};
    mets{i} = abb{1};
    
    values{i} = num2str(B(i));
    % Compartment MAX 3 char
    % If scripts detects larger values formula is incorrect.
    
    if length(c(1:end-1)) > 3
        fprintf('Formula is not correct: %s\n',formula);
    end
    comp{i} = c(1:end-1);
end
res = [mets, values, comp];

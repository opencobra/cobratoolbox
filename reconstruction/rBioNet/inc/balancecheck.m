
%Input      is cell matrix meta_meta type,  with one metabolite in each line, 
%           rows are [Abbreviation, Description, Coefficient, Compartment,
%            Side, Charge formula].
%
%Output     is empty if balance checks out, if unbalanced it returns 
%           cell matrix with Elements, prod and sub;
% 
%           numAtomsOfElementInFormula.m
% 
% 
% Stefan G. Thorleifsson July 2010

function  balance = balancecheck(meta_meta,output)

%output - incase other type of output is wanted from balance. Used in
%addreactions.m
if nargin < 2
    output = 0;
end

S = size(meta_meta);
Elements = {'C', 'H', 'O', 'P', 'S', 'N', 'Mg','X','Fe','Zn','Co','R'};
m = size(Elements);
sub = zeros(m); 
prod = zeros(m);  

for i = 1:S(1)
    if strcmp(meta_meta{i,5},'Substrate')
        for k = 1:length(Elements)
            element = numAtomsOfElementInFormula(meta_meta{i,6},Elements{k});
            sub(k) = sub(k) + meta_meta{i,3}*element;
        end
    else
        for k = 1:length(Elements)
            element = numAtomsOfElementInFormula(meta_meta{i,6},Elements{k});
            prod(k) = prod(k) + meta_meta{i,3}*element; 
        end
    end
end

% unbalanced(1,:) = Elements;   
% unbalanced(2,:) = num2cell(sub);
% unbalanced(3,:) = num2cell(prod);
% balance = unbalanced;

if output == 0
    if any(~(prod == sub))
        unbalanced(1,:) = Elements;
        unbalanced(2,:) = num2cell(sub);
        unbalanced(3,:) = num2cell(prod);
        balance = unbalanced;
    else
        balance = [];
    end
elseif output == 1
    unbalanced(1,:) = Elements;
    unbalanced(2,:) = num2cell(sub);
    unbalanced(3,:) = num2cell(prod);
    balance = unbalanced;
else
    error('wrong input');
end



    
    
    
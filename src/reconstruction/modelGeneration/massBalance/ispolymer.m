function res = ispolymer(formula)
% Checks to see if a formula corresponds to a polymer
%
% USAGE:
%
%    res = ispolymer(formula)
%
% INPUT:
%    formula:    formula to be checked
%
% OUTPUT:
%    res:        true if the formula corresponds to a polymer, false otherwise

list = {'X','R','FULLR','FULLR2','FULLR3'};
hasP=zeros(length(list),1);
for p=1:length(list)
	hasP(p)= numAtomsOfElementInFormula(formula,list{p});
end

res=any(hasP~=0);

end

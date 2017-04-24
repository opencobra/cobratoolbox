function mets = detectDeadEnds(model,removeExternalMets)
%DETECTDEADENDS returns a list(indices) of metabolites which either participate in only
%one reaction or can only be produced or consumed (all reactions involving
%the metabolite either only produce or only consume it, respecting the reaction lower and upper bounds. 
%
% outputMets = detectDeadEnds(model, removeExternalMets)
%
%INPUT
% model                 COBRA model structure
%
%OPTIONAL INPUT           
% removeExternalMets    Remove metabolites that participate in reactions of
%                       the following type:
%                       "A <=>/-> " or " <=>/-> A"
%
%OUTPUT
% outputMets            List of indicies of metabolites which can ether
%                       only be produced or consumed.
%
% Original: Unknown
% April 2017 - Thomas Pfau - massive Speed up and clarification of the
%                            removeExternalMets option

ltz = model.lb < 0;
gtz = model.ub > 0;

S = [model.S(:,gtz), -model.S(:,ltz)];
%Detect all metabolites which can only be produced or consumed (i.e. the absolute 
%sum of their coefficients, is the same as the sum of their absolute
%coefficients.
abssum = sum(abs(S),2);
sumabs = abs(sum(S,2));
onlyConsOrProd = sumabs == abssum;

%in addition, also find metabolites only involved in one reaction.

SPres = model.S~=0;
onlyOneReac = sum(SPres,2) == 1;


ExchangedMets = logical(zeros(size(model.S,1),1));

if removeExternalMets
    Exchangers = sum(SPres) == 1;
    ExchangedMets = sum(SPres(:,Exchangers),2) == 1;
end

mets = find((onlyConsOrProd | onlyOneReac) & ~ExchangedMets);

end
function mets = detectDeadEnds(model,removeExternalMets)
%DETECTDEADENDS returns a list of indices of metabolites which either participate in only
%one reaction or can only be produced or consumed (i.e. all reactions involving
%the metabolite either only produce or only consume it, respecting the reaction lower and upper bounds). 
%
% outputMets = detectDeadEnds(model, removeExternalMets)
%
%INPUT
% model                 COBRA model structure
%
%OPTIONAL INPUT           
% removeExternalMets    Dont return metabolites that participate in reactions of
%                       the following type:
%                       "A <=>/-> " or " <=>/-> A" or exclusively present in
%                       inconsistent reactions as defined in Gevorgyan et
%                       al, Bioinformatics, 2008
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

if (nargin > 1) && removeExternalMets    
    %Exchangers = sum(SPres) == 1;
    %ExchangedMets = sum(SPres(:,Exchangers),2) == 1;
    %This could also be done using a heuristic approach to detect external
    %mets, but this would need some additional explanation in the
    %documentation. How are "External" metabolites defined here?    
    [~,~,~,~,~,~,model] = findStoichConsistentSubset(model,0,0); % find inconsistent metabolites, assuming they are external both in Exchange reactions and in inconsistent reactions   
    InconsistentMetabolites = getCorrespondingRows(model.S,true(size(model.S,1),1),model.SInConsistentRxnBool,'exclusive'); % and select the according rows.
    ExchangedMets = InconsistentMetabolites | model.SExMetBool; %all inconsistent reactions, or reactions which are associated with Exchangers.    
    
end

mets = find((onlyConsOrProd | onlyOneReac) & ~ExchangedMets);

end
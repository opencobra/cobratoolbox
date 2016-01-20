function objectiveAbbr=checkObjective(model)
%checkObjective print out the Stoichiometric Coefficients for each 
%Metabolite, with the name of the objective
%
% objectiveAbbr = checkObjective(model)
%
%INPUT
% model             COBRA model structure
%
%OUTPUT
% objectiveAbbr     Objective reaction abbreviation
%
% Ronan Fleming 22/10/2008
% Thomas Pfau 15/12/2015 - Made the function compatible with sparse S matrices

objRxnInd=find(model.c~=0);
objectiveAbbr=model.rxns{objRxnInd};
if isempty(objRxnInd)
    warning('There is no objective!')
else
    fprintf('%s\t%s\t%s\t%s\t\t\t%s\n','Coefficient','Metabolite','#','Reaction','#')
    for n=1:length(objRxnInd)
        objMetInd=find(model.S(:,objRxnInd(n)));
        for m=1:length(objMetInd)
	    %Since the S Matrix tends to be sparse, and Sij is always a single value, this can easily be converted 
            Sij=full(model.S(objMetInd(m),objRxnInd(n)));
            if length(model.mets{objMetInd(m)})<4
                fprintf('%6.4g\t\t%s\t\t\t%i\t%s\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{objRxnInd(n)},objRxnInd(n))
            else
                if length(model.mets{objMetInd(m)})<8
                    fprintf('%6.4g\t\t%s\t\t%i\t%s\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{objRxnInd(n)},objRxnInd(n))
                else
                    if length(model.mets{objMetInd(m)})<12
                        fprintf('%6.4g\t\t%s\t%i\t%s\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{objRxnInd(n)},objRxnInd(n))
                    end
                end
            end
        end
    end
end


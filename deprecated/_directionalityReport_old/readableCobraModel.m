function model=readableCobraModel(model)
%Make a spreadsheet view of the model content for ease of viewing.
%
%this creates two cell arrays for reactions and metabolites so that they 
%can be read simultaneously in matlab. 
%NO DATA SHOULD BE CHANGED IN THESE CELL ARRAYS since they are 
%only there to be viewed.
%
%INPUT
% model.met(m)
% model.rxn(n)
%
%OUTPUT
% model.metabolites     cell array of metabolite data
% model.reactions       cell array of reaction data
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);

model.metabolites=cell(nMet,2);
model.metabolites{1,1}='abbreviation';
model.metabolites{1,2}='officialName';
model.metabolites{1,3}='dGft0Min';
model.metabolites{1,4}='dGft0Max';
model.metabolites{1,5}='dGftMin';
model.metabolites{1,6}='dGftMax';
model.metabolites{1,7}='albertyAbbreviation';
model.metabolites{1,8}='aveHbound';
model.metabolites{1,9}='aveZi';
model.metabolites{1,10}='nSpecies';
% model.metabolites{1,8}='albertyName';
for m=2:nMet+1
    model.metabolites{m,1} = model.mets(m-1); % model.met(m-1).abbreviation;
    model.metabolites{m,2} = model.metNames(m-1); % model.met(m-1).officialName;
%    model.metabolites{m,3} = model.met(m-1).dGft0Min;
%    model.metabolites{m,4}=model.met(m-1).dGft0Max;
    model.metabolites{m,5} = model.dGftMin(m-1); % model.met(m-1).dGftMin;
    model.metabolites{m,6} = model.dGftMax(m-1); % model.met(m-1).dGftMax;
%    model.metabolites{m,7}=model.met(m-1).albertyAbbreviation;
%    model.metabolites{m,8}=model.met(m-1).aveHbound;
%    model.metabolites{m,9}=model.met(m-1).aveZi;
    model.metabolites{m,10}=length(model.met(m-1).mf);
%     model.metabolites{m,8}=model.met(m-1).albertyName;
end

%thermodynamic constraints overly tighten
tightened=false(nRxn,1);
%reversible now forward
reversibleFwd=false(nRxn,1);
%reversible now reverse
reversibleRev=false(nRxn,1);
%forward now reverse
forwardReverse=false(nRxn,1);
%forward now reversible
forwardReversible=false(nRxn,1);

for n=1:nRxn
    if ~strcmp(model.rxn(n).directionality,model.rxn(n).directionalityThermo)
        if strcmp(model.rxn(n).directionality,'reversible')
            tightened(n)=1;
            if strcmp(model.rxn(n).directionalityThermo,'forward')
                reversibleFwd(n)=1;
            else
                reversibleRev(n)=1;
            end
        end
        if strcmp(model.rxn(n).directionality,'forward')
            if strcmp(model.rxn(n).directionalityThermo,'reverse')
                forwardReverse(n)=1;
            else
                forwardReversible(n)=1;
            end
        end
    end
end

if ~isfield(model,'SExRxnInd');
    model=findSExRxnInd(model);
end
%ignore exchange reactions
reversibleFwd(~model.SIntRxnBool)=0;
reversibleRev(~model.SIntRxnBool)=0;
forwardReverse(~model.SIntRxnBool)=0;
forwardReversible(~model.SIntRxnBool)=0;

changedDir=reversibleFwd+reversibleRev+forwardReverse+forwardReversible;
if max(changedDir)>1
    error('directionality check bug')
end

%last condition necessary in case some reactions have been set already
model.reactions=cell(nRxn,9);
model.reactions{1,1}='abbreviation';
model.reactions{1,2}='officialName';
model.reactions{1,3}='equation';
model.reactions{1,4}='lb';
model.reactions{1,5}='ub';
model.reactions{1,6}='directionality';
model.reactions{1,7}='directionalityThermo';
model.reactions{1,8}='dGtMin';
model.reactions{1,9}='dGtMax';
model.reactions{1,10}='dGt0Min';
model.reactions{1,11}='dGt0Max';
for n=2:nRxn+1
    model.reactions{n,1}=model.rxns{n-1};
    model.reactions{n,2}=model.rxnNames{n-1};
    model.reactions{n,3}=model.rxn(n-1).equation;
    model.reactions{n,4}=model.lb(n-1);
    model.reactions{n,5}=model.ub(n-1);
    model.reactions{n,6}=model.rxn(n-1).directionality;
    %thermo directions only if different
    model.reactions{n,7}=[];
    if ~strcmp(model.rxn(n-1).directionality,model.rxn(n-1).directionalityThermo)
        %only add entry if changed
        if changedDir(n-1)==1
            if reversibleFwd(n-1)
                model.reactions{n,7}='reversibleFwd';
            end
            if reversibleRev(n-1)
                model.reactions{n,7}='reversibleRev';
            end
            if forwardReverse(n-1)
                model.reactions{n-1,7}='forwardReverse';
            end
            if forwardReversible(n-1)
                model.reactions{n,7}='forwardReversible';
            end
        end
    end
    model.reactions{n,8}=model.rxn(n-1).dGtMin;
    model.reactions{n,9}=model.rxn(n-1).dGtMax;
    model.reactions{n,10}=model.rxn(n-1).dGt0Min;
    model.reactions{n,11}=model.rxn(n-1).dGt0Max;
end


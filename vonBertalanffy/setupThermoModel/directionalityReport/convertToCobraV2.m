function model=convertToCobraV2(model)
% Generate a model structure with metabolite and reaction subfields instead of vectors.
%
% create a COBRA v2 model structure with model.met(m) for metabolites and
% model.rxn(n) for reactions. This keeps all the information about a
% metabolite or reaction in one place. The primary keys model.mets and
% model.rxns are kept as is, and these can be used to access groups of
% model.met or model.rxn quickly.
%
% Replaces (*) with [*] to denote compartment in metabolite abbreviations
%
%
%INPUT
% model.S                   Stoichiometric matrix 
% model.rxns                Abbreviation for each reaction (primary key)
% model.rxnNames            Full name for each reaction
% model.mets                Abbreviation for each metabolite (primary key)
% model.metNames            Full name for each metabolite
% model.biomassRxnAbbr      abbreviation of biomass reaction
%
%OPTIONAL INPUT
% model.metFormulas         m x 1 cell array of strings with chemical 
%                           formula for metabolite
% model.metCharges          m x 1 numeric charge for each metabolite
%                           species
% 
%OUTPUT
% model.S                       Sparse Stoichiometric matrix +/- with 
%                               adjustment of reactions involving C02 
% model.SIntRxnBool             Boolean of internal reactions, i.e.
%                               non-mass balanced reactions
% model.met(m).abbreviation     metabolite abbreviation (primary key)
% model.met(m).officialName     metabolite name    
% model.rxn(n).abbreviation     reaction abbreviation (primary key)
% model.rxn(n).officialName     reaction name
% model.rxn(n).equation         reaction equation
% model.rxn(n).directionality   qualitative directionality    
% model.rxn(n).regulationStatus {('On'),'Off'} Off if lb=ub=0 
%
%OPTIONAL OUTPUT
% model.met(m).formula          metabolite elemental formula
%
% Ronan M. T. Fleming

[nMet,nRxn]=size(model.S);

%make it sparse
model.S=sparse(model.S);

numChar=1;
[allMetCompartments,uniqueCompartments]=getCompartment(model.mets,numChar);

if ~exist('thermoAdjustmentToS','var')
    thermoAdjustmentToS=1;
end

for m=1:nMet
    %find the rows with columns that are all zeros
    if nnz(model.S(m,:))==0
        fprintf('%s\n',['metabolite ' model.mets{m} ' without a reaction???']);
%         error(['metabolite ' model.mets{m} ' without a reaction.']);
    end
    
    %replace (*) with [*] to denote compartment
    model.mets{m}(end-2)='[';
    model.mets{m}(end)=']';
end

% start the conversion to a cobra v2 style model
fprintf('%s\n','Converting to cobra toolbox v2 style model.')
[nMet,nRxn]=size(model.S);

for n=1:nRxn
    model.rxn(n).abbreviation=model.rxns{n};
    model.rxn(n).officialName=model.rxnNames{n};
    %equation
    equation=printRxnFormula(model,model.rxns(n),0);
    model.rxn(n).equation=equation{1};
    %directionality
    if model.lb(n)<0 && model.ub(n)>0
        model.rxn(n).directionality='reversible';
    end
    if model.lb(n)<0 && model.ub(n)<=0
        model.rxn(n).directionality='reverse';
    end
    if model.lb(n)>=0 && model.ub(n)>0
        model.rxn(n).directionality='forward';
    end
    if model.lb(n)==0 && model.ub(n)==0
        model.rxn(n).directionality='off';
    end
end

%new metabolite structure
for m=1:nMet
    model.met(m).abbreviation=model.mets{m};
    model.met(m).officialName=model.metNames{m};
%    model=rmfield(model,'metNames');
end

if isfield(model,'metFormulas')
    for m=1:nMet
         model.met(m).formula=model.metFormulas{m};
    end
    model=rmfield(model,'metFormulas');
end

if isfield(model,'metCharges')
    for m=1:nMet
         model.met(m).charge=model.metCharges(m);
    end
    model=rmfield(model,'metCharges');
end

% %replace any dashes in metabolite names with underscores
% for m=1:nMet
%     x = strfind(model.met(m).abbreviation,'-');
%     if x~=0
%         %cobra v2 mets have underscores
%         model.met(m).abbreviation(x)='_';
%         %make cobra v1 mets have all underscores also
%         abbr=model.mets{m};
%         abbr(x)='_';
%         model.mets{m}=abbr;
%     end
% end

%finds the reactions in the model which export/import from the model
%boundary i.e. mass unbalanced reactions
%e.g. Exchange reactions
%     Demand reactions
%     Sink reactions
model=findSExRxnInd(model);

fprintf('%s\n\n','...finished converting.')
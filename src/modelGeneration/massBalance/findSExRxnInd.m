function model=findSExRxnInd(model,nRealMet,printLevel)
%  model=findSExRxnInd(model,nRealMet,printLevel)
%Returns a model with boolean vectors indicating internal vs external (exchange/demand/sink) reactions.
%
%finds the reactions in the model which export/import from the model
%boundary
%e.g. Exchange reactions
%     Demand reactions
%     Sink reactions
%
%INPUT
% model
% model.biomassRxnAbbr      abbreviation of biomass reaction
% printLevel                
%
%OPTIONAL INPUT
% nRealMet                  specified in case extra rows in S which dont
%                           correspond to metabolties
%OUTPUT
% model.SIntRxnBool         Boolean of reactions heuristically though to be mass balanced.
% model.SIntMetBool         Boolean of metabolites heuristically though to be involved in mass balanced reactions.
% model.SOnlyIntMetBool     Boolean of metabolites heuristically though only to be involved in mass balanced reactions.
% model.SExMetBool          Boolean of metabolites heuristically though to be involved in mass imbalanced reactions.
% model.SOnlyExMetBool      Boolean of metabolites heuristically though only to be involved in mass imbalanced reactions.
% model.biomassBool         Boolean of biomass reaction
% 
% OPTIONAL OUTPUT
% model.DMRxnBool           Boolean of demand reactions. Prefix 'DM_'
% model.SinkRxnBool         Boolean of sink reactions. Prefix 'sink_'
% model.ExchRxnBool         Boolean of exchange reactions. Prefix 'EX_' or 'Exch_' or Ex_

% Ronan Fleming	            


[nMet,nRxn]=size(model.S);

if ~exist('nRealMet','var')
    nRealMet=length(model.mets);
    if nMet~=nRealMet
        if printLevel>0
            fprintf('%s\n','Detected extra rows of S without corresponding metabolite abbreviations.')
        end
    end
else
    if isempty(nRealMet)
        nRealMet=length(model.mets);
    end
end

if ~exist('printLevel','var')
    printLevel=0;
end

%locate biomass reaction if there is one
biomassBool=false(nRxn,1);
if ~isfield(model,'c')
    model.c=zeros(nMet,1);
end
if ~isfield(model,'biomassRxnAbbr')
    if 0
        if printLevel>0
            fprintf('%s\n','No model.biomassRxnAbbr ? Give abbreviation of biomass reaction if there is one.');
        end
    else
        bool=model.c~=0;
        if nnz(bool)==1
            model.biomassRxnAbbr=model.rxns{model.c~=0};
            if printLevel>0
                
                fprintf('%s%s\n','Assuming biomass reaction is: ', model.biomassRxnAbbr);
            end
            biomassBool(bool)=1;
        else
            if nnz(bool)==0
                if printLevel>0
                    fprintf('%s\n','No model.biomassRxnAbbr ? Give abbreviation of biomass reaction if there is one.');
                end
            else
                warning('More than one biomass reaction?');
            end
        end
    end
else
    %bool=strcmp(model.biomassRxnAbbr,model.rxns);
    biomassBool=false(nRxn,1);
    foundBiomass=strfind(model.rxns,model.biomassRxnAbbr);%finds a subset of the abbreviation
    for n=1:nRxn
        if ~isempty(foundBiomass{n})
            if printLevel>0
                fprintf('%s%s\n','Found biomass reaction: ', model.rxns{n});
            end
            biomassBool(n)=1;
        end
    end
    if nnz(biomassBool)==0
        if printLevel>0
            fprintf('%s\n','Assuming no biomass reaction.');
        end
    else
        if nnz(biomassBool)>1
            %warning('More than one biomass reaction?');
        end
    end
end
model.biomassBool=biomassBool;

SExRxnBoolOneCoefficient=false(nRxn,1);
for n=1:nRxn
    %find reactions with only one coefficient
    %or no coefficient at all - Ronan May 29th 2011
    if nnz(model.S(1:nRealMet,n))<=1
        SExRxnBoolOneCoefficient(n,1)=1;
        if printLevel>1
            if nonzeros(model.S(1:nRealMet,n))>0
                if printLevel>0
                    fprintf('%s\t%s\n','Positive coefficient:',model.rxns{n});
                end
            else
                if printLevel>0
                    fprintf('%s\t%s\n','Negative coefficient:',model.rxns{n});
                    %                 fprintf('%s%s%s%s%s\n','''',model.rxns{n},''',0 ,0 ''',model.mets{find(model.S(1:nRealMet,n)~=0)},''',0 ,0 ;');
                end
            end
        end
    end
end

% models with typical COBRA abbreviations - heuristic
model.ExchRxnBool=strncmp('EX_', model.rxns, 3)==1 | strncmp('Exch_', model.rxns, 5)==1 | strncmp('Ex_', model.rxns, 5)==1 | biomassBool;
%demand reactions going out of model
model.DMRxnBool=strncmp('DM_', model.rxns, 3)==1;
%sink reactions going into or out of model
model.SinkRxnBool=strncmp('sink_', model.rxns, 5)==1;


%remove ATP demand as it is usually mass balanced
bool=strcmp('ATPM',model.rxns);
if any(bool)
    if printLevel>0
        fprintf('%s\n','ATP maintenance reaction is not considered an exchange reaction by default. It should be mass balanced:')
        formulas = printRxnFormula(model,{'ATPM'});
    end
    model.DMRxnBool(bool)=0;
end
bool=strcmp('DM_atp(c)',model.rxns);
if any(bool)
    if printLevel>0
        fprintf('%s\n','ATP demand reaction is not considered an exchange reaction by default. It should be mass balanced')
        formulas = printRxnFormula(model,{'DM_atp(c)'});
    end
    model.DMRxnBool(bool)=0;
end
bool=strcmp('DM_atp_c_',model.rxns);
if any(bool)
    if printLevel>0
        fprintf('%s\n','ATP demand reaction is not considered an exchange reaction by default. It should be mass balanced:')
        formulas = printRxnFormula(model,{'DM_atp_c_'});
    end
    model.DMRxnBool(bool)=0;
end

%input/output
SExRxnBoolHeuristic = model.ExchRxnBool | model.DMRxnBool | model.SinkRxnBool;

diffBool= ~SExRxnBoolHeuristic & SExRxnBoolOneCoefficient;
if any(diffBool)
    if printLevel>0
        fprintf('%s\n','Exchanges that would otherwise have been missed without abbreviation prefix search:')
        fprintf('%s\t%s\t%s\t\t%s\t\t%s\n','Coefficient','Metabolite','#','Reaction','#')
    end
    for n=1:nRxn
        if diffBool(n)
            objMetInd=find(model.S(:,n));
            for m=1:length(objMetInd)
                Sij=full(model.S(objMetInd(m),n));
                if length(model.mets{objMetInd(m)})<4
                    if printLevel>0
                        fprintf('%g\t\t\t%s\t\t\t%i\t%s\t\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{n},n)
                    end
                else
                    if length(model.mets{objMetInd(m)})<8
                        if printLevel>0
                            fprintf('%g\t\t\t%s\t\t%i\t%s\t\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{n},n)
                        end
                    else
                        if length(model.mets{objMetInd(m)})<12
                            if printLevel>0
                                fprintf('%g\t\t\t%s\t%i\t%s\t\t%i\n',Sij,model.mets{objMetInd(m)},objMetInd(m),model.rxns{n},n)
                            end
                        end
                    end
                end
            end
        end
    end
end
    
% %dont check if there are coupling constraints
% %(E. coli E matrix specific)
% if ~isfield(model,'A')
%     diffBool= SExRxnBoolHeuristic & ~SExRxnBoolOneCoefficient;
%     if any(diffBool)
%         if printLevel>0
%             fprintf('%s\n','Exchanges missed by prefix search:')
%             fprintf('%s\t%s\n','#', 'Exchange')
%         end
%         for n=1:length(diffBool)
%             if diffBool(n)
%                 equation=printRxnFormula(model,model.rxns(n),0);
%                 if printLevel>0
%                     fprintf('%i\t%s\t%s\n',n,model.rxns{n},equation{1});
%                 end
%             end
%         end
%     end
% end
    
%amalagamate all exchanges
SExRxnBool= SExRxnBoolHeuristic | SExRxnBoolOneCoefficient;
model.SIntRxnBool=~SExRxnBool;
%rows corresponding to internal reactions
boolMet=true(nMet,1);
%first pair
model.SIntMetBool = getCorrespondingRows(model.S,boolMet,model.SIntRxnBool,'inclusive');
model.SOnlyExMetBool = getCorrespondingRows(model.S,boolMet,~model.SIntRxnBool,'exclusive');
%second pair
model.SOnlyIntMetBool = getCorrespondingRows(model.S,boolMet,model.SIntRxnBool,'exclusive');
model.SExMetBool = getCorrespondingRows(model.S,boolMet,~model.SIntRxnBool,'inclusive');
%sanity check
if nnz(model.SIntMetBool)+nnz(model.SOnlyExMetBool) ~= nnz(model.SIntMetBool)+nnz(model.SOnlyExMetBool)
    error('Inconsistency in metabolite counts')
end

















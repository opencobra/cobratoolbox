function model=findSExRxnInd(model,nRealMet,printLevel)
%  model=findSExRxnInd(model,nRealMet,printLevel)
%Returns a model with boolean vectors indicating internal vs exchange/demand/sink reactions.
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
%
%OPTIONAL INPUT
% nRealMet                  specified in case extra rows in S which dont
%                           correspond to metabolties
%OUTPUT
% model.SIntRxnBool         Boolean of reactions though to be mass balanced.
% model.SIntMetBool         Boolean of metabolites though only to be involved in mass balanced reactions.
% model.biomassBool         Boolean of biomass reaction
% 
% OPTIONAL OUTPUT
% model.DMRxnBool           Boolean of demand reactions. Prefix 'DM_'
% model.SinkRxnBool         Boolean of sink reactions. Prefix 'sink_'
%

% Ronan Fleming	11/05/2014  commit to git	              


[nMet,nRxn]=size(model.S);

if ~exist('printLevel','var')
    printLevel=0;
end

if ~exist('nRealMet','var')
    nRealMet=length(model.mets);
    if nMet~=nRealMet
        if printLevel>0
            fprintf('%s\n','Detected extra rows of S without corresponding metabolite abbreviations.')
        end
    end
end

biomassBool=false(nRxn,1);

%locate biomass reaction if there is one
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
                error('More than one biomass reaction?');
            end
        end
    end
else
    bool=strcmp(model.biomassRxnAbbr,model.rxns);
    if nnz(bool)==1
        if printLevel>0
            
            fprintf('%s%s\n','Found biomass reaction: ', model.biomassRxnAbbr);
        end
        biomassBool(bool)=1;
    else
        if nnz(bool)==0
            if printLevel>0
                fprintf('%s\n','Assuming no biomass reaction.');
            end
        else
            error('More than one biomass reaction?');
        end
    end
end

if nMet > 2000 && 0 %Ronan
    % Human model or E.coli merged matrix
    model.ExchRxnBool=strncmp('Exch_', model.rxns, 5)==1;
    model.EXRxnBool=strncmp('EX_', model.rxns, 3)==1;
    %demand reactions going out of model
    model.DMRxnBool=strncmp('DM_', model.rxns, 3)==1;
    
    bool=strcmp('DM_atp(c)',model.rxns);
    if any(bool)
        if printLevel>0
            fprintf('%s\n','ATP demand reaction is not considered an exchange reaction by default.')
        end
        model.DMRxnBool(bool)=0;
    end
    
    %sink reactions going into or out of model
    model.SinkRxnBool=strncmp('sink_', model.rxns, 5)==1;
    
    %input/output
    SExRxnBool = model.ExchRxnBool | model.EXRxnBool | model.DMRxnBool | model.SinkRxnBool | biomassBool;
    
    %double check now by identifying reactions with only one metabolite
    SExRxnBool2=false(nRxn,1);
    for n=1:nRxn
        %find reactions with only one coefficient
        if nnz(model.S(1:nRealMet,n))==1
            SExRxnBool2(n)=1;
        end
    end
    SExRxnBool2 = SExRxnBool2 | biomassBool;
    
    diffBool= ~SExRxnBool & SExRxnBool2;
    if any(diffBool)
        if printLevel>0
            fprintf('%s\n','Missed Exchanges:')
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
    
    %dont check if there are coupling constraints
    %(E. coli E matrix specific)
    if ~isfield(model,'A')
        diffBool= SExRxnBool & ~SExRxnBool2;
        if any(diffBool)
            if printLevel>0
                
                fprintf('%s\n','Exchanges (by prefix) with more than one coefficient:')
                fprintf('%s\t%s\n','#', 'Exchange')
            end
            for n=1:length(diffBool)
                if diffBool(n)
                    equation=printRxnFormula(model,model.rxns(n),0);
                    if printLevel>0
                        fprintf('%i\t%s\t%s\n',n,model.rxns{n},equation{1});
                    end
                end
            end
        end
    end
    
else
    SExRxnBool=false(nRxn,1);
    
    for n=1:nRxn
        %find reactions with only one coefficient
        %or no coefficient at all - Ronan May 29th 2011
        if nnz(model.S(1:nRealMet,n))<=1
            SExRxnBool(n,1)=1;
            if 0
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
    if ~isempty(strcmp('ATPM',model.rxns))
        if printLevel>0
            fprintf('%s\n','ATP maintenance reaction is not considered an exchange reaction by default.')
        end
        ATPM_Ind=find(strcmp('ATPM',model.rxns)==1);
        SExRxnBool(ATPM_Ind,1)=0;
    end
    SExRxnBool(biomassBool)=1;
end
model.SIntRxnBool=~SExRxnBool;

model.biomassBool=biomassBool;
%rows corresponding to internal reactions
model.SIntMetBool = sum(model.S(:,model.SIntRxnBool)~=0,2)~=0;















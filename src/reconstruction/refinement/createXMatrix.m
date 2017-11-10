function ExchangeRxnMatrix = createXMatrix(compoundsIn, transport, compartment)
% Creates a matrix full of exchange reactions based
% on the input list (creates an exchange reaction for each of the
% metabolites present in the model)
%
% USAGE:
%
%    ExchangeRxnMatrix = createXMatrix(compoundsIn, transport, compartment)
%
% INPUTS:
%    compoundsIn:         SU matrix
%    transport:           if 1, transport reactions will be defined as well for
%                         every compound (default: 0, which corresponds to only
%                         exchange reactions (from the specified compartment)
%    compartment:         (default = '[c]') --> transport from cytoplasm [c] to
%                         extracellular space [e] (or sink)
%                         any other compartment (except '[e]' creates transport from [c] to
%                         the compartment, from the compartment to the external compartment 
%                         and an exchanger in the external compartment.
% OUTPUT:
%   ExchangeRxnMatrix:    model containing all exchange reactions for all
%                         compounds in compoundsIn
%
% .. Author: - IT 11-10-07
%    Modifications TP October 2017

if ~exist('transport','var') || isempty(transport)
    transport = 0;
end
if ~exist('compartment','var') || isempty(compartment)
    compartment = '[c]';
else
    if strcmp(compartment,'[e]')
        error('Cannot use the external compartment as target compartment');
    end
end

%Bring the compounds in the right dimension.
compoundsIn = columnVector(compoundsIn);

showprogress(0,'Exchange reaction list ...');

ExchangeRxnMatrix = createModel;

cnt=1;
HTABLE = java.util.Hashtable;

%removes the compartment from compound name
compoundsIn=regexprep(compoundsIn,'(\w*)]','');
compoundsIn=regexprep(compoundsIn,'[','');
compoundsIn=regexprep(compoundsIn,']','');
compoundsIn=regexprep(compoundsIn,' ','');

compounds=unique(compoundsIn);

%creates sparse matrix with corresponding dimensions
if  transport==0
    ExchangeRxnMatrix.S=spalloc(length(compounds),length(compounds),length(compounds));
    %Create one sink reaction per input metabolit = 1 S entry, one model
    %metabolite and one reaction per input metabolite
elseif transport == 1
    if (strcmp(compartment,'[c]')==1)
        ExchangeRxnMatrix.S=spalloc(2 * length(compounds),2*length(compounds),3*length(compounds));
        %This has 1 transporter and 1 Exchanger = 3 non zero entries per input metabolite.
        %2 model metabolites per input metabolites and 2 reactions per
        %input metabolite.
    else
        ExchangeRxnMatrix.S=spalloc(3 * length(compounds),3 * length(compounds),5*length(compounds));
        %Generate 2 transporters and 1 Exchanger = 5 non zero entries per input metabolite.
        %3 model metabolites (c,e,comp) per input metabolites and 3 reactions per
        %input metabolite.
    end
end

ExchangeRxnMatrix.mets=compounds;
for i=1:length(compounds)
    HTABLE.put(compounds{i}, i);
end

for i=1:length(compounds)
    if ~isempty(compounds(i))
        if transport == 0
            tmp = ['sink_' compounds(i) compartment];
            ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
            tmp = ['sink for ' compounds(i)];
            ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
            tmp = ['1 ' compounds(i) compartment ' <==>'];
            ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
            tmp = [compounds(i) compartment];
            ExchangeRxnMatrix.mets(i) = strcat(tmp(1),tmp(2));
            %   ExchangeRxnMatrix.grRules{cnt}='';
            [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
            cnt = cnt + 1;

        elseif transport == 1 %currently only this branch is taken.
            tmp = ['Ex_' compounds(i) '[e]'];
            ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
            tmp = ['Exchange of ' compounds(i)];
            ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
            tmp = ['1 ' compounds(i) '[e] <==>'];
            ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
            tmp = [compounds(i) '[e]'];
            ExchangeRxnMatrix.mets(i) = strcat(tmp(1),tmp(2));
            HTABLE.put(ExchangeRxnMatrix.mets{i}, i);
            %   ExchangeRxnMatrix.grRules{cnt}='';
            [ExchangeRxnMatrix, HTABLE] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[], HTABLE);
            cnt = cnt + 1;

            if (strcmp(compartment,'[c]')==1)
                % creates transport reaction from [c] to [e]
                tmp = [compounds{i} 'tr'];
                ExchangeRxnMatrix.rxns{cnt,1} = tmp;
                tmp = ['Transport of ' compounds{i}];
                ExchangeRxnMatrix.rxnsNames{cnt,1} =   tmp;
                tmp = ['1 ' compounds{i} '[e] <==> 1 ' compounds{i} '[c]'];
                ExchangeRxnMatrix.rxnFormulas{cnt,1} =  tmp;
                tmp = [compounds{i} '[c]'];
                ExchangeRxnMatrix.mets{length(ExchangeRxnMatrix.mets)+1,1} = tmp;
                HTABLE.put(ExchangeRxnMatrix.mets{end}, length(ExchangeRxnMatrix.mets));
                %  ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix, HTABLE] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[], HTABLE);
                cnt = cnt + 1;

            else % keep this branch the same for now.
                % creates transport reaction from [c] to [p]
                tmp = [compounds{i} 't' compartment(2:end-1) 'r'];
                ExchangeRxnMatrix.rxns{cnt,1} = tmp;
                tmp = ['[c] to ' compartment ' Transport of ' compounds{i}];
                ExchangeRxnMatrix.rxnsNames{cnt,1} =   tmp;
                tmp = ['1 ' compounds{i} compartment ' <==> 1 ' compounds{i} '[c]'];
                ExchangeRxnMatrix.rxnFormulas{cnt,1} =  tmp;
                tmp = [compounds{i} '[c]'];
                ExchangeRxnMatrix.mets{length(ExchangeRxnMatrix.mets)+1,1} = tmp;
                tmp = [compounds{i} compartment];
                ExchangeRxnMatrix.mets{length(ExchangeRxnMatrix.mets)+1,1} = tmp;
                %  ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                cnt = cnt + 1;

                % creates transport reaction from [p] to [e]
                tmp = [compounds{i} 'tr'];
                ExchangeRxnMatrix.rxns{cnt,1} = tmp;
                tmp = [compartment ' to [e] Transport of ' compounds{i}];
                ExchangeRxnMatrix.rxnsNames{cnt,1} =   tmp;
                tmp = ['1 ' compounds{i} '[e] <==> 1 ' compounds{i} compartment];
                ExchangeRxnMatrix.rxnFormulas{cnt,1} =  tmp;
                %    ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                cnt = cnt + 1;
            end
        end
    end

    showprogress(i/length(compounds));
end
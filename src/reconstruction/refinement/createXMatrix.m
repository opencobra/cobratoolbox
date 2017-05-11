function ExchangeRxnMatrix = createXMatrix(compoundsIn, transport, compartment)
%createXMatrix creates a matrix full of exchange reactions based
% on the input list (creates an exchange reaction for each of the
% metabolites present in the model)
%
% ExchangeRxnMatrix = createXMatrix(compoundsIn,transport,compartment)
%
% INPUTS
%
% compoundsIn   - SU matrix
% transport     - if 1, transport reactions will be defined as well for
%               every compound (default: 0, which corresponds to only
%               exchange reactions)
% compartment   - (default = [c]) --> transport from cytoplasm [c] to
%               extracellulat space [e], [p] creates transport from [c] to
%               [p] and from [p] to [c]
% OUTPUT
%
% ExchangeRxnMatrix - model containing all exchange reactions for all
%                   compounds in compoundsIn
%
% 11-10-07 IT
%

if ~exist('transport','var') || isempty(transport)
    transport = 0;
end
if ~exist('compartment','var') || isempty(compartment)
    compartment = '[c]';
end

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
elseif transport == 1
    if (strcmp(compartment,'[c]')==1)
        ExchangeRxnMatrix.S=spalloc(length(compounds),2*length(compounds),3*length(compounds));
    elseif (strcmp(compartment,'[p]')==1)
        ExchangeRxnMatrix.S=spalloc(length(compounds),3*length(compounds),5*length(compounds));
    end
end

ExchangeRxnMatrix.mets=compounds;
for i=1:length(compounds)
    HTABLE.put(compounds{i}, i);
end
for i=1:length(compounds)
    if ~isempty(compounds(i))
        if transport == 0
            tmp = ['sink_' compounds(i) '[c]'];
            ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
            tmp = ['sink for ' compounds(i)];
            ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
            tmp = ['1 ' compounds(i) '[c] <==>'];
            ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
            tmp = [compounds(i) '[c]'];
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
                tmp = [compounds(i) 'tr'];
                ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2));
                tmp = ['Transport of ' compounds(i)];
                ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                tmp = ['1 ' compounds(i) '[e] <==> 1 ' compounds(i) '[c]'];
                ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));
                tmp = [compounds(i) '[c]'];
                ExchangeRxnMatrix.mets(length(ExchangeRxnMatrix.mets)+1,1) = strcat(tmp(1),tmp(2));
                HTABLE.put(ExchangeRxnMatrix.mets{end}, length(ExchangeRxnMatrix.mets));
                %  ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix, HTABLE] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[], HTABLE);
                cnt = cnt + 1;

            elseif (strcmp(compartment,'[p]')==1) % keep this branch the same for now.
                % creates transport reaction from [c] to [p]
                tmp = [compounds(i) 'tpr'];
                ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2));
                tmp = ['[c] to [p] Transport of ' compounds(i)];
                ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                tmp = ['1 ' compounds(i) '[p] <==> 1 ' compounds(i) '[c]'];
                ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));
                tmp = [compounds(i) '[c]'];
                ExchangeRxnMatrix.mets(length(ExchangeRxnMatrix.mets)+1,1) = strcat(tmp(1),tmp(2));
                tmp = [compounds(i) '[p]'];
                ExchangeRxnMatrix.mets(length(ExchangeRxnMatrix.mets)+1,1) = strcat(tmp(1),tmp(2));
                %  ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                cnt = cnt + 1;

                % creates transport reaction from [p] to [e]
                tmp = [compounds(i) 'tr'];
                ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2));
                tmp = ['[p] to [e] Transport of ' compounds(i)];
                ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                tmp = ['1 ' compounds(i) '[e] <==> 1 ' compounds(i) '[p]'];
                ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));
                %    ExchangeRxnMatrix.grRules{cnt}='';
                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                cnt = cnt + 1;
            end
        end
    end

    showprogress(i/length(compounds));
end

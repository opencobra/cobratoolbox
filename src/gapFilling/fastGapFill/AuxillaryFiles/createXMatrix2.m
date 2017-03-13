function ExchangeRxnMatrix = createXMatrix2(compoundsIn, transport, compartment, model)
%% ExchangeRxnMatrix = createXMatrix2(compoundsIn, transport, compartment, model)
% createXMatrix creates a matrix full of exchange reactions based
% on the input list (creates an exchange reaction for each of the
% metabolites present in the model)
%
% INPUT
% compoundsIn           List of metabolites
% transport             if 1, transport reactions will be defined as well for every
%                       compounds (default: 0, which corresponds to only exchange reactions)
% compartment           [c] --> transport from cytoplasm [c] to extracellular space
%                       [e] (default), [p] creates transport from [c] to [p] and from [p] to [c]
% model                 model structure - used to check if exchange reaction exists
%                       already before adding it to ExchangeRxnMatrix
%
% OUTPUT
% ExchangeRxnMatrix     Model structure containing all exchange and
%                       transport reactions
%
% 11-10-07      Ines Thiele
% 13-06-09      Ines Thiele. Added option to add transport reactions for intracellular
%               compartments
% June 2013     Ines Thiele. Added option to add transport reactions for
%               all metabolites in all model compartment to the cytosol,
%               as well as exchange reactions for all extracellular
%               metabolites.
%
% Ines Thiele, http://thielelab.eu.
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

compoundsInOri=compoundsIn;
[compoundsInOri2, remain] = strtok(compoundsInOri, '[');

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
    elseif (strcmp(compartment,'all')==1)
        ExchangeRxnMatrix.S=spalloc(7*length(compounds),10*length(compounds),10*length(compounds));
    end
end

%ExchangeRxnMatrix.mets=compounds;
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

            if (strcmp(compartment,'[c]')==1)
                tmp = ['Ex_' compounds(i) '[e]'];
                ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
                tmp = ['Exchange of ' compounds(i)];
                ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                tmp = ['1 ' compounds(i) '[e] <==>'];
                ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
                tmp = [compounds(i) '[e]'];
                % ExchangeRxnMatrix.mets(length() = strcat(tmp(1),tmp(2));
                % HTABLE.put(ExchangeRxnMatrix.mets{i}, i);
                %   ExchangeRxnMatrix.grRules{cnt}='';

                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[]);
                cnt = cnt + 1;
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
                tmp = ['Ex_' compounds(i) '[e]'];
                ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
                tmp = ['Exchange of ' compounds(i)];
                ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                tmp = ['1 ' compounds(i) '[e] <==>'];
                ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
                tmp = [compounds(i) '[e]'];
                % ExchangeRxnMatrix.mets(length() = strcat(tmp(1),tmp(2));
                % HTABLE.put(ExchangeRxnMatrix.mets{i}, i);
                %   ExchangeRxnMatrix.grRules{cnt}='';

                [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[]);
                cnt = cnt + 1;
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
            elseif (strcmp(compartment,'all'))==1 % [m],[n],[g],[l],[x],[r]
                % if compound(i) exists in a compartment than add a
                % transport from [c] to compartment
                comp = strmatch(compounds(i),compoundsInOri2,'exact');
                if ~isempty(comp)
                    if exist('model','var')
                        % check if exchange reaction is already  in original model
                        met = strmatch(strcat(compounds(i), '[e]'),model.mets,'exact');
                        if ~isempty(met) && isempty(find(model.S(met,:)==-1))
                            % add exchange reaction
                            tmp = ['Ex_' compounds(i) '[e]'];
                            ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
                            tmp = ['Exchange of ' compounds(i)];
                            ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                            tmp = ['1 ' compounds(i) '[e] <==>'];
                            ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
                            tmp = [compounds(i) '[e]'];
                            [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[]);
                            cnt = cnt + 1;
                        end
                    else
                        % add exchange reaction
                        tmp = ['Ex_' compounds(i) '[e]'];
                        ExchangeRxnMatrix.rxns(cnt,1) = strcat(tmp(1),tmp(2),tmp(3));
                        tmp = ['Exchange of ' compounds(i)];
                        ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat(tmp(1),tmp(2));
                        tmp = ['1 ' compounds(i) '[e] <==>'];
                        ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3));
                        tmp = [compounds(i) '[e]'];
                        [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000,[],[],[],[],[]);
                        cnt = cnt + 1;
                    end
                    % find all corresponding compartment metabolites
                    [token, remain] = strtok(compoundsInOri(comp), '[');
                    remain = unique(remain);
                    % [c] to [e]
                    if length(token) == 1 && strcmp(remain(1),'[e]')==1
                        % exclude those metabolites that only occur in [e]
                    else
                        ExchangeRxnMatrix.rxns(cnt,1) = strcat(compounds(i),'t','[e]','r');
                        ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat('Transport of','- ', compounds(i),' ([c] to ', '[e]',')');
                        tmp = ['1 ' compounds(i) '[e]' ' <==> 1 ' compounds(i) '[c]'];
                        ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),tmp(6));
                        [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                        cnt = cnt + 1;
                    end

                    for j = 1 : length(remain)
                        if strcmp(remain(j),'[c]')==0 && strcmp(remain(j),'[e]')==0 && ~isempty(char(remain(j))) % is not cytosolic
                            % creates transport reaction from [c] to the compartment
                            ExchangeRxnMatrix.rxns(cnt,1) = strcat(compounds(i),'t',remain(j),'r');
                            ExchangeRxnMatrix.rxnsNames(cnt,1) =   strcat('Transport of','- ', compounds(i),' ([c] to ', remain(j),')');
                            tmp = ['1 ' compounds(i) remain(j) ' <==> 1 ' compounds(i) '[c]'];
                            ExchangeRxnMatrix.rxnFormulas(cnt,1) =  strcat(tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),tmp(6));
                            %tmp = [compounds(i) '[c]'];
                            %ExchangeRxnMatrix.mets(length(ExchangeRxnMatrix.mets)+1,1) = strcat(tmp(1),tmp(2));
                            %tmp = [compounds(i) remain];
                            % ExchangeRxnMatrix.mets(length(ExchangeRxnMatrix.mets)+1,1) = strcat(tmp(1),tmp(2));
                            %  ExchangeRxnMatrix.grRules{cnt}='';
                            [ExchangeRxnMatrix] = addReactionGEM(ExchangeRxnMatrix,ExchangeRxnMatrix.rxns(cnt,1),ExchangeRxnMatrix.rxnsNames(cnt,1),ExchangeRxnMatrix.rxnFormulas(cnt,1),1,-10000,10000);
                            cnt = cnt + 1;
                        end
                    end
                end
                clear tmp remain token;

            end
        end
    end
    showprogress(i/length(compounds));
end

ExchangeRxnMatrix.mets = ExchangeRxnMatrix.mets';

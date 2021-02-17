function ExchangeRxnMatrix = createXMatrix2(compoundsIn, transport, compartment, model)
% Creates a matrix full of exchange reactions based
% on the input list (creates an exchange reaction for each of the
% metabolites present in the model)
%
% USAGE:
%
%    ExchangeRxnMatrix = createXMatrix2(compoundsIn, transport, compartment, model)
%
% INPUTS:
%    compoundsIn:          List of metabolites
%    transport:            if 1, transport reactions will be defined as well for every
%                          compounds (default: 0, which corresponds to only exchange reactions)
%    compartment:          [c] --> transport from cytoplasm [c] to extracellular space
%                          [e] (default), [p] creates transport from [c] to [p] and from [p] to [c]
%    model:                model structure - used to check if exchange reaction exists
%                          already before adding it to `ExchangeRxnMatrix`
%
% OUTPUT:
%    ExchangeRxnMatrix:    Model structure containing all exchange and
%                          transport reactions
%
% .. Authors:
%       - Ines Thiele, 11-10-07
%       - Ines Thiele, 13-06-09, Added option to add transport reactions for intracellular compartments
%       - Ines Thiele, June 2013,  Added option to add transport reactions for
%         all metabolites in all model compartment to the cytosol,
%         as well as exchange reactions for all extracellular metabolites.

if ~exist('transport','var') || isempty(transport)
    transport = 0;
end
if ~exist('compartment','var') || isempty(compartment)
    compartment = '[c]';
end

showprogress(0,'Exchange reaction list ...');

ExchangeRxnMatrix = createModel;
if isfield(ExchangeRxnMatrix,'grRules')
    ExchangeRxnMatrix = rmfield(ExchangeRxnMatrix,'grRules');
end
if isfield(ExchangeRxnMatrix,'genes')
    ExchangeRxnMatrix = rmfield(ExchangeRxnMatrix,'genes');
end
if isfield(ExchangeRxnMatrix,'rxnGeneMat')
    ExchangeRxnMatrix = rmfield(ExchangeRxnMatrix,'rxnGeneMat');
end
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

%ExchangeRxnMatrix.mets=compounds;
for i=1:length(compounds)
    HTABLE.put(compounds{i}, i);
end
for i=1:length(compounds)
    if ~isempty(compounds(i))
        if transport == 0
            R = ['sink_' compounds(i) '[c]'];
            sub = cellstr([compounds{i} '[c]']);
            [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',sub(1),'stoichCoeffList',[-1],'lowerBound',-10000','upperBound',10000);
            
        elseif transport == 1 %currently only this branch is taken.
            
            if (strcmp(compartment,'[c]')==1)
                R = ['EX_' compounds(i) '[e]'];
               
                sub = cellstr([compounds{i} '[e]']);
                [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',sub(1),'stoichCoeffList',[-1],'lowerBound',-10000','upperBound',10000);
            
                % creates transport reaction from [c] to [e]
                R = [compounds(i) 'tr'];
                sub = cellstr([compounds{i} '[e]']);
                prod = cellstr([compounds{i} '[c]']);
                
                [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',[sub(1) prod(1)],'stoichCoeffList',[-1 1],'lowerBound',-10000','upperBound',10000);
               
            elseif (strcmp(compartment,'[p]')==1) % keep this branch the same for now.
                R = ['EX_' compounds{i} '[e]'];
                sub = cellstr([compounds{i} '[e]']);
                [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',sub(1),'stoichCoeffList',[-1],'lowerBound',-10000','upperBound',10000);
                % creates transport reaction from [c] to [p]
                R = [compounds{i} 'tpr'];
                sub = cellstr([compounds{i} '[p]']);
                prod = cellstr([compounds{i} '[c]']);
                [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',[sub(1) prod(1)],'stoichCoeffList',[-1 1],'lowerBound',-10000','upperBound',10000);
                
                % creates transport reaction from [p] to [e]
                R = [compounds{i} 'tr'];
                prod = [compounds{i} '[p]'];
                sub = [compounds{i} '[e]'];
                sub = cellstr([compounds{i} '[e]']);
                prod = cellstr([compounds{i} '[p]']);
                
                [ExchangeRxnMatrix] = addReaction(ExchangeRxnMatrix,R,'metaboliteList',[sub(1) prod(1)],'stoichCoeffList',[-1 1],'lowerBound',-10000','upperBound',10000);
                
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
    if isfield(ExchangeRxnMatrix,'grRules')
        ExchangeRxnMatrix = rmfield(ExchangeRxnMatrix,'grRules');
    end
    showprogress(i/length(compounds));
end
%Currently we are likely to have a largely blown up S matrix.
ExchangeRxnMatrix.S = ExchangeRxnMatrix.S(1:numel(ExchangeRxnMatrix.mets),1:numel(ExchangeRxnMatrix.rxns));


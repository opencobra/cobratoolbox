function [Rxns, grRules] = getRxnsFromGene(model,gene,causal)
% This function gets all reaction(s) associated with a particular gene by
% screening through the grRules provided in the model structure
% 
%
% [Rxns, grRules] = getRxnsFromGene(model,gene,causal)
% 
% INPUT
% model     model structure
% gene      gene of interest
% causal    if causal == 1 get only genes that would lead to loss of function of the
%           associated reactions, otw get all associated reactions
%           (default)
% 
% OUTPUT
% Rxns      List of reaction(s) associated with the input gene
% grRules   List of grRules containing the input gene, same order as Rxns
% 
% Ines Thiele 10/2019

if  ~exist('causal','var')
    causal = 0;
end

assoR = [];
for i = 1 : length(model.grRules)
    if ~isempty(strfind(model.grRules{i},gene))
        if causal == 1
            % case 1 - 1 gene
            if  ~isempty(strmatch(model.grRules{i},gene,'exact')) % perfect match
                assoR(i,1)=1;
                % case 2 - 1 complex
            elseif ~isempty(strfind(model.grRules{i},{' and '})) &&  isempty(strfind(model.grRules{i},{' or '}))
                [c,d] = split(model.grRules{i},' and ');
                if ~isempty(strmatch(gene,c)) % works only for single genes or when at the beginning of and statement
                    assoR(i,1)=1;
                end
            elseif ~isempty(strfind(model.grRules{i},{' or '})) % consider cases of alt splices and ' or '
                cnt = 0;
                [geneTok] = strtok(gene,'.');
                if isempty(strfind(model.grRules{i},{' and '})) % only 'or's
                    [c,d] = split(model.grRules{i},' or ');
                    for j = 1 : length(c)
                        cTok = strtok(c{j},'.');
                        if ~isempty(strmatch(geneTok,cTok,'exact')) % perfect match
                            cnt = cnt +1;
                        end
                    end
                    if cnt == length(c) % all genes in or are alt splice forms
                        assoR(i,1)=1;
                    end
                else % contains 'and'
                    [c,d] = split(model.grRules{i},' or '); % split first the 'or's
                    for j = 1 : length(c)
                        if ~isempty(strfind(c{j},{' and '})) % if 'and'
                            [a,b] = split(c{j},' and '); % split the 'and's
                            for k = 1 : length(a)
                                aTok = strtok(a{k},'.');
                                if ~isempty(strmatch(geneTok,aTok,'exact')) % perfect match
                                    cnt = cnt +1;
                                end
                            end
                        else % no 'and'
                            cTok = strtok(c{j},'.');
                            if ~isempty(strcmp(geneTok,cTok)) % perfect match
                                cnt = cnt +1;
                            end
                        end
                    end
                    % if there are as many counts as c's
                    if cnt == length(c) % all genes in or are alt splice forms
                        assoR(i,1)=1;
                    end
                end
            end
        else
            assoR(i,1) = 1;
        end
        
    end
end
Rxns=  model.rxns(find(assoR))
grRules= model.grRules(find(assoR))
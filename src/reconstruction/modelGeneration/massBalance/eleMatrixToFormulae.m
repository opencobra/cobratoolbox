function metForm = convertMatrixFormulas(element, metEle, dMax)
%Convert the matrix form of the chemical formulae into string form
%metForm = convertMatrixFormulas(element, metEle, dMax)
%Input:
%  element:     cell array of element corresponding to the columns of metEle
%  metEle:      chemical formulas in a M by E matrix for M metabolites and 'E elements in 'element'
%  dMax:        the maximum number of digits taken for the stoichiometry
%
%Siu Hung Joshua Chan Nov 2016
if nargin < 3 
    dMax = 12;
end
%combine duplicate elements
[eleUni,ia,ib] = unique(element);
if numel(eleUni) < numel(element)
    for j = 1:numel(eleUni)
        metEle(:,ia(j)) = sum(metEle(:,ib == j),2);
    end
    element = eleUni;
    metEle = metEle(:,ia);
end
%prioritize elements
[~,id] = ismember({'C';'H';'N';'O';'P';'S'}, element);
id2 = setdiff(1:numel(element), id);
element = element([id(id~=0); id2(:)]);
metEle = metEle(:, [id(id~=0); id2(:)]);
element = element(:);
%charge put at the end if exist
id = strcmp(element,'Charge');
if any(id)
    element = [element(~id); element(id)];
    metEle = metEle(:,[find(~id); find(id)]);
end
metForm = repmat({''}, size(metEle,1),1);
for j = 1:size(metEle,1)
    if ~any(isnan(metEle(j,:)))
        if ~any(metEle(j,:))
            metJ = 'Mass0'; %allow mets with no mass (e.g. photon)
        else
            metJ = '';
            for k = 1:numel(element)
                if abs(metEle(j,k)) > 10^(-dMax)
                    n = full(metEle(j,k));
                    d = 0;
                    while abs(round(n,d) - n) > 1e-10 && d < dMax
                        d = d + 1;
                    end
                    n = round(n,d);
                    if n == 1 && ~strcmp(element{k},'Charge')
                        metJ = strcat(metJ, element{k});
                    else
                        str = sprintf(['%.' num2str(dMax) 'f'],n);
                        str = regexp(fliplr(str),'0*+(\d*\.\d*\-?)|(.*)','tokens');
                        str = fliplr(str{1}{1});
                        if str(end) == '.'
                            str(end) = '';
                        end
                        metJ = strcat(metJ, element{k}, str);
                    end
                end
            end
        end
        metForm{j} = metJ;
    end
end
end
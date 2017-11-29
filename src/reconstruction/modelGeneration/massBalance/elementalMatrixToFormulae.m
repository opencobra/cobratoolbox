function metForm = elementalMatrixToFormulae(Ematrix, elements, dMax)
% Convert the elemental composition matrix into chemical formulae
%
% USAGE:
%    metForm = elementalMatrixToFormulae(elements, Ematrix, dMax)
%
% INPUTS:
%  Ematrix:      elemental composition (`M` x `E` matrix) for `M` metabolites and `E` elements
%  elements:     cell array of elements corresponding to the columns of Ematrix
%
% OPTIONAL INPUT:
%  dMax:         the maximum number of decimal places for the stoichiometry (default 12)
%
% Siu Hung Joshua Chan Nov 2016
if nargin < 3 
    dMax = 12;
end
%combine duplicate elements
[eleUni,ia,ib] = unique(elements);
if numel(eleUni) < numel(elements)
    for j = 1:numel(eleUni)
        Ematrix(:,ia(j)) = sum(Ematrix(:,ib == j),2);
    end
    elements = eleUni;
    Ematrix = Ematrix(:,ia);
end
%prioritize elements
[~,id] = ismember({'C';'H';'N';'O';'P';'S'}, elements);
id2 = setdiff(1:numel(elements), id);
elements = elements([id(id~=0); id2(:)]);
Ematrix = Ematrix(:, [id(id~=0); id2(:)]);
elements = elements(:);
%charge put at the end if exist
id = strcmp(elements,'Charge');
if any(id)
    elements = [elements(~id); elements(id)];
    Ematrix = Ematrix(:,[find(~id); find(id)]);
end
metForm = repmat({''}, size(Ematrix,1),1);
for j = 1:size(Ematrix,1)
    if ~any(isnan(Ematrix(j,:)))
        if ~any(Ematrix(j,:))
            metJ = 'Mass0'; %allow mets with no mass (e.g. photon)
        else
            metJ = '';
            for k = 1:numel(elements)
                if abs(Ematrix(j,k)) > 10^(-dMax)
                    n = full(Ematrix(j,k));
                    d = 0;
                    while abs(round(n,d) - n) > 1e-10 && d < dMax
                        d = d + 1;
                    end
                    n = round(n,d);
                    if n == 1 && ~strcmp(elements{k},'Charge')
                        metJ = strcat(metJ, elements{k});
                    else
                        str = sprintf(['%.' num2str(dMax) 'f'],n);
                        str = regexp(fliplr(str),'0*+(\d*\.\d*\-?)|(.*)','tokens');
                        str = fliplr(str{1}{1});
                        if str(end) == '.'
                            str(end) = '';
                        end
                        metJ = strcat(metJ, elements{k}, str);
                    end
                end
            end
        end
        metForm{j} = metJ;
    end
end
end
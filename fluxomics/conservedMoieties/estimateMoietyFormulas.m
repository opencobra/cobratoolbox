function [moietyFormulas,M] = estimateMoietyFormulas(L,E,elements)
% Estimates the chemical formulas of conserved moieties in a metabolic
% network
% 
% moietyFormulas = estimateMoietyFormulas(L,E)
% 
% INPUTS
% L        ... The m x r moiety matrix for a metabolic network. Each column is a
%              moiety vector.
% E        ... The m x p elemental matrix for metabolites in the metabolic network.
% elements ... A 1 x p cell array of element symbols.
% 
% OUTPUT
% M              ... An r x p estimated elemental matrix for moieties.
% moietyFormulas ... An r x 1 cell array of estimated moiety formulas.
% 
% Nov. 2015, Hulda S. Haraldsd??ttir

M = round(L\E); % Estimated elemental matrix for moieties

% Write formulas
elements = elements(:)';
ebool = ismember(elements,'e'); % electron
elements = elements(~ebool); % remove electron
M = M(:,~ebool); % remove electron

[elements,xi] = sort(elements); % Sort elements in alphabetical order
M = M(:,xi); % Sort elements in alphabetical order

r = size(M,1);
moietyFormulas = cell(r,1);

for k = 1:r
    idx = find(M(k,:));
    c = elements(idx);
    m = regexp(num2str(M(k,idx)),'\s+','split');
    m(ismember(m,'1')) = {''};
    F = [c; m];
    
    moietyFormulas{k} = sprintf('%s%s',F{:});
end
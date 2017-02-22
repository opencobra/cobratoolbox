function [E,elements] = constructElementalMatrix(metFormulas,metCharges)
% Constructs the elemental matrix for a set of metabolites
% 
% [E,elements] = constructElementalMatrix(metFormulas,metCharges)
% 
% INPUT
% metFormulas ... m x 1 cell array of metabolite formulas, e.g., CHO2
% 
% OPTIONAL INPUT
% metCharges  ... m x 1 vector of metabolite charges. Used to compute the
%                 electron vector.
% 
% OUTPUTS
% E        ... The m x p elemental matrix where p is the number of unique
%              elements in metFormulas (plus the electron if metCharges is
%              included as input) 
% elements ... 1 x p cell array of element symbols (e for electron)
% 
% Nov. 2015, Hulda S. Haraldsdóttir

% Format inputs
m = length(metFormulas);

includee = nargin == 2;
if nargin < 2 || isempty(metCharges)
    metCharges = zeros(m,1);
end

load atomicNumbers.mat % Load list of elements (s) and their atomic numbers (n)
s = [s; {'R'; 'X'; 'e'}]; % add pseudoelements and electron
n = [n; 0; 0; 0];
p = length(s);

% Construct elemental matrix
E = sparse(m,p);
for i = 1:m
    f = metFormulas{i};
    c = metCharges(i);
    
    for j = 1:p-1
        E(i,j) = numAtomsOfElementInFormula(f,s{j});
    end
    
    a = E(i,:)*n;
    E(i,end) = a - c;
end

% Remove invalid electon vector
if ~includee
    s = s(1:end-1);
    E = E(:,1:end-1);
end

% Remove elements not found in any metabolite formula
elements = s(any(E,1))';
E = E(:,any(E,1));

% Sort elements in alphabetical order
[elements,xi] = sort(elements);
E = E(:,xi);

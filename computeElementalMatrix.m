function [Ematrix] = computeElementalMatrix(model, metList, warnings)
%computeElementalMatrix Compute elemental matrix
%
% [Ematrix] = computeElementalMatrix(model, metList, warnings)
%
% INPUT
% model             COBRA model structure 
%                   (must define .mets and .metFormulas)
%
% OPTIONAL INPUTS
% metList           Cell array of which metabolites to search for
%                   (Default = all metabolites in model)
% warnings          Display warnings if there are errors with the
%                   formula.  (Default = true)
%
% OUTPUT
% Ematrix           m x 6 matrix of order [C N O H P other]

% Extracted from computeMW. Richard Que (1/22/10)

if nargin < 3
    warnings = true;
end

if nargin < 2 || isempty(metList)
    metIDs = 1:length(model.mets);
else
    metIDs = findMetIDs(model,metList);
end

metIDs = reshape(metIDs, length(metIDs),1);

Ematrix = zeros(length(metIDs), 6);
for n = 1:length(metIDs)
    i = metIDs(n);
    formula = model.metFormulas(i);
    [compounds, tok] = regexp(formula, '([A-Z][a-z]*)(\d*)', 'match', 'tokens');
    tok = tok{1,1};
    for j = 1:length(tok) % go through each token.
        t = tok{1,j};
        comp = t{1,1};
        q = str2num(t{1,2});
        if (isempty(q))
            q = 1;
        end
        switch comp
            case 'H'
                Ematrix(n,4) = q;
            case 'C'
                Ematrix(n,1) = q;
            case 'N'
                Ematrix(n,2) = q;
            case 'O'
                Ematrix(n,3) = q;
            case 'Na'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Mg'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'P'
                Ematrix(n,5) = q;
            case 'S'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Cl'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'K'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Ca'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Mn'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Fe'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Ni'
                Ematrix(n,6) = Ematrix(n,6) + q;                
            case 'Co'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Cu'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Zn'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'As'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Se'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Ag'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Cd'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'W'
                Ematrix(n,6) = Ematrix(n,6) + q;
            case 'Hg'
                Ematrix(n,6) = Ematrix(n,6) + q;
            otherwise
                if warnings
                    display('Warning');
                    display(formula)
                    display(comp);
                end
        end
    end

end
    
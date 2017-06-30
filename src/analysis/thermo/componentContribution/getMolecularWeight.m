function [MW, Ematrix] = getMolecularWeight(inchis, warnings)
%computeMW Compute molecular weight and elemental matrix of compounds
%
% [MW, Ematrix] = computeMW(model, metList, warnings)
%
%INPUT
% model             COBRA model structure 
%                   (must define .mets and .metFormulas)
%
%OPTIONAL INPUTS
% metList           Cell array of which metabolites to search for.
%                   (Default = all metabolites in model)
% warnings          Display warnings if there are errors with the
%                   formula.  (Default = true)
%
%OUTPUT
% MW                Vector of molecular weights
% Ematrix           m x 8 matrix of order [H, C, N, O, P, S, e-]
%                   Note that the number of electrons (e-) is counted only for these 6 
%                   common elements (i.e. we assume all other elements are not involved 
%                   in redox reactions anyway).

% Jan Schellenberger (Nov. 5, 2008)

if nargin < 2
    warnings = true;
end

letters = {'H', 'C', 'N', 'O', 'P', 'S', 'Na', 'Mg', 'Cl', 'K', 'Ca', 'Mn', 'Fe', 'Ni', 'Co', 'Cu', 'Zn', 'As', 'Se', 'Ag', 'Cd', 'W', 'Hg'};
weights = [  1,  12,  14,  16,  31,  32,   23,   24,   35,  39,   40,   55,   56,   58,   59,   63,   65,   75,   80,  107,  114, 184, 202];
protons = [  1,   6,   7,   8,  15,  16];

Ematrix = zeros(length(inchis), length(letters));
charges = zeros(length(inchis), 1);
for n = 1:length(inchis)
	if isempty(inchis{n})
		Ematrix(n, :) = NaN;
        if warnings
            fprintf('Warning: InChI no. %d is empty', n);
        end		
        continue;
    end
    [formula, nH, charge] = getFormulaAndChargeFromInChI(inchis{n});
    charges(n) = charge;
    [~, tok] = regexp(formula, '([A-Z][a-z]*)(\d*)', 'match', 'tokens');

    for j = 1:length(tok) % go through each token.
        comp = tok{j}{1};
        q = str2num(tok{j}{2});
        if isempty(q)
            q = 1;
        end
        k = find(strcmp(letters, comp));
        if isempty(k)
            if warnings
                fprintf('Warning: %s, %s', formula, comp);
            end
        else
            Ematrix(n, k) = q;
        end
    end
end
MW = Ematrix * weights';
electrons = Ematrix(:, 1:length(protons)) * protons' - charges;
Ematrix = [Ematrix(:, [1:length(protons)]), electrons];

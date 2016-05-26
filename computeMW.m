function [MW, Ematrix] = computeMW(model, metList, warnings)
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
% Ematrix           m x 6 matrix of order [C N O H P other]

% Jan Schellenberger (Nov. 5, 2008)

if nargin < 3
    warnings = true;
end

if nargin < 2 || isempty(metList)
    metList = model.mets;
    metIDs = 1:length(model.mets);
else
    metIDs = findMetIDs(model,metList);
end

metIDs = reshape(metIDs, length(metIDs),1);

MW = zeros(size(metIDs));
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
        mwt = 0;
        switch comp
            case 'H'
                mwt = 1;
            case 'C'
                mwt = 12;
            case 'N'
                mwt = 14;  
            case 'O'
                mwt = 16;
            case 'Na'
                mwt = 23;
            case 'Mg'
                mwt = 24;   
            case 'P'
                mwt = 31;
            case 'S'
                mwt = 32;     
            case 'Cl'
                mwt = 35;                  
            case 'K'
                mwt = 39;                     
            case 'Ca'
                mwt = 40;                 
            case 'Mn'
                mwt = 55;                
            case 'Fe'
                mwt = 56;
            case 'Ni'
                mwt = 58;
            case 'Co'
                mwt = 59;                
            case 'Cu'
                mwt = 63;                  
            case 'Zn'
                mwt = 65;          
            case 'As'
                mwt = 75;                  
            case 'Se'
                mwt = 80;     
            case 'Ag'
                mwt = 107;         
            case 'Cd'
                mwt = 114;              
            case 'W'
                mwt = 184;                    
            case 'Hg'
                mwt = 202;       
            otherwise
                if warnings
                    display('Warning');
                    display(formula)
                    display(comp);
                end
        end
        MW(n) = MW(n)+ q*mwt;
    end
end
Ematrix = computeElementalMatrix(model,metList,false);
    
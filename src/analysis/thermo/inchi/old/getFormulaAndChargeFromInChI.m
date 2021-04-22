function [formula, nH, charge] = getFormulaAndChargeFromInChI(inchi)

% [formula,charge] = getFormulaAndChargeFromInChI(inchi)
% 
% INPUT
% inchi.......Nonstandard IUPAC InChI for a particular pseudoisomer of a
%             metabolite
% 
% OUTPUTS
% formula....The chemical formula for the input pseudoisomer
% charge.....The charge on the input pseudoisomer


layers = regexp(inchi,'/','split');
f1 = layers{2}; % Fully protonated formula

p = {};
if ~isempty(strmatch('p',layers))
    p = layers{strmatch('p',layers)}; % nH to add or subtract
end

q = {};
if ~isempty(strmatch('q',layers))
    q = layers{strmatch('q',layers)}; % charge
end

if ~isempty(q)
   charge = str2double(q(2:end));
else
    charge = 0;
end

f1_nH = numAtomsOfElementInFormula(f1,'H'); % nH in fully protonated formula
if ~isempty(p)
    nH = f1_nH + str2double(p(2:end)); % nH in pseudoisomer formula
else
    nH = f1_nH;
end

formula = regexprep(f1,'H[a-z]*[0-9]*',''); % Remove all H from fully protonated formula
if nH == 1
    formula = [formula 'H'];
elseif nH > 1
    formula = [formula 'H' num2str(nH)]; % Add appropriate nH back in to create pseudoisomer formula
elseif nH < 0
    error('Negative number of H in formula.') % Should never get here
end

% In case there is Hg in formula
f1_nHg = numAtomsOfElementInFormula(f1,'Hg');
if f1_nHg == 1
    formula = [formula 'Hg'];
elseif f1_nHg > 1
    formula = [formula 'Hg' num2str(f1_nHg)];
end

end

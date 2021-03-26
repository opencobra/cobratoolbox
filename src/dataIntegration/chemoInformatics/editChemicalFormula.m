function newFormula = editChemicalFormula(metFormula, addOrRemove)
% For each instance, removes non-chemical characters from the chemical
% formula and replaces them with a R group. Removes atoms from the formula 
% as well. Produces a chemical formula from a string of atoms.
%
% USAGE:
%
%    [metFormula] = cobraFormulaToChemFormula(metReconFormula)
%
% INPUTS:
%    metReconFormula:   An n x 1 array of metabolite Recon formulas
% OPTIONAL INPUTS:
%    addOrRemove:          A struct array containing:
%                           *.elements - element to edit
%                           *.times - vector indicated the times the
%                                     element will be deleted (negative) or 
%                                     added (positive)
%
% OUTPUTS:
%    chemicalFormula:	A chemical formula for a metabolite

if nargin < 2 || isempty(addOrRemove)
    addOrRemove = [];
end

% Update R groups
metFormula = regexprep(char(metFormula), 'X|Y|*|FULLR', 'R');

% Rearrange the formulas (e.g., from RCRCOC to C3OR2)

% Count the atoms
[elemetList, ~ , elemetEnd] = regexp(metFormula, ['[', 'A':'Z', '][', 'a':'z', ']?'], 'match');
[num, numStart] = regexp(metFormula, '\d+', 'match');
numList = ones(size(elemetList));
idx = ismember(elemetEnd + 1, numStart);
numList(idx) = cellfun(@str2num, num);

% Combine atoms if neccesary
uniqueElemetList = unique(elemetList);
for j = 1:size(uniqueElemetList, 2)
    atomBool = ismember(elemetList, uniqueElemetList{j});
    if sum(atomBool) > 1
        dataToKeep = find(atomBool);
        numList(dataToKeep(1)) = sum(numList(atomBool));
        numList(dataToKeep(2:end)) = [];
        elemetList(dataToKeep(2:end)) = [];
    end
end

% Delete/add atoms if neccesary
if ~isempty(addOrRemove)
    for i = 1:length(addOrRemove.elements)
        elemetBool = ismember(elemetList, addOrRemove.elements(i));
        if any(elemetBool)
            numList(elemetBool) = numList(elemetBool) + addOrRemove.times(i);
        else
            elemetList{size(elemetList, 2) + 1} = addOrRemove.elements{i};
            numList(size(elemetList, 2)) = addOrRemove.times(i);
        end
    end
end

% Sort atoms
[elemetList, ia] = sort(elemetList);

% Make formula
newFormula = [];
for j = 1:size(elemetList, 2)
    if numList(ia(j)) == 1
        newFormula = [newFormula elemetList{j}];
    else
        newFormula = [newFormula elemetList{j} num2str(numList(ia(j)))];
    end
end

end

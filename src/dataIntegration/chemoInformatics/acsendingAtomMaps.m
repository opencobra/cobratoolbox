function balanced = acsendingAtomMaps(rxnFile)
% Reassign the atom mapping numbers to be ascending in the RXN file V2000  
%
% USAGE:
%
%    balanced = acsendingAtomMaps(rxnFile)
%
% INPUT:
%    rxnFile:        Name and path of the RXN file to asign ascending atom
%                   mappings.
%
% OUTPUTS:
%    balanced:       Logical value indicating if the RXN file is balanced
%                   or not (true, or false).
%    A RXN file with ascending atom mappings.
%
% EXAMPLE:
%
%    rxnFile = ['rxnFileDir' filesep 'DOPACNNL.rxn'];
%    balanced = acsendingAtomMaps(rxnFile);
%
% .. Author: - German A. Preciat Gonzalez 25/05/2017

rxnFileData = regexp(fileread(rxnFile), '\n', 'split')'; % Reads the RXN file

% Set the reaction as balanced.
balanced = true;

% Extracts the # of molecules (substractes and products).
substrates = str2double(rxnFileData{5}(1:3));
products = str2double(rxnFileData{5}(4:6));

% Identify the indexes of the metabolites in the RXN file
begmol = strmatch('$MOL', rxnFileData); 

% For all the subtrates  in the reaction assign ascending atom mappings 
noOfAtoms = 0;
for i = 1 : substrates
    % number of atoms in the molecule
    for j = 1 : str2double(rxnFileData{begmol(i) + 4}(1:3))   
        noOfAtoms = noOfAtoms + 1;
        if str2double(rxnFileData{begmol(i) + j + 4}(61:63)) ~= 0
            oldMapNum(noOfAtoms) = str2double(rxnFileData{begmol(i) + j + 4}...
                (61:63));
            rxnFileData{begmol(i) + j + 4}(61:63) = '   ';
            rxnFileData{begmol(i) + j + 4}(61 + 3 - length(num2str(noOfAtoms)):...
                63) = num2str(noOfAtoms);
        end
    end
end

% For all the subtrates assign ascending atom mappings
for i = substrates + 1 : substrates + products
    for j = 1 : str2double(rxnFileData{begmol(i) + 4}(1:3))
        atomMapNum = str2double(rxnFileData{begmol(i) + j + 4}(61:63));
        if atomMapNum ~= 0
            atomMatrixIndex = find(oldMapNum == atomMapNum);
            if ~isempty(atomMatrixIndex)
                oldMapNum(atomMatrixIndex) = 0;
                rxnFileData{begmol(i) + j + 4}(61:63) = '   ';
                rxnFileData{begmol(i) + j + 4}(61+3 - length(num2str(...
                    atomMatrixIndex(1))):63) = num2str(atomMatrixIndex(1));
                atomMatrixIndex(1) = [];
            else
                balanced = false;
                noOfAtoms = noOfAtoms + 1;
                atomMatrixIndex = noOfAtoms;
                rxnFileData{begmol(i) + j + 4}(61:63) = '   ';
                rxnFileData{begmol(i) + j + 4}(61 + 3 -length(num2str...
                    (atomMatrixIndex(1))):63) = num2str(atomMatrixIndex(1));
            end
        end
    end
end
            
if sum(oldMapNum) ~=0; balanced = false; end

fid2 = fopen(rxnFile, 'w');
fprintf(fid2, '%s\n', rxnFileData{:});
fclose(fid2);
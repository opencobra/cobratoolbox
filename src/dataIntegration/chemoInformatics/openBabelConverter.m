function newFormat = openBabelConverter(origFormat, outputFormat, saveFileDir)
% This function converts chemoformatic formats using OpenBabel. It requires
% to have openbabel installed. The formats that can be converted are used
% MDL MOL, SMILES, InChI, InChIKey, MDL RXN, reaction SMILES and rInChI.
%
% USAGE:
%
%    newStructure = openBabelConverter(origFormat, outputFormat, saveFile)
%
% INPUT:
%    origFormat:    Original chemoinformatic format. Chemical tables such
%                   as MDL MOL or MDL RXN must be provided as files
%    outputFormat:  The format to be converted. Formats supported: smiles,
%                   mol, inchi, inchikey, rxn and rinchi.
%
% OPTIONAL INPUTS:
%    saveFileDir:	String with the directory where the new format will be
%                   saved. If is empty, the format is not saved.
%
% EXAMPLE:
%
%    Example 1 (MDL MOL to InChI):
%    origFormat = [pwd filesep 'alanine.mol'];
%    outputFormat = 'inchi';
%    newFormat = openBabelConverter(origFormat, outputFormat);
%    
%    Example 2 (InChI to SMILES):
%    origFormat = 'InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1';
%    outputFormat = 'smiles';
%    newFormat = openBabelConverter(origFormat, outputFormat);
%    
%    Example 3 (SMILES to mol):
%    origFormat = 'C[C@@H](C(=O)O)N';
%    outputFormat = 'mol';
%    newFormat = openBabelConverter(origFormat, outputFormat);

if nargin < 3 || isempty(saveFileDir)
    toSave = false;
else
    toSave = true;
end

% Identify the chemoinformatic format of the input
if isfile(origFormat)
    ctfFile = regexp(fileread(origFormat), '\n', 'split')';
    if contains(ctfFile{1}, '$RXN')
        inputType = 'rxn';
    else
        inputType = 'mol';
    end
elseif contains(origFormat, 'InChI=')
    inputType = 'inchi';
else
    inputType = 'smiles';
end

% Convert
if ismember(inputType, {'inchi'; 'smiles'})
    
    fid2 = fopen('tmp', 'w');
    fprintf(fid2, '%s\n', origFormat);
    fclose(fid2);
    [~, cmdout] = system(['obabel -i' inputType ' tmp -o' outputFormat]);
    delete('tmp')

else
    switch inputType
        case 'mol'
            [~, cmdout] = system(['obabel -imol ' origFormat ' -o' outputFormat]);
        case 'rxn'
            [~, cmdout] = system(['obabel -irxn ' origFormat ' -o' outputFormat]);
    end
end

% Prepare the output
cmdout = splitlines(cmdout);
switch outputFormat
    case 'mol'
        startIdx = find(cellfun(@isempty, cmdout));
        endIdx = find(ismember(cmdout, 'M  END'));
        newFormat = cmdout(startIdx(1):endIdx);
        
    case 'inchikey'
        cmdout = split(cmdout{end - 2});
        newFormat = cmdout{1};
        
    case 'inchi'
        newFormat = cmdout{contains(cmdout,'InChI=1S')};
        
    case 'smiles'
        cmdout = split(cmdout{end - 2});
        newFormat = cmdout{1};
        
    case 'rinchi'
        newFormat = cmdout{contains(cmdout,'RInChI=')};
end

% Save the file
if toSave
    fid2 = fopen(saveFileDir, 'w');
    fprintf(fid2, '%s\n', newFormat{:});
    fclose(fid2);
end

function [inchiStruct, molBool] = createInChIStruct(mets, sdfFileName, molFileDir)
% Converts metabolite structures in SDF to InChI strings with OpenBabel,
% and maps InChIs to mets.
%
% USAGE:
%
%    [inchiStruct, molBool] = createInChIStruct(mets, sdfFileName, molFileDir)
%
% INPUTS:
%    mets:           `m x 1` cell array of metabolite identifiers (e.g. BiGG abbreviations)
%    sdfFileName:    SDF file with structures of the metabolites in `mets`; the
%                    metabolite identifiers in the SDF are assumed to match `mets`.
%                    If empty, InChIs are built from individual mol files instead
%
% OPTIONAL INPUT:
%    molFileDir:     directory of individual mol files (named `<met>.mol`), used
%                    when `sdfFileName` is empty
%
% OUTPUTS:
%    inchiStruct:    structure with fields:
%
%                      * .standard - standard InChIs with no isotope, stereo or charge layers
%                      * .standardWithStereo - standard InChIs with stereo layers
%                      * .standardWithStereoAndCharge - standard InChIs with stereo and charge layers
%                      * .nonstandard - nonstandard InChIs with all layers
%    molBool:        `m x 1` logical, true where a structure was found for the metabolite
%
% .. Author: - Hulda SH, Nov. 2012

mets = reshape(mets,length(mets),1);
if ischar(mets)
    mets = strtrim(cellstr(mets));
end
if iscell(mets)
    mets = regexprep(mets,'(\[\w\])$',''); % Remove compartment assignment
end
if isnumeric(mets)
    mets = strtrim(cellstr(num2str(mets)));
end

%preallocate inchi sructure
inchiStruct.standard = cell(size(mets));
inchiStruct.standardWithStereo = cell(size(mets));
inchiStruct.standardWithStereoAndCharge = cell(size(mets));
inchiStruct.nonstandard = cell(size(mets));

%populate with empty string by default
for i=1:length(inchiStruct.standard)
    inchiStruct.standard{i,1} = '';
    inchiStruct.standardWithStereo{i,1} = '';
    inchiStruct.standardWithStereoAndCharge{i,1} = '';
    inchiStruct.nonstandard{i,1} = '';
end

molBool = false(length(mets),1);
if isempty(sdfFileName)
    % create inchi from individual mol files
    for i=1:length(mets)
        molFileName = [molFileDir filesep mets{i} '.mol'];
        if exist(molFileName,'file')
            molBool(i)=1;
            [inchi, annotation] = mol2inchi(molFileName, '-xtT/noiso/nochg/nostereo');
            if ~contains(annotation,mets{i})
                fprintf('%s\n',['createInChIStruct: no molecule identifier in ' mets{i}])
            end
            inchiStruct.standard{i,1} = inchi;
            inchiStruct.standardWithStereo{i,1} = mol2inchi(molFileName, '-xtT/noiso/nochg');
            inchiStruct.standardWithStereoAndCharge{i,1} = mol2inchi(molFileName, '-xtT/noiso');
            inchiStruct.nonstandard{i,1} = mol2inchi(molFileName, '-xtFT/noiso');
        end
    end
else
    %create inchi from sdf file
    [standard,metList1] = sdf2inchi(sdfFileName,'-xtT/noiso/nochg/nostereo'); % Convert SDF to InChIs
    
    [standardWithStereo,metList2] = sdf2inchi(sdfFileName,'-xtT/noiso/nochg');
    if ~all(strcmp(metList1,metList2))
        error('Error creating InChI structure.');
    end
    
    [standardWithStereoAndCharge,metList3] = sdf2inchi(sdfFileName,'-xtT/noiso');
    if ~all(strcmp(metList1,metList3))
        error('Error creating InChI structure.');
    end
    
    [nonstandard,metList4] = sdf2inchi(sdfFileName,'-xtFT/noiso');
    if ~all(strcmp(metList1,metList4))
        error('Error creating InChI structure.');
    end
    %  Map InChIs to mets
    for i = 1:length(metList1)
        inchiStruct.standard(ismember(mets,metList1{i})) = standard(i,1);
        inchiStruct.standardWithStereo(ismember(mets,metList1{i})) = standardWithStereo(i,1);
        inchiStruct.standardWithStereoAndCharge(ismember(mets,metList1{i})) = standardWithStereoAndCharge(i,1);
        inchiStruct.nonstandard(ismember(mets,metList1{i})) = nonstandard(i,1);
    end
    
    molBool = ismember(mets,metList1);
end

% for i=1:length(inchiStruct.standard)
%     inchiStruct.standard = erase(inchiStruct.standard{i,1},'''');
%     inchiStruct.standardWithStereo = erase(inchiStruct.standardWithStereo{i,1},'''');
%     inchiStruct.standardWithStereoAndCharge = erase(inchiStruct.standardWithStereoAndCharge{i,1},'''');
%     inchiStruct.nonstandard = erase(inchiStruct.nonstandard{i,1},'''');
% end






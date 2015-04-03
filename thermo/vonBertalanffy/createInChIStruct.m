function inchiStruct = createInChIStruct(mets,sdfFileName)
% Converts metabolite structures in SDF to InChI strings with OpenBabel,
% and maps InChIs to mets. 
% 
% inchi = createInChIStruct(mets,sdfFileName)
% 
% INPUTS
% mets          m x 1 cell array of metabolite identifiers (e.g., BiGG
%               abbreviations).
% sdfFileName   SDF with structures of metabolites in mets. Metabolite
%               identifiers in the SDF are assumed to be the same as in
%               mets.
% 
% OUTPUTS
% inchi                         Structure with following fields:
% .standard                     Standard InChIs with no isotope, stereo
%                               or charge layers. 
% .standardWithStereo           Standard InChIs with stereo layers.
% .standardWithStereoAndCharge  Standard InChIs with stereo and charge
%                               layers
% .nonstandard                  Nonstandard InChI with all layers.
% 
% Hulda SH, Nov. 2012

% Convert SDF to InChIs
[standard,metList1] = sdf2inchi(sdfFileName,'-xtT/noiso/nochg/nostereo');

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
inchiStruct.standard = cell(size(mets));
inchiStruct.standardWithStereo = cell(size(mets));
inchiStruct.standardWithStereoAndCharge = cell(size(mets));
inchiStruct.nonstandard = cell(size(mets));

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

for i = 1:length(metList1)
    inchiStruct.standard(ismember(mets,metList1{i})) = standard(i);
    inchiStruct.standardWithStereo(ismember(mets,metList1{i})) = standardWithStereo(i);
    inchiStruct.standardWithStereoAndCharge(ismember(mets,metList1{i})) = standardWithStereoAndCharge(i);
    inchiStruct.nonstandard(ismember(mets,metList1{i})) = nonstandard(i);
end


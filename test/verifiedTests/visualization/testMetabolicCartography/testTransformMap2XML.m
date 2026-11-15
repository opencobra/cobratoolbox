% The COBRAToolbox: testTransformMap2XML.m
%
% Purpose:
%     - transformMap2XML copies the information of a CellDesigner map structure (molecule
%       aliases, species, reactions with their base and secondary reactants and products,
%       modifiers, colours, widths, notes, compartments) back into the XML structure read by
%       transformXML2Map, drops from each reaction's species references the aliases no longer
%       in the map, and writes the XML file with struct2xml. The test writes a small
%       CellDesigner file (five species, six aliases, three reactions that use every
%       single/multiple element form), reads it with transformXML2Map, and checks that
%       (1) the unchanged map is written and read back identically, (2) edited values of
%       the map appear in the written file, (3) removed aliases are dropped from the species
%       references and a reduced list of secondary reactants or products is written, (4) the
%       single-compartment, no-compartment and home-folder ('~') forms work, and (5) the
%       inconsistent inputs the function rejects raise errors. Expected values follow from
%       the documentation (the map information is transferred to the file).
%
% Function under test:
%     src/visualization/metabolicCartography/transformMap2XML.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner file in a tempname folder.
%
% Coverage exemptions:
%     Lines 109, 127: skipped defective input (first defect below). Lines 212-215, 246-249:
%     unreachable (dead code) - they follow an unconditional error() call in the same block.
%     Lines 66-70: reached only on Unix-like systems (the section that names the file with
%     a leading '~' is skipped on Windows).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The check for a removed only reactant or product compares with the whole alias list
%       SEVERITY: limitation
%       TRIGGER: a reaction with one species reference of reactants (or products) whose alias
%         was removed from map.molAlias, or a map whose only molecule alias is that reference
%       OBSERVED: strcmp(alias, map.molAlias) returns one logical per map alias and 'if'
%         needs all of them true, so the error 'removing only substrate in reaction' (or
%         '... product ...') is never raised for a map of two or more aliases (the removed
%         reference is kept in the file) and is raised for a one-alias map in which nothing
%         was removed.
%       EXPECTED: the error only when the single reference's alias is not in map.molAlias
%       LINES: 108-109, 126-127
%     - DEFECT: Map information can be added or changed but not removed
%       SEVERITY: limitation
%       TRIGGER: a map in which a compartment alias of a molecule, species notes or reaction
%         notes are emptied, or rxnReversibility is set to 'true' for a reaction read as
%         reversible="false"
%       OBSERVED: these values are written only when non-empty (or 'false'), so the value of
%         xmlStruct stays in the file.
%       EXPECTED: the file reflects the map
%       LINES: 79-81, 99-101, 162-164, 281-283
%     - DEFECT: The error for a single secondary reactant or product link with several map aliases says 'should not be cell'
%       SEVERITY: cosmetic
%       TRIGGER: a map with two secondary reactants (or products) for a reaction whose XML has
%         one link (a struct, not a cell)
%       OBSERVED: error 'should not be cell' although the link is not a cell
%       EXPECTED: a message naming the inconsistent reactant (product) aliases
%       LINES: 211, 245
%     - DEFECT: Every '~' of the file name is replaced by the home folder
%       SEVERITY: limitation
%       TRIGGER: a file name starting with '~' that contains another '~', e.g. '~/maps/a~b.xml'
%       OBSERVED: strrep(fileName, '~', homePath) replaces each '~', not only the leading one
%       EXPECTED: only the leading '~' expanded
%       LINES: 69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformMap2XML'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder removed at the end
tempFolder = tempname;
mkdir(tempFolder);

% a CellDesigner map (SBML level 2): compartments c1 and c2 (aliases ca1, ca2); species
% s1 glc (with notes), s2 atp, s3 g6p, s4 adp, s5 hk; aliases sa1 (s1, in ca1), sa2 (s2, in
% ca1), sa3 (s3), sa4 (s4), sa5 (s5), sa6 (s1, second drawing). Reactions:
%   re1 HEX1, irreversible, notes: glc (sa1) + atp (sa2, link) -> g6p (sa3) + adp (sa4, link),
%       one modifier hk (sa5)
%   re2 PGI: g6p (sa3) + glc (sa6) + links atp (sa2), adp (sa4) -> glc (sa6) + adp (sa4) +
%       links atp (sa2), g6p (sa3); modifiers hk (sa5) and glc (sa6)
%   re3 R3: atp (sa2) -> adp (sa4), one species reference on each side, no link or modifier
aliasXml = @(id, species, extra) ['<celldesigner:speciesAlias id="' id '" species="' species '"' extra '>' ...
    '<celldesigner:bounds x="10.0" y="20.0" w="80.0" h="30.0"/><celldesigner:usualView>' ...
    '<celldesigner:paint color="ffccff66" scheme="Color"/></celldesigner:usualView></celldesigner:speciesAlias>'];
speciesXml = @(id, name, class, notes) ['<species metaid="' id '" id="' id '" name="' name '" compartment="c1">' ...
    notes '<annotation><celldesigner:extension><celldesigner:speciesIdentity><celldesigner:class>' class ...
    '</celldesigner:class><celldesigner:name>' name '</celldesigner:name></celldesigner:speciesIdentity>' ...
    '</celldesigner:extension></annotation></species>'];
referenceXml = @(tag, species, alias) ['<' tag ' species="' species '"><annotation><celldesigner:extension>' ...
    '<celldesigner:alias>' alias '</celldesigner:alias></celldesigner:extension></annotation></' tag '>'];
linkXml = @(tag, role, species, alias) ['<celldesigner:' tag ' ' role '="' species '" alias="' alias '">' ...
    '<celldesigner:line width="1.0" color="ff000000"/></celldesigner:' tag '>'];
modificationXml = @(type, species, alias) ['<celldesigner:modification type="' type '" modifiers="' species ...
    '" aliases="' alias '"><celldesigner:line width="1.0" color="ff000000"/></celldesigner:modification>'];
notesXml = @(text) ['<notes><html xmlns="http://www.w3.org/1999/xhtml"><body>' text '</body></html></notes>'];
lineXml = '<celldesigner:line width="1.0" color="ff000000"/>';
xmlLines = {
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<sbml xmlns="http://www.sbml.org/sbml/level2/version4" xmlns:celldesigner="http://www.sbml.org/2001/ns/celldesigner" level="2" version="4">'
    '<model metaid="toy" id="toy"><annotation><celldesigner:extension>'
    '<celldesigner:listOfCompartmentAliases>'
    '<celldesigner:compartmentAlias id="ca1" compartment="c1"/>'
    '<celldesigner:compartmentAlias id="ca2" compartment="c2"/>'
    '</celldesigner:listOfCompartmentAliases>'
    '<celldesigner:listOfSpeciesAliases>'
    aliasXml('sa1', 's1', ' compartmentAlias="ca1"')
    aliasXml('sa2', 's2', ' compartmentAlias="ca1"')
    aliasXml('sa3', 's3', '')
    aliasXml('sa4', 's4', '')
    aliasXml('sa5', 's5', '')
    aliasXml('sa6', 's1', '')
    '</celldesigner:listOfSpeciesAliases>'
    '</celldesigner:extension></annotation>'
    '<listOfSpecies>'
    speciesXml('s1', 'glc', 'SIMPLE_MOLECULE', notesXml('glucose'))
    speciesXml('s2', 'atp', 'SIMPLE_MOLECULE', '')
    speciesXml('s3', 'g6p', 'SIMPLE_MOLECULE', '')
    speciesXml('s4', 'adp', 'SIMPLE_MOLECULE', '')
    speciesXml('s5', 'hk', 'PROTEIN', '')
    '</listOfSpecies>'
    '<listOfReactions>'
    ['<reaction metaid="re1" id="re1" name="HEX1" reversible="false">' notesXml('hexokinase') ...
     '<annotation><celldesigner:extension><celldesigner:reactionType>STATE_TRANSITION</celldesigner:reactionType>' ...
     '<celldesigner:baseReactants><celldesigner:baseReactant species="s1" alias="sa1"/></celldesigner:baseReactants>' ...
     '<celldesigner:baseProducts><celldesigner:baseProduct species="s3" alias="sa3"/></celldesigner:baseProducts>' ...
     '<celldesigner:listOfReactantLinks>' linkXml('reactantLink', 'reactant', 's2', 'sa2') '</celldesigner:listOfReactantLinks>' ...
     '<celldesigner:listOfProductLinks>' linkXml('productLink', 'product', 's4', 'sa4') '</celldesigner:listOfProductLinks>' ...
     '<celldesigner:listOfModification>' modificationXml('CATALYSIS', 's5', 'sa5') '</celldesigner:listOfModification>' ...
     lineXml '</celldesigner:extension></annotation>' ...
     '<listOfReactants>' referenceXml('speciesReference', 's1', 'sa1') referenceXml('speciesReference', 's2', 'sa2') '</listOfReactants>' ...
     '<listOfProducts>' referenceXml('speciesReference', 's3', 'sa3') referenceXml('speciesReference', 's4', 'sa4') '</listOfProducts>' ...
     '<listOfModifiers>' referenceXml('modifierSpeciesReference', 's5', 'sa5') '</listOfModifiers></reaction>']
    ['<reaction metaid="re2" id="re2" name="PGI">' ...
     '<annotation><celldesigner:extension><celldesigner:reactionType>STATE_TRANSITION</celldesigner:reactionType>' ...
     '<celldesigner:baseReactants><celldesigner:baseReactant species="s3" alias="sa3"/><celldesigner:baseReactant species="s1" alias="sa6"/></celldesigner:baseReactants>' ...
     '<celldesigner:baseProducts><celldesigner:baseProduct species="s1" alias="sa6"/><celldesigner:baseProduct species="s4" alias="sa4"/></celldesigner:baseProducts>' ...
     '<celldesigner:listOfReactantLinks>' linkXml('reactantLink', 'reactant', 's2', 'sa2') linkXml('reactantLink', 'reactant', 's4', 'sa4') '</celldesigner:listOfReactantLinks>' ...
     '<celldesigner:listOfProductLinks>' linkXml('productLink', 'product', 's2', 'sa2') linkXml('productLink', 'product', 's3', 'sa3') '</celldesigner:listOfProductLinks>' ...
     '<celldesigner:listOfModification>' modificationXml('CATALYSIS', 's5', 'sa5') modificationXml('INHIBITION', 's1', 'sa6') '</celldesigner:listOfModification>' ...
     lineXml '</celldesigner:extension></annotation>' ...
     '<listOfReactants>' referenceXml('speciesReference', 's3', 'sa3') referenceXml('speciesReference', 's1', 'sa6') ...
     referenceXml('speciesReference', 's2', 'sa2') referenceXml('speciesReference', 's4', 'sa4') '</listOfReactants>' ...
     '<listOfProducts>' referenceXml('speciesReference', 's1', 'sa6') referenceXml('speciesReference', 's4', 'sa4') ...
     referenceXml('speciesReference', 's2', 'sa2') referenceXml('speciesReference', 's3', 'sa3') '</listOfProducts>' ...
     '<listOfModifiers>' referenceXml('modifierSpeciesReference', 's5', 'sa5') referenceXml('modifierSpeciesReference', 's1', 'sa6') '</listOfModifiers></reaction>']
    ['<reaction metaid="re3" id="re3" name="R3">' ...
     '<annotation><celldesigner:extension><celldesigner:reactionType>STATE_TRANSITION</celldesigner:reactionType>' ...
     '<celldesigner:baseReactants><celldesigner:baseReactant species="s2" alias="sa2"/></celldesigner:baseReactants>' ...
     '<celldesigner:baseProducts><celldesigner:baseProduct species="s4" alias="sa4"/></celldesigner:baseProducts>' ...
     lineXml '</celldesigner:extension></annotation>' ...
     '<listOfReactants>' referenceXml('speciesReference', 's2', 'sa2') '</listOfReactants>' ...
     '<listOfProducts>' referenceXml('speciesReference', 's4', 'sa4') '</listOfProducts></reaction>']
    '</listOfReactions></model></sbml>'};
inputFile = fullfile(tempFolder, 'toyMap.xml');
fileId = fopen(inputFile, 'w');
fprintf(fileId, '%s\n', xmlLines{:});
fclose(fileId);
[xmlStruct, map] = transformXML2Map(inputFile);

% short names for the parts of the XML structure checked below
reactionsOf = @(xml) xml.sbml.model.listOfReactions.reaction;
extensionOf = @(xml, r) xml.sbml.model.listOfReactions.reaction{r}.annotation.celldesigner_colon_extension;

%% the unchanged map is written and read back identically

outputFile = fullfile(tempFolder, 'roundTrip.xml');
transformMap2XML(xmlStruct, map, outputFile);
[xmlBack, mapBack] = transformXML2Map(outputFile);
% all fields are text or integer matrices, so the comparison is exact
assert(isequal(mapBack, map));
% the reaction names are also written as CellDesigner names of the reactions
assert(strcmp(extensionOf(xmlBack, 1).celldesigner_colon_name.Text, 'HEX1'));

%% edited map values are transferred to the file

editedMap = map;
editedMap.molColor{1} = 'ffff0000';            % colour of alias sa1
editedMap.molXPos{2} = '99.0';                 % position of alias sa2
editedMap.specName{2} = 'ATP';                 % species name (attribute and CellDesigner name)
editedMap.specNotes{3} = 'glucose 6-phosphate';% notes added to s3
editedMap.rxnColor{1} = 'ff00ff00';            % colour of re1 and of its links
editedMap.rxnWidth{1} = '5.0';
editedMap.rxnReversibility{2} = 'false';       % re2 becomes irreversible
editedMap.rxnType{3} = 'TRANSPORT';
editedMap.rxnID{3} = '';                       % no ID: written as 'No_ID'
editedMap.rxnName{3} = '';                     % no name: written as 'No_Name'
editedMap.rxnModType{2}{2} = 'CATALYSIS';
editedMap.rxnNotes{2} = 'isomerase';           % notes added to re2
editedMap.compartName{2} = 'c1';               % compartment of alias ca2
outputFile = fullfile(tempFolder, 'edited.xml');
transformMap2XML(xmlStruct, editedMap, outputFile);
[xmlBack, mapBack] = transformXML2Map(outputFile);
assert(strcmp(mapBack.molColor{1}, 'ffff0000'));
assert(strcmp(mapBack.molXPos{2}, '99.0'));
assert(strcmp(mapBack.specName{2}, 'ATP'));
assert(strcmp(xmlBack.sbml.model.listOfSpecies.species{2}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_name.Text, 'ATP'));
assert(strcmp(mapBack.specNotes{3}, 'glucose 6-phosphate'));
assert(strcmp(mapBack.rxnColor{1}, 'ff00ff00'));
assert(strcmp(mapBack.rxnWidth{1}, '5.0'));
% the secondary reactant and product links of re1 take the reaction colour and width
reactantLink = extensionOf(xmlBack, 1).celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink;
productLink = extensionOf(xmlBack, 1).celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink;
assert(strcmp(reactantLink.celldesigner_colon_line.Attributes.color, 'ff00ff00'));
assert(strcmp(productLink.celldesigner_colon_line.Attributes.width, '5.0'));
assert(strcmp(mapBack.rxnReversibility{2}, 'false'));
assert(strcmp(mapBack.rxnType{3}, 'TRANSPORT'));
assert(strcmp(mapBack.rxnID{3}, 'No_ID'));
assert(strcmp(mapBack.rxnName{3}, 'No_Name'));
assert(isequal(mapBack.rxnModType{2}, {'CATALYSIS'; 'CATALYSIS'}));
assert(strcmp(mapBack.rxnNotes{2}, 'isomerase'));
assert(isequal(mapBack.compartName, {'c1'; 'c1'}));
% the unedited parts are unchanged
assert(isequal(mapBack.rxnBaseReactantAlias, map.rxnBaseReactantAlias));
assert(isequal(mapBack.sID, map.sID));

%% removed aliases are dropped from species references; reduced link lists are written

% sa6 (second drawing of glc) is removed from the map and from the XML aliases, as
% removeMapMol does; re2 then keeps three of its four reactant and product references
reducedMap = map;
keepAlias = ~strcmp(map.molAlias, 'sa6');
for field = {'molAlias', 'molID', 'molCompartAlias', 'molXPos', 'molYPos', 'molWidth', 'molHeight', 'molColor'}
    reducedMap.(field{1}) = map.(field{1})(keepAlias);
end
reducedXml = xmlStruct;
aliasList = reducedXml.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
reducedXml.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias = aliasList(keepAlias);
% re2 keeps one secondary reactant (atp) and one secondary product (atp) of two each
reducedMap.rxnReactantAlias{2} = {'sa2'};
reducedMap.rxnReactantID{2} = {'s2'};
reducedMap.rxnProductAlias{2} = {'sa2'};
reducedMap.rxnProductID{2} = {'s2'};
outputFile = fullfile(tempFolder, 'reduced.xml');
transformMap2XML(reducedXml, reducedMap, outputFile);
xmlBack = xml2struct(outputFile);
reactions = reactionsOf(xmlBack);
reactantReferences = reactions{2}.listOfReactants.speciesReference;
referencedAliases = cellfun(@(ref) ref.annotation.celldesigner_colon_extension.celldesigner_colon_alias.Text, ...
    reactantReferences, 'UniformOutput', false);
assert(isequal(referencedAliases, {'sa3', 'sa2', 'sa4'}));
productReferences = reactions{2}.listOfProducts.speciesReference;
referencedAliases = cellfun(@(ref) ref.annotation.celldesigner_colon_extension.celldesigner_colon_alias.Text, ...
    productReferences, 'UniformOutput', false);
assert(isequal(referencedAliases, {'sa4', 'sa2', 'sa3'}));
% re1 and re3 do not use sa6 and keep all references
assert(numel(reactions{1}.listOfReactants.speciesReference) == 2);
assert(isstruct(reactions{3}.listOfProducts.speciesReference));
% the two-element link lists became single links
reactantLink = extensionOf(xmlBack, 2).celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink;
productLink = extensionOf(xmlBack, 2).celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink;
assert(isstruct(reactantLink) && numel(reactantLink) == 1);
assert(strcmp(reactantLink.Attributes.alias, 'sa2'));
assert(isstruct(productLink) && numel(productLink) == 1);
assert(strcmp(productLink.Attributes.product, 's2'));

%% one compartment, no compartment

% a single compartment alias is written into a single (non-cell) entry
oneCompartmentXml = xmlStruct;
compartmentList = oneCompartmentXml.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias;
oneCompartmentXml.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias = compartmentList{1};
oneCompartmentMap = map;
oneCompartmentMap.compartAlias = {'ca1'};
oneCompartmentMap.compartName = {'c2'};
outputFile = fullfile(tempFolder, 'oneCompartment.xml');
transformMap2XML(oneCompartmentXml, oneCompartmentMap, outputFile);
[~, mapBack] = transformXML2Map(outputFile);
assert(isequal(mapBack.compartAlias, {'ca1'}));
assert(isequal(mapBack.compartName, {'c2'}));
% an empty compartment list leaves the compartments of xmlStruct as they are
noCompartmentMap = map;
noCompartmentMap.compartAlias = '';
noCompartmentMap.compartName = '';
outputFile = fullfile(tempFolder, 'noCompartment.xml');
transformMap2XML(xmlStruct, noCompartmentMap, outputFile);
[~, mapBack] = transformXML2Map(outputFile);
assert(isequal(mapBack.compartAlias, map.compartAlias));

%% a file name starting with '~' is resolved from the home folder (Unix-like systems)

if isunix
    % the name climbs from the home folder to the file system root and descends into the
    % temporary folder, so nothing is written outside tempFolder
    savedDir = pwd;
    cd('~');
    homeFolder = pwd;
    cd(savedDir);
    levelsUp = numel(strfind(homeFolder, '/'));
    tildeName = ['~' repmat('/..', 1, levelsUp) tempFolder '/tildeName.xml'];
    transformMap2XML(xmlStruct, map, tildeName);
    assert(exist(fullfile(tempFolder, 'tildeName.xml'), 'file') == 2);
    [~, mapBack] = transformXML2Map(fullfile(tempFolder, 'tildeName.xml'));
    assert(isequal(mapBack, map));
    % the current folder is restored by the function
    assert(strcmp(pwd, savedDir));
end

%% inconsistent link lists are rejected

errorFile = fullfile(tempFolder, 'error.xml');
% re2: the XML has three reactant (product) links and the map one fewer, two
threeLinksXml = xmlStruct;
links = extensionOf(threeLinksXml, 2).celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink;
threeLinksXml.sbml.model.listOfReactions.reaction{2}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink = [links, links(1)];
assert(verifyCobraFunctionError('transformMap2XML', 'inputs', {threeLinksXml, map, errorFile}, ...
    'testMessage', 'inconsistent reactant aliases'));
threeLinksXml = xmlStruct;
links = extensionOf(threeLinksXml, 2).celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink;
threeLinksXml.sbml.model.listOfReactions.reaction{2}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink = [links, links(1)];
assert(verifyCobraFunctionError('transformMap2XML', 'inputs', {threeLinksXml, map, errorFile}, ...
    'testMessage', 'inconsistent product aliases'));
% re1: the XML has one reactant (product) link and the map two
twoLinksMap = map;
twoLinksMap.rxnReactantAlias{1} = {'sa2'; 'sa4'};
twoLinksMap.rxnReactantID{1} = {'s2'; 's4'};
assert(verifyCobraFunctionError('transformMap2XML', 'inputs', {xmlStruct, twoLinksMap, errorFile}));
twoLinksMap = map;
twoLinksMap.rxnProductAlias{1} = {'sa4'; 'sa2'};
twoLinksMap.rxnProductID{1} = {'s4'; 's2'};
assert(verifyCobraFunctionError('transformMap2XML', 'inputs', {xmlStruct, twoLinksMap, errorFile}));

% remove the temporary folder
rmdir(tempFolder, 's');

% change the directory
cd(currentDir)

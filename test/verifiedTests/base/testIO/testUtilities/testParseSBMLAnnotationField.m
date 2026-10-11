% The COBRAToolbox: testParseSBMLAnnotationField.m
%
% Purpose:
%     - parseSBMLAnnotationField reads the ChEBI, HMDB, KEGG, PubChem and InChI identifiers of a metabolite from an SBML annotation text, in the urn:miriam and the identifiers.org notations.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/parseSBMLAnnotationField.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     For the urn:miriam notation the ChEBI ID keeps a stray "3A" prefix (the text "obo.chebi:CHEBI%" is removed from "obo.chebi:CHEBI%3A15422", leaving "3A15422"). This is documented and the ChEBI value of that notation is NOT asserted.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseSBMLAnnotationField'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% urn:miriam notation: KEGG and PubChem identifiers

annotation = ['<rdf:li rdf:resource="urn:miriam:obo.chebi:CHEBI%3A15422"/>' ...
              '<rdf:li rdf:resource="urn:miriam:kegg.compound:C00002"/>' ...
              '<rdf:li rdf:resource="urn:miriam:pubchem.substance:3304"/>'];
[metChebi, metHmdb, metKegg, metPubChem, metInChI] = parseSBMLAnnotationField(annotation);
% (the ChEBI value is not asserted, see the header)
assert(ischar(metChebi) && ~isempty(metChebi));
assert(isequal(metHmdb, ''));
assert(strcmp(metKegg, 'C00002'));
assert(strcmp(metPubChem, '3304'));
assert(isequal(metInChI, ''));

%% an InChI element: the "InChI=" prefix is removed

annotation = ['<in:inchi xmlns:in="http://biomodels.net/inchi" metaid="m1">InChI=1S/H2O/h1H2</in:inchi>' ...
              '<rdf:li rdf:resource="urn:miriam:obo.chebi:CHEBI%3A15377"/>'];
[~, ~, ~, ~, metInChI] = parseSBMLAnnotationField(annotation);
assert(strcmp(metInChI, '1S/H2O/h1H2'));

%% an InChI element without "InChI" in it, and an unknown database: nothing is returned

annotation = ['<in:inchi xmlns:in="http://biomodels.net/inchi" metaid="m1">notinchi</in:inchi>' ...
              '<rdf:li rdf:resource="urn:miriam:other:xx"/>'];
[metChebi, metHmdb, metKegg, metPubChem, metInChI] = parseSBMLAnnotationField(annotation);
assert(isempty(metChebi) && isempty(metHmdb) && isempty(metKegg) && isempty(metPubChem) && isempty(metInChI));

%% identifiers.org notation (used when no urn:miriam keyword is present)

annotation = ['<rdf:li rdf:resource="http://identifiers.org/chebi/CHEBI:15377"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/hmdb/HMDB0002111"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/pubchem.compound/962"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/kegg.compound/C00001"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/inchi/InChI=1S/H2O"/>'];
[metChebi, metHmdb, metKegg, metPubChem, metInChI] = parseSBMLAnnotationField(annotation);
assert(strcmp(metChebi, '15377'));
assert(strcmp(metHmdb, 'HMDB0002111'));
assert(strcmp(metKegg, 'C00001'));
assert(strcmp(metPubChem, '962'));
assert(strcmp(metInChI, 'InChI=1S/H2O'));

% ChEBI without the "CHEBI:" prefix, and a PubChem substance identifier
annotation = ['<rdf:li rdf:resource="http://identifiers.org/chebi/15377"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/pubchem.substance/55"/>'];
[metChebi, ~, ~, metPubChem] = parseSBMLAnnotationField(annotation);
assert(strcmp(metChebi, '15377'));
assert(strcmp(metPubChem, '55'));

%% an empty annotation gives empty identifiers

[metChebi, metHmdb, metKegg, metPubChem, metInChI] = parseSBMLAnnotationField('');
assert(isempty(metChebi) && isempty(metHmdb) && isempty(metKegg) && isempty(metPubChem) && isempty(metInChI));

% change the directory
cd(currentDir)

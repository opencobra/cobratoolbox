% The COBRAToolbox: testCleanUpMetabolite_structure.m
%
% Purpose:
%     - cleanUpMetabolite_structure tidies the identifier fields of a metabolite structure: removes spaces and "CHEBI:" prefixes, corrects "InChi=" to "InChI=", converts text numbers to numbers and replaces a PubChem ID of 0 by NaN.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None for line coverage; see the console note below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. Console noise: the function prints the loop index ("i = ...") for every metabolite; this is not suppressed (Constitution VII-A).
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCleanUpMetabolite_structure'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two metabolites: m1 has text values to clean, m2 has NaN / numeric values and a PubChem ID of 0
metabolites.m1 = struct('keggId', 'C 00 1', 'cheBIId', 'CHEBI:123', 'drugbank', 'DB 1', ...
    'inchiString', 'InChi=1S/x', 'pubChemId', '55', 'charge', '-1', 'avgmolweight', '10.5', ...
    'monoisotopicweight', '10.1', 'chemspider', '77', 'metlin', '88');
metabolites.m2 = struct('keggId', NaN, 'cheBIId', '456', 'drugbank', NaN, ...
    'inchiString', 'InChI=1S/y', 'pubChemId', 0, 'charge', 2, 'avgmolweight', [], ...
    'monoisotopicweight', 5, 'chemspider', NaN, 'metlin', NaN);

%% all metabolites

cleaned = cleanUpMetabolite_structure(metabolites);

% m1: text identifiers are cleaned, text numbers become numbers
assert(strcmp(cleaned.m1.keggId, 'C001'));
assert(strcmp(cleaned.m1.cheBIId, '123'));
assert(strcmp(cleaned.m1.drugbank, 'DB1'));
assert(strcmp(cleaned.m1.inchiString, 'InChI=1S/x'));
assert(cleaned.m1.pubChemId == 55 && cleaned.m1.charge == -1);
assert(cleaned.m1.avgmolweight == 10.5 && cleaned.m1.monoisotopicweight == 10.1);
assert(cleaned.m1.chemspider == 77 && cleaned.m1.metlin == 88);

% m2: NaN and numeric values are left alone, a PubChem ID of 0 becomes NaN
assert(isnan(cleaned.m2.keggId) && isnan(cleaned.m2.drugbank));
assert(strcmp(cleaned.m2.cheBIId, '456'));
assert(strcmp(cleaned.m2.inchiString, 'InChI=1S/y'));
assert(isnan(cleaned.m2.pubChemId));
assert(cleaned.m2.charge == 2 && cleaned.m2.monoisotopicweight == 5);
assert(isempty(cleaned.m2.avgmolweight));

%% only a range of metabolites

% only metabolite 2 is processed; metabolite 1 keeps its uncleaned text
partlyCleaned = cleanUpMetabolite_structure(metabolites, 2, 2);
assert(strcmp(partlyCleaned.m1.keggId, 'C 00 1'));
assert(isnan(partlyCleaned.m2.pubChemId));

% change the directory
cd(currentDir)

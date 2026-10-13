% The COBRAToolbox: testParseCVTerms.m
%
% Purpose:
%     - parseCVTerms collects the databases, identifiers and relations (qualifiers) of the
%     controlled-vocabulary terms of an SBML element.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/SBML/parseCVTerms.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseCVTerms'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% two terms with three resources

cvTerms = struct('qualifier', {'bqbiol:is', 'bqbiol:isVersionOf'}, ...
                 'resources', {{'https://identifiers.org/chebi/CHEBI:1', 'http://identifiers.org/kegg.compound/C1'}, ...
                               {'urn:miriam:hmdb:HMDB1'}});
[databases, identifiers, relations] = parseCVTerms(cvTerms);
assert(isequal(databases, {'chebi'; 'kegg.compound'; 'hmdb'}));
assert(isequal(identifiers, {'CHEBI:1'; 'C1'; 'HMDB1'}));
% every resource carries the qualifier of its term
assert(isequal(relations, {'bqbiol:is'; 'bqbiol:is'; 'bqbiol:isVersionOf'}));

%% no terms: empty results

[databases, identifiers, relations] = parseCVTerms([]);
assert(isempty(databases) && isempty(identifiers) && isempty(relations));

% change the directory
cd(currentDir)

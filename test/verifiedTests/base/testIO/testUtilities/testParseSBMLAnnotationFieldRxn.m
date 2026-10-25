% The COBRAToolbox: testParseSBMLAnnotationFieldRxn.m
%
% Purpose:
%     - parseSBMLAnnotationFieldRxn reads the EC number and the PubMed references of a reaction from an SBML annotation text.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/parseSBMLAnnotationFieldRxn.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseSBMLAnnotationFieldRxn'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% EC number and several PubMed references (joined with commas and a PMID: prefix)

annotation = ['<rdf:li rdf:resource="http://identifiers.org/ec-code/1.1.1.1"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/pubmed/11"/>' ...
              '<rdf:li rdf:resource="http://identifiers.org/pubmed/22"/>'];
[rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn(annotation);
assert(strcmp(rxnEC, '1.1.1.1'));
assert(strcmp(rxnReference, 'PMID:11,PMID:22'));

%% a single PubMed reference has no separator

[~, rxnReference] = parseSBMLAnnotationFieldRxn('<rdf:li rdf:resource="http://identifiers.org/pubmed/33"/>');
assert(strcmp(rxnReference, 'PMID:33'));

%% an unrecognised database (name made of word characters): a warning is issued and nothing is returned

lastwarn('');
[rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn('<rdf:li rdf:resource="http://identifiers.org/rhea/12345"/>');
assert(contains(lastwarn, 'Unrecognized field rhea with value 12345 in reaction!'));
assert(isempty(rxnEC) && isempty(rxnReference));

%% an empty annotation gives empty outputs

[rxnEC, rxnReference] = parseSBMLAnnotationFieldRxn('');
assert(isempty(rxnEC) && isempty(rxnReference));

% change the directory
cd(currentDir)

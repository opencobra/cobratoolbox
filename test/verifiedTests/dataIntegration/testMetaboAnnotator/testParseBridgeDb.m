% The COBRAToolbox: testParseBridgeDb.m
%
% Purpose:
%     - parseBridgeDb queries the BridgeDb web service (curl -X POST
%       https://webservice.bridgedb.org/Human/xrefsBatch/<system code>) with each identifier of
%       each metabolite of a metabolite structure, parses the cross-references of the answer
%       ('<code>:<identifier>' items separated by commas), adds those the metabolite lacks
%       (IDsAdded) and lists those that differ from the existing ones (IdsMismatch). The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       a ChEBI cross-reference or a mismatch silently stops the processing of the answer, so no
%       assertion about the function is made. The defects were observed offline with a stand-in
%       curl script placed first on the PATH that prints a fixed BridgeDb answer; the same
%       stand-in would let a test run without the internet.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built metabolite structure and a
%     stand-in curl script (needs a Unix shell) instead of the web service.
%
% Coverage exemptions:
%     every line - parseBridgeDb is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A ChEBI cross-reference stops the processing of the answer
%       SEVERITY: wrong-result
%       TRIGGER: s.VMH_glc_D with keggId = 'C00031' and NaN hmdb, wikidata, cheBIId,
%         chemspider (plus the fields read by cleanUpMetabolite_structure), BridgeDb answer
%         "C00031<TAB>KEGG Compound<TAB>Ch:HMDB0000122,Wd:Q37525,Ce:CHEBI:4167,Cs:5589"
%         (stand-in curl); [o, IDsAdded] = parseBridgeDb(s)
%       OBSERVED: IDsAdded lists hmdb HMDB0000122 and wikidata Q37525 only; cheBIId and
%         chemspider stay NaN: cheBIId is listed twice in the mapping table, so the code 'Ce'
%         matches two rows, the dynamic field name of line 120 is a list and the error is
%         swallowed by the try without catch (line 92), which skips every later item of the
%         answer (R2025a, 2026-11-15)
%       EXPECTED: cheBIId = '4167' and chemspider = '5589' added
%       LINES: 58, 61, 92, 118-121
%     - DEFECT: A mismatch needs a field fullName and otherwise stops the processing of the answer
%       SEVERITY: wrong-result
%       TRIGGER: s.VMH_atp with keggId = 'C00002', hmdb = 'HMDB9999999' and no field fullName
%         (metaboliteStructureFieldNames has none), answer "C00002<TAB>KEGG
%         Compound<TAB>Ch:HMDB0000538,Wd:Q80863,Cs:5742"; [o, IDsAdded, IdsMismatch] = parseBridgeDb(s)
%       OBSERVED: IdsMismatch is empty and wikidata and chemspider of VMH_atp are not added: line
%         131 reads metabolite_structure.(met).fullName, the error is swallowed by the try
%         (line 92); with a field fullName = 'ATP' the mismatch is listed and Q80863 and 5742
%         are added (R2025a, 2026-11-15)
%       EXPECTED: the mismatch listed (with metNames) and the other cross-references added
%       LINES: 92, 131
%     - DEFECT: Numeric identifiers are never queried
%       SEVERITY: limitation
%       TRIGGER: a metabolite whose pubChemId, cheBIId or chemspider is numeric, as
%         cleanUpMetabolite_structure and sanityCheckMetIds make them
%       OBSERVED: regexprep(5793, ',', ';') at line 95 raises "The 'STRING' input must be either a
%         char row vector, a cell array of char row vectors, or a string array.", swallowed by
%         the try (line 92), so the identifier is skipped (R2025a, 2026-11-15)
%       EXPECTED: numeric identifiers converted to text and queried
%       LINES: 95
%     - DEFECT: The progress shown exceeds 100 percent when startSearch is above 1
%       SEVERITY: cosmetic
%       TRIGGER: parseBridgeDb(s, 2, 3) for a structure of three metabolites
%       OBSERVED: prints "100 percent ..." and "150 percent ..." (progress = i/(endSearch -
%         startSearch + 1)) (R2025a, 2026-11-15)
%       EXPECTED: 50 and 100 percent ((i - startSearch + 1)/(endSearch - startSearch + 1))
%       LINES: 87
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseBridgeDb'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

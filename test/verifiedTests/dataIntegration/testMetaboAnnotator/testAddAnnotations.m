% The COBRAToolbox: testAddAnnotations.m
%
% Purpose:
%     - addAnnotations fills missing (empty or NaN) fields of the metabolites of a metabolite
%       structure from a table read with xlsread: column 1 holds the VMH abbreviation ('-', '('
%       and ')' replaced as in the field names VMH_<abbr>), the header row names the fields
%       (lmId and cheBlId renamed to lipidmaps and cheBIId), and 'NULL', 'null', '\N', empty
%       and '0' (except for charge) are not copied; each copied value gets a source
%       'annotationSource:annotationType:<date>'. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): its documented option
%       annotationVerification has no effect, so no assertion about the function is made.
%       Without that option, a table {'VMH', 'keggId', 'hmdb', 'charge', 'lmId', 'cheBlId',
%       'pubChemId'; 'glc-D', 'C00031', NaN, '0', 'LM1', 'CHEBI:1', '0'} fills keggId, charge
%       ('0'), lipidmaps of VMH_glc_minus_D, keeps its existing cheBIId and does not copy
%       pubChemId '0' (R2025a, 2026-11-15).
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/addAnnotations.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built metabolite structure and
%     table.
%
% Coverage exemptions:
%     every line - addAnnotations is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option annotationVerification has no effect
%       SEVERITY: unusable-option
%       TRIGGER: ms.VMH_glc_minus_D = struct('keggId', NaN, 'hmdb', '', 'charge', NaN,
%         'lipidmaps', NaN, 'cheBIId', 'old', 'pubChemId', NaN); RAW = {'VMH', 'keggId', 'hmdb',
%         'charge', 'lmId', 'cheBlId', 'pubChemId'; 'glc-D', 'C00031', NaN, '0', 'LM1',
%         'CHEBI:1', '0'}; o = addAnnotations(ms, RAW, 'src', 'manual', 'verified by curator')
%       OBSERVED: o.VMH_glc_minus_D.keggId_source = 'src:manual:15-Nov-2026 19:29:05'; the
%         verification given as fifth argument appears nowhere: it is set to a default (lines
%         42-44) and never read (R2025a, 2026-11-15)
%       EXPECTED: the verification recorded with each annotation, as acceptIDsSuggested records
%         'source:type:verification:date'
%       LINES: 42-44, 62
%     - DEFECT: An empty field receives NaN with a source when the table cell is NaN
%       SEVERITY: cosmetic
%       TRIGGER: the call above (field hmdb = '' and table cell hmdb = NaN)
%       OBSERVED: o.VMH_glc_minus_D.hmdb = NaN and hmdb_source = 'src:manual:<date>': the test
%         isempty(field) || hasNaN(field) && ~isnan(cell) applies the NaN check of the table cell
%         only to NaN fields (&& binds tighter than ||), and NaN passes the text checks of line
%         60 (R2025a, 2026-11-15)
%       EXPECTED: missing table values not copied and no source written for them
%       LINES: 59-62
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddAnnotations'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

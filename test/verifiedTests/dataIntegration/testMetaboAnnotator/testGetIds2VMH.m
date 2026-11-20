% The COBRAToolbox: testGetIds2VMH.m
%
% Purpose:
%     - getIds2VMH looks up each SEED, KEGG, BioCyc and BiGG identifier of a metabolite in the
%       Compounds sheet of pnas.1401329111.sd01.xlsx (PMID 24927599; columns 3, 5, 6 and 18)
%       and copies the other identifiers of the first matching row into the empty fields,
%       checking BiGG ids against the BiGG web site. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a lookup by KEGG, BioCyc
%       or BiGG id never matches when that column has a blank cell, which every one of these
%       columns of the shipped table has, so no assertion about the function is made.
%     - A test would write the Compounds sheet by hand (writecell, then add docProps/app.xml and
%       list the Id attribute first in xl/_rels/workbook.xml.rels, which xlsread needs to find a
%       sheet by name on Linux) and replace urlread by a stand-in, so that neither the tutorials
%       submodule nor the internet is needed.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/getIds2VMH.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built metabolite structure and spreadsheet would
%     suffice.
%
% Coverage exemptions:
%     every line - getIds2VMH is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A KEGG, BioCyc or BiGG id is never found when its column has a blank cell
%       SEVERITY: wrong-result
%       TRIGGER: with the shipped pnas.1401329111.sd01.xlsx on the path,
%         getIds2VMH(struct('byKegg', struct('seed', NaN, 'keggId', 'C00080', 'biocyc', NaN,
%         'biggId', 'h'))) (biggId set so that no web request is made)
%       OBSERVED: IDsAdded is empty and seed and biocyc stay NaN (R2025a, 2026-11-15). xlsread
%         returns NaN for the 10211 blank KEGG, 13988 blank BioCyc and 25171 blank BiGG cells,
%         and strmatch('C00080', RAW(:, 5), 'exact') then returns [] although row 2 holds
%         C00080; only the SEED column (no blank) is searched successfully. The same input
%         with seed 'cpd00067' instead adds keggId C00080 and biocyc PROTON.
%       EXPECTED: seed 'cpd00067' and biocyc 'PROTON' added from row 2 of the Compounds sheet
%       LINES: 50
%     - DEFECT: The metabolite counter is printed for every identifier looked up
%       SEVERITY: cosmetic
%       TRIGGER: any metabolite with an identifier, e.g. the call above
%       OBSERVED: i = 1 is printed once per non-empty identifier (line 48 has no semicolon;
%         R2025a, 2026-11-15)
%       EXPECTED: no console output
%       LINES: 48
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetIds2VMH'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

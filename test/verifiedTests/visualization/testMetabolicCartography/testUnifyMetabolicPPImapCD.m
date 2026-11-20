% The COBRAToolbox: testUnifyMetabolicPPImapCD.m
%
% Purpose:
%     - unifyMetabolicPPImapCD sets every reaction of a CellDesigner metabolic/PPI map to
%       grey ('FFDCDCDC') of width 1, every molecule and complex to white ('FFFFFFFF'),
%       and every non-empty secondary product/reactant link colour to grey with width 1.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the secondary links of the wrong reactions are recoloured (defect
%       below); no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/unifyMetabolicPPImapCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - unifyMetabolicPPImapCD is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Secondary links are recoloured by position, not by the index of the
%       non-empty entries
%       SEVERITY: wrong-result
%       TRIGGER: a map whose reactions with secondary links are not the first ones, as
%         transformFullXML2Map produces ('' for reactions without links), e.g.
%         map.rxnName = {'r1'; 'r2'; 'r3'}; map.rxnColor = {'FF000000'; 'FF000000';
%         'FF000000'}; map.rxnWidth = {5; 5; 5}; map.molColor = {'FF00FF00'};
%         map.complexColor = {'FF0000FF'}; map.rxnProductLineColor = {''; {'FFFF0000'}; ''};
%         map.rxnProductLineWidth = {''; {5}; ''}; map.rxnReactantLineColor = {''; '';
%         {'FFFF0000'; 'FFFF0000'}}; map.rxnReactantLineWidth = {''; ''; {5; 5}};
%         map2 = unifyMetabolicPPImapCD(map)
%       OBSERVED: MATLAB R2025a: map2.rxnReactantLineColor{3} is still {'FFFF0000';
%         'FFFF0000'} and map2.rxnProductLineColor{2} is still {'FFFF0000'}: the loops run
%         t (r) = 1:length(index) and read entry t (r) instead of index(t) (index(r)), so
%         they visit the empty first entries and never the non-empty ones
%       EXPECTED: every non-empty secondary link colour 'FFDCDCDC' with width 1 (OUTPUT)
%       LINES: 51-60, 67-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUnifyMetabolicPPImapCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

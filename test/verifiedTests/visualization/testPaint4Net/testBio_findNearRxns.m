% The COBRAToolbox: testBio_findNearRxns.m
%
% Purpose:
%     - bio_findNearRxns returns the reactions given in Rxns followed by their
%       neighbouring reactions (Paint4Net): the metabolites of the given reactions selected by
%       direction ('struc': all; 'sub'/'prod'/'both': substrates/products/both according to
%       the sign of S and of flux),
%       then the reactions of those metabolites that match the same direction.
%       The file declares the function name findNearRxns, so MATLAB runs it only as
%       bio_findNearRxns; bio_draw_by_met calls findNearRxns, which resolves to
%       src/visualization/paint4Net/Draw_by_met/findNearRxns.m (same code). The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the documented defaults of direction and flux are not implemented, and a call that
%       selects no metabolite or passes a row cell Rxns fails; no assertion about the function
%       is made.
%
% Function under test:
%     src/visualization/paint4net/bio_paint4Net/bio_draw_by_met/bio_findNearRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model (createModel) and flux vectors; no solver is used.
%
% Coverage exemptions:
%     every line - bio_findNearRxns is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented defaults of direction and flux are not implemented
%       SEVERITY: error
%       TRIGGER: fm = createModel({'R1', 'R2', 'R3'}, {'a', 'b', 'c'}, ...
%         {'a -> b', 'b -> c', 'c -> '});
%         r = bio_findNearRxns(fm, {'R2'}); r = bio_findNearRxns(fm, {'R2'}, 'prod')
%       OBSERVED: (R2025a, 2026-11-23) "Not enough input arguments." (MATLAB:minrhs) at line
%         69 for the two-input call (direction undefined) and at line 102 for the
%         three-input call (flux undefined); only direction 'struc' runs without flux
%       EXPECTED: direction = 'struc' and flux = a vector of zeros when omitted (help text,
%         OPTIONAL INPUTS)
%       LINES: 69, 74, 102, 130
%     - DEFECT: A call that selects no metabolite fails
%       SEVERITY: error
%       TRIGGER: r = bio_findNearRxns(fm, {'R2'}, 'sub', zeros(3, 1)) (fm as above)
%       OBSERVED: (R2025a, 2026-11-23) "Array indices must be positive integers or logical
%         values." (MATLAB:badsubscript) at line 190: no metabolite passes the flux test, so
%         metIndexes keeps its placeholder -1 (line 61) and model.mets{-1} is read; the
%         same call with flux = [1; 1; 1] returns {'R2', 'R1'}
%       EXPECTED: Rxns returned with no neighbouring reaction added (zero flux is the
%         documented default and the help text treats it as no flux)
%       LINES: 61, 189-190
%     - DEFECT: A row cell Rxns with more than one reaction fails
%       SEVERITY: error
%       TRIGGER: r = bio_findNearRxns(fm, {'R2', 'R3'}, 'struc', [1; 1; 1]) (fm as above)
%       OBSERVED: (R2025a, 2026-11-23) "Index in position 1 exceeds array bounds. Index must
%         not exceed 1." (MATLAB:badsubscript) at line 270: Rxns{w, 1} indexes rows of a
%         1 x 2 cell; the column cell {'R2'; 'R3'} returns {'R2'; 'R3'; 'R1'}
%       EXPECTED: the same result as for the column cell (the help text documents a cell array
%         or cell vector of reaction abbreviations, with no orientation)
%       LINES: 266-270, 278
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBio_findNearRxns'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)

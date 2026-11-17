% The COBRAToolbox: testGetSubsystemPresence.m
%
% Purpose:
%     - getSubsystemPresence(propertiesFolder, reconVersion) reads the reactions of a
%       reconstruction resource (Reactions_<reconVersion>.txt, column 11 the subsystem) and
%       the reaction presence of every reconstruction
%       (ReactionMetabolitePresence/reactionPresence_<reconVersion>.txt) and writes
%       ReactionMetabolitePresence/SubsystemPresence_<reconVersion>.txt: per reconstruction,
%       the fraction of the reactions of each subsystem that it contains.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the documented default of
%       propertiesFolder is not implemented, so the documented way to request it fails; this
%       file makes no assertion about the function. The wave version of this test (git
%       history) wrote both files by hand in a temporary folder and checked the hand-counted
%       fractions, the sorted subsystem header, the dropped empty subsystem and a subsystem
%       absent from the presence file; it is the starting point once the defect is fixed.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/getSubsystemPresence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a temporary folder.
%
% Coverage exemptions:
%     every line - getSubsystemPresence is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line except line 43 (branch for MATLAB
%     releases before R2020a).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default of propertiesFolder is not implemented
%       SEVERITY: unusable-option
%       TRIGGER: getSubsystemPresence([], 'v') or getSubsystemPresence('', 'v') run in a
%         folder that holds Reactions_v.txt and ReactionMetabolitePresence/
%         reactionPresence_v.txt; propertiesFolder is the first argument and reconVersion is
%         required, so an empty value is the only way to ask for the default
%       OBSERVED: (R2025a, 2026-11-17, Linux) "Unable to find or open '/Reactions_v.txt'.
%         Check the path and filename or file permissions." (readtable, called through
%         readInputTableForPipeline from line 20): [[] filesep 'Reactions_v.txt'] is a path
%         in the root of the file system; there is no nargin or isempty handling. The same
%         call with propertiesFolder '.' writes the output
%       EXPECTED: the files read from and written to the current folder, as the header
%         documents ("propertiesFolder: Folder where the retrieved subsystem presences will
%         be stored (default: current folder)", lines 13-14)
%       LINES: 20, 23
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetSubsystemPresence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

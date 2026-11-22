% The COBRAToolbox: testWriteRxnfile.m
%
% Purpose:
%     - writeRxnfile writes an MDL rxnfile for one reaction: the header ($RXN, reaction name,
%       empty line, reaction equation), the counts of reactant and product molecules (a
%       coefficient n gives n copies), then one $MOL block per molecule copy, reactants first,
%       each the metabolite's molfile with its first line replaced by the metabolite id. The
%       test writes small hand-made molfiles in a temporary folder and checks the whole rxnfile
%       text, built by hand from the format, for: all six arguments (with .mol/.rxn suffixes,
%       directories without a trailing separator and with a backslash separator), a sparse row
%       vector of coefficients with a zero entry (that metabolite is ignored, its molfile need
%       not exist), and the defaults (molfile names = metabolite ids, current directory, name
%       rxn.rxn).
%
% Function under test:
%     src/dataIntegration/chemoInformatics/RXN/writeRxnfile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written molfiles in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The reaction equation drops every "1 " it contains, not only unit coefficients
%       SEVERITY: cosmetic
%       TRIGGER: writeRxnfile([-11; 1], {'met1'; 'met2'}, {'met1'; 'met2'}, d, 'r2', d)
%       OBSERVED: equation line "1met1 -> met2" (R2025a, 2026-11-15); a coefficient 11 or 21,
%         or a metabolite id ending in 1 followed by " + ", loses the "1 "
%       EXPECTED: "11 met1 -> met2"; only the equation (comment) line is affected, the counts
%         line and the $MOL blocks are right
%       LINES: 76, 80
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteRxnfile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% one-atom molfiles that differ by their element, so that each $MOL block can be traced back;
% each ends with blank lines that deblank removes
workDir = tempname;
mkdir(workDir);
molBody = @(element) sprintf(['  -header-\n\n  1  0  0  0  0  0  0  0  0  0999 V2000\n' ...
    '    0.0000    0.0000    0.0000 %-3s 0  0  0  0  0  0  0  0  0  0  0  0\nM  END'], element);
elements = struct('glc', 'C', 'o2', 'O', 'co2', 'N', 'h2o', 'S');
metIds = fieldnames(elements);
for k = 1:numel(metIds)
    fileId = fopen([workDir filesep 'file_' metIds{k} '.mol'], 'w');
    fprintf(fileId, 'oldTitle\n%s\n\n', molBody(elements.(metIds{k})));
    fclose(fileId);
    % the same molfile under the metabolite id, for the default molfile names
    copyfile([workDir filesep 'file_' metIds{k} '.mol'], [workDir filesep metIds{k} '.mol']);
end
% $MOL block of one copy of metabolite metId: the first line becomes the metabolite id
molBlock = @(metId) sprintf('$MOL\n%s\n%s\n', metId, molBody(elements.(metId)));

%% all arguments: suffixes are stripped, separators added, backslashes turned into slashes

% glc + 2 o2 -> co2 + 2 h2o (the unit coefficients are not printed in the equation line)
stoichiometry = [-1; -2; 1; 2];
mets = {'glc'; 'o2'; 'co2'; 'h2o'};
molfileNames = {'file_glc.mol'; 'file_o2.mol'; 'file_co2'; 'file_h2o'};
outDir = [workDir filesep 'out'];
mkdir(outDir);
writeRxnfile(stoichiometry, mets, molfileNames, workDir, 'combustion.rxn', [outDir '\']);
expectedText = [sprintf('$RXN\ncombustion\n\nglc + 2 o2 -> co2 + 2 h2o\n  3  3\n') ...
    molBlock('glc') molBlock('o2') molBlock('o2') molBlock('co2') molBlock('h2o') molBlock('h2o')];
% the file is text built from the inputs: exact comparison
assert(strcmp(fileread([outDir filesep 'combustion.rxn']), expectedText));

%% a sparse row of coefficients with a zero entry; the zero metabolite is ignored

% 'missing' has coefficient 0 and no molfile; it must not appear in the rxnfile
writeRxnfile(sparse([0, -1, 1]), {'missing'; 'o2'; 'co2'}, {'none'; 'file_o2'; 'file_co2'}, ...
    [workDir filesep], 'transfer', outDir);
expectedText = [sprintf('$RXN\ntransfer\n\no2 -> co2\n  1  1\n') molBlock('o2') molBlock('co2')];
assert(strcmp(fileread([outDir filesep 'transfer.rxn']), expectedText));

%% defaults: molfiles named after the metabolites in the current directory, output rxn.rxn

cd(workDir);
writeRxnfile([-1; 1], {'glc'; 'co2'});
expectedText = [sprintf('$RXN\nrxn\n\nglc -> co2\n  1  1\n') molBlock('glc') molBlock('co2')];
assert(strcmp(fileread([workDir filesep 'rxn.rxn']), expectedText));
% five arguments: the rxnfile is written to the current directory under the given name
writeRxnfile([-2; 1], {'h2o'; 'o2'}, {'h2o'; 'o2'}, workDir, 'split');
expectedText = [sprintf('$RXN\nsplit\n\n2 h2o -> o2\n  2  1\n') molBlock('h2o') molBlock('h2o') molBlock('o2')];
assert(strcmp(fileread([workDir filesep 'split.rxn']), expectedText));
cd(fileDir);

% remove the temporary folder
rmdir(workDir, 's');

% change the directory
cd(currentDir)

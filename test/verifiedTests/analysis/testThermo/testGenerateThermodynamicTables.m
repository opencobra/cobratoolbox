% The COBRAToolbox: testGenerateThermodynamicTables.m
%
% Purpose:
%     - generateThermodynamicTables writes three tab-delimited tables (CRLF line ends) from
%       the thermodynamic fields of a model: <base>thermo_parameters.csv (compartment
%       identifiers, temperature, pH, ionic strength and electrical potential per
%       compartment), <base>thermo_reactions.csv (DrG0, its uncertainty, DrGt0, DrGtMin,
%       DrGtMax per reaction) and <base>thermo_metabolites.csv (DfG0, its uncertainty, DfGt0,
%       DfGtMin, DfGtMax, concMin, concMax per metabolite), numbers with two decimals and
%       concentrations in exponent notation. The test compares each file with the text built
%       by hand from the inputs (rounding shown by 1.234 -> 1.23 and 7.2 -> 7.20), with an
%       explicit base name and with the default base name 'out' in the current folder.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/generateThermodynamicTables.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a three-reaction createModel model with hand-set thermodynamic fields; files
%     in a temporary folder; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateThermodynamicTables'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);

% three reactions over the metabolites A[c], B[c], C[c] and two compartments given as a
% char column (converted with cellstr)
model = createModel({'R1'; 'R2'; 'R3'}, {'one'; 'two'; 'three'}, ...
    {'A[c] -> B[c]'; 'B[c] -> C[c]'; 'C[c] -> A[c]'}, [], zeros(3, 1), 10 * ones(3, 1));
model.compartments = ['c'; 'e'];
model.ph = [7.2 7.0];
model.is = [0.25 0.15];
model.chi = [0 30];
model.T = 298.15;
model.DrG0 = [1.234; -2; 3];
model.DrG0_Uncertainty = [0.5; 0.25; 1];
model.DrGt0 = [1; 2; 3];
model.DrGtMin = [-3; -9; -10];
model.DrGtMax = [3; 1; 5];
model.DfG0 = [-1; -2; -3];
model.DfG0_Uncertainty = [1; 2; 3];
model.DfGt0 = [-1.5; -2.5; -3.5];
model.DfGtMin = [-4; -5; -6];
model.DfGtMax = [4; 5; 6];
model.concMin = 1e-5 * ones(3, 1);
model.concMax = 1e-2 * ones(3, 1);

% the expected tables, written out from the inputs above (two decimals, CRLF line ends)
crlf = sprintf('\r\n');
expectedParameters = [sprintf('Compartment\tc\te'), crlf, ...
    sprintf('Temperature (K)\t298.15\t298.15'), crlf, ...
    sprintf('pH\t7.20\t7.00'), crlf, ...
    sprintf('Ionic strength (M)\t0.25\t0.15'), crlf, ...
    sprintf('Electrical potential relative to cytosol (mV)\t0.00\t30.00'), crlf];
expectedReactions = [sprintf(['Reaction ID\tStandard reaction Gibbs energy (kJ/mol)\t' ...
    'Uncertainty corresponding to 95%% confidence interval (kJ/mol)\t' ...
    'Standard transformed reaction Gibbs energy (kJ/mol)\t' ...
    'Minimum transformed reaction Gibbs energy (kJ/mol)\t' ...
    'Maximum transformed reaction Gibbs energy (kJ/mol)']), crlf, ...
    sprintf('R1\t1.23\t0.50\t1.00\t-3.00\t3.00'), crlf, ...
    sprintf('R2\t-2.00\t0.25\t2.00\t-9.00\t1.00'), crlf, ...
    sprintf('R3\t3.00\t1.00\t3.00\t-10.00\t5.00'), crlf];
expectedMetabolites = [sprintf(['Metabolite ID\tStandard Gibbs energy of formation (kJ/mol)\t' ...
    'Uncertainty corresponding to 95%% confidence interval (kJ/mol)\t' ...
    'Standard transformed Gibbs energy of formation (kJ/mol)\t' ...
    'Minimum transformed Gibbs energy of formation (kJ/mol)\t' ...
    'Maximum transformed Gibbs energy of formation (kJ/mol)\t' ...
    'Minimum concentration (M)\tMaximum concentration (M)']), crlf, ...
    sprintf('A[c]\t-1.00\t1.00\t-1.50\t-4.00\t4.00\t1.00e-05\t1.00e-02'), crlf, ...
    sprintf('B[c]\t-2.00\t2.00\t-2.50\t-5.00\t5.00\t1.00e-05\t1.00e-02'), crlf, ...
    sprintf('C[c]\t-3.00\t3.00\t-3.50\t-6.00\t6.00\t1.00e-05\t1.00e-02'), crlf];

%% explicit base name: three files, each with the expected text

baseName = fullfile(tmpDir, 'results_');
generateThermodynamicTables(model, baseName);
% the text is exact: the numbers are written with a fixed format
assert(strcmp(fileread([baseName 'thermo_parameters.csv']), expectedParameters));
assert(strcmp(fileread([baseName 'thermo_reactions.csv']), expectedReactions));
assert(strcmp(fileread([baseName 'thermo_metabolites.csv']), expectedMetabolites));
assert(numel(dir(fullfile(tmpDir, '*.csv'))) == 3);

%% default base name 'out': the files are written in the current folder

cd(tmpDir);
generateThermodynamicTables(model);
assert(strcmp(fileread('outthermo_parameters.csv'), expectedParameters));
assert(strcmp(fileread('outthermo_reactions.csv'), expectedReactions));
assert(strcmp(fileread('outthermo_metabolites.csv'), expectedMetabolites));
assert(numel(dir(fullfile(tmpDir, '*.csv'))) == 6);
cd(fileDir);

% remove the temporary folder and restore the directory
rmdir(tmpDir, 's');
cd(currentDir)

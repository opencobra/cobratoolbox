% The COBRAToolbox: testOpenBabelConverter.m
%
% Purpose:
%     - openBabelConverter converts a molecule or reaction between SMILES, InChI, MDL MOL/RXN,
%       InChIKey and RInChI by calling the Open Babel program obabel, and optionally saves the
%       result.
%     - Once the defects below are fixed, the test should stand in for Open Babel with an
%       executable named obabel written by the test into a tempname folder put first on PATH
%       (it prints the usage text with status 1 without arguments and canned output for each
%       -o format), work in a tempname folder, and check: the installation message when obabel
%       cannot be found (PATH = an empty folder, status 127), the input detection (MOL file,
%       RXN file, missing file errors, InChI, SMILES), the parsing of each output format
%       (smiles, mol, inchi with its error case, inchikey, rxn, rinchi) and saving to the
%       documented folder for every format. Line 50 (isunix || ispc is always true) stays exempt.
%       Quarantined: no behaviour of openBabelConverter is asserted until the error and
%       unusable-option defects below are fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/openBabelConverter.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; Open Babel is replaced by a test double (needs a Unix shell).
%
% Coverage exemptions:
%     every line - openBabelConverter is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Saving fails for every output format except mol
%       SEVERITY: error
%       TRIGGER: openBabelConverter('InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1',
%         'smiles', outFile) with a non-empty third argument and outputFormat 'smiles', 'inchi',
%         'inchikey' or 'rinchi' (reproduced with a stand-in obabel first on PATH)
%       OBSERVED: (R2025a, 2026-11-17) MATLAB:cellRefFromNonCell "Brace indexing is not supported
%         for variables of this type." for all four formats (the same calls without the third
%         argument return the converted text): newFormat is a char for these formats and line
%         124 writes newFormat{:}
%       EXPECTED: the converted text is returned and written to the save location
%       LINES: 103-118, 124
%     - DEFECT: saveFileDir is documented as a directory but opened as a file
%       SEVERITY: error
%       TRIGGER: openBabelConverter('C[C@@H](C(=O)O)N', 'mol', existingFolder) with a stand-in
%         obabel first on PATH
%       OBSERVED: (R2025a, 2026-11-17) MATLAB:FileIO:InvalidFid "Invalid file identifier. Use
%         fopen to generate a valid file identifier.": fopen of the folder name returns -1
%       EXPECTED: the structure is saved in the given directory, as the help text says
%         ("saveFileDir: String with the directory where the new format will be saved")
%       LINES: 123-125
%     - DEFECT: The documented output format rxn returns nothing
%       SEVERITY: unusable-option
%       TRIGGER: openBabelConverter('C[C@@H](C(=O)O)N', 'rxn') with a stand-in obabel first on
%         PATH that prints an RXN block
%       OBSERVED: (R2025a, 2026-11-17) returns [] without error or message: the output switch has
%         no case 'rxn'
%       EXPECTED: the MDL RXN text produced by Open Babel ("Formats supported: smiles, mol,
%         inchi, inchikey, rxn and rinchi")
%       LINES: 96-119
%     - DEFECT: A scratch file named tmp is written into the current folder and left there
%       SEVERITY: limitation
%       TRIGGER: any SMILES or InChI input, e.g. openBabelConverter('C[C@@H](C(=O)O)N', 'inchi')
%       OBSERVED: (R2025a, 2026-11-17) after the calls the current folder holds a file 'tmp' with
%         the input string; an existing file of that name is overwritten
%       EXPECTED: a tempname file that is deleted after the conversion
%       LINES: 79-82
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; quarantined
%       after independent review, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOpenBabelConverter'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)

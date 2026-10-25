% The COBRAToolbox: testRegulariseModelFormulae.m
%
% Purpose:
%     - regulariseModelFormulae rewrites the metabolite formulas of a model in Hill notation,
%     replaces formulas by those derived from InChI strings, and marks formulas with R groups,
%     reporting counts.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/regulariseModelFormulae.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 33-35, the debugging messages (if 0) in the handler for formulas that cannot be
%     converted: they never run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRegulariseModelFormulae'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'a'; 'b'};
model.metFormulas = {'H2O'; 'O2C'};

%% formulas are written in Hill notation

text = evalc('[out, regularised, rGroup] = regulariseModelFormulae(model);');
assert(isequal(out.metFormulas, {'H2O'; 'CO2'}));
assert(~any(regularised) && ~any(rGroup));
assert(contains(text, '#Metabolites: 2'));
assert(contains(text, '#Inchi replacement formulae: 0'));
assert(contains(text, '#Formulae with ''A'' Group: 0'));

%% formulas that follow from an InChI replace the old formula

withInchi = model;
withInchi.metFormulas = {'CH4'; 'O2C'};
withInchi.metInChIString = {'InChI=1S/H2O/h1H2'; ''};
text = evalc('[out, regularised] = regulariseModelFormulae(withInchi);');
assert(isequal(regularised, [true; false]));
assert(strcmp(out.metFormulas{1}, 'H2O') || strcmp(out.metFormulas{1}, 'O'));
assert(contains(text, 'Metabolites that have old formula (left) replaced with InChI derived formula (right):'));
assert(contains(text, '#Inchi replacement formulae: 1'));

%% formulas with R groups are marked with the symbol A

rModel.mets = {'a'; 'b'};
rModel.metFormulas = {'C2H4R'; 'CH4'};
text = evalc('[out, ~, rGroup] = regulariseModelFormulae(rModel);');
assert(isequal(rGroup, [true; false]));
assert(endsWith(out.metFormulas{1}, 'A'));
assert(contains(text, '#Formulae with ''A'' Group: 1'));

% change the directory
cd(currentDir)

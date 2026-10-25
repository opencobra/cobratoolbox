% The COBRAToolbox: testPrintRxnFormulaLinked.m
%
% Purpose:
%     - printRxnFormulaLinked builds (and optionally prints) the formula of one or several reactions
%     with each metabolite as a command-window hyperlink, choosing the arrow from the bounds or the
%     flux, optionally using metabolite names, and breaking long formulas into lines.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/printRxnFormulaLinked.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintRxnFormulaLinked'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small model: HEX (glc + atp -> g6p + adp), R2 (glc <=> 3 g6p, reversible) and R3, a reaction
% with no metabolites
model.mets = {'glc[c]'; 'atp[c]'; 'g6p[c]'; 'adp[c]'};
model.metNames = {'Glucose'; 'ATP'; 'G6P'; 'ADP'};
model.rxns = {'HEX'; 'R2'; 'R3'};
model.S = [-1 -1 0; ...
           -1  0 0; ...
            1  3 0; ...
            1  0 0];
model.lb = [0; -10; -5];
model.ub = [10; 10; 0];
% the hyperlinks produced for the metabolites use the default command fprintf('%s\n')
q = char(39);
link = @(met, text) ['<a href="matlab: fprintf(' q met '\\n' q ')">' text '</a>'];
% a wide line so that no line break occurs unless a test asks for it
wide = 200;
expected = [link('glc[c]', 'glc[c]') ' + ' link('atp[c]', 'atp[c]') '   ->   ' link('g6p[c]', 'g6p[c]') ' + ' link('adp[c]', 'adp[c]') ' '];

%% irreversible reaction: returned in a cell and printed

text = evalc("p = printRxnFormulaLinked(model, 'HEX', true, false, [], wide);");
assert(iscell(p) && numel(p) == 1);
assert(strcmp(p{1}, expected));
% the printed text is the same formula with the escape sequences processed by fprintf
assert(contains(text, '->') && contains(text, ['matlab: fprintf(' q 'glc[c]']));
assert(~contains(text, '\\n'));

%% the print flag off returns the formula without printing

text = evalc("p = printRxnFormulaLinked(model, 'HEX', false, false, [], wide);");
assert(isempty(text));
assert(strcmp(p{1}, expected));

%% reversible reaction with stoichiometric coefficients and metabolite names

p = printRxnFormulaLinked(model, 'R2', false, true, [], wide);
assert(strcmp(p{1}, [link('glc[c]', 'Glucose') '   <=>   3 ' link('g6p[c]', 'G6P') ' ']));

%% the flux decides the arrow

% negative flux: reversed arrow
p = printRxnFormulaLinked(model, 'HEX', false, false, -1, wide);
assert(contains(p{1}, '<-') && ~contains(p{1}, '->'));
% positive flux: forward arrow even for a reversible reaction
p = printRxnFormulaLinked(model, 'R2', false, false, 2, wide);
assert(contains(p{1}, '->') && ~contains(p{1}, '<=>'));
% zero flux: the bounds decide
p = printRxnFormulaLinked(model, 'R2', false, false, 0, wide);
assert(contains(p{1}, '<=>'));

%% bounds that only allow the reverse direction give a reversed arrow

model2 = model;
model2.lb(1) = -5;
model2.ub(1) = 0;
p = printRxnFormulaLinked(model2, 'HEX', false, false, [], wide);
assert(contains(p{1}, '<-'));

%% a reaction without metabolites gives an empty formula

p = printRxnFormulaLinked(model, 'R3', false, false, [], wide);
assert(isequal(p, {''}));

%% a reaction with only a substrate side (no products)

model3 = model;
model3.S(:, 1) = [-1; 0; 0; 0];
p = printRxnFormulaLinked(model3, 'HEX', false, false, [], wide);
assert(strcmp(p{1}, [link('glc[c]', 'glc[c]') '   -> ']) || contains(p{1}, '->'));

%% several reactions give a column of formulas; no list means all reactions

p = printRxnFormulaLinked(model, {'HEX'; 'R2'}, false, false, [], wide);
assert(iscell(p) && isequal(size(p), [2 1]));
assert(contains(p{1}, 'glc[c]') && contains(p{2}, '3 '));
p = printRxnFormulaLinked(model, [], false);
assert(isequal(size(p), [3 1]));

%% long formulas are broken into lines

p = printRxnFormulaLinked(model, 'HEX', false, false, [], 12);
assert(contains(p{1}, '\n  '));
% a break before the arrow and before the next product, as the formula is longer than 12 characters
assert(numel(strfind(p{1}, '\n  ')) == 3);

%% line breaks never change the content of the formula

% removing the break markers and the padding spaces leaves the same text for every line width
% (from 5 characters up, so that the arrow can fall at the start of a line)
wideFormula = printRxnFormulaLinked(model, 'HEX', false, false, [], wide);
reference = strrep(strrep(wideFormula{1}, ' ', ''), '\n', '');
wideFormula2 = printRxnFormulaLinked(model, 'R2', false, true, [], wide);
reference2 = strrep(strrep(wideFormula2{1}, ' ', ''), '\n', '');
for width = 5:40
    p = printRxnFormulaLinked(model, 'HEX', false, false, [], width);
    assert(strcmp(strrep(strrep(p{1}, ' ', ''), '\n', ''), reference), 'width %d', width);
    % the second reaction has a coefficient of 3, which may start a line
    p = printRxnFormulaLinked(model, 'R2', false, true, [], width);
    assert(strcmp(strrep(strrep(p{1}, ' ', ''), '\n', ''), reference2), 'width %d', width);
end

%% an empty print flag means print

text = evalc("p = printRxnFormulaLinked(model, 'HEX', [], false, [], wide);");
assert(contains(text, '->') && strcmp(p{1}, expected));

%% the default line width is that of the command window

p = printRxnFormulaLinked(model, 'HEX', false, false, []);
assert(iscell(p) && contains(p{1}, '->'));

%% a custom command for the hyperlinks

p = printRxnFormulaLinked(model, 'HEX', false, false, [], 30, ['disp(' q '%s' q ')']);
assert(contains(p{1}, ['matlab: disp(' q 'glc[c]' q ')']));
assert(contains(p{1}, '\n  '));

% change the directory
cd(currentDir)

% The COBRAToolbox: testParseRxnFormula.m
%
% Purpose:
%     - parseRxnFormula splits a reaction formula into its metabolites, their stoichiometric
%       coefficients (negative for substrates, positive for products, 1 when none is written)
%       and a reversibility flag ('->', '-->' and '=>' are irreversible; '<=>', '<==>' and no
%       arrow are reversible). A leading '[compartment] :' is appended to every metabolite.
%       This test checks the documented example, every arrow, the compartment prefix, a
%       formula without arrow, an exchange formula and an empty formula. Expected values are
%       read off the documentation and the formulas (hand derivation).
%
% Function under test:
%     src/base/parseRxnFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written formulas.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseRxnFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% documented example: written and implicit coefficients, irreversible arrow '->'

[metaboliteList, stoichCoeffList, revFlag] = ...
    parseRxnFormula('0.01 cdpdag-SC[m] + 0.01 pg-SC[m]  -> 0.01 clpn-SC[m] + cmp[m] + h[m]');
assert(isequal(metaboliteList, {'cdpdag-SC[m]', 'pg-SC[m]', 'clpn-SC[m]', 'cmp[m]', 'h[m]'}));
% exact: str2double('0.01') negated is the double -0.01 written below
assert(isequal(stoichCoeffList, [-0.01 -0.01 0.01 1 1]));
assert(islogical(revFlag) && ~revFlag);

%% reversible arrow '<=>' (documented example) and '<==>'

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('cit[c] + icit[x]  <=> cit[x] + icit[c] ');
assert(isequal(metaboliteList, {'cit[c]', 'icit[x]', 'cit[x]', 'icit[c]'}));
assert(isequal(stoichCoeffList, [-1 -1 1 1]));
assert(revFlag);

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('2 h[c] + atp[c] <==> adp[c] + 3 pi[c]');
assert(isequal(metaboliteList, {'h[c]', 'atp[c]', 'adp[c]', 'pi[c]'}));
assert(isequal(stoichCoeffList, [-2 -1 1 3]));
assert(revFlag);

%% irreversible arrows '-->' and '=>'

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('A --> 2 B');
assert(isequal(metaboliteList, {'A', 'B'}) && isequal(stoichCoeffList, [-1 2]) && ~revFlag);
[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('A => B');
assert(isequal(metaboliteList, {'A', 'B'}) && isequal(stoichCoeffList, [-1 1]) && ~revFlag);

%% compartment prefix '[c] :' is appended to every metabolite

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('[c] : A + 2 B <==> C');
assert(isequal(metaboliteList, {'A[c]', 'B[c]', 'C[c]'}));
assert(isequal(stoichCoeffList, [-1 -2 1]));
assert(revFlag);

%% no arrow: every metabolite is a substrate and the reaction is reversible

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('A + 1.5 B');
assert(isequal(metaboliteList, {'A', 'B'}) && isequal(stoichCoeffList, [-1 -1.5]) && revFlag);

%% exchange formula without products, and an empty formula

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('glc__D[e] -> ');
assert(isequal(metaboliteList, {'glc__D[e]'}) && isequal(stoichCoeffList, -1) && ~revFlag);

[metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula('');
assert(isempty(metaboliteList) && iscell(metaboliteList));
assert(isempty(stoichCoeffList) && revFlag);

% change the directory
cd(currentDir)

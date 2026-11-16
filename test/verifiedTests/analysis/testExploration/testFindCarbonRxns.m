% The COBRAToolbox: testFindCarbonRxns.m
%
% Purpose:
%     - findCarbonRxns counts the carbons of every metabolite from its formula (the digits after
%       the first C, 1 when the C has no digits, 0 without a C), lists the reactions that act on
%       a non-currency metabolite with at least nCarbonThr carbons, and the reactions whose
%       metabolites all have no carbon. This test checks the three formula cases, the currency
%       exclusion, thresholds that select none, some and all metabolites, the zero-carbon list
%       (including a reaction without metabolites) and the output shapes on a hand-built model
%       of eight metabolites and six reactions. Expected values are worked out by hand.
%
% Function under test:
%     src/analysis/exploration/findCarbonRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a hand-built model with fields S, mets, metFormulas
%     and rxns is the smallest model that reaches every branch.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two-letter element symbols beginning with C are counted as one carbon
%       SEVERITY: limitation
%       TRIGGER: a metabolite whose formula contains Ca, Cl, Co, Cu, Cr, Cd, Ce or Cs, for
%         example metFormulas {'Cl'; 'Ca'; 'CaC2O4'} in a model with one reaction that uses the
%         three metabolites, findCarbonRxns(model, 1)
%       OBSERVED: MATLAB R2025a: nCarbon = [1 1 1]; the regular expression C(\d*) of line 42
%         matches the C of the element symbol and an empty digit group counts as one carbon at
%         line 50, so chloride and calcium are reported as carbon-containing metabolites and the
%         reaction is in hiCarbonRxns for every threshold up to 1; calcium oxalate counts 1
%         carbon instead of 2
%       EXPECTED: nCarbon = [0 0 2], the number of carbon atoms in each formula
%       LINES: 42, 50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindCarbonRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: eight metabolites (three formula cases, currency and non-currency) and six reactions

% glucose (6 C), pyruvate (3 C), bicarbonate (CHO3: a C without digits, 1 C), ATP (10 C but a
% currency metabolite), CO2 (1 C, currency), water (no C, currency), x (empty formula) and
% dinitrogen (no C), the last two not currency metabolites
model.mets = {'glc_D[c]'; 'pyr[c]'; 'hco3[c]'; 'atp[c]'; 'co2[c]'; 'h2o[c]'; 'x[c]'; 'n2[c]'};
model.metFormulas = {'C6H12O6'; 'C3H3O3'; 'CHO3'; 'C10H12N5O13P3'; 'CO2'; 'H2O'; ''; 'N2'};
model.rxns = {'HEX'; 'CO2T'; 'H2OT'; 'XT'; 'ATPM'; 'EMPTY'};
%                  HEX CO2T H2OT  XT ATPM EMPTY
model.S = sparse([ -1    0    0   0    0    0;    % glc_D
                    1    0    0   0    0    0;    % pyr
                    0    1    0   0    0    0;    % hco3
                   -1    0    0   0   -1    0;    % atp
                    0   -1    0   0    0    0;    % co2
                    0   -1   -1   0    1    0;    % h2o
                    0    0    0  -1    0    0;    % x
                    0    0    0   1    0    0]);  % n2
% structural consistency of the fixture
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(numel(model.metFormulas) == numel(model.mets));

%% carbon count of every metabolite: digits after C, 1 for a bare C, 0 without C

[hiCarbonRxns, zeroCarbonRxns, nCarbon] = findCarbonRxns(model, 3);
assert(isequal(nCarbon, [6; 3; 1; 10; 1; 0; 0; 0]));

%% threshold 3: glucose and pyruvate qualify, so only HEX acts on a selected metabolite

% ATP has 10 carbons but is a currency metabolite, so ATPM is not listed
assert(isequal(hiCarbonRxns, {'HEX'}));
assert(iscolumn(hiCarbonRxns));

%% threshold 1 adds bicarbonate (CO2T); threshold 0 adds the carbon-free non-currency metabolites

hiCarbonRxns = findCarbonRxns(model, 1);
% CO2 also has one carbon but is a currency metabolite; CO2T is selected through bicarbonate
assert(isequal(hiCarbonRxns, {'HEX'; 'CO2T'}));
hiCarbonRxns = findCarbonRxns(model, 0);
% x and n2 (0 carbons, not currency) select XT; water, ATP and CO2 stay excluded as currency
% metabolites, so H2OT and ATPM are not listed, and EMPTY has no metabolite
assert(isequal(hiCarbonRxns, {'HEX'; 'CO2T'; 'XT'}));

%% a threshold above every carbon count selects no reaction

hiCarbonRxns = findCarbonRxns(model, 11);
assert(iscell(hiCarbonRxns) && isempty(hiCarbonRxns));

%% zero-carbon reactions: every metabolite of the reaction has no carbon, currency included

% H2OT (water), XT (x and n2) and EMPTY (no metabolite at all) qualify; CO2T and ATPM involve
% a carbon-containing metabolite; the threshold plays no role
[~, zeroCarbonRxnsThr11] = findCarbonRxns(model, 11);
assert(isequal(zeroCarbonRxns, {'H2OT'; 'XT'; 'EMPTY'}));
assert(isequal(zeroCarbonRxnsThr11, zeroCarbonRxns));
assert(iscolumn(zeroCarbonRxns) && iscolumn(nCarbon));

% change the directory
cd(currentDir)

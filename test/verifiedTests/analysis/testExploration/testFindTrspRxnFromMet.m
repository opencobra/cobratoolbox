% The COBRAToolbox: testFindTrspRxnFromMet.m
%
% Purpose:
%     - findTrspRxnFromMet lists, for each metabolite of a list, the reactions in which that
%       metabolite (without its compartment) appears in exactly two compartments, i.e. its
%       transport reactions, optionally only those that involve a given compartment. The test
%       checks a hand-built model with transports between three compartments, a reaction that
%       uses the metabolite in one compartment only, a list of two metabolites, a metabolite
%       without transport and the compartment filter (matching, other side, not present).
%       Expected lists are read off the reaction formulas.
%
% Function under test:
%     src/analysis/exploration/findTrspRxnFromMet.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model is queried, no solver is used (the ledger lists the row as
%     Tier 3; the code calls no solver).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindTrspRxnFromMet'));
cd(fileDir);

% declare the requirements of this test. It needs no solver, MATLAB toolbox or particular
% operating system, so none is listed; the call is the standard opening of a COBRA test and
% the place where a requirement would be added later
prepareTest();

% a hand-built model:
%   EX_glc  glc[e] <=>                              glc in one compartment: not a transport
%   GLCt    glc[e] -> glc[c]                        transport of glc between e and c
%   HEX     glc[c] + atp[c] -> g6p[c] + adp[c]      glc in one compartment: not a transport
%   GLCmt   glc[c] <=> glc[m]                       transport of glc between c and m
%   ATPmt   atp[c] + h[e] -> atp[m] + h[c]          transport of atp (c, m) and of h (e, c)
rxnIds = {'EX_glc'; 'GLCt'; 'HEX'; 'GLCmt'; 'ATPmt'};
rxnFormulas = {'glc[e] <=>'; 'glc[e] -> glc[c]'; 'glc[c] + atp[c] -> g6p[c] + adp[c]'; ...
    'glc[c] <=> glc[m]'; 'atp[c] + h[e] -> atp[m] + h[c]'};
model = createModel(rxnIds, rxnIds, rxnFormulas, 'printLevel', 0);

%% no compartment filter: every transport of the metabolite, in reaction order (lines 21-22, 45)
trspRxns = findTrspRxnFromMet(model, {'glc[c]'});
% the list is a row cell array of reaction identifiers
assert(isequal(trspRxns, {'GLCt', 'GLCmt'}));

%% a list of two metabolites: the transports of each are concatenated in list order
trspRxns = findTrspRxnFromMet(model, {'glc[c]', 'atp[c]'});
assert(isequal(trspRxns, {'GLCt', 'GLCmt', 'ATPmt'}));

%% a metabolite whose reactions are not transports gives an empty list
trspRxns = findTrspRxnFromMet(model, {'g6p[c]'});
assert(iscell(trspRxns) && isempty(trspRxns));

%% compartment filter (lines 40-42): only transports that involve the compartment
% 'm' keeps the c <-> m transport of glc
trspRxns = findTrspRxnFromMet(model, {'glc[c]'}, 'm');
assert(isequal(trspRxns, {'GLCmt'}));
% 'e' keeps the e -> c transport of glc
trspRxns = findTrspRxnFromMet(model, {'glc[c]'}, 'e');
assert(isequal(trspRxns, {'GLCt'}));
% 'c' is involved in both transports of glc
trspRxns = findTrspRxnFromMet(model, {'glc[c]'}, 'c');
assert(isequal(trspRxns, {'GLCt', 'GLCmt'}));
% a compartment in none of the transports gives an empty list
trspRxns = findTrspRxnFromMet(model, {'glc[c]'}, 'x');
assert(iscell(trspRxns) && isempty(trspRxns));

%% an empty compartment filter behaves like no filter (the test of line 40)
trspRxns = findTrspRxnFromMet(model, {'atp[c]'}, '');
assert(isequal(trspRxns, {'ATPmt'}));

% change the directory
cd(currentDir)

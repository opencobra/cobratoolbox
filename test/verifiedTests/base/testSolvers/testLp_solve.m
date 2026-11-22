% The COBRAToolbox: testLp_solve.m
%
% Purpose:
%     - lp_solve is the MATLAB driver of the lp_solve 5.5 MEX interface mxlpsolve: it builds a
%       maximisation problem (objective f, constraint matrix a, right-hand side b, senses e with
%       -1 <=, 0 =, 1 >=), sets bounds, integer variables and scaling when given, solves, returns
%       the solution for the result codes 0, 1, 11 and 12 and empty outputs otherwise, and
%       deletes the problem unless keep is given. The lp_solve MEX file is not available on the
%       reference machine (the toolbox ships only a Windows mxlpsolve.dll; mxlpsolve.m is a
%       help script), so the test replaces mxlpsolve by a recording stub on a temporary path and
%       checks the sequence of calls. Expected constraint codes come from the lp_solve 5.5
%       reference (set_constr_type: LE = 1, GE = 2, EQ = 3).
%
% Function under test:
%     src/base/solvers/lp_solve/lp_solve.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; mxlpsolve is a stub written to a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLp_solve'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the stub records every call in a global and returns the handle 7 for make_lp, the result
% code in LP_SOLVE_STUB_RESULT for solve and a fixed solution for get_solution; the globals
% it creates are removed at the end
globalsBefore = who('global');
global LP_SOLVE_STUB_CALLS LP_SOLVE_STUB_RESULT
stubDir = tempname;
mkdir(stubDir);
stubCode = {
    'function varargout = mxlpsolve(varargin)'
    '% recording stub of the lp_solve MEX interface (testLp_solve)'
    'global LP_SOLVE_STUB_CALLS LP_SOLVE_STUB_RESULT'
    'LP_SOLVE_STUB_CALLS{end + 1} = varargin;'
    'switch varargin{1}'
    '    case ''make_lp'''
    '        varargout = {7};'
    '    case ''solve'''
    '        varargout = {LP_SOLVE_STUB_RESULT};'
    '    case ''get_solution'''
    '        varargout = {42, [1; 2], 3};'
    '    otherwise'
    '        varargout = {};'
    'end'
    'end'};
fid = fopen(fullfile(stubDir, 'mxlpsolve.m'), 'w');
fprintf(fid, '%s\n', stubCode{:});
fclose(fid);
addpath(stubDir);

%% without input the help text is shown and nothing is called

LP_SOLVE_STUB_CALLS = {};
lp_solve();
assert(isempty(LP_SOLVE_STUB_CALLS));

%% four inputs: problem built as a maximisation, senses translated, problem deleted

LP_SOLVE_STUB_CALLS = {};
LP_SOLVE_STUB_RESULT = 0;
a = [1, 2; 3, 4; 5, 6];
[obj, x, duals, stat] = lp_solve([1, 1], a, [1; 2; 3], [-1, 0, 1]);
% the solution of get_solution is returned for result 0 (exact: copied values)
assert(obj == 42);
assert(isequal(x, [1; 2]));
assert(duals == 3);
assert(stat == 0);
calls = LP_SOLVE_STUB_CALLS;
commands = cellfun(@(c) c{1}, calls, 'UniformOutput', false);
assert(isequal(commands, {'make_lp', 'set_verbose', 'set_mat', 'set_rh_vec', 'set_obj_fn', ...
    'set_maxim', 'set_constr_type', 'set_constr_type', 'set_constr_type', 'solve', ...
    'get_solution', 'delete_lp'}));
% make_lp receives the size of a; every later call uses the handle 7
assert(isequal(calls{1}(2:3), {3, 2}));
assert(all(cellfun(@(c) isequal(c{2}, 7), calls(2:end))));
assert(isequal(calls{3}{3}, a));
assert(isequal(calls{4}{3}, [1; 2; 3]));
assert(isequal(calls{5}{3}, [1, 1]));
% e = -1, 0, 1 give the lp_solve codes LE = 1, EQ = 3, GE = 2 for rows 1, 2, 3
assert(isequal(calls{7}(3:4), {1, 1}));
assert(isequal(calls{8}(3:4), {2, 3}));
assert(isequal(calls{9}(3:4), {3, 2}));

%% all nine inputs: bounds, integer variables and scaling set, problem kept

LP_SOLVE_STUB_CALLS = {};
LP_SOLVE_STUB_RESULT = 2;
[obj, x, duals, stat] = lp_solve([1, 1], [1, 1], 4, 1, [0, -1], [10, 5], 2, 4, 1);
% result 2 is not a solution code, so the outputs are empty and stat is the result
assert(isempty(obj) && isempty(x) && isempty(duals));
assert(stat == 2);
calls = LP_SOLVE_STUB_CALLS;
commands = cellfun(@(c) c{1}, calls, 'UniformOutput', false);
assert(isequal(commands, {'make_lp', 'set_verbose', 'set_mat', 'set_rh_vec', 'set_obj_fn', ...
    'set_maxim', 'set_constr_type', 'set_lowbo', 'set_lowbo', 'set_upbo', 'set_upbo', ...
    'set_int', 'set_scaling', 'solve'}));
assert(isequal(calls{8}(3:4), {1, 0}));
assert(isequal(calls{9}(3:4), {2, -1}));
assert(isequal(calls{10}(3:4), {1, 10}));
assert(isequal(calls{11}(3:4), {2, 5}));
assert(isequal(calls{12}(3:4), {2, 1}));
assert(isequal(calls{13}{3}, 4));

%% scalemode 0 sets no scaling and the other solution codes return the solution

for resultCode = [1, 11, 12]
    LP_SOLVE_STUB_CALLS = {};
    LP_SOLVE_STUB_RESULT = resultCode;
    [obj, ~, ~, stat] = lp_solve([1, 1], [1, 1], 4, 0, [], [], [], 0);
    assert(obj == 42);
    assert(stat == resultCode);
    commands = cellfun(@(c) c{1}, LP_SOLVE_STUB_CALLS, 'UniformOutput', false);
    % empty bounds and integer lists give no call; eight inputs delete the problem
    assert(isequal(commands, {'make_lp', 'set_verbose', 'set_mat', 'set_rh_vec', ...
        'set_obj_fn', 'set_maxim', 'set_constr_type', 'solve', 'get_solution', 'delete_lp'}));
end

% remove the stub, its folder and the globals of this test
rmpath(stubDir);
rmdir(stubDir, 's');
clear global LP_SOLVE_STUB_CALLS LP_SOLVE_STUB_RESULT
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)

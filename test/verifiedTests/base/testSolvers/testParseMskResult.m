% The COBRAToolbox: testParseMskResult.m
%
% Purpose:
%     - parseMskResult converts the result structure returned by mosekopt into the COBRA solver
%     outputs (status flag, original status string, primal and dual vectors, basis, objectives).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test. MOSEK itself is not needed: the result
%       structures are built by hand.
%
% Function under test:
%     src/base/solvers/mosek/parseMskResult.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseMskResult'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% a complete interior-point solution used by several sections
itr = struct('solsta', 'OPTIMAL', 'xx', [1; 2], 'slc', [0.5; 0], 'suc', [0; 0.25], ...
             'slx', [0.1; 0], 'sux', [0; 0.3], 'doty', [7; 8], 'pobjval', 3, 'dobjval', 3);

% a complete basis solution used by several sections
bas = struct('solsta', 'OPTIMAL', 'xx', [4; 5], 'slc', [1; 1], 'suc', [0; 2], 'slx', [0; 0], ...
             'sux', [1; 1], 's', [9; 9], 'skc', {{'BS'; 'LL'}}, 'skx', {{'BS'; 'UL'}}, ...
             'xc', [4; 5], 'pobjval', 10, 'dobjval', 10);

%% no sol field: status unknown, original status explains why

[stat, origStat, x, y, yl, yu, z, zl, zu, s, basis, pobjval, dobjval] = parseMskResult(struct());
assert(stat == -1);
assert(strcmp(origStat, 'NO_RES_SOL_FIELD'));
assert(isempty(x) && isempty(y) && isempty(yl) && isempty(yu) && isempty(z));
assert(isempty(zl) && isempty(zu) && isempty(s) && isempty(basis));
assert(isempty(pobjval) && isempty(dobjval));

% the return code string is used when present
[stat, origStat] = parseMskResult(struct('rcodestr', 'MSK_RES_ERR_SPACE'));
assert(stat == -1);
assert(strcmp(origStat, 'MSK_RES_ERR_SPACE'));

% an empty return code string is ignored
[~, origStat] = parseMskResult(struct('rcodestr', ''));
assert(strcmp(origStat, 'NO_RES_SOL_FIELD'));

%% sol field without interior-point or basis solution

[stat, origStat, x] = parseMskResult(struct('sol', struct()));
assert(stat == -1);
assert(strcmp(origStat, 'NO_ITR_OR_BAS_SOLUTION'));
assert(isempty(x));

%% strict optimal interior-point solution: all vectors are returned

res = struct('sol', struct('itr', itr));
[stat, origStat, x, y, yl, yu, z, zl, zu, s, basis, pobjval, dobjval] = parseMskResult(res);
assert(stat == 1);
assert(strcmp(origStat, 'OPTIMAL'));
assert(isequal(x, [1; 2]));
assert(isequal(yl, [0.5; 0]) && isequal(yu, [0; 0.25]));
% row duals are yl - yu and variable duals are zu - zl
assert(norm(y - [0.5; -0.25]) < tol);
assert(isequal(zl, [0.1; 0]) && isequal(zu, [0; 0.3]));
assert(norm(z - [-0.1; 0.3]) < tol);
assert(isequal(s, [7; 8]));
% the basis is only filled for a basis solution
assert(isempty(basis));
assert(pobjval == 3 && dobjval == 3);

%% other spellings of the optimal status

for name = {'MSK_SOL_STA_OPTIMAL', 'INTEGER_OPTIMAL', 'MSK_SOL_STA_INTEGER_OPTIMAL'}
    res = struct('sol', struct('itr', setfield(itr, 'solsta', name{1}))); %#ok<SFLD>
    [stat, origStat] = parseMskResult(res);
    assert(stat == 1, name{1});
    assert(strcmp(origStat, name{1}));
end

%% near optimal solution is accepted and gets status 3

for name = {'NEAR_OPTIMAL', 'MSK_SOL_STA_NEAR_OPTIMAL'}
    res = struct('sol', struct('itr', setfield(itr, 'solsta', name{1}))); %#ok<SFLD>
    [stat, origStat, x] = parseMskResult(res);
    assert(stat == 3, name{1});
    assert(strcmp(origStat, name{1}));
    assert(isequal(x, [1; 2]));
end

%% a string-class status is converted to a character vector

res = struct('sol', struct('itr', setfield(itr, 'solsta', "OPTIMAL"))); %#ok<SFLD>
[stat, origStat] = parseMskResult(res);
assert(stat == 1);
assert(ischar(origStat) && strcmp(origStat, 'OPTIMAL'));

%% infeasibility certificates: status flag set, no solution vectors returned

for name = {'PRIMAL_INFEASIBLE_CER', 'PRIM_INFEAS_CER', 'MSK_SOL_STA_PRIM_INFEAS_CER', 'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER'}
    res = struct('sol', struct('itr', setfield(itr, 'solsta', name{1}))); %#ok<SFLD>
    [stat, origStat, x, y] = parseMskResult(res);
    assert(stat == 0, name{1});
    assert(strcmp(origStat, name{1}));
    % certificate vectors must not be mistaken for a feasible point
    assert(isempty(x) && isempty(y));
end

for name = {'DUAL_INFEASIBLE_CER', 'DUAL_INFEAS_CER', 'MSK_SOL_STA_DUAL_INFEAS_CER', 'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER'}
    res = struct('sol', struct('itr', setfield(itr, 'solsta', name{1}))); %#ok<SFLD>
    [stat, origStat, x] = parseMskResult(res);
    assert(stat == 2, name{1});
    assert(strcmp(origStat, name{1}));
    assert(isempty(x));
end

%% unrecognised status: -1 and the status is passed through

res = struct('sol', struct('itr', setfield(itr, 'solsta', 'UNKNOWN'))); %#ok<SFLD>
[stat, origStat, x] = parseMskResult(res);
assert(stat == -1);
assert(strcmp(origStat, 'UNKNOWN'));
assert(isempty(x));

%% missing or empty solsta gives the placeholder status

res = struct('sol', struct('itr', struct('xx', [1; 2])));
[stat, origStat] = parseMskResult(res);
assert(stat == -1);
assert(strcmp(origStat, 'NO_SOLSTA'));

res = struct('sol', struct('bas', struct('solsta', [], 'xx', 1)));
[~, origStat] = parseMskResult(res);
assert(strcmp(origStat, 'NO_SOLSTA'));

%% the return code string is appended to the original status

res = struct('sol', struct('itr', itr), 'rcodestr', 'MSK_RES_OK');
[stat, origStat] = parseMskResult(res);
assert(stat == 1);
assert(strcmp(origStat, 'OPTIMAL & MSK_RES_OK'));

%% basis solution: used when there is no usable interior-point solution

res = struct('sol', struct('bas', bas));
[stat, origStat, x, y, ~, ~, z, ~, ~, s, basis, pobjval, dobjval] = parseMskResult(res);
assert(stat == 1);
assert(strcmp(origStat, 'OPTIMAL'));
assert(isequal(x, [4; 5]));
assert(isequal(y, [1; -1]));
assert(isequal(z, [1; 1]));
% no doty field, so the conic duals fall back to the field s
assert(isequal(s, [9; 9]));
assert(isequal(basis.skc, {'BS'; 'LL'}) && isequal(basis.skx, {'BS'; 'UL'}));
assert(isequal(basis.xc, [4; 5]) && isequal(basis.xx, [4; 5]));
assert(pobjval == 10 && dobjval == 10);

% doty is preferred when present
basDoty = bas;
basDoty.doty = [2; 3];
[~, ~, ~, ~, ~, ~, ~, ~, ~, s] = parseMskResult(struct('sol', struct('bas', basDoty)));
assert(isequal(s, [2; 3]));

% only the basis fields that exist are copied
res = struct('sol', struct('bas', struct('solsta', 'OPTIMAL', 'xx', 1)));
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, basis] = parseMskResult(res);
assert(isequal(fieldnames(basis), {'xx'}));

%% the interior-point solution wins when both are usable

res = struct('sol', struct('itr', itr, 'bas', bas));
[~, ~, x] = parseMskResult(res);
assert(isequal(x, [1; 2]));

%% a non-optimal interior-point solution does not hide a usable basis solution

res = struct('sol', struct('itr', setfield(itr, 'solsta', 'UNKNOWN'), 'bas', bas)); %#ok<SFLD>
[stat, ~, x] = parseMskResult(res);
assert(stat == 1);
assert(isequal(x, [4; 5]));

%% no usable solution: the status of the interior-point solution is reported first

res = struct('sol', struct('itr', setfield(itr, 'solsta', 'UNKNOWN'), 'bas', setfield(bas, 'solsta', 'DUAL_INFEAS_CER'))); %#ok<SFLD>
[stat, origStat] = parseMskResult(res);
assert(stat == -1);
assert(strcmp(origStat, 'UNKNOWN'));

% with only a basis solution that is not optimal the basis status is reported
res = struct('sol', struct('bas', setfield(bas, 'solsta', 'DUAL_INFEAS_CER'))); %#ok<SFLD>
[stat, origStat, x] = parseMskResult(res);
assert(stat == 2);
assert(strcmp(origStat, 'DUAL_INFEAS_CER'));
assert(isempty(x));

%% vector handling: sparse input becomes full, rows become columns, objectives must be scalar

sol = itr;
sol.xx = sparse([1 0 2]);
sol.pobjval = [1 2];
sol.dobjval = single(4);
[~, ~, x, ~, ~, ~, ~, ~, ~, ~, ~, pobjval, dobjval] = parseMskResult(struct('sol', struct('itr', sol)));
assert(~issparse(x));
assert(isequal(x, [1; 0; 2]));
% a non-scalar objective is dropped, a scalar one is converted to double
assert(isempty(pobjval));
assert(isa(dobjval, 'double') && dobjval == 4);

% empty fields are treated as absent
sol = itr;
sol.xx = [];
[~, ~, x] = parseMskResult(struct('sol', struct('itr', sol)));
assert(isempty(x));

% change the directory
cd(currentDir)

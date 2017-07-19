% The COBRAToolbox: testCorrespondingRowsCols.m
%
% Purpose:
%     - tests getCorrespondingRows and getCorrespondingCols
%
% Author:
%     - CI integration: Laurent Heirendt


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCorrespondingRowsCols'));
cd(fileDir);

% toy model stoichiometric matrix
S = [-1,  0,  0,  0,  0;
      2, -3,  0,  0,  0;
      0,  4, -5,  0,  0;
      0,  0,  6, -7,  0;
      0,  0,  0,  0,  8];

display(S);
fprintf('--- row subset for getCorrespondingRows ----\n')

rowBool = false(size(S, 1), 1);
colBool = false(size(S, 2), 1);
rowBool(1:5) = 1;
colBool(1:3) = 1;

display(S(rowBool, colBool))

% test the exclusive mode
mode = 'exclusive';
fprintf('%s\n', mode);
restrictedRowBool = getCorrespondingRows(S, rowBool, colBool, mode);

display(S(restrictedRowBool, colBool));
ref_rows_exclusive = [-1,  0,  0;
                       2, -3,  0;
                       0,  4, -5];
assert(isequal(S(restrictedRowBool, colBool), ref_rows_exclusive));

% test the inclusive mode
mode = 'inclusive';
fprintf('%s\n', mode);
restrictedRowBool = getCorrespondingRows(S, rowBool, colBool, mode);

display(S(restrictedRowBool, colBool));
ref_rows_inclusive = [-1,  0,  0;
                       2, -3,  0;
                       0,  4, -5;
                       0,  0,  6];
assert(isequal(S(restrictedRowBool, colBool), ref_rows_inclusive));

% test the partial mode
mode = 'partial';
fprintf('%s\n', mode);

restrictedRowBool = getCorrespondingRows(S, rowBool, colBool, mode);

display(S(restrictedRowBool,colBool));
ref_rows_partial = [0, 0, 6];
assert(isequal(S(restrictedRowBool, colBool), ref_rows_partial));

fprintf('--- col subset for getCorrespondingCols ----\n');
rowBool = false(size(S, 1), 1);
colBool = false(size(S, 2), 1);
rowBool(1:3) = 1;
colBool(1:5) = 1;

display(S(rowBool, colBool));

% test the exclusive mode
mode ='exclusive';
fprintf('%s\n', mode);
restrictedColBool = getCorrespondingCols(S, rowBool, colBool, mode);

display(S(rowBool, restrictedColBool));
ref_cols_exclusive = [-1,  0;
                       2, -3;
                       0,  4];
assert(isequal(S(rowBool, restrictedColBool), ref_cols_exclusive));

% test the inclusive mode
mode ='inclusive';
fprintf('%s\n', mode);
restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode);

display(S(rowBool,restrictedColBool));
ref_cols_inclusive = [-1,  0,  0;
                       2, -3,  0;
                       0,  4, -5];
assert(isequal(S(rowBool, restrictedColBool), ref_cols_inclusive));

% test the partial mode
mode ='partial';
fprintf('%s\n', mode);
restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode);

display(S(rowBool,restrictedColBool));
ref_cols_partial = [0;
                    0;
                   -5];
assert(isequal(S(rowBool, restrictedColBool), ref_cols_partial));

% testing input of functions
testrowBool(1:5) = '1';
try
  getCorrespondingRows(S, testrowBool, colBool);
catch ME
    assert(length(ME.message) > 0)
end

testrowBool(1:5) = '1';
try
  getCorrespondingCols(S, testrowBool, colBool);
catch ME
    assert(length(ME.message) > 0)
end

testcolBool(1:5) = '1';
try
  getCorrespondingRows(S, rowBool, testcolBool);
catch ME
    assert(length(ME.message) > 0)
end

testcolBool(1:5) = '1';
try
  getCorrespondingCols(S, rowBool, testcolBool);
catch ME
    assert(length(ME.message) > 0)
end
% change the directory
cd(currentDir)

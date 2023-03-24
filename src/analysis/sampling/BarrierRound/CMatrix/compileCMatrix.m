configCMatrix

%% setup source files
[path,~,~] = fileparts(mfilename('fullpath'));
qdpath = fullfile(path, 'qd');
source = {fullfile(qdpath, 'util.cc'), fullfile(qdpath, 'bits.cc'), fullfile(qdpath, 'dd_real.cc'), fullfile(qdpath, 'dd_const.cc'), fullfile(qdpath, 'qd_real.cc'), fullfile(qdpath, 'qd_const.cc')};
global EIGEN_PATH
include = {path, EIGEN_PATH};

%% compile ddouble
compileEachCMatrix('ddouble', source, include);

%% compile qdouble
compileEachCMatrix('qdouble', source, include);

%% compile AdaptiveChol 
[path,~,~] = fileparts(mfilename('fullpath'));

if isarm()
	mexFile = fullfile(path, 'include', 'AdaptiveCholArmMex.mex');
else
	mexFile = fullfile(path, 'include', 'AdaptiveCholMex.mex');
end

fprintf('compiling AdaptiveChol...\n');
compile(mexFile, [{fullfile(path, 'cholMex.cpp')} source], include);

function compileEachCMatrix(name, source, include)
[path, ~, ~] = fileparts(mfilename('fullpath'));

% copy CMatrix.m file
code = fileread(fullfile(path, 'CMatrix.m'));
code = strrep(code, 'CMatrix', name);

fileID = fopen(fullfile(path, 'include', [name '.m']), 'w');
fprintf(fileID, '%s', code);
fclose(fileID);


if isarm()
	mexFile = [name 'ArmMex.mex'];
else
	mexFile = [name 'Mex.mex'];
end
mexFile = fullfile(path, 'include', mexFile);

fprintf('compiling %s...\n', name);
compile(mexFile, [{fullfile(path, 'include', [name, '.cpp'])} source], include);
end
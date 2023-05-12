function compile(output, source, include, opts)
%compile(output, source, include, options)
%compile the C++ file
%
%Input:
% output - output location for the mex
% source - filename for source C++ files
% include - the list of directories to search for #include

if nargin <= 3, opts = struct; end
if nargin <= 2, include = {}; end

defaults = struct('std', 'c++17', 'debug', false, 'tol', 1e-8, 'fmath', false);
opts = setField(defaults, opts);

if ~iscell(include)
   include = {include};
end

if ~iscell(source)
   source = {source};
end

if (isempty(mex.getCompilerConfigurations('C++', 'Selected')))
   error('No C++ mex compiler is available.');
end

[path,~,~] = fileparts(mfilename('fullpath'));
include = [include {path}];

compiler = mex.getCompilerConfigurations('C++', 'Selected').ShortName;

cmd = 'mex -R2018a -O -silent -output "%output"';
if opts.debug
   cmd = [cmd ' -g'];
end

if (contains(compiler, 'MSVCPP'))
   fmath = '/fp:fast';
   cmd = [cmd ' COMPFLAGS="$COMPFLAGS /O2 /arch:AVX2 /std:%std %fmath"'];
elseif (contains(compiler, 'Clang++'))
   fmath = '-ffast-math';
   cmd = [cmd ' CFLAGS="$CFLAGS -O3 -march=native -std=%std %fmath"'];
elseif (contains(compiler, 'g++'))
   fmath = '-ffast-math';
   cmd = [cmd ' CFLAGS="$CFLAGS -O3 -march=native -std=%std %fmath"'];
else
   error('Currently, we only support MSVCPP, Clang++ or g++ as the compiler.');
end

if ~opts.fmath
   fmath = '';
end


cmd = [cmd ' %include %source'];

source = join(source, '" "');
source = ['"' source{1} '"'];
include = join(include, '" -I"');
include = ['-I"' include{1} '"'];

keywords = {'%std', '%output', '%include', '%source', '%fmath'};
replaces = {opts.std, output, include, source, fmath};
cmd = replace(cmd, keywords, replaces);

clear mex
eval(cmd);

end
function addCOBRABinaryPathToSystemPath()
% Sets up the path to system executables shipped by the toolbox.
%
% USAGE:
%     addCOBRABinaryPathToSystemPath()
%

global CBTDIR

arch = computer('arch');

%Set thefolders
binaryDir = [CBTDIR filesep 'binary' filesep arch filesep 'bin'];
libDir = [CBTDIR filesep 'binary' filesep arch filesep 'lib'];

%get all Subfolders
bindirs = rdir([binaryDir filesep '**' filesep '*']);
libdirs = rdir([libDir filesep '**' filesep '*']);
binnames = {bindirs.name};
libnames = {libdirs.name};
bindirs = [{binaryDir},binnames([bindirs.isdir])]; %Add all subdirectories and the top level
libdirs = [{libDir},libnames([libdirs.isdir])];

if ispc
    setenv('Path', [getenv('Path') ';' strjoin(union(bindirs,libdirs),';')  ]);
else
    setenv('PATH', [getenv('PATH') ':' strjoin(bindirs,':')]);
    setenv('LD_LIBRARY_PATH', [getenv('LD_LIBRARY_PATH') ':' strjoin(libdirs,':')]);
end

end

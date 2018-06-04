function Ok = InstallMD5Mex(SourceFile, varargin)
% INSTALLMEX - Compile and install Mex file
% The C, C++ or FORTRAN mex file is compiled and additional installation
% routines are started. Advanced users can call MEX() manually instead, but some
% beginners are overwhelmed by instructions for a compilation sometimes.
% Therefore this function can be called automatically from an M-function, when
% the compiled Mex-Function does not exist already.
%
% Ok = InstallMex(SourceFile, ...)
% INPUT:
%   SourceFile: Name of the source file, with or without absolute or partial
%               path. The default extension '.c' is appended on demand.
%   Optional arguments in arbitrary order:
%     Function name: Function is started after compiling, e.g. a unit-test.
%     Cell string:   Additional arguments for the compilation, e.g. libraries.
%     '-debug':      Enable debug mode.
%     '-force32':    Use the compatibleArrayDims flag under 64 bit Matlab.
%     '-replace':    Overwrite existing mex file without confirmation.
%
% OUTPUT:
%   Ok:  Logical flag, TRUE if compilation was successful. Optional.
%
% COMPATIBILITY:
% - A compiler must be installed and setup before: mex -setup
% - For Linux and MacOS the C99 style is enabled for C-files.
% - The optimization flag -O is set.
% - Defined compiler directives:
%    * MATLABVER<XYZ>: <XYZ> is the current version, e.g. 708 for v7.8.
%    * _LITTLE_ENDIAN or _BIG_ENDIAN: according to processor type
%    * HAS_HG2: Defined for Matlab >= R2014b with HG2 graphics.
%
% EXAMPLES:
% Compile func1.c with LAPACK libraries:
%   InstallMex('func1', {'libmwlapack.lib', 'libmwblas.lib'})
% Compile func2.cpp, enable debugging and call a test function:
%   InstallMex('func2.cpp', '-debug', 'Test_func2');
% These commands can be appended after the help section of an M-file, when the
% compilation should be started automatically, if the compiled MEX is not found.
%
% NOTES:
% Suggestions for improvements and comments are welcome!
% Feel free to add this function to your FEX submissions, when you change the
% URL in the variable "Precompiled" accordingly.
%
% Tested: Matlab/64 7.8, 7.13, 8.6, 9.1, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2012-2017 matlab.2010(a)n(MINUS)simon.de

% $JRev: R5J V:035 Sum:2nORyg1Xr1iA Date:03-Jan-2017 15:58:22 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\GLSource\InstallMex.m $
% History:
% 001: 27-Jul-2012 09:06, First version.
% 005: 29-Jul-2012 17:11, Run the unit-test instead of showing a link only.
% 006: 11-Aug-2012 23:59, Inputs are accepted in free order.
% 020: 30-Dec-2013 01:48, Show a question dialog if mex is existing already.
% 027: 08-Mar-2015 22:15, Define _LITTLE_ENDIAN / _BIG_ENDIAN.
% 028: 22-Aug-2015 19:16, Define HAS_HG2 for Matlab >= 2014b.
% 029: 24-Dec-2015 17:46, CATCH MException: No Matlab6.5 support anymore.
% 032: 24-Apr-2016 17:45, Bugs fixed: "cmd" instead of "cmdStr".

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
% URL to file or folder containing pre-compiled files, or the empty string if
% pre-compiled files are not offered:
% ### START: ADJUST TO USER NEEDS
Precompiled = 'http://www.n-simon.de/mex';
% ### END

% Initial values: --------------------------------------------------------------
bakCD   = cd;
matlabV = [100, 1] * sscanf(version, '%d.%d', 2);  % Matlab version
[Arch, MaxSize, Endian] = computer;  %#ok<ASGLU>

hasHG2         = (matlabV >= 804);  % R2014b
hasLargeDims   = (matlabV >= 705) & any(strfind(Arch, '64'));  % R2007b & 64bit
isLittleEndian = strncmpi(Endian, 'L', 1);

% Program Interface: -----------------------------------------------------------
% Parse inputs:
Param       = {};
UnitTestFcn = '';
doDebug     = false;
debugFlag   = {};
force32     = false;
replace     = false;

% First input is the name of the source file:
if ~ischar(SourceFile)
   error_L('BadTypeInput1', '1st input must be a string.');
end

% Additional inputs are identified by their type:
% String:      unit-test function or the flag to enable debugging.
% Cell string: additional parameters for the MEX command
for iArg = 1:numel(varargin)
   Arg = varargin{iArg};
   if ischar(Arg)
      if strcmpi(Arg, '-debug')
         doDebug     = true;
         debugFlag   = {'-v'};
      elseif strcmpi(Arg, '-force32')
         force32     = true;
      elseif strcmpi(Arg, '-replace')
         replace     = true;
      elseif exist(Arg, 'file') == 2
         UnitTestFcn = Arg;
      else
         error_L('MissFile', 'Unknown string or missing file: %s', Arg);
      end
   elseif iscellstr(Arg)  % As row cell:
      Param = Arg(:).';
   else
      error_L('BadInputType', 'Bad type of input.');
   end
end

% User Interface: --------------------------------------------------------------
hasHRef = usejava('jvm');   % Hyper-links in the command window?

% Do the work: =================================================================
% Search the source file, solve partial or relative path, get the real
% upper/lower case:
[dummy, dummy, Ext] = fileparts(SourceFile);  %#ok<ASGLU>
if isempty(Ext)
   SourceFile = [SourceFile, '.c'];
end

whichSource = which(SourceFile);
if isempty(whichSource)
   error_L('NoSource', 'Cannot find the source file: %s', SourceFile);
end
[SourcePath, SourceName, Ext] = fileparts(whichSource);
Source                        = [SourceName, Ext];

% Consider output name and outputdir:
index = find(strcmpi(Param, '-output'), 1, 'last');
if isempty(index)
   mexName = SourceName;
else
   [dummy, mexName] = fileparts(Param{index + 1});  %#ok<ASGLU>
end
mexFile = [mexName, '.', mexext];

index = find(strcmpi(Param, '-outdir'), 1, 'last');
if isempty(index)
   mexPath = SourcePath;
else
   mexPath = Param{index + 1};
end

fprintf('== Compile: %s\n', fullfile(SourcePath, Source));

% Check if the compiled file is existing already:
whichMex = which(mexFile);
if ~isempty(whichMex)
   fprintf('  Existing already:  %s\n', whichMex);
   
   if ~replace
      % Ask the user if a new compilation is wanted:
      QuestReply = questdlg({ ...
         ['\bf', mfilename, ': ', TeXFirm(SourceName), '\rm'], ...
         '', 'The function is existing already:', ...
         ['  ', TeXFirm(whichMex)], '', ...
         'Do you want to compile it here:', ...
         ['  ', TeXFirm(fullfile(mexPath, mexFile))], ''}, ...
         mfilename, 'Compile', 'Cancel', ...
         struct('Default', 'Cancel', 'Interpreter', 'tex'));
      
      % User does not want to recompile:
      if strcmp(QuestReply, 'Cancel')
         if nargout
            Ok = false;
         end
         return;
      end
   end
   fprintf('  Recompile in: %s\n\n', mexPath);
end

if ~ispc && strcmpi(Ext, '.c')
   % C99 for the GCC and XCode compilers.
   % Note: 'CFLAGS="\$CFLAGS -std=c99"' must be separated to 2 strings!!!
   Flags = {'-O', 'CFLAGS="\$CFLAGS', '-std=c99"'};
else
   Flags = {'-O'};
end

% Large array dimensions under 64 bit, possible since R2007b:
matlabVDef = {sprintf('-DMATLABVER=%d', matlabV)};
if hasLargeDims && ~force32
   Flags = cat(2, Flags, {'-largeArrayDims'});
else
   Flags = cat(2, Flags, {'-compatibleArrayDims'});
end

% Define endianess directive:
if isLittleEndian
   Flags = cat(2, Flags, {'-D_LITTLE_ENDIAN'});
else  % Does Matlab run on a big endian machine currently?!
   Flags = cat(2, Flags, {'-D_BIG_ENDIAN'});
end

% Define the new HG2 graphic handles:
if hasHG2
   Flags = cat(2, Flags, {'-DHAS_HG2'});
end

% Compile: ---------------------------------------------------------------------
% Display the compilation command:
Flags  = cat(1, Flags(:), debugFlag, matlabVDef, Param(:), {Source});
cmdStr = ['mex', sprintf(' %s', Flags{:})];
fprintf('%s\n\n', cmdStr);

cd(SourcePath);
try    % Start the compilation:
   mex(Flags{:});
   compiled = true;
   fprintf('Compiled:\n  %s\n', which(mexFile));
   
catch ME  % Compilation failed - MException fails in Matlab 6.5!
   compiled = false;
   fprintf(2, '\n*** Compilation failed:\n%s\n\n', ME.message);
   fprintf('Matlab version: %s\n', version);
   if ~doDebug  % Compile again in debug mode if not done already:
      fprintf('Compile with debug flag to get details:\n');
      try
         mex(Flags{:}, '-v');
      catch  % Empty - it is known already that it fails
      end
   end
   
   % Show commands for manual compilation and download pre-compiled files:
   fprintf('\n== The compilation failed! Possible solutions:\n');
   fprintf('  * Is a compiler installed and set up properly by: mex -setup?\n');
   fprintf('  * Try to compile manually:\n    cd(''%s'')\n', SourcePath);
   fprintf('    %s -v\n', cmdStr);
   fprintf('  * Or download the pre-compiled file %s:\n', mexFile);
   if ~isempty(Precompiled)
      if hasHRef
         fprintf( ...
            '    <a href="matlab:web(''%s#%s'',''-browser'')">%s</a>\n', ...
            Precompiled, mexFile, Precompiled);
      else  % No hyper-references in the command window without Java:
         fprintf('    %s\n', Precompiled);
      end
   end
   fprintf('  * Please send this report to the author.\n');
end

% Restore original directory and check precedence: -----------------------------
cd(bakCD);
if compiled
   allWhich = which(mexName, '-all');
   if ~strcmpi(allWhich{1}, fullfile(mexPath, mexFile))
      Spec  = sprintf('  %%-%ds   ', max(cellfun('length', allWhich)));
      fprintf(2, '\n*** Failed: Compiled function is shadowed:\n');
      fprintf(2, [Spec, '*USED*\n'],     allWhich{1});
      fprintf(2, [Spec, '*SHADOWED*\n'], allWhich{2:end});
      
      compiled = false;
   end
   
   allWhichMex = which(mexFile, '-all');
   if length(allWhichMex) > 1
      fprintf(2, '\n::: Multiple instances of compiled file:\n');
      fprintf(2, '  %s\n', allWhich{:});
   end
end

% Run the unit-test: -----------------------------------------------------------
if ~isempty(UnitTestFcn) && compiled
   fprintf('\n\n== Post processing:\n');
   [dum, UnitTestName] = fileparts(UnitTestFcn);  %#ok<ASGLU> % Remove extension
   if ~isempty(which(UnitTestName))
      fprintf('  Call: %s\n\n', UnitTestName);
      feval(UnitTestName);
   else
      fprintf(2, '??? Cannot find function: %s\n', UnitTestFcn);
   end
end

% Return success of compilation: -----------------------------------------------
if nargout >= 1
   Ok = compiled;
end
if compiled
   fprintf('\n== %s: ready.\n', mfilename);
else
   fprintf('\n== %s: failed.\n', mfilename);
end

% end

% ******************************************************************************
function error_L(ID, Msg, varargin)
% Automatic error ID and mfilename in the message:
error(['JSimon:', mfilename, ':', ID], ...
   ['*** %s: ', Msg], mfilename, varargin{:});

% end

% ******************************************************************************
function S = TeXFirm(S)
% Escape special characters for the TeX interpreter:
S = strrep(strrep(S, '\', '\\'), '_', '\_');

% end

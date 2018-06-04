function S = GetMD5_helper(V)
% GetMD5_helper: Convert non-elementary array types for GetMD5
% The C-Mex function GetMD5 calls this function to obtain meaningful unique data
% for function handles, java or user-defined objects and sparse arrays. The
% applied processing can depend on the needs of the users, therefore it is
% implemented as an M-function, which is easier to modify than the C-code.
%
% INPUT:
%   V: Array of any type, which is not handled in the C-Mex.
% OUTPUT:
%   S: Array or struct containing elementary types only.
%      The implementation migth be changed by the user!
%      Default:
%      - Sparse arrays:   Struct containing the indices and values.
%      - Function handle: The reply of FUNCTIONS and the size and date of the
%        file.
%      - User defined and java objects: V.hashCode if existing, else: struct(V).
%
% NOTE:
%   For objects the function getByteStreamFromArray() might be exhaustive and
%   efficient, but unfortunately it is not documented.
%
% Tested: Matlab/64 7.8, 7.13, 8.6, 9.1, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2016-2017 matlab.2010(a)n(MINUS)simon.de

% $JRev: R5i V:008 Sum:hPPK4pV7BpW8 Date:03-Jan-2017 13:59:12 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\GLFile\GetMD5_helper.m $
% History:
% 001: 28-Jun-2015 19:19, Helper for GetMD5.

% Initialize: ==================================================================
% Do the work: =================================================================

% The dimensions, number of dimensions and the name of the class is considered
% already in the MEX function!

if isa(V, 'function_handle')
   % Please adjust the subfunction ConvertFuncHandles to your needs.
   
   % The Matlab version influences the conversion by FUNCTIONS:
   % 1. The format of the struct replied FUNCTIONS is not fixed,
   % 2. The full path of toolbox function e.g. for @mean differ.
   S = functions(V);
   
   % Include modification file time and file size. Suggested by Aslak Grinsted:
   if ~isempty(S.file)
      d = dir(S.file);
      if ~isempty(d)
         S.filebytes = d.bytes;
         S.filedate  = d.datenum;
      end
   end
   
   % ALTERNATIVE: Use name and path. The <matlabroot> part of the toolbox
   % functions is replaced such that the hash for @mean does not depend on the
   % Matlab version.
   % Drawbacks: Anonymous functions, nested functions...
   % funcStruct = functions(FuncH);
   % funcfile   = strrep(funcStruct.file, matlabroot, '<MATLAB>');
   % S          = uint8([funcStruct.function, ' ', funcfile]);
   
   % Finally I'm afraid there is no unique method to get a hash for a function
   % handle. Please adjust this conversion to your needs.
   
elseif (isobject(V) || isjava(V)) && ismethod(V, 'hashCode')  % ================
   % Java or user-defined objects might have a hash function:
   S = char(V.hashCode);
   
elseif issparse(V)  % ==========================================================
   % Create struct with indices and non-zero values:
   [S.Index1, S.Index2, S.Value] = find(V);
   
else  % Most likely this is a user-defined object: =============================
   try    % Perhaps a direct conversion is implemented:
      S = uint8(V);
      
      % Matt Raum had this excellent idea - unfortunately this function is
      % undocumented and might not be supported in te future:
      % S = getByteStreamFromArray(DataObj);

   catch ME  % Or perhaps this is better:
      fprintf(2, ['### %s: Convert object to struct as fallback.', char(10), ...
         '    %s\n'], ME.message);
      WarnS = warning('off', 'MATLAB:structOnObject');
      S     = struct(V);
      warning(WarnS);
   end
end

% return;

function uTest_GetMD5(doSpeed)
% Automatic test: GetMD5 (Mex)
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% uTest_GetMD5(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%   The speed is compared to a Java method.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2009-2016 matlab.2010(a)n(MINUS)simon.de

% $JRev: R5t V:026 Sum:B5AwHml2fH/p Date:28-Jul-2017 03:20:31 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\UnitTests_\uTest_GetMD5.m $
% History:
% 018: 01-Mar-2015 13:48, Compare results with Java hash.
% 022: 28-Jun-2015 19:10, Check array input.

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
ErrID = ['JSimon:', mfilename];

% Initial values: --------------------------------------------------------------
if nargin == 0
   doSpeed = true;
end

% Program Interface: -----------------------------------------------------------
% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
whichFunc = which('GetMD5');
fprintf('==== Test GetMD5:  %s\nVersion: %s\n\n', ...
   datestr(now, 0), whichFunc);

% Known answer tests - see RFC1321: --------------------------------------------
disp('== Known answer tests:');
TestData = { ...
   '',               'd41d8cd98f00b204e9800998ecf8427e'; ...
   'a',              '0cc175b9c0f1b6a831c399e269772661'; ...
   'abc',            '900150983cd24fb0d6963f7d28e17f72'; ...
   'message digest', 'f96b697d7cb7938d525a2f31aaf161d0'; ...
   ...
   'abcdefghijklmnopqrstuvwxyz', ...
   'c3fcd3d76192e4007dfb496cca67e13b'; ...
   ...
   'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', ...
   'd174ab98d277d9f5a5611c2c9f419d9f'; ...
   ...
   ['123456789012345678901234567890123456789012345678901234567890123456', ...
   '78901234567890'], ...
   '57edf4a22be3c955ac49da2e2107b67a'; ...
   ...
   char(0:255), 'e2c865db4162bed963bfaa9ef6ac18f0'};  % Not in RFC1321

TestFile = tempname;

% Loop over test data:
for iTest = 1:size(TestData, 1)
   % Check string input considering ASCII range only:
   Str = GetMD5(TestData{iTest, 1}, '8bit');
   if strcmpi(Str, TestData{iTest, 2}) == 0
      error([ErrID, ':KAT'], ['Failed for string:', ...
            char(10), '[', TestData{iTest, 1}, ']']);
   end
   
   % Check file input:
   FID = fopen(TestFile, 'w+');
   if FID < 0
      error([ErrID, ':KAT'], 'Cannot open test file [%s]', TestFile);
   end
   fwrite(FID, TestData{iTest, 1}, 'uchar');
   fclose(FID);
   
   Str2 = GetMD5(TestFile, 'file');
   if strcmpi(Str2, TestData{iTest, 2}) == 0
      error([ErrID, ':KAT'], 'Failed for file: [%s]', TestData{iTest, 1});
   end
   
   % Check string converted to UINT8:
   Str3 = GetMD5(uint8(TestData{iTest, 1}), 'Binary');
   if strcmpi(Str3, TestData{iTest, 2}) == 0
      error([ErrID, ':KAT'], ['Failed for UINT8:', ...
            char(10), '[', TestData{iTest, 1}, ']']);
   end
end
disp('  ok');
delete(TestFile);

% Compare results with java implementation: ------------------------------------
if usejava('jvm')
   disp('== Compare mex and Java:');
   Engine = java.security.MessageDigest.getInstance('MD5');
   for k = 0:1026                   % More or less arbitrary upper limit
      S = uint8(rand(k, 1) * 256);  % Random test data of growing length
      
      if k > 0
         Engine.update(S);
      end
      jHash = typecast(Engine.digest, 'uint8');
      
      mHash = GetMD5(S, 'bin', 'uint8');
      
      if ~isequal(jHash(:), mHash(:))
         error([ErrID, ':JavaComp'], 'Result differs from Java!');
      end
   end
   fprintf('  ok\n');
   
else  % No Java VM:
   fprintf('::: No comparison with Java: JVM not available.\n\n');
end

% Check different output types: ------------------------------------------------
N = 1000;
disp('== Check output types:');
for i = 1:N
   data      = uint8(fix(rand(1, 1 + fix(rand * 100)) * 256));
   lowHexOut = GetMD5(data, 'bin', 'hex');
   upHexOut  = GetMD5(data, 'bin', 'HEX');
   decOut    = GetMD5(data, 'bin', 'Double');
   b64Out    = GetMD5(data, 'bin', 'Base64');
   uint8Out  = GetMD5(data, 'bin', 'Uint8');
   
   if not(strcmpi(lowHexOut, upHexOut) && ...
         isequal(sscanf(lowHexOut, '%2x'), decOut(:)) && ...
         isequal(Base64decode(b64Out), decOut)) && ...
         isequal(decOut, double(uint8Out))
      fprintf('\n');
      error([ErrID, ':Output'], 'Different results for output types.');
   end
   
   % Check binary, e.g. if the data length is a multiple of 2:
   if rem(length(data), 2) == 0
      doubleData = double(data);
      uniData    = char(doubleData(1:2:end) + 256 * doubleData(2:2:end));
      uniOut     = GetMD5(uniData, 'binary', 'dec');
      if not(isequal(uniOut, decOut))
         error([ErrID, ':Output'], 'Different results for binary mode.');
      end
   end
end
fprintf(['  ok: %d random tests with hex, HEX, double, uint8, base64 ', ...
   'output: \n'], N);

% Check arrays as inputs: ------------------------------------------------------
disp('== Test array input:');

% Hash must depend on the type of the array:
S1 = GetMD5([], 'Array');
if ~isequal(S1, '5b302b7b2099a97ba2a276640a192485')
   error([ErrID, ':Array'], 'Bad result for array: []');
end

S1 = GetMD5(uint8([]), 'Array');
if ~isequal(S1, 'cb8a2273d1168a72b70833bb0d79be13')
   error([ErrID, ':Array'], 'Bad result for array: uint8([])');
end

S1 = GetMD5(int8([]), 'Array');
if ~isequal(S1, '0160dd4473fe1a952572be239e077ed3')
   error([ErrID, ':Array'], 'Bad result for array: int8([])');
end

Data = struct('Field1', 'string', 'Field2', {{'Cell string', '2nd string'}});
Data.Field3 = Data;
S1   = GetMD5(Data, 'Array');
if ~isequal(S1, '4fe320b06e3aaaf4ba712980d649e274')
   error([ErrID, ':Array'], 'Bad result for array: <struct>.');
end

Data = sparse([1,0,2; 0,3,0; 4, 0,0]);
S1   = GetMD5(Data, 'Array');
if ~isequal(S1, 'f157bdc9173dff169c782dd639984c82')
   error([ErrID, ':Array'], 'Bad result for array: <sparse>.');
end
fprintf('  ok\n');

% Speed test: ------------------------------------------------------------------
if doSpeed
   disp('== Test speed:');
   disp('(Short data: Slower due to overhead of calling a function!)');
   Delay = 2;
   
   for Len = [10, 100, 1000, 10000, 1e5, 1e6, 1e7, 1e8]
      [Number, Unit] = UnitPrint(Len, false);
      fprintf('  Data length: %s %s:\n', Number, Unit);
      data = uint8(fix(rand(1, Len) * 256));
      
      % Check if Java heap size is large enough:
      try
         javaWorked = true;
         x = java.security.MessageDigest.getInstance('MD5');
         x.update(data);
      catch ME
         % This happens for 100MB data, if the heap space is too small. I've
         % observed this on 32 bit versions of Matlab in the default setup
         % only.
         javaWorked = false;
         msg        = lower(ME.message);
         if any(strfind(msg, 'outofmemoryerror')) || ...
               any(strfind(msg, 'heap space'))
            fprintf('## Insufficient Java heap space for processing.\n');
            fprintf('   This is no problem of GetMD5.c, but of Java:\n');
            fprintf(2, '%s\n', msg);
         end
      end
      
      % Measure java time:
      if javaWorked
         iniTime  = cputime;
         finTime  = iniTime + Delay;
         javaLoop = 0;
         while cputime < finTime
            x        = java.security.MessageDigest.getInstance('MD5');
            x.update(data);
            javaHash = double(typecast(x.digest, 'uint8'));
            javaLoop = javaLoop + 1;
            clear('x');
         end
         javaLoopPerSec = javaLoop / (cputime - iniTime);
         [Number, Unit] = UnitPrint(javaLoopPerSec * Len, true);
         fprintf('    java: %8s %s/sec\n', Number, Unit);
      else
         javaLoopPerSec = 0;
      end
      
      % Measure Mex time:
      iniTime = cputime;
      finTime = iniTime + Delay;
      mexLoop = 0;
      while cputime < finTime
         mexHash = GetMD5(data, 'binary', 'dec');
         mexLoop = mexLoop + 1;
      end
      mexLoopPerSec  = mexLoop / (cputime - iniTime);
      [Number, Unit] = UnitPrint(mexLoopPerSec * Len, true);
      fprintf('    mex:  %8s %s/sec: %.1f times faster\n', ...
         Number, Unit, mexLoopPerSec / javaLoopPerSec);
      
      % Compare the results:
      if javaWorked && ~isequal(javaHash(:), mexHash(:))
         error([ErrID, ':Compare'], 'Different results from java and Mex.');
      end
   end
end

fprintf('\nGetMD5 passed the tests.\n');
   
% return;

% ******************************************************************************
function Out = Base64decode(In)
% Decode from base 64

% Initialize: ==================================================================
Pool = [65:90, 97:122, 48:57, 43, 47];  % [0:9, a:z, A:Z, +, /]
v8   = [128, 64, 32, 16, 8, 4, 2, 1];
v6   = [32; 16; 8; 4; 2; 1];

% Do the work: =================================================================
In          = reshape(In, 1, []);
Table       = zeros(1, 256);
Table(Pool) = 1:64;
Value       = Table(In) - 1;

X   = rem(floor(Value(ones(6, 1), :) ./ v6(:, ones(length(In), 1))), 2);
Out = v8 * reshape(X(1:fix(numel(X) / 8) * 8), 8, []);

% return;

% ******************************************************************************
function [Number, Unit] = UnitPrint(N, useMB)

if N >= 1e6 || useMB
   Number = sprintf('%.1f', N / 1e6);
   Unit   = 'MB';
elseif N >= 1e3
   Number = sprintf('%.1f', N / 1000);
   Unit   = 'kB';
else
   Number = sprintf('%g', N);
   Unit   = 'Byte';
end

% return;

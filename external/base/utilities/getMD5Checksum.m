function [md5sum] = getMD5Checksum(fileName)
% Get the md5 checksum character array for a file with the given FileName
%
% USAGE: 
%    [ok, md5, byteArray] = md5_builtin(FileName)
%
% INPUTS:
%    fileName:      The FileName to obtain the md5 hash for.
%
% OUTPUTS:
%    md5sum:        The (lower case) hex md5 checksum
% Author:
%    Thomas Pfau - Dec 2018 
%
% NOTE:
%    Based on comments in: https://stackoverflow.com/questions/415953/how-can-i-generate-an-md5-hash

if exist('uni.lu.md5.MD5','class') ~= 8
    javaaddpath([fileparts(which(mfilename)) filesep 'MD5.jar'])
    import uni.lu.md5.*;
end

md5calc = MD5();

md5sum = char(md5calc.getMD5CheckSum(fileName));
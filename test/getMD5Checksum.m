function [ok, md5, byteArray] = getMD5Checksum(fileName)
% Get the md5 checksum character array for a file with the given FileName
%
% USAGE: 
%    [ok, md5, byteArray] = md5_builtin(FileName)
%
% INPUTS:
%    fileName:      The FileName to obtain the md5 hash for.
%
% OUTPUTS:
%    ok:            Whether an md5 could be calculated (0 e.g. if the
%                   file does not exist)
%    md5:           the (lower case) hex md5 checksum
%    byteArray:     the unsigned integer byte md5
% Author:
%    Thomas Pfau - Jan 2018 
%
% NOTE:
%    Based on comments in: https://stackoverflow.com/questions/415953/how-can-i-generate-an-md5-hash

persistent Digester

if exist('java.security.MessageDigest','class') ~= 8
    import java.security.MessageDigest   
end

if exist('java.security.DigestInputStream','class') ~= 8
    import java.security.DigestInputStream   
end
if exist('java.io.FileInputStream','class') ~= 8
    import java.io.FileInputStream   
    import java.io.BufferedInputStream   
end

if isempty(Digester)
    Digester = MessageDigest.getInstance('MD5');
else
    Digester.reset();
end

try
    is = BufferedInputStream(FileInputStream(fileName));
    ds = DigestInputStream(is,Digester);
    %Just read everything....
    while(ds.read() ~= -1)        
    end
    %Convert to a unsigned byt array
    byteArray = typecast(Digester.digest(),'uint8');
    %and then to the hex checkSum.
    md5 = dec2hex(byteArray);    
    md5 = lower(reshape(md5',1,32));
    ok = 1;
catch ME
    ok = 0;
    md5 = 0;
    byteArray = [];
end
    




function OK=SaveMPS(filename, Contain)
% function OK=SaveMPS(filename, Contain);
%
% Save matrix sring Contain in file "filename"
% Return OK == 1 if saving is success
%        OK == 0 otherwise
%
% See also: BuildMPS
%
% Author: Bruno Luong
% Last update: 18/April/2008

% Default value of something goes wrong
OK=0;

% Open the file
fid=fopen(filename,'w');
if fid==-1
    return
end

% Write each line
for n=1:size(Contain,1)
    fprintf(fid,'%s\n', Contain(n,:));
end

% Close and exit
fclose(fid);
OK=1;
    

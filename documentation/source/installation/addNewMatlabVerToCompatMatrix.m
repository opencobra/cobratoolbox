function addNewMatlabVerToCompatMatrix(fileName)
% adds a new column corresponding to a matlab version as a duplicate in the
% filename given. Then one must manually edit to update compatMatrix.rst
%
% INPUT:
% fileName: full filename of compatMatrix.rst including path
% 
% USAGE:
% addNewMatlabVerToCompatMatrix('~/work/sbgCloud/code/fork-cobratoolbox/docs/source/installation/compatMatrix.rst')

% Ronan 2020

movefile(fileName,[fileName(1:end-4) '_backup.rst'])

fidold = fopen([fileName(1:end-4) '_backup.rst'],'r');

fidnew = fopen(fileName,'w');

readOn = 1;
while readOn
    tline = fgetl(fidold);
    if tline==-1
        readOn=0;
    else
        if isempty(tline)
            fprintf(fidnew,'\n');
        else
            if any(strcmp(tline(1),{'+','|'}))
                fprintf(fidnew,'%s%s%s%s\n',tline(1:20),tline(21:41),tline(21:41),tline(42:end));
            else
                fprintf(fidnew,'%s\n',tline(1:end));
            end
        end
    end
end
fclose(fidold);
fclose(fidnew);

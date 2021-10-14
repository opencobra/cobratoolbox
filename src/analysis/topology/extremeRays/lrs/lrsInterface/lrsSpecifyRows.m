function [status, result] = lrsSpecifyRows(fileNameIn)
%read the number of rows of data in the file and replace the **** with the 
%number of rows

if ~contains(fileNameIn,filesep)
    fileNameIn = [pwd filesep fileNameIn];
end

fid = fopen(fileNameIn,'r+');
if fid<0
    disp(fileNameOut)
    error('Could not open lrs output file.');
end

countRows = 0;
while 1
    tline = fgetl(fid);
    if countRows ~=0
        countRows = countRows + 1;
    end
    if strcmp(tline, 'begin')
        countRows = 1;
    elseif strcmp(tline, 'end')
        break
    elseif ~ischar(tline)
        error('Could not read lrs output file.');
    end
end
nRows = countRows -3;

%open the file and write the number of rows and columns
%The procedure to change the text in files under Linux/Unix using sed:
%Use Stream EDitor (sed) as follows:
%sed -i 's/old-text/new-text/g' input.txt
%The s is the substitute command of sed for find and replace
%It tells sed to find all occurrences of ‘old-text’ and replace with ‘new-text’ in a file named input.txt
[status, result] =  system(['sed -i ''s/\*\*\*\*\*/' int2str(nRows) '/g'' ' fileNameIn]);
if status == 1
    disp(result)
    error(['sed failed on file ' fileNameIn]);
end


end


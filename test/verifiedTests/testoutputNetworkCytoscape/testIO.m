function testIO(str)
% The COBRAToolbox: testIO.m
%
% Purpose:
%     - called from testoutputNetworkCytoscape, compares function output
% with saved file contents
% 
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017
    %load test data
    fileID = fopen(str,'r');
    testData=fscanf(fileID,'%s');
    fclose(fileID);
    %save produced data
    str2 = strrep(str,'test','data');
    fileID = fopen(str2,'r');
    Data=fscanf(fileID,'%s');
    fclose(fileID);
    %compare with produced data
    assert(isequal(testData,Data));
    %delete file
    delete(str2);
end
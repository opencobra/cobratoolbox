% The COBRAToolbox: testListBiGGModels.m
%
% Purpose:
%     - test the listBiGGModels function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testListBiGGModels'));
cd(fileDir);

prepareTest('needsWebAddress','http://bigg.ucsd.edu/api/v2/models');

% function outputs
[str] = listBiGGModels();

%With 2016b we can properly test this
cver = ver('MATLAB');

if str2num(cver.Version) >= 9.1 % after 2016b
    data = jsondecode(str);
    %Structure
    assert(isfield(data,'results'))
    assert(isfield(data,'results_count'));
    %At least ecoli core should be there.
    assert(any(ismember({data.results.bigg_id},'e_coli_core')));
else
    %Lets see, if there is at least e_coli_core in the result
    assert(~isempty(regexp(str,'"bigg_id" *: *"e_coli_core"','once')));
end

% change to old directory
cd(currentDir);

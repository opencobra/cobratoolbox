% The COBRAToolbox: testShowprogress.m
%
% Purpose:
%     - testShowprogress tests the showprogress function (0: silent, 1: textprogressbar, 2: waitbar)
%
% Author:
%     - Laurent Heirendt - March 2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testShowprogress'));
cd(fileDir);

global WAITBAR_TYPE

for m = 0:2
    WAITBAR_TYPE = m;
    fprintf('Testing show progress, mode = %i:\n', m)

    % run multiple tests with the textprogressbar (WAITBAR_TYPE = 1)
    if WAITBAR_TYPE == 1
        kend = 3;
    else
        kend = 1;
    end

    for k = 1:kend
        showprogress(0,'Testing showprogress ...');
        for i = 1:k * 10
            showprogress(i/(k * 10));
            pause(0.02)
        end
    end
    if WAITBAR_TYPE == 1
        fprintf('\n')
    end
end

% update with 1 input argument
WAITBAR_TYPE = 1;
showprogress(0);

% update with WAITBAR_TYPE=[]
WAITBAR_TYPE = [];
showprogress(0,'Testing showprogress ...');

% reset the default WAITBAR_TYPE
WAITBAR_TYPE = 1;
if ~isempty(strfind(getenv('HOME'), 'jenkins'))
    WAITBAR_TYPE = 0;
end

% return to original directory
cd(currentDir);

% The COBRAToolbox: testShowprogress.m
%
% Purpose:
%     - testShowprogress tests the showprogress function (0: silent, 1: textprogressbar, 2: waitbar)
%
% Author:
%     - Laurent Heirendt - March 2017

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools']);

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

% reset the default WAITBAR_TYPE
WAITBAR_TYPE = 1;

%return to original directory
cd(CBTDIR);

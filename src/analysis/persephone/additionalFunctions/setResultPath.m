function saveDir = setResultPath(solutionDir)
% Function for creating a common path to all flux results

% Set name
if ispc % Check if os is windows or non-windows
    topDir = char(regexp(solutionDir,'.*(?=\\)','match'));
    folder = char(regexp(solutionDir,'[^\\]+$','match'));
else
    topDir = char(regexp(solutionDir,'.*(?=\\)','match'));
    folder = char(regexp(solutionDir,'[^\/]+$','match'));
end

% Create new folder if necessary
saveDir = [topDir filesep strcat('Results_',folder)];
if ~exist(saveDir,'dir')
    disp(strcat('Create new folder:', saveDir))
    mkdir(saveDir)
end
end
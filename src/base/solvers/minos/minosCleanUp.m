function minosCleanUp(tmpPath,dataDirectory,modelName)
% CleanUp after Minos Solver.

% Files to keep
keepFiles = {'lp1.spc','lp2.spc','qrunfba','runfba'};

% Get directory listing
files = dir(tmpPath);

for k = 1:numel(files)
    name = files(k).name;

    % Skip current and parent directories
    if strcmp(name,'.') || strcmp(name,'..')
        continue
    end
    
    fullpath = fullfile(tmpPath, name);
    % If not in keep list, delete
    if ~ismember(name, keepFiles)
        delete(fullpath);       % remove file
    end
end


% remove temporary data 
tmpFileName = [dataDirectory filesep modelName  '.txt'];
try
    if exist(tmpFileName, 'file')
        delete(tmpFileName)
    end
catch
end

end
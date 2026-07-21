function minosCleanUp(tmpPath, dataDirectory, modelName)
% Cleans up after the MINOS solver by deleting temporary run files from
% `tmpPath` (other than the spec/run files to keep) and removing the
% temporary data file for the given model
%
% USAGE:
%
%    minosCleanUp(tmpPath, dataDirectory, modelName)
%
% INPUTS:
%    tmpPath:           path to the temporary MINOS working folder to
%                       clean; every file not in the keep list
%                       (`lp1.spc`, `lp2.spc`, `qrunfba`, `runfba`) is
%                       deleted
%    dataDirectory:     path to the folder containing the temporary model
%                       data file to delete
%    modelName:         name of the model, used to build the temporary
%                       data file name `<modelName>.txt` in `dataDirectory`
%

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
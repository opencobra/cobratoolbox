function DQQCleanup(tmpPath, originalDirectory)
% Performs cleanup after solving with the DQQ solver, removing temporary
% solver output and returning to the original working directory
%
% USAGE:
%
%    DQQCleanup(tmpPath, originalDirectory)
%
% INPUTS:
%    tmpPath:               path to the temporary folder containing the
%                           `results` and `MPS` subfolders, and the
%                           `fort.*`/`*.sol` output files, to be deleted
%    originalDirectory:     folder to `cd` back into once cleanup is
%                           complete

try
    % cleanup
    rmdir([tmpPath filesep 'results'], 's');
    files = dir(fullfile(tmpPath,'fort.*'));
    for k = 1:numel(files)
        if ~files(k).isdir
            delete(fullfile(tmpPath,files(k).name));
        end
    end
    files = dir(fullfile(tmpPath,'*.sol'));
    for k = 1:numel(files)
        if ~files(k).isdir
            delete(fullfile(tmpPath,files(k).name));
        end
    end
catch
end
try        % remove the temporary .mps model file
    rmdir([tmpPath filesep 'MPS'], 's')
catch
end
cd(originalDirectory);
end

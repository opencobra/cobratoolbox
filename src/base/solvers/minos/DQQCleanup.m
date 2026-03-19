function DQQCleanup(tmpPath, originalDirectory)
% perform cleanup after DQQ.
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

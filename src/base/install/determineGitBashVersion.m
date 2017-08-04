function [installedVersion, installedVersionNum] = getGitBashVersion()
% determine the version of gitBash. This function can only be run on Windows,
% and throws an error when run on a UNIX system.
%
% USAGE:
%     installGitBash()
%

    global CBTDIR
    global gitBashVersion

    % define the architecture
    archstr = computer('arch');
    archBit = archstr(end-1:end);

    % define the name of the temporary folder
    tmpFolder = '.tmp';

    if ispc
        installedVersion = [];
        installedVersionNum = 0;

        % determine the installed version
        pathVersion = getsysenvironvar('Path');
        index1 = strfind(pathVersion, [tmpFolder filesep 'PortableGit-']);
        index2 = strfind(pathVersion, [filesep 'usr' filesep 'bin']);
        catchLength = length([tmpFolder filesep 'PortableGit-']);
        index1 = index1 + catchLength;
        if  ~isempty(index2) && ~isempty(index1)
            if index2(1) > index1(1)
                installedVersion = pathVersion(index1(1):index1(1) + index2(1) - index1(1) - 1);
                installedVersionNum = str2num(strrep(installedVersion, '.', ''));
            end
        end

        % define a minimal version to be installed should there
        if isempty(installedVersion)
            installedVersion = gitBashVersion;
        end
    else
        error('gitBash can only be installed on Windows.');
    end
end

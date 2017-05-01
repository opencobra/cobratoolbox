function updateCobraToolbox(fetchAndCheckOnly)
% Checks new commits exist on the master branch of the openCOBRA repository
% and asks the user to update The COBRA Toolbox (updates the develop and master branches)
%
% USAGE:
%     updateCobraToolbox();
%
% INPUT:
%     fetchAndCheckOnly: if set to true, the repository is not updated (default: false)
%

    if nargin < 1
        fetchAndCheckOnly = false;
    end

    % check if origin is set to the opencobra URL
    [status_gitRetrieveURL, result_gitOriginURL] = system('git config --get remote.origin.url');

    [status_gitHEAD, result_gitHEAD] = system('git symbolic-ref --short -q HEAD');

    if status_gitRetrieveURL == 0 && ~isempty(strfind(result_gitOriginURL, 'opencobra/cobratoolbox')) && status_gitHEAD == 0 && length(result_gitHEAD) > 0
        % fetch all content from remote
        [status_gitFetch, result_gitFetch] = system('git fetch origin');
        if status_gitFetch ~= 0
            fprintf(result_gitFetch);
            fprintf(' > The changes of The COBRA Toolbox could not be fetched.');
        end

        % check if master branch exists
        [status_gitCheckMaster, result_gitCheckMaster] = system('git show-ref --verify --quiet refs/heads/master');

        % determine the number of commits that the local master branch is behind
        if status_gitCheckMaster == 0
            [status_gitCountMaster, result_gitCountMaster] = system('git rev-list --left-right --count master...origin/master');
            commitsAheadBehindMaster = str2num(char(split(result_gitCountMaster)));
            if commitsAheadBehindMaster(1) > 0
                fprintf(' > Your branch <master> is ahead by %d commit(s).\n', commitsAheadBehindMaster(1));
            end
        else
            status_gitCountMaster = 0;
            commitsAheadBehindMaster = [0, 0];
        end

        % check if develop branch exists
        [status_gitCheckDevelop, result_gitCheckDevelop] = system('git show-ref --verify --quiet refs/heads/develop');

        % determine the number of commits that the local develop branch is behind
        if status_gitCheckDevelop == 0
            [status_gitCountDevelop, result_gitCountDevelop] = system('git rev-list --left-right --count develop...origin/develop');
            commitsAheadBehindDevelop = str2num(char(split(result_gitCountDevelop)));
            if commitsAheadBehindDevelop(1) > 0
                fprintf(' > Your branch <develop> is ahead by %d commit(s).\n', commitsAheadBehindDevelop(1));
            end
        else
            status_gitCountDevelop = 0;
            commitsAheadBehindDevelop = [0, 0];
        end

        if commitsAheadBehindMaster(1) > 0 || commitsAheadBehindDevelop(1) > 0
            error(['The COBRA Toolbox could not be updated.']);
        end

        if status_gitCountMaster == 0 && status_gitCountDevelop == 0
            if commitsAheadBehindMaster(2) > 0 || commitsAheadBehindDevelop(2) > 0

                currentBranch = getCurrentBranchName();

                fprintf(' > There are %d new commit(s) on <master> and %d new commit(s) on <develop>. Current branch: <%s>\n', commitsAheadBehindMaster(2), commitsAheadBehindDevelop(2), currentBranch);

                % retrieve the status
                [status_gitStatus, result_gitStatus] = system('git status -s');

                if ~fetchAndCheckOnly
                    if status_gitStatus == 0 && isempty(result_gitStatus)
                        reply = input(['   -> Do you want to update The COBRA Toolbox? Y/N [Y]: '], 's');

                        if ~isempty(reply) && (strcmpi(reply, 'y') || strcmpi(reply, 'yes'))

                            branches = {'develop', 'master'};

                            % loop over develop and master
                            for k = 1:length(branches)
                                % checkout the master branch of the devTools
                                [status_gitCheckout, result_gitCheckout] = system(['git checkout -f ', branches{k}]);
                                if status_gitCheckout ~= 0
                                    fprintf(result_gitCheckout);
                                    error(['The ', branches{k},' branch of The COBRA Toolbox could not be checked out.']);
                                end

                                % pull the latest changes from the master branch
                                [status_gitPull, result_gitPull] = system(['git reset --hard origin/', branches{k}]);
                                if status_gitPull == 0
                                    fprintf([' > The COBRA Toolbox has been updated (<', branches{k}, '> branch).\n']);
                                else
                                    fprintf(result_gitPull);
                                    error(['The COBRA Toolbox could not be updated (<', branches{k}, '> branch).']);
                                end
                            end

                            % reset each submodule
                            [status_gitReset result_gitReset] = system('git submodule foreach --recursive git reset --hard');
                            if status_gitReset == 0
                                fprintf(' > The submodules have been updated (reset).\n');
                            else
                                fprintf(result_gitReset);
                                error('The submodules could not be updated (reset).');
                            end

                            % switch back to the original branch
                            [status_gitCheckoutCurrentBranch, result_gitCheckoutCurrentBranch] = system(['git checkout -f ', currentBranch]);
                            if status_gitCheckoutCurrentBranch ~= 0
                                fprintf(result_gitCheckoutCurrentBranch);
                                error(['The ', currentBranch, ' branch of The COBRA Toolbox could not be checked out.']);
                            end
                        end
                    else
                        fprintf(' > The COBRA Toolbox cannot be updated as you have unstaged files. Commits should only be made in your local and cloned fork.\n');
                    end
                else
                    fprintf(' > You can update The COBRA Toolbox by running updateCobraToolbox() (from within MATLAB).\n');
                end
            else
                fprintf(['The COBRA Toolbox is up-to-date.\n']);
            end
        else
            fprintf(result_gitCountMaster);
            error('Eventual changes of the <master> branch of The COBRA Toolbox could not be counted.');
        end
    else
        fprintf(['You cannot update your fork using updateCobraToolbox(). Please use the MATLAB.devTools (https://github.com/opencobra/MATLAB.devTools).\n']);
    end
end

function currentBranch = getCurrentBranchName()
% Retrieves the name of the current branch
%
% USAGE:
%     getCurrentBranchName();
%

    [status, currentBranch] =  system('git rev-parse --abbrev-ref HEAD');

    if status == 0
        currentBranch = currentBranch(1:end-1);
    else
        fprintf(currentBranch);
        error(['The name of the current feature (branch) could not be retrieved.']);
    end
end

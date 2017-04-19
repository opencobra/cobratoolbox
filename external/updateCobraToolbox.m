function updateCobraToolbox(check)
% Checks new commits exist on the master branch of the openCOBRA repository
% and asks the user if
%
% USAGE:
%     updateCobraToolbox();
%

    if nargin < 1
        check = false;
    end

    % fetch all content from remote
    [status_gitFetch, result_gitFetch] = system('git fetch origin');
    if status_gitFetch ~= 0
        fprintf(result_gitFetch);
        fprintf(' > The changes of The COBRA Toolbox could not be fetched.');
    end

    % determine the number of commits that the local master branch is behind
    [status_gitCount, result_gitCount] = system('git rev-list --count origin/master...HEAD');
    result_gitCount = char(result_gitCount);
    result_gitCount = result_gitCount(1:end-1);

    if status_gitCount == 0

        if check && str2num(result_gitCount) > 0
            fprintf('You can update The COBRA Toolbox by running >> updateCobraToolbox(); (from within MATLAB).\n');
        end
        if str2num(result_gitCount) > 0
            fprintf([' > There are ', result_gitCount, ' new commit(s).\n']);

            % retrieve the status
            [status_gitStatus, result_gitStatus] = system('git status -s');

            if ~check && status_gitStatus == 0 && isempty(result_gitStatus)
                reply = input(['   -> Do you want to update The COBRA Toolbox? Y/N [Y]: '], 's');

                if ~isempty(reply) && (strcmpi(reply, 'y') || strcmpi(reply, 'yes'))

                    branches = {'develop', 'master'};

                    % loop over develop and master
                    for k = 1:length(branches)
                        % checkout the master branch of the devTools
                        [status_gitCheckoutMaster, result_gitCheckoutMaster] = system(['git checkout ', branches{k}]);
                        if status_gitCheckoutMaster == 0
                            fprintf([' > The ', branches{k},' branch of The COBRA Toolbox has been checked out.']);
                        else
                            fprintf(result_gitCheckoutMaster);
                            error(['The ', branches{k},' branch of The COBRA Toolbox could not be checked out.']);
                        end

                        % pull the latest changes from the master branch
                        [status_gitPull, result_gitPull] = system(['git pull origin ', branches{k}]);
                        if status_gitPull == 0
                            fprintf(' > The COBRA Toolbox has been updated.');
                        else
                            fprintf(result_gitPull);
                            error('The COBRA Toolbox could not be updated.');
                        end
                    end
                end
            else
                fprintf(' > The COBRA Toolbox cannot be updated as you have unstaged files. Commits should only be made in your local and cloned fork.\n');
            end
        else
            fprintf(['The COBRA Toolbox is up-to-date.\n']);
        end
    else
        fprintf(result_gitCount);
        error('Eventual changes of the <master> branch of The COBRA Toolbox could not be counted.');
    end
end

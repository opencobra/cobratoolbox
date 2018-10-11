function issueConfirmationWarning(message)
% Issues a warning, which and blocks execution until confirmation by the
% user.
% USAGE:
%
%    issueConfirmationWarning(message)
%
% INPUTS:
%    message:           The message to be displayed
%
% .. Author: - Thomas Pfau Sep 2018
%
%
warnstat = warning();
finish = onCleanup(@() warning(warnstat));
% forced activation of warnings
warning('on');
warning(message);

if ~isempty(strfind(getenv('HOME'), 'jenkins')) 
    % stall only if we are NOT on jenkins! I.e. not on the CI
    str = input('If you want to continue anyways please type Y\n','s');
    if ~strcmpi(str,'y')
        error('Aborted by user');
    end
end
    
end



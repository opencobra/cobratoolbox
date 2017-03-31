function runLrs(filename, positivity, inequality, shellScript)
% Runs lrs in the command line either using a shell script or launched
% directly from Matlab.
%
% USAGE:
%
%     runLrs(filename, positivity, inequality, shellScript)
%
% INPUTS:
%    filename:      name of the file to give as input to lrs
%    positivity:    if equals to 1, then positive orthant base
%    inequality:    if equals to 1, then use two inequalities rather than a single equality
%    shellScript:   if equals to 1, then lrs is run through a bash script
%

    if isunix
        [status, result] = system('which lrs');
        if ~isempty(result)
            suffix = '';
            if positivity
                suffix = [suffix 'pos_'];
            else
                suffix = [suffix 'neg_'];
            end
            if inequality
                suffix = [suffix 'ineq'];
            else
                suffix = [suffix 'eq'];
            end

            if shellScript
                % call lrs through a bash script and wait until extreme pathways have been calculated
                systemCallText = ['sh ' pwd filesep filename '_' suffix '.sh'];
                [status, result] = system(systemCallText);
                if status == 0
                    error(['Failure to run Bash script ' pwd filesep filename '_' suffix '.sh']);
                end
            else
                % call lrs and wait until extreme pathways have been calculated
                systemCallText = ['lrs ' pwd filesep filename '_' suffix '.ine > ' pwd filesep filename '_' suffix '.ext'];
                [status, result] = system(systemCallText);
                if status == 1
                    error(['lsr failed on file ', pwd filesep filename '_' suffix '.ine']);
                end
            end
        else
            fprintf('lrs not installed or not in path\n');
        end
    else
        fprintf('non unix machines not yet supported\n');
    end
end 



function runLrsBash(filename, positivity, inequality)
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
    
            % call lrs and wait until extreme pathways have been calculated
            systemCallText = ['sh ' pwd filesep filename '_' suffix '.sh'];
            [status, result] = system(systemCallText);
            if status == 0
                error(['Failure to run Bash script ' pwd filesep filename '_' suffix '.sh']);
            end
        else
            fprintf('lrs not installed or not in path\n');
        end
    else
        fprintf('non unix machines not yet supported\n');
    end
end 

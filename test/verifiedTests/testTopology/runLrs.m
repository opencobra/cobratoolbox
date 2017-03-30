function runLrs(filename, positivity, inequality)
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
            systemCallText = ['lrs ' pwd filesep filename '_' suffix '.ine > ' pwd filesep filename '_' suffix '.ext'];
            [status, result] = system(systemCallText);
            if status == 1
                error(['lsr failed on file ', pwd filesep filename '_' suffix '.ine']);
            end
        else
            fprintf('lrs not installed or not in path\n');
        end
    else
        fprintf('non unix machines not yet supported\n');
    end
end 



function generateStructFunction(S, structName)
    fields = fieldnames(S);
    fileID = fopen([structName, '_init.m'], 'w');
    
    for i = 1:length(fields)
        val = S.(fields{i});
        if isnumeric(val)
            % Format: structName.field = [1 2 3];
            fprintf(fileID, '%s.%s = %s;\n', structName, fields{i}, mat2str(val));
        elseif ischar(val)
            % Format: structName.field = 'text';
            fprintf(fileID, '%s.%s = ''%s'';\n', structName, fields{i}, val);
        end
    end
    fclose(fileID);
end
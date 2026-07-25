function generateStructFunction(S, structName)
% Generate a `.m` script that reconstructs the numeric/char-valued fields of a struct
%
% Writes a file named `<structName>_init.m` containing one assignment
% statement per field of `S` that is numeric or char, so that running the
% generated file recreates those field values under the variable name
% `structName`.
%
% USAGE:
%
%    generateStructFunction(S, structName)
%
% INPUTS:
%    S:             struct whose numeric and char fields are written out
%    structName:    char, the variable name used in the generated
%                   assignment statements and the base name of the
%                   generated `<structName>_init.m` file
%
% NOTE:
%    Fields of `S` that are neither numeric nor char (e.g. cell, struct)
%    are silently skipped.

    fields = fieldnames(S);
    fileID = fopen([structName, '_init.m'], 'w');
    
    for i = 1:length(fields)
        val = S.(fields{i});
        if isnumeric(val)
            % Format: <structName> . <field> = [1 2 3];
            fprintf(fileID, '%s.%s = %s;\n', structName, fields{i}, mat2str(val));
        elseif ischar(val)
            % Format: <structName> . <field> = 'text';
            fprintf(fileID, '%s.%s = ''%s'';\n', structName, fields{i}, val);
        end
    end
    fclose(fileID);
end
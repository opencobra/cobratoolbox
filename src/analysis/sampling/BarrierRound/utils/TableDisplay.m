% This class is used internal for testing only
% It prints out a table (to a string) row by row.
classdef TableDisplay < handle
    properties
        format
    end
    
    methods
        function o = TableDisplay(format)
            % o = TableDisplay(format)
            % format is struct where each field is a col in the table.
            % If that field is a string,
            %    it represents the format (according to printf)
            % otherwise
            %    it is a structure with fields
            %        format 
            %        default    (default value for the field)
            %        length
            %        label
            %        type       (double or string)
            
            fields = fieldnames(format);
            for i = 1:length(fields)
                name = fields{i};
                field = format.(fields{i});
                
                % if the field contains only a string,
                % convert it into the structure format.
                if ischar(field)
                    formattmp = field;
                    field = struct;
                    field.format = formattmp;
                end
                
                % read off the type if not specified
                if ~(isfield(field, 'type'))
                    if endsWith(field.format, 's')
                        field.type = 'string';
                    else
                        field.type = 'double';
                    end
                end
                
                % set the default if not specified
                if ~(isfield(field, 'default'))
                    if strcmp(field.type, 'string')
                        field.default = '';
                    else
                        field.default = NaN;
                    end
                end
                
                % read off the length from the format if not specified
                if ~(isfield(field, 'length'))
                    matchStr = regexp(field.format, '[0-9]*', 'match', 'once');
                    if ismissing(matchStr)
                        field.length = +Inf;
                    else
                        field.length = str2double(matchStr);
                    end
                end
                
                % use the field id as label if not specified
                if ~(isfield(field, 'label'))
                    field.label = name;
                end
                
                format.(name) = field;
            end
            o.format = format;
        end
        
        function s = header(o)
            % s = o.header();
            % Print out the header of the table
            
            s = '';
            fields = fieldnames(o.format);
            total_length = 0;
            for i = 1:length(fields)
                field = o.format.(fields{i});
                if field.length == +Inf
                    f = '%s';
                    total_length = total_length + strlength(field.label);
                else
                    f = strcat('%', num2str(field.length), 's');
                    total_length = total_length + field.length + 1;
                end
                s = strcat(s, sprintf(f, field.label), ' ');
            end
            total_length = total_length - 1;
            
            s = [s, newline, repmat('-', 1, total_length), newline];
        end
        
        function s = print(o, data)
            % s = o.print(item);
            % Print out a row of the table with the data
            
            s = '';
            fields = fieldnames(o.format);
            for i = 1:length(fields)
                name = fields{i};
                if (isfield(data, name))
                    data_i = data.(name);
                else
                    data_i = o.format.(fields{i}).default;
                end
                field = o.format.(name);
                if  strcmp(field.type, 'string') && ...
                    strlength(data_i) > field.length-1
                    data_i = extractBetween(data_i, 1, field.length-1);
                    data_i = data_i{1};
                end
                s = strcat(s, sprintf(strcat('%', field.format), data_i), ' ');
            end
            
            s = [s, newline];
        end
    end
end
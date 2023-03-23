% A class for displaying a structure as a row of a table
classdef TableDisplay < handle
   properties
      % Each field contains a structure with fields
      %    label
      %	  format
      %	  length
      %	  default	(default value for the field)
      %	  type		(double or string)
      fields
      
      % Function handle for the output function
      output = @disp
   end
   
   methods
      function o = TableDisplay(varargin)
         % o = TableDisplay(name1, format1, name2, format2, ...)
         % name is the fieldname of the structure
         % format is the format string for fprintf
         
         assert(mod(nargin,2) == 0)
         for i = 1:(nargin/2)
            name = varargin{i*2 - 1};
            format = varargin{i*2};
            field = struct('format', format, 'label', name);
            
            % check the type of the field
            if endsWith(format, 's')
               field.type = 'string';
               field.default = '';
            else
               field.type = 'double';
               field.default = NaN;
            end
            
            % Set the length from the format
            matchStr = regexp(field.format, '[0-9]*', 'match', 'once');
            if ismissing(matchStr)
               field.length = +Inf;
            else
               field.length = str2double(matchStr);
            end
            
            fields.(name) = field;
         end
         o.fields = fields;
      end
      
      function header(o)
         % o.header();
         % Print out the header of the table
         
         if isempty(o.output), return; end
         s = '';
         names = fieldnames(o.fields);
         total_length = 0;
         for i = 1:length(names)
            field = o.fields.(names{i});
            if field.length == +Inf
               f = '%s ';
               total_length = total_length + strlength(field.label);
            else
               f = ['%', num2str(field.length), 's '];
               total_length = total_length + field.length + 1;
            end
            s = [s, sprintf(f, field.label)];
         end
         total_length = total_length - 1;
         
         s = [s, newline, repmat('-', 1, total_length)];
         o.output(s);
      end
      
      function row(o, data)
         % o.row(item);
         % Print out a row of the table with the data
         
         if isempty(o.output), return; end
         s = '';
         names = fieldnames(o.fields);
         for i = 1:length(names)
            name = names{i};
            if (isfield(data, name))
               data_i = data.(name);
            else
               data_i = o.fields.(name).default;
            end
            field = o.fields.(name);
            if  strcmp(field.type, 'string') && ...
                  strlength(data_i) > field.length-1
               data_i = extractBetween(data_i, 1, field.length-1);
               data_i = data_i{1};
            end
            s = [s, sprintf(['%', field.format], data_i), ' '];
         end
         
         o.output(s);
      end
   end
end

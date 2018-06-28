classdef JSON < handle
    % v = JSON.parse(jsonString) converts a JSON string to a MATLAB value.
    %
    % This started out as a recursive descent parser, but JSON is so simple
    % that most of the parser collapsed out.
    %
    % In the service of speed, simplicity, and laziness, this code is NOT a
    % validator. Its purpose is to convert correct JSON strings to MATLAB
    % values. It does not reject all malformed JSON.
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Access = private)
        json % the string
        index % position in the string
    end
    
    
    methods (Access = private)
        
        function this = JSON(JSONstring)
            this.json = JSONstring;
            this.index = 1;
        end
        
        function value = getValue(this)
            % get the next value in the string
            [token,tokenType] = this.getNextToken;
            value = token;
            
            if strcmp(tokenType,'Special')
                if strcmp(token,'{')
                    value = this.getObject;
                elseif strcmp(token,'[')
                    value = this.getArray;
                end
            end
        end
        
        function array = getArray(this)
            % an array is [ value, ... ]
            array = {};
            
            value = this.getValue;
            while ~strcmp(value,']')
                % got a value
                array{end+1} = value; %#ok<AGROW> final size is unknowable
                
                % followed by a comma or a "]"
                value = this.getValue;
                
                if strcmp(value,',')
                    value = this.getValue;
                elseif strcmp(value,']')
                    continue
                else
                    error('JSON parser requires commas between array elements');
                end
            end
            
            % Arrays of all numbers are turned into numeric arrays
            fcn = @(x) isnumeric(x) && ~isscalar(x);
            if all(cellfun(fcn,array))
                array = [array{:}];
            end
        end
        
        function obj = getObject(this)
            % an object is { string : value, ... }
            obj = struct;
            value = this.getValue;
            while ~strcmp(value,'}')
                
                fieldname = value;
                % make sure its a valid structure field name
                fieldname = strrep(fieldname,':','_');
                fieldname = strrep(fieldname,'-','_');
                % fix for field names that start with numbers
                % Thanks to Guy Ziv!
                fieldname = regexprep(fieldname,'(^\d)','s$1');
                
                % check for colon
                value = this.getValue;
                if ~strcmp(value,':')
                    error('JSON parser requires colons between object names and values');
                end
                
                % get the value
                value = this.getValue;
                obj.(fieldname) = value;
                
                value = this.getValue;
                if strcmp(value,',')
                    value = this.getValue;
                elseif strcmp(value,'}')
                    continue
                else
                    error('JSON parser requires commas between object elements');
                end
            end
            
        end
        
        function [token,tokenType] = getNextToken(this)
            % get whatever is next in the string
            
            % skip whitespace
            ch = this.json(this.index);
            while isWhitespace(ch)
                this.index = this.index + 1;
                ch = this.json(this.index);
            end
            
            % is it a special character?
            if isSpecial(ch)
                token = ch;
                tokenType = 'Special';
                this.index = this.index + 1;
                return
            end
            
            % is it one of the three keywords?
            switch(ch)
                case 't'
                    match(this,'true');
                    token = true;
                    tokenType = 'Logical';
                    return;
                case 'f'
                    match(this,'false');
                    tokenType = 'Logical';
                    token = false;
                    return;
                case 'n'
                    match(this,'null');
                    tokenType = 'Null';
                    token = [];
                    return;
            end
            
            % is it a string?
            if(ch == '"')
                token = getString(this);
                tokenType = 'String';
                return;
            end
            
            % well, then it better be a number
            token = getNumber(this);
            tokenType = 'Number';
            
            function match(this,str)
                % find and consume exactly str at the current location of error
                n = length(str);
                range = this.index:(this.index + n - 1);
                found = this.json(range);
                if strcmp(str,found)
                    this.index = this.index + n;
                else
                    error('The JSON parser expected "%s" but found %s',str,found)
                end
            end
            
            function tf = isWhitespace(aChar)
                % space, carrage return, linefeed, horizontal tab
                tf = aChar == 32 || aChar == 10 || aChar == 13 || aChar == 9;
            end
            
            function tf = isSpecial(aChar)
                % the special characters in the JSON "language"
                tf = aChar == '{' || aChar == '}' || aChar == '['|| aChar == ']'|| aChar == ':' || aChar == ',';
            end
                     
            function string = getString(this)
                first = this.index + 1;
                last = first;
                str = this.json;
                
                ch = str(last);
                while ch ~= '"'
                    if(ch == '\\') %#ok<STCMP> We KNOW both are single chars
                        last = last + 2;
                    else
                        last = last + 1;
                    end
                    ch = str(last);
                end
                
                % get the string without it's quotes
                string = str(first:(last-1));
                this.index = last + 1; % skip the trailing "
            end
            
            function number = getNumber(this)
                first = this.index;
                last = first;
                ch = charAt(this,first);
                
                if(ch == '-')
                    last = last + 1;
                    ch = charAt(this,last);
                end
                
                while isDigit(ch)
                    last = last + 1;
                    ch = charAt(this,last);
                end
                
                if(ch == '.')
                    last = last + 1;
                    ch = charAt(this,last);
                    while isDigit(ch)
                        last = last + 1;
                        ch = charAt(this,last);
                    end
                end
                
                if ch == 'e' || ch == 'E'
                    last = last + 1;
                    ch = charAt(this,last);
                    if ismember(ch,'+-')
                        last = last + 1;
                        ch = charAt(this,last);
                    end
                    while isDigit(ch)
                        last = last + 1;
                        ch = charAt(this,last);
                    end
                end
                
                % pull out the string
                str = this.json(first:(last-1));
                number = str2double(str);
                
                % move past it
                this.index = last;
                
                % helper functions
                function char = charAt(this,position)
                    if(position > length(this.json))
                        char = 0;
                    else
                        char = this.json(position);
                    end
                end
                
                function tf = isDigit(aChar)
                    tf = aChar > 47 && aChar < 58;
                end
                
            end
            
        end
        
    end
    
    methods(Static)
        % This is the one method you should call from outside the file.
        % JSON.parse(string)... that should be familiar to Javascrpt
        % programmers
        function value = parse(JSONstring)
            jsonObject = JSON(JSONstring);
            value = jsonObject.getValue;
        end
    end
    
end
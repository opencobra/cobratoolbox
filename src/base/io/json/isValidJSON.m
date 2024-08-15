function [isValid] = isValidJSON(fileName)
% This function checks if a JSON file is valid or not.
% A JSON file is considered valid if it can be decoded into a structure.
%
% USAGE:
%
%    [isValid] = isValidJSON(fileName)
%
% INPUT:
%    fileName:        A string containing the file name of the JSON file
%
% OUTPUT:
%    isValid:         A logical variable: 1 if JSON file is valid
%                                         0 if JSON file is invalid
%
% EXAMPLE:
%
%    [isValid] = isValidJSON('toyModel_output.json')
%
% .. Author: - Farid Zare  2024/08/15
%

% Check if the file name ends with '.json'
[~, ~, ext] = fileparts(fileName);
if ~strcmpi(ext, '.json')
    fileName = [fileName, '.json'];
end

% Check if the file exists
if ~isfile(fileName)
    error('File does not exist: %s', fileName);
end

% It is a valid JSON if it can be decoded into a structure
try
    % Read the JSON file into a string
    jsonData = fileread(fileName);

    % Try to decode the JSON data
    jsondecode(jsonData);

    % If no error, the JSON is valid
    isValid = true;
catch
    % If any error in decoding set the output as false
    isValid = false;
end
end

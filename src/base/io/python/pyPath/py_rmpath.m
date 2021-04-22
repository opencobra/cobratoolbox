function new_py_path = py_rmpath(directory, MATLAB_too)
%Add directory to import search path for the instance of 
%the Python interpreter currently controlled by MATLAB
%
%EXAMPLE USAGE
% >> py_rmpath('C:\Documents\ERPResults')
%
%REQUIRED INPUTS
% directory      - Directory to remove from the Python import search path
% MATLAB_too     - If true (or 1), directory will also be added to the
%                  MATLAB path. {default: false}
%
%OPTIONAL OUTPUT
% new_py_path    - a cell array of the directories on the updated
%                  Python path; to get this output without updating the 
%                  Python path, use an empty string as the input:
%                  py_path = py_addpath('')
%
%VERSION DATE: 13 April 2021
%AUTHOR: Ronan Fleming, based on py_addpath by Eric Fields
%
%NOTE: This function is provided "as is" and any express or implied warranties 
%are disclaimed.

%This code is free and open source software made available under the 3-clause BSD license.

    %check input
    if ~ischar(directory)
        error('Input must be a string')
    elseif ~exist(directory, 'dir') && ~isempty(directory)
        error('%s is not a valid directory', directory)
    end
    
    %Convert relative path to absolute path
    if ~isempty(directory)
        directory = char(py.os.path.abspath(directory));
    end
    
    %add directory to Python path if already present
    if any(strcmp(get_py_path(), directory))
        py_path = py.sys.path;
        py_path.remove(directory);
    end
    
    %remove directory to MATLAB path if requested
    if nargin>1 && MATLAB_too
        rnpath(directory);
    end
    
    %optionally return ammended path.sys as cell array
    if nargout
        new_py_path = get_py_path();
    end
    
end
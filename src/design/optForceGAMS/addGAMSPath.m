function added = addGAMSPath(gamsPath)
%% DESCRIPTION
%This function add to MATLAB path the folder where GAMS in located 

%% INPUTS
% path              Type: string
%                   Description: path of GAMS is located
%                   Example: gamsPath='C:\GAMS\win64\24.8';
%                   (this is the default location in windows for GAMS)

%% OUTPUTS
% added             Type: double
%                   Description: describe if the path was correcly added
%                   (added = 1) or not (added = 0)

%% CODE
%input handling 
if nargin <1
    error('GAMS path not specified. Please provide a path'); 
end
    
addpath(gamsPath); 
[~, values] = fileattrib(which('pathdef.m'));
if values.UserWrite
    savepath
end

fullGamsPath=which('gams');
if ~isempty(fullGamsPath)
    fprintf('GAMS path was added to MATLABPATH\n');
    added=1;
else
    fprintf('GAMS path was not added to MATLABPATH. Please verify that you entered the correct path\n')
    added=0;
end

end


function addpath_recurse(directory,ignore)
%ADDPATH_RECURSE  Adds the specified directory and its subfolders
%   addpath_recurse(directory,ignore)
%
%   Descriptions of Input Variables:
%   directory: full path to the starting directory.  All subdirectories
%       will be added to the path as well.  If this is not specified, then
%       the current directory will be used.
%   ignore: a cell array of strings specifying directory names to ignore.
%       This will cause all subdirectories beneath this directory to be
%       ignored as well.
%
%   Descriptions of Output Variables:
%   none
%
%   Example(s):
%   >> addpath_recurse(pwd,{'.svn'}); %adds the current directory and all
%   subdirectories, ignoring the SVN-generated .svn directories
%
%   See also: rdir

% Author: Anthony Kendall
% Contact: anthony [dot] kendall [at] gmail [dot] com
% Created: 2008-08-08

if nargin==0
    directory = pwd;
    ignore={''};
elseif nargin==1
    ignore={''};
end

%Add the current directory to the path
assert(exist(directory,'dir')>0,'The input directory does not exist');
addpath(directory);

%Get list of directories beneath the specified directory
currDir = dir([directory,filesep,'*']);

%Loop through the directory list and recursively call this function
for m = 1:length(currDir)
    if ~any(strcmp(currDir(m).name,{'.','..',ignore{:}})) && currDir(m).isdir
        addpath_recurse([directory,filesep,currDir(m).name],ignore);
    end
end

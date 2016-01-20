function generateDoc(pathname, graph)
%generateDoc uses m2html to create a set of html docs 
%in the cba toolbox and place them in a directory called 'docs'.
%
% generateDoc(pathname, graph)
%
%OPTIONAL INPUTS
% pathname  Path to folder to generate documents for
% graph     Generate function dependcy graph (Default = off) Set to 'on' 
%
%If the directory 'docs' exists, the user will be prompted 
%for notice that the contents of the directory will be 
%replaced with a new set of generated docs.
%
%This routine will exit if the user does not agree with this.
%If the directory 'docs' does not exist, then it will be created.
% 
%generateDoc uses m2html, therefore m2html must be in the path.
%m2html will be located in the cba toolbox and added to the path 
%if not found on the path.
%
% Wing Choi 1/17/08
% Richard Que (8/06/2010)

saveDir = pwd;
%BUGFIX: Updated to work on Unix systems in addition to MS Windows
%Do not remove this unless you've validated that your changes function
%on Mac OS X and GNU/Linux
if filesep == '/'
  cbaDir = filesep;
else
  cbaDir = '';
end
dN = '';

%locate the cbaToolbox from where matlab finds generateDoc
mFilePath = mfilename('fullpath');
cbaDir = mFilePath(1:end-length(mfilename)-1);
cd(cbaDir);

%if pathname was not an input argument
currentDir = pwd;
if(nargin<1)||isempty(pathname)
    % parse out the current dir name, not the entire path
    display (' ');
    display(strcat('Creating html docs for --> ' , ' ' , currentDir));
    reply = input('is this ok? y/n [n]: ', 's');
    if ((isempty(reply)) || (reply ~= 'y'))
        cd(saveDir);
        return;
    end
else
    cbaDir = pathname;
end

%Get Directory Name
remain = currentDir;
while true
    [str, remain] = strtok(remain,filesep);
    if isempty(str), break; end
    dirName = str;
end

if (exist('m2html','file') ~= 2)
    disp('m2html not found, adding it to path');
    addpath(strcat(cbaDir,filesep,'external',filesep,'m2html')); %changed to reflect new folder structure
end

if (isdir('docs'))
    display ('The docs directory already exists')
    display ('I will remove the existing docs directory')
    display ('and replace its entire contents with newly')
    display ('generated html docs.')
    display (' ');
    reply = input('Do you want to replace the contents of the directory? y/n [n]: ', 's');
    if ((isempty(reply)) || (reply ~= 'y'))
        cd(saveDir);
        return;
    end
end

preDirName = cbaDir(1:end-length(dirName));
if(nargin<2)||~strcmp(graph, 'on')
    dirNames = getDir(cbaDir,{'.svn','obsolete','docs','private','@template','toolboxes','internal','testing'});  
    for i=1:length(dirNames), dirNames{i} = strrep(dirNames{i},preDirName,''); end
    cd ..;
    m2html('mfiles',dirNames,'htmldir',strcat(dirName,filesep,'docs'),'recursive','off', 'global','on','template','frame', 'index','menu', 'globalHypertextLinks', 'on');
else
    dirNames = getDir(cbaDir,{'.svn','obsolete','docs','private','@template','internal','toolboxes','testing'});
    for i=1:length(dirNames), dirNames{i} = strrep(dirNames{i},preDirName,''); end
% go up one dir
    cd ..;
% call m2html
    m2html('mfiles', dirNames, 'htmldir',strcat(dirName,filesep,'docs'),'recursive','off', 'global','on','template','frame', 'index','menu', 'globalHypertextLinks', 'on', 'graph', 'on');
end
% cd back to saveDir again
cd(saveDir);

function directories = getDir(directory,ignore)
%Get list of directories beneath the specified directory
directories = {directory};
currDir = dir([directory,filesep,'*']);
currDir = {currDir([currDir.isdir]).name};
currDir =  currDir(~ismember(currDir,{'.','..',ignore{:}}));

%Loop through the directory list and recursively call this function
for i = 1:length(currDir)
    tmp = getDir([directory,filesep,currDir{i}],ignore);
    tmp = columnVector(tmp);
    directories = [directories; tmp(:)];
end

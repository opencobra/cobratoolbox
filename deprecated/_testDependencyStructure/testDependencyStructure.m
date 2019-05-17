function out=testDependencyStructure()
out=0;

which('initCobraToolbox.m')
global CBTDIR

%excluded folders and subfolders
exclusionFolderList={'external'};

exclusion_list

function Build_Dependency_Map(root_dir, exclusion_list);
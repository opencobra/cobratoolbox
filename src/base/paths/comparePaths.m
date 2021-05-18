function [common,system_not_matlab,matlab_not_system] = comparePaths(NAME,printLevel)
%compare the system and matlab paths for a given NAME environment variable
%
% INPUT
% NAME          environment variable, e.g., PATH or LD_LIBRARY_PATH
% printLevel
%
% OUTPUT
% common                cell array
% system_not_matlab
% matlab_not_system
%
% USAGE example
% [common,system_not_matlab,matlab_not_system] = comparePaths('LD_LIBRARY_PATH',1);

if ~exist('printLevel','var')
    printLevel=0;
end

if strcmp(NAME,'PYTHON')
    matlab_split = get_py_path();
    [success,system_response]=system('python -c "import sys; print(sys.path)"');
    system_split = split(system_response,',');
    system_split{1}=strtrim(system_split{1});
    system_split{1}=strrep(system_split{1},'[','');
    system_split{end}=strtrim(system_split{end});
    system_split{end}=strrep(system_split{end},']','');
    system_split{end}=strrep(system_split{end},'''','');
    for i=1:length(system_split)
        system_split{i}=strrep(system_split{i},' ','');
        system_split{i}=strrep(system_split{i},'''','');
    end
else
    [success,system_response]=system(['echo $' NAME]);
    system_split = split(system_response,':');
    for i=1:length(system_split)
        system_split{i} = strtrim(system_split{i});
    end
    
    matlab_response = getenv(NAME);
    matlab_split = split(matlab_response,':');
    for i=1:length(matlab_split)
        matlab_split{i} = strtrim(matlab_split{i});
    end
end

if printLevel>1
    disp(system_split)
    disp(matlab_split)
end

common = intersect(system_split,matlab_split);
if printLevel>1
    fprintf('%s\n',[NAME ' common to system and matlab'])
    for i=1:length(common)
        fprintf('%s\n',common{i})
    end
end

system_not_matlab = setdiff(system_split,matlab_split);
if printLevel>0
    if isempty(system_not_matlab)
        fprintf('%s\n',['No ' NAME ' in system but not matlab'])
    else
        fprintf('\n%s\n',[NAME ' in system but not matlab'])
        for i=1:length(system_not_matlab)
            fprintf('%s\n',system_not_matlab{i})
        end
    end
end

matlab_not_system = setdiff(matlab_split,system_split);
if printLevel>0
    if isempty(matlab_not_system)
        fprintf('%s\n',['No ' NAME ' in matlab but not system'])
    else
        fprintf('\n%s\n',[NAME ' in matlab but not system'])
        for i=1:length(matlab_not_system)
            fprintf('%s\n',matlab_not_system{i})
        end
    end
end



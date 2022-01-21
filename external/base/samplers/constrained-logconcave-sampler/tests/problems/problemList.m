function l = problemList(options)
if ~exist('options', 'var'), options = []; end
problems = {};

% Read files with size within the range (bytes)
default.fileSizeLimit = [0 1000000];

% Ignore the following files in default to speed up the test
% In particular, we skip pilot87, fit1p, fit2p because it will
% break MATLAB lp solver
% all string are regex
default.ignoreProblems = ...
    {'netlib/pilot87$', 'netlib/fit1p$', 'netlib/fit2p$', 'netlib/qap15$', ...
    'netlib/pds_20$', 'netlib/qap12$', 'netlib/osa_60$', 'netlib/cre_b$', ...
    'netlib/cre_d$','netlib/ken_18$','netlib/dfl001$','netlib/pds_10$', ...
    'basic/random_dense@\d\d\d\d', 'basic/random_sparse@\d\d\d\d'};

default.folders = {'basic', 'metabolic', 'netlib'};

default.generateDimensions = [10 100 1000 10000];

o = setDefault(options, default); % add the default options if not user-specified

curFolder = fileparts(mfilename('fullpath'));

for j = 1:length(o.folders)
    files = dir(fullfile(curFolder, o.folders{j}, '*.m*'));
    for k = 1:length(files)
        file = fullfile(files(k).folder, files(k).name);
        [~,name,ext] = fileparts(file);
        name = [o.folders{j} '/' name];
        
        if strcmp(ext, '.mat') == 1
            s = dir(file);
            if (s.bytes < o.fileSizeLimit(1) || s.bytes > o.fileSizeLimit(2))
                continue;
            end
            problems{end+1} = name;
        elseif strcmp(ext, '.m') == 1
            for l = 1:length(o.generateDimensions)
                problems{end+1} = [name '@' num2str(o.generateDimensions(l))];
            end
        end
    end
end

% removed ignored problems
l = {};
for j = 1:length(problems)
    name = problems{j};
    ignored = 0;
    for k = 1:length(o.ignoreProblems)
        if ~isempty(regexp(name, o.ignoreProblems{k}))
            ignored = 1;
            break;
        end
    end
    if ignored == 0
        l{end+1} = name;
    end
end
end

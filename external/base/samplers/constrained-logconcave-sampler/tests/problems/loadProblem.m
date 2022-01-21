function P = loadProblem(name)
path_size = split(name,'@');
path_folders = split(path_size{1},'/');
curFolder = fileparts(mfilename('fullpath'));
path = fullfile(curFolder, path_folders{:});

% check if the file exists as a mat
if exist([path '.mat'], 'file') && length(path_size) == 1
    load([path '.mat'], 'problem');
    P = Problem;
    if isfield(problem,'Aeq'), P.Aeq = problem.Aeq; end
    if isfield(problem,'beq'), P.beq = problem.beq; end
    if isfield(problem,'Aineq'), P.Aineq = problem.Aineq; end
    if isfield(problem,'bineq'), P.bineq = problem.bineq; end
    if isfield(problem,'ub'), P.ub = problem.ub; end
    if isfield(problem,'lb'), P.lb = problem.lb; end
    if isfield(problem,'df'), P.df = problem.df; end
    if isfield(problem,'ddf'), P.ddf = problem.ddf; end
    if isfield(problem,'dddf'), P.dddf = problem.dddf; end
elseif exist([path '.m'], 'file') && length(path_size) == 2
    [folder,name] = fileparts(path);
    prevDir = pwd;
    cd(folder);
    h = str2func(['@' name]);
    cd(prevDir);
    
    scurr = rng;
    rng(123456); % fix the seed for random generator
    P = h(str2double(path_size{2}));
    rng(scurr);
else
    error(['Problem ' name ' does not exists']);
end

if isempty(P.df)
    scurr = rng;
    rng(123456); % fix the seed for random generator
    P.df = randn(P.n,1);
    rng(scurr);
end

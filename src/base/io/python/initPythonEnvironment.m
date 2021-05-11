function [pyEnvironment,pySearchPath]=initPythonEnvironment(environmentName,reset)
%initialise an interface to a Python environment using CPython3/2 or Anaconda
%
% OPTIONAL INPUT
% environmentName    String denoting the Python environment to establish an interface to.
%                    Fixed options: 'CPython3' (default), 'CPython2', 'base' (Anaconda)
%                    Variable Anaconda options: environmentName as in anaconda3/env/environmentName
%                    See https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html
%
% reset     {(0),1}, reset with terminate(pyenv) if true
%
% OUTPUT
% pyEnvironment     Python environment returned by pyenv
% pySearchPath      Python search path (for loading packages)
%
% USAGE
% [pythonEnvironment,pythonPath]=initPythonEnvironment('base',1)
% or
% [pythonEnvironment,pythonPath]=initPythonEnvironment('CPython',1)

% Author: Ronan M.T. Fleming 2021

if ~exist('environmentName','var')
    environmentName = 'CPython3';
end
if ~exist('reset','var')
    reset = 0;
end

%remove any preexisting Anaconda custom environment paths within matlab
matlab_PATH = getenv('PATH');
matlab_PATH = split(matlab_PATH,':');
matlab_PATH = matlab_PATH(~contains(matlab_PATH,{['anaconda3' filesep 'envs'],'$PATH'}));
matlab_PATH = join(matlab_PATH,':');
setenv('PATH',matlab_PATH{1});

matlab_PATH = getenv('LD_LIBRARY_PATH');
matlab_PATH = split(matlab_PATH,':');
matlab_PATH = matlab_PATH(~contains(matlab_PATH,{['anaconda3' filesep 'envs'],'$LD_LIBRARY_PATH'}) | contains(matlab_PATH,{'condabin','$LD_LIBRARY_PATH'}));
matlab_PATH = join(matlab_PATH,':');
setenv('LD_LIBRARY_PATH',matlab_PATH{1});
            
if reset
    try
        terminate(pyenv)
    catch
        warning('pyenv not initialised, no need to reset')
    end


end

switch environmentName
    case 'CPython3'
        [success,response]=system('which python3');
    case 'CPython2'
        [success,response]=system('which python2');
    otherwise
        %Anaconda
        [successAnaconda,responseAnaconda]=system('which anaconda');
        if successAnaconda~=0
            error('Could not find anaconda on the matlab-system path')
        end
        [successAnaconda,responseAnaconda]=system('which conda');
        if successAnaconda~=0
            error('Could not find conda on the matlab-system path')
        end
        %conda env list
        [env_names, env_paths,active_path] = conda.getenv;%from condalab
        if ~any(contains(env_names(3:end),environmentName))
            disp([environmentName ' not a reconised anaconda environment.'])
            disp('Recognised anaconda environments are:')
            disp(env_names)
            disp(['See https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html'])
            disp('Example of how to create a conda environment:')
            disp('conda create -n dGPredictor python=3.8')
            disp('conda install -n  dGPredictor -c conda-forge rdkit')
            disp('conda install -n  dGPredictor -c conda-forge pandas')
            disp('conda install -n  dGPredictor -c conda-forge scikit-learn')
            disp('conda install -n  dGPredictor -c conda-forge streamlit')
            disp('conda activate dGPredictor')
            
            
            %conda install -n  dGPredictor -c conda-forge future
            %conda install -n  dGPredictor -c conda-forge streamlit==0.55.2
            disp('Attempting to proceed with base anaconda environment')
            environmentName='base';
        end
        
        if strcmp(env_names{active_path},environmentName)
            disp([environmentName ' anaconda environment is already active.'])
        else
            conda.setenv(environmentName)
            disp([environmentName ' anaconda environment activated.'])
        end
        %now get correct python path to the current environment
        [success,response]=system('which python3');
end
pythonExePath=strtrim(response);
if isempty(pythonExePath)
    disp('Run the following command(s) in a terminal and then run initPythonEnvironment again:')
    switch environmentName
        case 'CPython3'
            %Cpython
            disp('sudo apt-get install python3 python3-all-dev')
        case 'CPython2'
            %Cpython
            disp('sudo apt-get install python2 python2-all-dev')
        otherwise
            
    end
end
if success~=0
    error('Could not find python with system command: which python*. Follow the instructions above.')
end

switch environmentName
    case 'CPython3'
        % The reverence CPython installation version needs to be compatible with MATLAB
        [success,response]=system('python3 --version');
        if ~(contains(response,'3.6') || contains(response,'3.7') || contains(response,'3.8'))
            %MATLAB >=R2020b is compatible with python 2.7,3.6,3.7,3.8
            disp(response)
            error('MATLAB >=R2020b is only stated to be compatible with Python 3.6,3.7,3.8')
        end
        
        try
            pyEnvironment = pyenv('ExecutionMode','OutOfProcess','Version',pythonExePath);
        catch
            %try to terminate Python environment if its allready loaded
            terminate(pyenv)
            %try to initialise Python environment
            pyEnvironment = pyenv('ExecutionMode','OutOfProcess','Version',pythonExePath);
        end
        %Remove any paths from the matlab-python environment that are not in the system python environment to avoid dependency conflicts
        % between the Anaconda environment and the python libraries provided by matlab
        printLevel=0;
        [common,system_not_matlab,matlab_not_system] = comparePaths('PYTHON',printLevel);
        bool = contains(matlab_not_system,'interprocess/bin/glnxa64/pycli');
        %only remove the matlab added paths containing interprocess/bin/glnxa64/pycli
        matlab_not_system=matlab_not_system(bool);
        for i=1:length(matlab_not_system)
            %new_py_path = py_rmpath('/usr/local/bin/MATLAB/R2021a/interprocess/bin/glnxa64/pycli', 0);
            pySearchPath = py_rmpath(matlab_not_system{i}, 0);
        end
    case 'CPython2'
        % The reverence CPython installation version needs to be compatible with MATLAB
        [success,response]=system('python2 --version');
        if ~contains(response,'2.7')
            %MATLAB >=R2020b is compatible with python 2.7,3.6,3.7,3.8
            disp(response)
            error('MATLAB >=R2020b is only stated to be compatible with Python 2.7')
        end
        
        try
            pyEnvironment = pyenv('ExecutionMode','OutOfProcess','Version',pythonExePath);
        catch
            %try to terminate Python environment if its allready loaded
            terminate(pyenv)
            %try to initialise Python environment
            pyEnvironment = pyenv('ExecutionMode','OutOfProcess','Version',pythonExePath);
        end
        %Remove any paths from the matlab-python environment that are not in the system python environment to avoid dependency conflicts
        % between the Anaconda environment and the python libraries provided by matlab
        printLevel=0;
        [common,system_not_matlab,matlab_not_system] = comparePaths('PYTHON',printLevel);
        bool = contains(matlab_not_system,'interprocess/bin/glnxa64/pycli');
        %only remove the matlab added paths containing interprocess/bin/glnxa64/pycli
        matlab_not_system=matlab_not_system(bool);
        for i=1:length(matlab_not_system)
            %new_py_path = py_rmpath('/usr/local/bin/MATLAB/R2021a/interprocess/bin/glnxa64/pycli', 0);
            pySearchPath = py_rmpath(matlab_not_system{i}, 0);
        end
        
    otherwise
        try
            pyEnvironment = pyenv("ExecutionMode","OutOfProcess","Version", pythonExePath);
        catch
            %try to terminate Python environment if its allready loaded
            terminate(pyenv)
            %try to initialise Python environment
            pyEnvironment = pyenv("ExecutionMode","OutOfProcess","Version", pythonExePath);
        end
        %Remove any paths from the matlab-python environment that are not in the system python environment to avoid dependency conflicts
        % between the Anaconda environment and the python libraries provided by matlab
        printLevel=0;
        [common,system_not_matlab,matlab_not_system] = comparePaths('PYTHON',printLevel);
        bool = contains(matlab_not_system,'interprocess/bin/glnxa64/pycli');
        %only remove the matlab added paths containing interprocess/bin/glnxa64/pycli
        matlab_not_system=matlab_not_system(bool);
        for i=1:length(matlab_not_system)
            %new_py_path = py_rmpath('/usr/local/bin/MATLAB/R2021a/interprocess/bin/glnxa64/pycli', 0);
            pySearchPath = py_rmpath(matlab_not_system{i}, 0);
        end
        
        [success,anaconda_PATH]=system('which anaconda');
        anaconda_PATH=strtrim(anaconda_PATH);
        anaconda_PATH=strrep(anaconda_PATH,'3/bin/anaconda','3');
        anacondaCustomEnv_PATH = [anaconda_PATH filesep 'env' environmentName filesep 'bin'];
        matlab_PATH = getenv('PATH');
        setenv('PATH',[anacondaCustomEnv_PATH ':' matlab_PATH]);
        
        anacondaCustomEnv_LD_LIBRARY_PATH = [anaconda_PATH filesep 'envs' filesep environmentName filesep 'lib'];
        matlab_LD_LIBRARY_PATH = getenv('LD_LIBRARY_PATH');
        setenv('LD_LIBRARY_PATH',[anacondaCustomEnv_LD_LIBRARY_PATH ':' matlab_LD_LIBRARY_PATH]);
end

if ~isequal(pyEnvironment.ExecutionMode,'OutOfProcess')
    error('dGPredictor requires Python to be called OutOfProcess\n','Restart MATLAB and run the following from the command line: \n', 'pyenv("ExecutionMode","OutOfProcess");')
end
if isequal(pyEnvironment.Library,'')
    error('make sure to add python development libraries: sudo apt-get install python3-all-dev, then run init_dGPredictor again.')
end
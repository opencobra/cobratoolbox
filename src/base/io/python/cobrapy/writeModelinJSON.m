function [success,pymodel] = writeModelinJSON(model,COBRApyPath)
%write out a model in JSON format using COBRApy
%
% INPUT
% model
%
% OPTIONAL INPUT
% dGPredictorPath   path to the folder containg a git clone of https://github.com/maranasgroup/dGPredictor
%                   path must be the full absolute path without ~/
% cacheName         fileName of cache to load (if it exists) or save to (if it does not exist)
%
% OUTPUT
% success = 1,0
%
% EXTERNAL DEPENDENCIES
% Python, see:
% [pyEnvironment,pySearchPath]=initPythonEnvironment(environmentName,reset)
%
% rdkit, e.g., installed in an Anaconda environment
% https://www.rdkit.org
% https://www.rdkit.org/docs/Install.html#introduction-to-anaconda
%
% COBRApy
% https://github.com/opencobra/cobrapy
% Install COBRApy using this command in a terminal:
% conda install -c bioconda cobra

% Author Ronan M.T. Fleming 2021

if ~exist('dGPredictorPath','var') || isempty(dGPredictorPath)
    %must be the full absolute path without ~/
    COBRApyPath='/home/rfleming/work/sbgCloud/code/cobrapy';
end

classModel = class(model);
switch classModel
    case 'struct'
        fileName=[pwd filesep 'tmp.xml'];
        %write out the model in SBML format
        writeCbModel(model, 'format','sbml','fileName',fileName)
    case 'char'
        fileName = model;
end

% try
%     pythonPath = py_addpath(COBRApyPath);
%     cobrapy = py.importlib.import_module('bioconda.cobrapy');
%     py.importlib.reload(cobrapy); %uncomment if edits to decompose_groups.py made since the last load
% catch e
%     disp(e.message)
    current_py_path = get_py_path();
    [pyEnvironment,pySearchPath]=initPythonEnvironment('base',1);
    pythonPath = py_addpath(COBRApyPath);
    cobrapy = py.importlib.import_module('bioconda.cobra');
% end


%read in the model into COBRApy
try
    pymodel = cobrapy.io.sbml.read_sbml_model(str(fileName));
    success=1;
catch e
    disp(e.message)
end
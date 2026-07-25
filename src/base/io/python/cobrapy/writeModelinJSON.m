function [success, pymodel] = writeModelinJSON(model, COBRApyPath)
% Write out a model in JSON format using COBRApy
%
% USAGE:
%
%    [success, pymodel] = writeModelinJSON(model, COBRApyPath)
%
% INPUTS:
%    model:          COBRA model structure, or a char path to an existing
%                     SBML file
%
% OPTIONAL INPUTS:
%    COBRApyPath:    Path to the folder containing a git clone of COBRApy
%                     (https://github.com/opencobra/cobrapy); must be the
%                     full absolute path without `~/`
%
% OUTPUTS:
%    success:        1 if the model was successfully read into COBRApy, 0
%                     (or unset) otherwise
%    pymodel:        COBRApy model object read from the SBML file
%
% NOTE:
%
%    External dependencies:
%
%      * Python, see `initPythonEnvironment`
%      * rdkit, e.g., installed in an Anaconda environment
%        (https://www.rdkit.org)
%      * COBRApy (https://github.com/opencobra/cobrapy), installed with:
%        `conda install -c bioconda cobra`
%
% .. Author: - Ronan M.T. Fleming, 2021

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
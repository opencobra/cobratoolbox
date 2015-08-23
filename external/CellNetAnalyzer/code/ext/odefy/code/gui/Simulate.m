% SIMULATE  Show Simulation Java GUI.
%
%   SIMULATE()  lets the user choose a model file from a file selection
%   dialog. Input files can be yEd graphml files, text files containing
%   Boolean equations or .mat files containing an Odefy model or a
%   simulation structure.
%
%   SIMULATE(MODEL) opens the simulation dialog with a given model or
%   simulation structure.
%
%   SIMULATE(MODEL,CNASTRUCT) takes an Odefy model and a CNA structure and
%   connects to GUI dialog to the text fields of the CellNetAnalyzer
%   network.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function Simulate(inmodel, cna)

if ~IsMatlab
    error('The Odefy graphical user interface only works with MATLAB');
end

% check how to load the model
if nargin<1
    % let user choose via GUI
    [file path] = uigetfile('*','Select a model file');
    if file==0; return; end
    try
        model=LoadModelFile([path file]);
        inmodel = [path file];
    catch E
        javax.swing.JOptionPane.showMessageDialog([], ...
            E.message, 'Error',...
            javax.swing.JOptionPane.ERROR_MESSAGE, []);
        return;
    end
elseif IsOdefyModel(inmodel) || IsSimulationStructure(inmodel)
    model = inmodel;
elseif isstr(inmodel)
    % a file
    model=LoadModelFile(inmodel);
else
    javax.swing.JOptionPane.showMessageDialog([], ...
        'You have to specify an Odefy model or a file containing a valid Odefy model', 'Info',...
        javax.swing.JOptionPane.WARNING_MESSAGE, []);
    return;
end


global simstruct graphfile;
simstruct = CreateSimstruct(model);
% Check if we loaded a GraphML file
if (ischar(inmodel) && IsXML(inmodel))
    graphfile = inmodel;
else
    graphfile = [];
end

% are we in CNA mode? [currently disabled]
global cnastruct
if nargin > 1
    cnastruct = cna;
    CNAUpdate;
    % inform user
    javax.swing.JOptionPane.showMessageDialog([], ...
        'Odefy is connected to the CNA GUI. You can change initial values and activate/deactivate reactions using the CNA text fields.', 'Information',...
        javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
else
    cnastruct = [];
end

frame = odefy.ui.SimulateWindow('Odefy');
frame.centerScreen;
frame.setSize(550, 300);
frame.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);

% select correct item in simulation type cmb
numtype = ValidateType(simstruct.type);
frame.getTypeCombo().setSelectedIndex(numtype-1);

% set time
frame.setTime(simstruct.timeto);
title = sprintf('Odefy - Simulating: %s', simstruct.modelname);
frame.setTitle(title);

sim_button = frame.getSimButton();
set(sim_button, 'ActionPerformedCallback', ...
    {@SimButtonCallback, frame});

edit_init_button = frame.getEditInitButton();
set(edit_init_button, 'ActionPerformedCallback', ...
    {@EditInitButtonCallback, frame});

edit_params_button = frame.getEditParamsButton();
set(edit_params_button, 'ActionPerformedCallback', ...
    {@EditParamsButtonCallback, frame});

load_params = frame.getLoadParametersButton();
set(load_params, 'ActionPerformedCallback', ...
    {@LoadButtonCallback, frame, 'params'});

load_init = frame.getLoadInitialValuesButton();
set(load_init, 'ActionPerformedCallback', ...
    {@LoadButtonCallback, frame, 'initial'});


load_type = frame.getTypeCombo();
set(load_type, 'ActionPerformedCallback', ...
    {@TypeSelectCallback, frame, 'type'});


load_sim = frame.getLoadSimulationButton();
set(load_sim, 'ActionPerformedCallback', ...
    {@LoadButtonCallback, frame, 'all'});

save_params = frame.getSaveParametersButton();
set(save_params, 'ActionPerformedCallback', ...
    {@SaveButtonCallback, frame, 'params'});

save_init = frame.getSaveInitialValuesButton();
set(save_init, 'ActionPerformedCallback', ...
    {@SaveButtonCallback, frame, 'initial'});

save_sim = frame.getSaveSimulationButton();
set(save_sim, 'ActionPerformedCallback', ...
    {@SaveButtonCallback, frame, 'all'});

about_button = frame.getAboutButton();
set(about_button, 'ActionPerformedCallback', ...
    {@AboutButtonCallback, frame});

open_button = frame.getOpenButton();
set(open_button, 'ActionPerformedCallback', ...
    {@OpenButtonCallback, frame});

reload_button = frame.getReloadButton();
set(reload_button, 'ActionPerformedCallback', ...
    {@ReloadButtonCallback, frame});
reload_button.setVisible((numel(graphfile) > 0));

reloadcna_button = frame.getReloadCNAButton();
set(reloadcna_button, 'ActionPerformedCallback', ...
    {@ReloadCNAButtonCallback, frame});
reloadcna_button.setVisible((numel(cnastruct) > 0));

% Display variables in workspace combo
vars_arr = getWorkspaceVariablesJavaArray();
frame.setVariablesInWorkspace(vars_arr);

frame.pack();
frame.setVisible(true);

end

function vars = getWorkspaceVariablesJavaArray()
vars = evalin('base', 'who');
vars_arr = javaArray('java.lang.String', numel(vars));
for i=1:numel(vars)
    vars_arr(i) = java.lang.String(vars{i});
end
end

function CancelButtonCallback(eventSrc, eventData, window)
window.dispose();
end

function EditInitButtonCallback(eventSrc, eventData, frame)
global simstruct cnastruct 
 
if numel(cnastruct)
       javax.swing.JOptionPane.showMessageDialog(frame, ...
           'Please change initial values in the CellNetAnalyzer GUI.');
else
    array = makeSpeciesValuesJavaArray(simstruct.model.species, simstruct.initial);
    
    dialog = odefy.ui.speciesvalues.SpeciesValuesDialog(...
        frame, 'Initial Values', array);
    
    set(dialog.getOKButton(), 'ActionPerformedCallback', ...
        {@EditInitOkButtonCallback, dialog});
    
    dialog.setVisible(true);
end
end

function EditInitOkButtonCallback(eventSrc, eventData, dialog)
global simstruct;

result = dialog.getValues();
if (numel(result) > 0)
    simstruct.initial = result;
end
dialog.dispose();
end

% Start HillParameters dialog
function EditParamsButtonCallback(eventSrc, eventData, frame)
global simstruct;

jspecies = makeSpeciesJavaArray(simstruct.model.species);
jtables = makeTablesJavaArray(simstruct.model);
jhillmatrix = makeHillParamsJavaArray(simstruct.params);

default_tau = java.lang.Double(1.0);
default_n = java.lang.Double(3.0);
default_k = java.lang.Double(0.5);

dialog = odefy.ui.hillparameters.Dialog(frame, default_tau, default_n, ...
    default_k, jspecies, jtables, jhillmatrix);
set(dialog.getOKButton(), 'ActionPerformedCallback', ...
    {@HillParamsOKCallback, dialog});
set(dialog.getCancelButton(), 'ActionPerformedCallback', ...
    {@CancelButtonCallback, dialog});
dialog.setSize(300, 500);
dialog.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
dialog.setVisible(true);
end

function HillParamsOKCallback(eventSrc, eventData, dialog)
global simstruct;
returnmat = dialog.getHillmatrix();
if (numel(returnmat) > 0)
    simstruct.params = returnmat;
end
dialog.setVisible(0);
dialog.dispose();
dialog = [];
end



function jtables = makeTablesJavaArray(model)
if (~IsOdefyModel(model))
    error('first parameter must be a model');
end

% Use 1 as size of 2nd dimension, we override it later anyway
jtables = javaArray('java.lang.Integer', numel(model.tables), 1);

for i=1:numel(model.tables)
    insp = model.tables(i).inspecies;
    if numel(insp) > 0
        insp_arr = javaArray('java.lang.Integer', numel(insp));
        for j=1:numel(insp)
            insp_arr(j) = java.lang.Integer(insp(j));
        end
    else
        % input species
        insp_arr = javaArray('java.lang.Integer', 1);
        insp_arr(1) = java.lang.Integer(i);
    end
    jtables(i) = insp_arr;
end

end

function LoadButtonCallback(eventSrc, eventData, frame, type)
global simstruct;

vars_arr = getWorkspaceVariablesJavaArray();
% Matlab's [] == Java's null
varname = char(javax.swing.JOptionPane.showInputDialog(frame, ...
    'Choose variable from workspace', ...
    'Choose variable', ...
    javax.swing.JOptionPane.QUESTION_MESSAGE, ...
    [], vars_arr, vars_arr(1)));

% Check if the user pressed Cancel
if (numel(varname) == 0)
    return
end

value = evalin('base', varname);
if (numel(value) > 0)
    switch (type)
        case 'initial'
            if (isValidInitialValuesVector(value))
                simstruct.initial = value;
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    'Successfully loaded initial values from workspace variable.');
            else
                msg = sprintf(...
                    'Invalid variable.\nMust be a column vector of length %i', ...
                    numel(simstruct.model.species));
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    java.lang.String(msg), 'Invalid variable', ...
                    javax.swing.JOptionPane.ERROR_MESSAGE, []);
            end

        case 'params'
            correctwidth = getHillMatrixWidth();
            if (isValidHillMatrix(value, correctwidth))
                simstruct.params = value;
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    'Successfully loaded parameters from workspace variable.');
            else
                msg = sprintf('Invalid variable.\nMatrix must contain doubles and have the size %ix%i', ...
                    numel(simstruct.model.species), correctwidth);
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    java.lang.String(msg), 'Invalid variable', ...
                    javax.swing.JOptionPane.ERROR_MESSAGE, []);
            end
        case 'all'
            if (IsSimulationStructure(value))
                % everything ok, load it
                simstruct = value;
                UpdateFrameFromSimulation(frame, simstruct);
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    'Simulation settings successfully loaded from workspace.');
            else
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    'Invalid simulation parameter variable. Make sure that you only load settings generated by this program.', ...
                    'Invalid variable', ...
                    javax.swing.JOptionPane.ERROR_MESSAGE, []);
            end
        otherwise
            error('Unknown type');
    end
end
end

function UpdateFrameFromSimulation(frame, simstruct)
frame.setTime(simstruct.timeto);
title = sprintf('Odefy - Simulating: %s', ...
    simstruct.modelname);
frame.setTitle(title);
end

function SaveButtonCallback(eventSrc, eventData, frame, type)
global simstruct;

switch (type)
    case 'initial'
        value = simstruct.initial;
    case 'params'
        value = simstruct.params;
    case 'all'
        % store time to
        simstruct.timeto = frame.getTime();
        value = simstruct;
    otherwise
        error('Unknown type');
end

newname = char(javax.swing.JOptionPane.showInputDialog(frame, ...
    'Please enter a name for the new workspace variable:'));
if (numel(newname) > 0)
    % store it
    assignin('base', newname, value);
    javax.swing.JOptionPane.showMessageDialog(frame, ...
        'Successfully stored in workspace.');
end
end

function AboutButtonCallback(eventSrc, eventData, frame)
AboutOdefy(frame);
end

function OpenButtonCallback(eventSrc, eventData, frame)
global simstruct graphfile;

% let user choose via GUI
[file path] = uigetfile('*','Select a model file');
if file==0; return; end
try
    model=LoadModelFile([path file]);
    simstruct = CreateSimstruct(model);
catch E
    javax.swing.JOptionPane.showMessageDialog([], ...
        E.message, 'Error',...
        javax.swing.JOptionPane.ERROR_MESSAGE, []);
    return;
end

if IsXML([path file])
    graphfile = inmodel;
else
    graphfile = [];
end

% set time
frame.setTime(simstruct.timeto);
title = sprintf('Odefy - Simulating: %s', simstruct.modelname);
frame.setTitle(title);

end

function ReloadButtonCallback(eventSrc, eventData, frame)
global simstruct graphfile;

if (numel(graphfile) > 0)
    try
        simstruct = UpdateSimulationFromyEdFile(simstruct, graphfile);
        frame.getReloadButton.setEnabled(true);
    catch ME
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            ME.message, 'An error occured', ...
            javax.swing.JOptionPane.ERROR_MESSAGE, []);
    end
    UpdateFrameFromSimulation(frame, simstruct);
end
end

function jspecies = makeSpeciesJavaArray(species)
jspecies = javaArray('java.lang.String', numel(species));

for i=1:numel(species)
    jspecies(i) = java.lang.String(species(i));
end
end

function jhill = makeHillParamsJavaArray(hillmatrix)
[matrixsize, numspecies] = size(hillmatrix);

jhill = javaArray('java.lang.Double', matrixsize, numspecies);

for i=1:matrixsize
    for j=1:numspecies
        jhill(i, j) = java.lang.Double(hillmatrix(i, j));
    end
end
end

function r=isValidPermutation(var,n)
r = isnumeric(var) && numel(var) == n && norm(sort(var) - (1:max(var))) == 0;
end

function r=isValidInitialValuesVector(value)
global simstruct;
r = isa(value,'double') && size(value,1) == numel(simstruct.model.species) && size(value,2) == 1;
end

% find correct width of the matrix
function correctwidth=getHillMatrixWidth()
global simstruct;
max = -1;
for i=1:numel(simstruct.model.species)
    el=numel(simstruct.model.tables(i).inspecies);
    if (el>max)
        max=el;
    end
end
correctwidth = max*2+1;
end

function r=isValidHillMatrix(value, correctwidth)
global simstruct;
if (isa(value,'double'))
    % check whether it has the correct dimensions
    r = (size(value,1) == numel(simstruct.model.species) && size(value,2) == correctwidth);
else
    r = 0;
end
end


function array = makeSpeciesValuesJavaArray(species, values)
n = numel(species);
if (n ~= numel(values))
    error('Both arguments must be of same size')
end

array = javaArray('java.lang.Object', n, 2);

for i = 1:n
    array(i, 1) = java.lang.String(species(i));
    array(i, 2) = java.lang.Double(values(i));
end
end

function SimButtonCallback(eventSrc, eventData, frame)

global simstruct cnastruct

% set species order
var = char(frame.getSelectedVariable());
if (strcmp(var, ''))
    simstruct.speciesorder = 1:numel(simstruct.model.species);
else
    value = evalin('base', var);
    % verify
    if (numel(value) > 0)
        numspecies = numel(simstruct.model.species);
        if (~isValidPermutation(value, numspecies))
            javax.swing.JOptionPane.showMessageDialog(frame, ...
                'A species permutation vector must contain each element from 1 to n exactly once.', ...
                'Invalid permutation', javax.swing.JOptionPane.ERROR_MESSAGE);
            return;
        else
            simstruct.speciesorder = value;
        end
    end
end

% type of simulation?
type = frame.getSelectedSimulationIndex() + 1;
% translate to string
switch type
    case 1, stype='boolcube';
    case 2, stype='hillcube';
    case 3, stype='hillcubenorm';
    case 4, stype='boolsync';
    case 5, stype='boolasync';
    case 6, stype='boolrandom';
end
simstruct.type = stype;


% store time to
simstruct.timeto = frame.getTime();

if numel(cnastruct)
    % is CNA mode
    CNAUpdate;
    lsimstruct = simstruct;
    [react,init] = CNAreadSFNValues(cnastruct);
    % check for eventually disabled reactions (0:disabled, <>0 or NaN:enabled)
    react(find(isnan(react))) = 1;
    % generate eventually reduced model
    lsimstruct.model = CNAToOdefy(cnastruct, react);
    lsimstruct.params = ParasBigToSmall(simstruct.model, lsimstruct.model, simstruct.params);
else
    lsimstruct = simstruct;
end


frame.markBusy(true);
% do the simulation
if (type < 4)
    [t,y] = OdefySimulation(lsimstruct,1,frame.getPlotType);
else
    y = OdefySimulation(lsimstruct,1,frame.getPlotType);
end
frame.markBusy(false);

% store in workspace?
if (frame.getStoreInWorkspace())
    if (type < 4)
        assignin('base', 'simt', t);
        assignin('base', 'simy', y);
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            'Saved simulation results into workspace as variables "simt" and "simy".', ...
            'Stored in workspace', javax.swing.JOptionPane.INFORMATION_MESSAGE);
    else
        assignin('base', 'simy', y);
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            'Saved simulation results into workspace as variable "simy".', ...
            'Stored in workspace', javax.swing.JOptionPane.INFORMATION_MESSAGE);
    end
end

end



function TypeSelectCallback(eventSrc, eventData, frame, type)

global simstruct
% if async => ask user for oder
if frame.getTypeCombo().getSelectedIndex==4
    result=javax.swing.JOptionPane.showInputDialog(...
        frame, 'In which order do you want to update the species:',...
        'Asynchronous order', javax.swing.JOptionPane.PLAIN_MESSAGE, [],...
        {'Randomly generated order','Sequential order','Select from workspace'}, ...
        'Randomly generated order');

    numspec = numel(simstruct.model.species);
    if strcmp(result(1:3),'Ran')
        simstruct.asyncorder = randperm(numspec);
    elseif strcmp(result(1:3),'Seq')
        simstruct.asyncorder = 1:numspec;
    else
        % select from workspace
        var = javax.swing.JOptionPane.showInputDialog(...
            frame, 'Select variable from workspace:',...
            'Select variable', javax.swing.JOptionPane.PLAIN_MESSAGE, [],...
            evalin('base', 'who'), '');
        % check it
        check = evalin('base', var);
        if (~isValidPermutation(check, numspec))
            javax.swing.JOptionPane.showMessageDialog(frame, ...
                'A species permutation vector must contain each element from 1 to n exactly once. Using randomly generated order.', ...
                'Invalid permutation', javax.swing.JOptionPane.ERROR_MESSAGE);
            simstruct.asyncorder = randperm(numspec);
        else
            simstruct.asyncorder = check;
        end
    end
end
end


function CNAUpdate
% reload the stuff

global simstruct cnastruct;

% get values from CNA
[react,init] = CNAreadSFNValues(cnastruct);

% initial values - replace all NaNs by zeros
init(find(isnan(init))) = 0;

simstruct.initial = init;



end


function ReloadCNAButtonCallback(eventSrc, eventData, frame, type)
CNAUpdate;
javax.swing.JOptionPane.showMessageDialog([], ...
    'CNA settings successfully updated', 'Success',...
    javax.swing.JOptionPane.INFORMATION_MESSAGE, []);

end

% EXPORT  Show Export Java GUI.
%
%   EXPORT() lets the user choose a model file from a file selection
%   dialog. Input files can be yEd graphml files, text files containing
%   Boolean equations or .mat files containing an Odefy model or a
%   simulation structure.
%
%   EXPORT(MODEL) opens the export dialog with a given model or simulation
%   structure.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function Export(inmodel)

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
        if IsSimulationStructure(model)
            model=model.model;
        end
    catch E
        javax.swing.JOptionPane.showMessageDialog([], ...
            E.message, 'Error',...
            javax.swing.JOptionPane.ERROR_MESSAGE, []);
        return;
    end
elseif ~IsOdefyModel(inmodel) && ~isstr(inmodel)
    javax.swing.JOptionPane.showMessageDialog([], ...
        'You have to specify an Odefy model or a file containing a valid Odefy model', 'Info',...
        javax.swing.JOptionPane.WARNING_MESSAGE, []);
    return;
elseif IsOdefyModel(inmodel)
    model = inmodel;
elseif isstr(inmodel)
    % a file
    model=LoadModelFile(inmodel);
    if IsSimulationStructure(model)
        model=model.model;
    end
end


global odefymodel
odefymodel=model;

% create it
frame = odefy.ui.ExportWindow('Odefy');
frame.centerScreen;
frame.setSize(450, 180);
frame.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);

% set title
title = sprintf('Odefy - Exporting: %s', model.name);
frame.setTitle(title);

% fill in list of model types
typeslist = frame.getTypeList();
list = {  'MATLAB (BooleCube)'; 'MATLAB (HillCube)'; 'MATLAB (HillCube, normalized)'; ...
    'SB Toolbox (BooleCube)';'SB Toolbox (HillCube)' ; 'SB Toolbox (HillCube, normalized)' ; ...
    'GNA' ; 'SQUAD' ; ...
    'R (BooleCube)'; 'R (HillCube)' ; 'R (HillCube, normalized)' ; ...
    'SBML (BooleCube)'; 'SBML (HillCube)' ; 'SBML (HillCube, normalized)'};
for i=1:numel(list)
    typeslist.addItem(list{i});
end




% set action handlers
set(frame.getAboutButton(), 'ActionPerformedCallback', ...
    {@AboutButtonCallback, frame});

set(frame.getTextOut(),'MouseClickedCallback', ...
    {@TextOutCallback,frame});

set(frame.getExportButton(),'ActionPerformedCallback', ...
    {@ExportButtonCallback,frame});




function AboutButtonCallback(eventSrc, eventData, frame)
AboutOdefy(frame);

function TextOutCallback(eventSrc, eventData, frame)

filechooser = odefy.ui.JFileChooserAskOverwrite();
filechooser.showSaveDialog(frame);

file = filechooser.getSelectedFile();
if (numel(file) > 0)
    filename = char(file.getAbsolutePath());
    try
        % do it
        frame.getTextOut().setText(filename);
    catch ME
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            ME.message, 'An error occured', ...
            javax.swing.JOptionPane.ERROR_MESSAGE, []);
    end
end

function ExportButtonCallback(eventSrc, eventData, frame)

global odefymodel
% check whether the user specified both files
basefile = char(frame.getTextOut().getText());
if (basefile(1) == '[')
    javax.swing.JOptionPane.showMessageDialog(frame, ...
        'Please select an output file!', 'Info',...
        javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
else
    type = frame.getTypeList().getSelectedIndex()+1;
    
    if (type < 4) % odefy models
        switch type
            case 1, stype='boolcube';
            case 2, stype='hillcube';
            case 3, stype='hillcubenorm';
        end
        % save model
        SaveMatlabODE(odefymodel, basefile, stype);
        
        % done
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            sprintf('Successfully exported MATLAB script!\n\nFile written:\n%s', basefile), 'Info',...
            javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
        
    elseif (type >= 4 && type <= 6) % SB Toolbox
        switch type-3
            case 1, stype='boolcube';
            case 2, stype='hillcube';
            case 3, stype='hillcubenorm';
        end
        
        sbstruct = CreateSBToolboxModel(odefymodel, stype, 0);
        varname = [odefymodel.name '_sb'];
        eval([varname '=sbstruct;']);
        eval(['save ' basefile ' ' varname]);
        % done
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            sprintf('Successfully exported SB Toolbox model as .mat file!\n\nFile written:\n%s\n\nVariable name: %s', basefile, varname), 'Info',...
            javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
        
    elseif (type == 7) % GNA
        SaveGNAModel(odefymodel, basefile);
        % done
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            sprintf('Successfully exported GNA model!\n\nFile written:\n%s', basefile), 'Info',...
            javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
        
    elseif (type == 8) % SQUAD
        try
            SaveSQUADModel(odefymodel, basefile);
            javax.swing.JOptionPane.showMessageDialog(frame, ...
                sprintf('Successfully exported SQUAD model!\n\nFile written:\n%s', basefile), 'Info',...
                javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
        catch
            % function crashed, we got ambiguities
            if (strcmp(questdlg('At least one of the interactions in this model is ambiguous. That means that a species has both inhibitory and activatory influence on its target species. Do you want to ignore such cases?', 'Warning', 'Yes', 'No', 'Yes'), 'Yes'))
                % ignore cases
                SaveSQUADModel(odefymodel, basefile,1);
                javax.swing.JOptionPane.showMessageDialog(frame, ...
                    sprintf('Successfully exported SQUAD model!\n\nFile written:\n%s', basefile), 'Info',...
                    javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
            else
                % abort
                h = msgbox('Model not exported!');
                uiwait(h);
            end
            
        end
        
    elseif (type >= 9 && type <= 11) % R
        switch type-8
            case 1, stype='boolcube';
            case 2, stype='hillcube';
            case 3, stype='hillcubenorm';
        end
        
        SaveRModel(odefymodel, basefile, stype);
        % done
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            sprintf('Successfully exported R model script!\n\nFile written:\n%s', basefile), 'Info',...
            javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
        
    elseif (type >= 12 && type <= 14) % SBML
        switch type-11
            case 1, stype='boolcube';
            case 2, stype='hillcube';
            case 3, stype='hillcubenorm';
        end
        
        SaveSBML(odefymodel, basefile, stype);
        % done
        javax.swing.JOptionPane.showMessageDialog(frame, ...
            sprintf('Successfully exported SBML model!\n\nFile written:\n%s', basefile), 'Info',...
            javax.swing.JOptionPane.INFORMATION_MESSAGE, []);
    end
end

function dummy
%%
ExportJava(model)

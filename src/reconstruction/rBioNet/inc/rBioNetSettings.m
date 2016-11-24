% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = rBioNetSettings(varargin)
% RBIONETSETTINGS MATLAB code for rBioNetSettings.fig
%      RBIONETSETTINGS, by itself, creates a new RBIONETSETTINGS or raises the existing
%      singleton*.
%
%      H = RBIONETSETTINGS returns the handle to a new RBIONETSETTINGS or the handle to
%      the existing singleton*.
%
%      RBIONETSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RBIONETSETTINGS.M with the given input arguments.
%
%      RBIONETSETTINGS('Property','Value',...) creates a new RBIONETSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rBioNetSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rBioNetSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rBioNetSettings

% Last Modified by GUIDE v2.5 24-Mar-2011 15:15:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rBioNetSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @rBioNetSettings_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rBioNetSettings is made visible.
function rBioNetSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rBioNetSettings (see VARARGIN)

% Choose default command line output for rBioNetSettings
handles.output = hObject;

a=exist('rBioNetSettingsDB.mat','file');

if a == 2 %file exist and is one of the paths
    load 'rBioNetSettingsDB.mat';
    fileID = fopen('rBioNetSettingsDB.mat');
    handles.path = fopen(fileID);
else %File not found and has to be located.
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Mat files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Locate Settings file.',...
        'MultiSelect','off');
    if pathname == 0
        return
    end
    handles.path = fullfile(pathname,input_file);
    load(handles.path)
end

if exist('rxn_path','var')
    handles.rxn = rxn_path;
else
    handles.rxn = '';
end
if exist('met_path','var')
    handles.met = met_path;
else
    handles.met = '';
end
if exist('comp_path','var')
   handles.comp = comp_path;
else
    handles.comp = '';
end


handles.split = '/';
if isempty(regexpi(handles.rxn,handles.split)) %if empty then windows
   handles.split = '\';
end
rxn = regexpi(handles.rxn,handles.split,'split');
set(handles.text_rxn,'string',rxn{end});
set(handles.text_rxn,'TooltipString',handles.rxn);

met = regexpi(handles.met,handles.split,'split');
set(handles.text_met,'string',met{end});
set(handles.text_met,'TooltipString',handles.met);

comp = regexpi(handles.comp,handles.split,'split');
set(handles.text_comp,'string',comp{end});
set(handles.text_comp,'TooltipString',handles.comp);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rBioNetSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rBioNetSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in act_save.
function act_save_Callback(hObject, eventdata, handles)
% hObject    handle to act_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rxn_path = handles.rxn;
met_path = handles.met;
comp_path = handles.comp;
save(handles.path,'rxn_path','met_path','comp_path');
delete(gcf)



% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)

% --- Executes on button press in act_rxn.
function act_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to act_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[input_file,pathname] = uigetfile( ...
    {'*.mat', 'Mat files (*.mat)';...
    '*.*','All Files (*.*)'},...
    'Select reaction database file.',...
    'MultiSelect','off');
if pathname == 0
    return
end
handles.rxn = fullfile(pathname,input_file);
set(handles.text_rxn,'string',input_file);
set(handles.text_rxn,'TooltipString',handles.rxn);
guidata(hObject,handles)



% --- Executes on button press in act_met.
function act_met_Callback(hObject, eventdata, handles)
% hObject    handle to act_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[input_file,pathname] = uigetfile( ...
    {'*.mat', 'Mat files (*.mat)';...
    '*.*','All Files (*.*)'},...
    'Select metabolite database file.',...
    'MultiSelect','off');
if pathname == 0
    return
end
handles.met = fullfile(pathname,input_file);
set(handles.text_met,'string',input_file);
set(handles.text_met,'TooltipString',handles.met);
guidata(hObject,handles)



% --- Executes on button press in act_comp.
function act_comp_Callback(hObject, eventdata, handles)
% hObject    handle to act_comp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[input_file,pathname] = uigetfile( ...
    {'*.mat', 'Mat files (*.mat)';...
    '*.*','All Files (*.*)'},...
    'Select compartment database file.',...
    'MultiSelect','off');
if pathname == 0
    return
end
handles.comp = fullfile(pathname,input_file);
set(handles.text_comp,'string',input_file);
set(handles.text_comp,'TooltipString',handles.comp);
guidata(hObject,handles)

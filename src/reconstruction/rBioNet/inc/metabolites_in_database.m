function varargout = metabolites_in_database(varargin)
% m-file for metabolites_in_database.fig
% metabolites_in_database, by itself, creates a new object or raises the existing singleton*.
%
% USAGE:
%
%    varargout = metabolites_in_database(varargin)
%
% INPUTS:
%    varargin:    various input arguments
%
% OUTPUTS:
%    varargout:   various output arguments
%
% EXAMPLE:
%
%    H = metabolites_in_database() returns the handle to a new metabolites_in_database or the handle to
%    the existing singleton*.
%
%    metabolites_in_database('CALLBACK',hObject,eventData,handles,...) calls the local
%    function named CALLBACK in metabolites_in_database.M with the given input arguments.
%
%    metabolites_in_database('Property','Value',...) creates a new metabolites_in_database or raises the
%    existing singleton*.  Starting from the left, property value pairs are
%    applied to the GUI before `metabolites_in_database_OpeningFcn` gets called.  An
%    unrecognized property name or invalid value makes property application
%    stop.  All inputs are passed to `metabolites_in_database_OpeningFcn` via `varargin`.
%
% .. Author: - Stefan G. Thorleifsson 2011
%
% NOTE:
%    See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%    instance to run (singleton)".
%    See also: GUIDE, GUIDATA, GUIHANDLES
% .. Edit the above text to modify the response to help metabolites_in_database
% .. Last Modified by GUIDE v2.5 31-Aug-2010 18:09:02
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is
gui_Singleton = 1; % Begin initialization code - DO NOT EDIT
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @metabolites_in_database_OpeningFcn, ...
                   'gui_OutputFcn',  @metabolites_in_database_OutputFcn, ...
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


% --- Executes just before metabolites_in_database is made visible.
function metabolites_in_database_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to metabolites_in_database (see VARARGIN)
data = varargin{1};
set(handles.uitable1,'data',data);
% Choose default command line output for metabolites_in_database
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes metabolites_in_database wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = metabolites_in_database_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf)


% --- Executes on button press in act_continue.
function act_continue_Callback(hObject, eventdata, handles)
% hObject    handle to act_continue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 1;
guidata(hObject,handles)
uiresume;

% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume

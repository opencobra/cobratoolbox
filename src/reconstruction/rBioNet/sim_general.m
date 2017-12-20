function varargout = sim_general(varargin)
% MATLAB code for sim_general.fig
% sim_general, by itself, creates a new object or raises the existing singleton*.
%
% USAGE:
%
%    varargout = sim_general(varargin)
%
% INPUTS:
%    varargin:    various input arguments
%
% OUTPUTS:
%    varargout:   various output arguments
%
% EXAMPLE:
%
%    H = sim_general returns the handle to a new sim_general or the handle to
%    the existing singleton*.
%
%    sim_general('CALLBACK',hObject,eventData,handles,...) calls the local
%    function named CALLBACK in sim_general.M with the given input arguments.
%
%    sim_general('Property','Value',...) creates a new sim_general or raises the
%    existing singleton*.  Starting from the left, property value pairs are
%    applied to the GUI before `sim_general_OpeningFcn` gets called.  An
%    unrecognized property name or invalid value makes property application
%    stop.  All inputs are passed to `sim_general_OpeningFcn` via `varargin`.
%
% .. Author: - Stefan G. Thorleifsson 2011
%
% NOTE:
%    See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%    instance to run (singleton)".
%    See also: GUIDE, GUIDATA, GUIHANDLES
% .. Edit the above text to modify the response to help sim_general
% .. Last Modified by GUIDE v2.5 15-Nov-2010 21:48:17
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is

gui_Singleton = 1; % Begin initialization code - DO NOT EDIT
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sim_general_OpeningFcn, ...
                   'gui_OutputFcn',  @sim_general_OutputFcn, ...
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


% --- Executes just before sim_general is made visible.
function sim_general_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sim_general (see VARARGIN)

% Choose default command line output for sim_general
handles.output = hObject;
set(handles.uitable1,'data',varargin{1});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sim_general wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sim_general_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)

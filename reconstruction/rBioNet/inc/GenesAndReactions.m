% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

function varargout = GenesAndReactions(varargin)
% GENESANDREACTIONS M-file for GenesAndReactions.fig
%      GENESANDREACTIONS, by itself, creates a new GENESANDREACTIONS or raises the existing
%      singleton*.
%
%      H = GENESANDREACTIONS returns the handle to a new GENESANDREACTIONS or the handle to
%      the existing singleton*.
%
%      GENESANDREACTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENESANDREACTIONS.M with the given input arguments.
%
%      GENESANDREACTIONS('Property','Value',...) creates a new GENESANDREACTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenesAndReactions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenesAndReactions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GenesAndReactions

% Last Modified by GUIDE v2.5 12-May-2011 15:15:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenesAndReactions_OpeningFcn, ...
                   'gui_OutputFcn',  @GenesAndReactions_OutputFcn, ...
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


% --- Executes just before GenesAndReactions is made visible.
function GenesAndReactions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GenesAndReactions (see VARARGIN)

% Choose default command line output for GenesAndReactions
handles.output = hObject;
set(handles.uitable1,'data',varargin{1});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GenesAndReactions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GenesAndReactions_OutputFcn(hObject, eventdata, handles) 
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
delete(gcf);
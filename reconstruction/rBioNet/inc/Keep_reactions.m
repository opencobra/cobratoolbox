% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = Keep_reactions(varargin)
% KEEP_REACTIONS M-file for Keep_reactions.fig
%      KEEP_REACTIONS, by itself, creates a new KEEP_REACTIONS or raises the existing
%      singleton*.
%
%      H = KEEP_REACTIONS returns the handle to a new KEEP_REACTIONS or the handle to
%      the existing singleton*.
%
%      KEEP_REACTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KEEP_REACTIONS.M with the given input arguments.
%
%      KEEP_REACTIONS('Property','Value',...) creates a new KEEP_REACTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Keep_reactions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Keep_reactions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Keep_reactions

% Last Modified by GUIDE v2.5 08-Sep-2010 22:49:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Keep_reactions_OpeningFcn, ...
                   'gui_OutputFcn',  @Keep_reactions_OutputFcn, ...
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


% --- Executes just before Keep_reactions is made visible.
function Keep_reactions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Keep_reactions (see VARARGIN)

% Choose default command line output for Keep_reactions
% 0 for cancel, 1 for yes, 2 for no
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Keep_reactions wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Keep_reactions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf)


% --- Executes on button press in Yes.
function Yes_Callback(hObject, eventdata, handles)
% hObject    handle to Yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 1;
guidata(hObject,handles)
uiresume

% --- Executes on button press in No.
function No_Callback(hObject, eventdata, handles)
% hObject    handle to No (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 2;
guidata(hObject,handles)
uiresume

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 0;
guidata(hObject,handles)
uiresume


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume

% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = model_description(varargin)
% MODEL_DESCRIPTION M-file for model_description.fig
%      MODEL_DESCRIPTION, by itself, creates a new MODEL_DESCRIPTION or raises the existing
%      singleton*.
%
%      H = MODEL_DESCRIPTION returns the handle to a new MODEL_DESCRIPTION or the handle to
%      the existing singleton*.
%
%      MODEL_DESCRIPTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL_DESCRIPTION.M with the given input arguments.
%
%      MODEL_DESCRIPTION('Property','Value',...) creates a new MODEL_DESCRIPTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before model_description_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to model_description_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help model_description

% Last Modified by GUIDE v2.5 01-Sep-2010 15:45:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @model_description_OpeningFcn, ...
                   'gui_OutputFcn',  @model_description_OutputFcn, ...
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


% --- Executes just before model_description is made visible.
function model_description_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to model_description (see VARARGIN)

% Choose default command line output for model_description
handles.output = [];
handles.output2 = [];
handles.group = [handles.edit1, handles.edit2, handles.edit3,...
     handles.edit4, handles.edit5, handles.edit6,handles.edit7];


data = varargin{1};

if ~isempty(data)
    set(handles.edit1,'String',data{1});
    set(handles.edit2,'String',data{2});
    set(handles.edit3,'String',data{3});
    set(handles.edit4,'String',data{4});
    set(handles.edit5,'String',data{5});
    set(handles.edit6,'String',data{6});
    set(handles.edit7,'String',data{7});
end
% Update handles structureW
guidata(hObject, handles);

% UIWAIT makes model_description wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = model_description_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(gcf)

% --- Executes on button press in act_ok.
function act_ok_Callback(hObject, eventdata, handles)
% hObject    handle to act_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(handles.group,'String');

guidata(hObject,handles);
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
uiresume;

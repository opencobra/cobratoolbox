% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = unbalanced(varargin)
% UNBALANCED M-file for unbalanced.fig
%      UNBALANCED, by itself, creates a new UNBALANCED or raises the existing
%      singleton*.
%
%      H = UNBALANCED returns the handle to a new UNBALANCED or the handle to
%      the existing singleton*.
%
%      UNBALANCED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNBALANCED.M with the given input arguments.
%
%      UNBALANCED('Property','Value',...) creates a new UNBALANCED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before unbalanced_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to unbalanced_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help unbalanced

% Last Modified by GUIDE v2.5 23-Sep-2010 20:22:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @unbalanced_OpeningFcn, ...
                   'gui_OutputFcn',  @unbalanced_OutputFcn, ...
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


% --- Executes just before unbalanced is made visible.
function unbalanced_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to unbalanced (see VARARGIN)
 


%data comes in: 1 reaction 3 lines! that is reacion 2 takes lines 4 to 6
%and reaction 3 takes lines 7 to 9 and so on. 

handles.output = 0;% continue: if 0 no, if 1 yes.
handles.data = varargin{1};
names = varargin{2}; 
set(handles.listbox1,'String',names);
set(handles.uitable1,'data',handles.data(1:3,:));


% Update handles structure
guidata(hObject, handles);
uiwait
% UIWAIT makes unbalanced wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = unbalanced_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject)


 
% --- Executes on button press in unbal_close.
function unbal_close_Callback(hObject, eventdata, handles)
% hObject    handle to unbal_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume


% --- Executes on button press in button_continue.
function button_continue_Callback(hObject, eventdata, handles)
% hObject    handle to button_continue (see GCBO.)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 1;
guidata(hObject,handles)
uiresume


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume
%delete(hObject);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
val = get(hObject,'Value');

set(handles.uitable1,'data',handles.data(3*val-2:3*val,:));

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

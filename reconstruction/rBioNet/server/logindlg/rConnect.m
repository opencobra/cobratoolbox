% Establish connection to server
% OUTPUT - java object rbionet

function varargout = rConnect(varargin)
% RCONNECT MATLAB code for rConnect.fig
%      RCONNECT, by itself, creates a new RCONNECT or raises the existing
%      singleton*.
%
%      H = RCONNECT returns the handle to a new RCONNECT or the handle to
%      the existing singleton*.
%
%      RCONNECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RCONNECT.M with the given input arguments.
%
%      RCONNECT('Property','Value',...) creates a new RCONNECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rConnect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rConnect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rConnect

% Last Modified by GUIDE v2.5 19-Apr-2012 20:02:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rConnect_OpeningFcn, ...
                   'gui_OutputFcn',  @rConnect_OutputFcn, ...
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


% --- Executes just before rConnect is made visible.
function rConnect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rConnect (see VARARGIN)

% Choose default command line output for rConnect
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rConnect wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rConnect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf);



function server_Callback(hObject, eventdata, handles)
% hObject    handle to server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of server as text
%        str2double(get(hObject,'String')) returns contents of server as a double


% --- Executes during object creation, after setting all properties.
function server_CreateFcn(hObject, eventdata, handles)
% hObject    handle to server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_connect.
function button_connect_Callback(hObject, eventdata, handles)
% hObject    handle to button_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[user, pwd] = logindlg('Title','Server login');

if isempty(user) || isempty(pwd)
    % Do nothing
else
    r = javaObjectEDT('rbionet.Rbionet');
    server = get(handles.server,'String');
    database = get(handles.database,'String');
    r.Innitiate(server,database,user,pwd)
    % Does database exist
    
    handles.output = r;
    guidata(hObject, handles);
    
    
    if ~r.dbExists()
        if ~r.isConnected()
            msgbox({'There was an error connecting to the server.',...
                char(r.last_error())},'Connection error','error');
            handles.output = [];
            guidata(hObject, handles);
            return
        else
            uiresume;
            msgbox(['Database ' database ' does not exist on this server.'...
                ' Database needs to be created by an authorized user or server administrator.'],...
                'Database does not exist','warn'); 
        end
    end  
    uiresume;
    
end


% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to button_cancel (see GCBO)
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

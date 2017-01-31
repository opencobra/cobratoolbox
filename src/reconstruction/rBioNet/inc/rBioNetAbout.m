% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = rBioNetAbout(varargin)
% RBIONETABOUT MATLAB code for rBioNetAbout.fig
%      RBIONETABOUT, by itself, creates a new RBIONETABOUT or raises the existing
%      singleton*.
%
%      H = RBIONETABOUT returns the handle to a new RBIONETABOUT or the handle to
%      the existing singleton*.
%
%      RBIONETABOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RBIONETABOUT.M with the given input arguments.
%
%      RBIONETABOUT('Property','Value',...) creates a new RBIONETABOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rBioNetAbout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rBioNetAbout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rBioNetAbout

% Last Modified by GUIDE v2.5 16-May-2011 11:22:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rBioNetAbout_OpeningFcn, ...
                   'gui_OutputFcn',  @rBioNetAbout_OutputFcn, ...
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


% --- Executes just before rBioNetAbout is made visible.
function rBioNetAbout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rBioNetAbout (see VARARGIN)

% Choose default command line output for rBioNetAbout
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rBioNetAbout wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rBioNetAbout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)


% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate image1
axes(hObject);

imshow('hilogo.png');

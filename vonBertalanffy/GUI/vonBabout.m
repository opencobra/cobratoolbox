function varargout = vonBabout(varargin)
% VONBABOUT M-file for vonBabout.fig
%      VONBABOUT, by itself, creates a new VONBABOUT or raises the existing
%      singleton*.
%
%      H = VONBABOUT returns the handle to a new VONBABOUT or the handle to
%      the existing singleton*.
%
%      VONBABOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VONBABOUT.M with the given input arguments.
%
%      VONBABOUT('Property','Value',...) creates a new VONBABOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vonBabout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vonBabout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vonBabout

% Last Modified by GUIDE v2.5 02-May-2012 13:25:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vonBabout_OpeningFcn, ...
                   'gui_OutputFcn',  @vonBabout_OutputFcn, ...
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


% --- Executes just before vonBabout is made visible.
function vonBabout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vonBabout (see VARARGIN)

% Choose default command line output for vonBabout
handles.output = hObject;
string = sprintf('%s\n%s\n\%s\n%s','Created by','Gezim Haziri and','Guðmundur Páll Kjartansson','University of Iceland 2012');
set(handles.text2,'String',string);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vonBabout wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vonBabout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

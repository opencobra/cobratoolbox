% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = similarities(varargin)
% SIMILARITIES M-file for similarities.fig
%      SIMILARITIES, by itself, creates a new SIMILARITIES or raises the existing
%      singleton*.
%
%      H = SIMILARITIES returns the handle to a new SIMILARITIES or the handle to
%      the existing singleton*.
%
%      SIMILARITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMILARITIES.M with the given input arguments.
%
%      SIMILARITIES('Property','Value',...) creates a new SIMILARITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before similarities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to similarities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help similarities

% Last Modified by GUIDE v2.5 26-Jul-2010 18:39:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @similarities_OpeningFcn, ...
                   'gui_OutputFcn',  @similarities_OutputFcn, ...
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


% --- Executes just before similarities is made visible.
function similarities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to similarities (see VARARGIN)
table_data = cell(1,4);
line = varargin{1};
rxns = varargin{2};
for i = 1:length(line)
    table_data{i,1} = num2str(line(i));
    table_data{i,2} = rxns{i,1};
    table_data{i,3} = rxns{i,3};
    table_data{i,4} = rxns{i,10};
end


set(handles.uitable1,'data',table_data)
% Choose default command line output for similarities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes similarities wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = similarities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)

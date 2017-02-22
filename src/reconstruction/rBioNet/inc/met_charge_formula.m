% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = met_charge_formula(varargin)
% MET_CHARGE_FORMULA MATLAB code for met_charge_formula.fig
%      MET_CHARGE_FORMULA, by itself, creates a new MET_CHARGE_FORMULA or raises the existing
%      singleton*.
%
%      H = MET_CHARGE_FORMULA returns the handle to a new MET_CHARGE_FORMULA or the handle to
%      the existing singleton*.
%
%      MET_CHARGE_FORMULA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MET_CHARGE_FORMULA.M with the given input arguments.
%
%      MET_CHARGE_FORMULA('Property','Value',...) creates a new MET_CHARGE_FORMULA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before met_charge_formula_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to met_charge_formula_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help met_charge_formula

% Last Modified by GUIDE v2.5 04-Apr-2011 13:23:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @met_charge_formula_OpeningFcn, ...
                   'gui_OutputFcn',  @met_charge_formula_OutputFcn, ...
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


% --- Executes just before met_charge_formula is made visible.
function met_charge_formula_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to met_charge_formula (see VARARGIN)

% Choose default command line output for met_charge_formula
%Stefan Thorleifsson April 2011
%Shows Same charge formula in tables. 


set(handles.uitable1,'data', varargin{1}); %metabolites that have similar charge formula as in database

handles.output = 'Cancel';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes met_charge_formula wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = met_charge_formula_OutputFcn(hObject, eventdata, handles) 
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
handles.output = 'Continue';
guidata(hObject,handles)
uiresume

% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume

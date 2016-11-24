% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = addmissing(varargin)
% ADDMISSING MATLAB code for addmissing.fig
%      ADDMISSING, by itself, creates a new ADDMISSING or raises the existing
%      singleton*.
%
%      H = ADDMISSING returns the handle to a new ADDMISSING or the handle to
%      the existing singleton*.
%
%      ADDMISSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDMISSING.M with the given input arguments.
%
%      ADDMISSING('Property','Value',...) creates a new ADDMISSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addmissing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addmissing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addmissing

% Last Modified by GUIDE v2.5 25-Nov-2010 00:19:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addmissing_OpeningFcn, ...
                   'gui_OutputFcn',  @addmissing_OutputFcn, ...
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


% --- Executes just before addmissing is made visible.
function addmissing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addmissing (see VARARGIN)
%Reaction pyk. 
% Choose default command line output for addmissing
handles.output = hObject;
handles.step1 = [handles.uipanel1, handles.act_next, handles.act_cancel];
handles.step2 = [handles.uipanel2, handles.act_next, handles.act_cancel];
handles.step3 = [handles.uipanel3, handles.act_finish];



handles.mets = varargin{1}; %Abbrevitions of missing metabolites;
handles.rxns = varargin{2}; %abbreviation, formula, reversibility, EC number, kegggID, description. 

if isempty(handles.mets{1})
    set(handles.step1,'Visible','off');
    set(handles.step3,'Visible','off');
    set(handles.step2,'Visible','on');
    handles.step = 2;
else 
    set(handles.step2,'Visible','off');
    set(handles.step3,'Visible','off');
    set(handles.step1,'Visible','on');
    handles.step = 1;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addmissing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = addmissing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in act_next.
function act_next_Callback(hObject, eventdata, handles)
% hObject    handle to act_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.step == 1
    set(handles.figure1,'visible','off');
    out = addmetabolites(handles.mets);
    

    if ~isempty(handles.rxns)
            set(handles.step1,'Visible','off');
            set(handles.step3,'Visible','off');
            set(handles.step2,'Visible','on');
            set(handles.figure1,'visible','on');
            handles.step = 2;
        else
            set(handles.step1,'Visible','off');
            set(handles.step2,'Visible','off');
            set(handles.step3,'Visible','on');
            set(handles.figure1,'visible','on');
            handles.step = 3;
    end
else
    set(handles.figure1,'visible','off');
    load rxn.mat;
    load metab.mat;
    load compartments.mat;
    % 1:4 - abbreviation,description,formula, reversible,
    % 8 - CS, 11 - Notes, 10 - reference, 11:12 - EC number, KeggID
    reactions = [handles.rxns(:,1:4), handles.rxns(:,8), handles.rxns(:,11),...
        handles.rxns(:,10), handles.rxns(:,12:13)];
    out = addreactions(rxn,metab,compartments,reactions);%add reactions

    
    set(handles.step1,'Visible','off');
    set(handles.step2,'Visible','off');
    set(handles.step3,'Visible','on');
    handles.step = 3;
    set(handles.figure1,'visible','on');
end

guidata(hObject,handles)

% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);

% --- Executes on button press in act_finish.
function act_finish_Callback(hObject, eventdata, handles)
% hObject    handle to act_finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

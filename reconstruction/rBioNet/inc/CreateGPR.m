% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = CreateGPR(varargin)
% CREATEGPR M-file for CreateGPR.fig
%      CREATEGPR, by itself, creates a new CREATEGPR or raises the existing
%      singleton*.
%
%      H = CREATEGPR returns the handle to a new CREATEGPR or the handle to
%      the existing singleton*.
%
%      CREATEGPR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEGPR.M with the given input arguments.
%
%      CREATEGPR('Property','Value',...) creates a new CREATEGPR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CreateGPR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CreateGPR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CreateGPR

% Last Modified by GUIDE v2.5 18-Aug-2010 13:19:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CreateGPR_OpeningFcn, ...
                   'gui_OutputFcn',  @CreateGPR_OutputFcn, ...
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


% --- Executes just before CreateGPR is made visible.
function CreateGPR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CreateGPR (see VARARGIN)
handles.data = varargin{1};
set(handles.uitable1,'data',handles.data)
if ~isempty(varargin{2}) % Previous gpr set in table2
    handles.data2 = {varargin{2}};
else
   handles.data2 = {};
end


set(handles.uitable2,'data',handles.data2);
% Choose default command line output for CreateGPR
handles.output = [];
handles.selection1 = [];
handles.selection2 = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CreateGPR wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CreateGPR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf)

% --- Executes on button press in group_and.
function group_and_Callback(hObject, eventdata, handles)
% hObject    handle to group_and (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
line = handles.selection2;
data2 = handles.data2;

S = size(line);

genes = {};
GPR = [];
if S(1) <= 1
    msgbox('To group genes, multiple genes must be selected.',...
        'Select genes.','help')
    return
else
    lines = line(:,1);
    genes = data2(lines,1);
        
    for i = 1:S(1)-1
        GPR = [ GPR genes{i} ' and '];
    end
    GPR = ['(' GPR genes{end} ')'];
     
    cnt = 0;
    for k = 1:S(1)
        
        data2(lines(k)-cnt,:) = '';
        cnt = cnt + 1;
        
    end
    if isempty(data2)
        data2 = {GPR};
    else
        
        data2(end+1,:) = {GPR};
    end
end

handles.data2 = data2;

set(handles.uitable2,'data',handles.data2);

guidata(hObject,handles)

% --- Executes on button press in group_or.
function group_or_Callback(hObject, eventdata, handles)
% hObject    handle to group_or (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
line = handles.selection2;
data2 = handles.data2;

S = size(line);

genes = {};
GPR = [];
if S(1) <= 1
    msgbox('To group genes, multiple genes must be selected.',...
        'Select genes.','help')
    return
else
    lines = line(:,1);
    genes = data2(lines,1);
        
    for i = 1:S(1)-1
        GPR = [ GPR genes{i} ' or '];
    end
    GPR = ['(' GPR genes{end} ')'];
     
    cnt = 0;
    for k = 1:S(1)
        
        data2(lines(k)-cnt,:) = '';
        cnt = cnt + 1;
        
    end
    if isempty(data2)
        data2 = {GPR};
    else
        
        data2(end+1,:) = {GPR};
    end
end

handles.data2 = data2;

set(handles.uitable2,'data',handles.data2);

guidata(hObject,handles)

% --- Executes on button press in group_scatter.
function group_scatter_Callback(hObject, eventdata, handles)
% hObject    handle to group_scatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data2 = handles.data2;
line = handles.selection2;
S = size(line);
if ~(S(1) == 1) || S(1) == 0
    return
else
    GPR = data2(line(1),1);
    genes = GPR2Genes(GPR); 
    data2(line(1),:) = '';
    data2 = [data2; genes'];
    handles.data2 = data2;
    set(handles.uitable2,'data',handles.data2);
end

guidata(hObject,handles)

% --- Executes on button press in group_finished.
function group_finished_Callback(hObject, eventdata, handles)
% hObject    handle to group_finished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data2 = handles.data2;
S = size(data2);
if ~(S(1) == 1)
    msgbox('When finished only one line can remain in the Genes and GPR table'...
        ,'To many lines in table.','help');
    return
else
    handles.output = data2{1,1};
end
guidata(hObject,handles)

uiresume

% --- Executes on button press in group_addgene.
function group_addgene_Callback(hObject, eventdata, handles)
% hObject    handle to group_addgene (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
line = unique(handles.selection1(:,1));
S = size(line);

genes = handles.data(line(:,1),1);

data2 = handles.data2;
if isempty(data2)
    handles.data2 = genes;
    set(handles.uitable2,'data',handles.data2);
else
    handles.data2 = [data2; genes];
    set(handles.uitable2,'data',handles.data2);
end

guidata(hObject,handles)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.selection1 = eventdata.Indices;
guidata(hObject,handles)

% --- Executes when selected cell(s) is changed in uitable2.
function uitable2_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.selection2 = eventdata.Indices;
guidata(hObject,handles)


% --- Executes on button press in group_removegene.
function group_removegene_Callback(hObject, eventdata, handles)
% hObject    handle to group_removegene (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
line = handles.selection2;
if size(line) == [0,0]
    return
end
line = unique(line(:,1));
data2 = handles.data2;
S = size(line);
cnt = 0;
for i = 1:S(1)
    data2(line(i)-cnt,:) = '';
    cnt = cnt + 1;
end
handles.data2 = data2;
set(handles.uitable2,'data',handles.data2);
guidata(hObject,handles)

   

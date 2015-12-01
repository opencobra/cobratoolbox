% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = load_reaction(varargin)
% LOAD_REACTION M-file for load_reaction.fig
%      LOAD_REACTION, by itself, creates a new LOAD_REACTION or raises the existing
%      singleton*.
%
%      H = LOAD_REACTION returns the handle to a new LOAD_REACTION or the handle to
%      the existing singleton*.
%
%      LOAD_REACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_REACTION.M with the given input arguments.
%
%      LOAD_REACTION('Property','Value',...) creates a new LOAD_REACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before load_reaction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to load_reaction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help load_reaction

% Last Modified by GUIDE v2.5 04-Oct-2011 17:49:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @load_reaction_OpeningFcn, ...
                   'gui_OutputFcn',  @load_reaction_OutputFcn, ...
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


% --- Executes just before load_reaction is made visible.
function load_reaction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to load_reaction (see VARARGIN)

% Choose default command line output for load_reaction
handles.output = [];


%-------Setup view table begin

% load('rxn.mat') %loads in rxn database.
% handles.rxn = rxn; %tag for rxn database.
handles.rxn = varargin{1};
handles.dispdata = handles.rxn;
set(handles.rxn_view_table,'data',handles.dispdata); %display data in view table.
handles.searchOutcome = 1:length(handles.rxn); %set searchOutcome as default.
handles.rxn_selection = []; %Selecetion of main table

%-------Setup view table end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes load_reaction wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = load_reaction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf)



% --- Executes on button press in search_refresh.
function search_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to search_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rxn = rBioNetSaveLoad('load','rxn');
handles.metab = rBioNetSaveLoad('load','met');


handles.searchOutcome = 1:length(handles.rxn); %set searchOutcome as default.
handles.dispdata = handles.rxn;

set(handles.rxn_view_table,'data',handles.dispdata); %display rxn in rxntable


guidata(hObject, handles);




% --- Executes on button press in search_search.
function search_search_Callback(hObject, eventdata, handles)
% hObject    handle to search_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------------------- search_search_rxn Engine ----------------------- begin

%----Get search_search_rxn value
str = get(handles.search_tag,'String');


%----Get search_search_rxn column
column = get(handles.search_list,'Value');

%----Get data from search_exact_rxn match checkbox
exact = get(handles.search_exact,'Value');
handles.dispdata = rBioNet_search('rxn',column,str,exact);

%set(handles.rxntable,'Data',handles.dispdata_rxn);
set(handles.rxn_view_table,'Data',handles.dispdata);

handles.output = hObject;
guidata(hObject, handles);

% rxn = handles.rxn;
% 
% %----Get data from search_exact_rxn match checkbox
% matchtype = get(handles.search_exact,'Value');
% 
% 
% if matchtype == 1 %Exact match
%     A = strmatch(name,rxn(:,colmn),'exact');
%     
% else %Partial match
%     
%     A = [];
%     for i = 1:size(rxn,1)
%         if isempty(rxn{i,colmn})
%             continue;
%         else
%             k = regexpi(rxn{i,colmn},name);
%             if ~isempty(k)
%                 A = [A i];
%             end
%         end
%     end
%         
% %     k = regexpi(rxn(:,colmn),name);
% %     A = [];
% %     for i = 1:length(k);
% %         if ~isempty(k{i})
% %             A = [A i];
% %         end;
% %     end    
% end
% 
% handles.dispdata = handles.rxn(A,:);
% 
% set(handles.rxn_view_table,'Data',handles.dispdata);
% handles.searchOutcome = A;
% 
% handles.output = hObject;
% guidata(hObject, handles);
%--------------------- search_search_rxn Engine --------------------------- End



% --- Executes when selected cell(s) is changed in rxn_view_table.
function rxn_view_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to rxn_view_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.rxn_selection = eventdata.Indices;
guidata(hObject,handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume;


% --- Executes on button press in act_load.
function act_load_Callback(hObject, eventdata, handles)
% hObject    handle to act_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
S = size(handles.rxn_selection);
if S(1) == 1
    rxnline = handles.dispdata(handles.rxn_selection(1),:);
    
    handles.output = rxnline;
    guidata(hObject,handles)
    uiresume;
end



% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = [];
guidata(hObject,handles);
uiresume;


% --------------------------------------------------------------------
function pathway_ec_Callback(hObject, eventdata, handles)
% hObject    handle to pathway_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webKeggMapper('ec',handles.dispdata{handles.rxn_selection(1),8});


% --------------------------------------------------------------------
function pathway_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to pathway_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webKeggMapper('kegg',handles.dispdata{handles.rxn_selection(1),9});



% --------------------------------------------------------------------
function db_ec_Callback(hObject, eventdata, handles)
% hObject    handle to db_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please a cell and then right-click.','Help','help');
    return;
end
webDatabases('ec',handles.dispdata{handles.rxn_selection(1),8});


% --------------------------------------------------------------------
function db_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to db_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webDatabases('kegg',handles.dispdata{handles.rxn_selection(1),9});



function search_tag_Callback(hObject, eventdata, handles)
% hObject    handle to search_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_tag as text
%        str2double(get(hObject,'String')) returns contents of search_tag as a double
 search_search_Callback(hObject, eventdata, handles);

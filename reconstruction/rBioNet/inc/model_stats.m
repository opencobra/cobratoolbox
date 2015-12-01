% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = model_stats(varargin)
% MODEL_STATS MATLAB code for model_stats.fig
%      MODEL_STATS, by itself, creates a new MODEL_STATS or raises the existing
%      singleton*.
%
%      H = MODEL_STATS returns the handle to a new MODEL_STATS or the handle to
%      the existing singleton*.
%
%      MODEL_STATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL_STATS.M with the given input arguments.
%
%      MODEL_STATS('Property','Value',...) creates a new MODEL_STATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before model_stats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to model_stats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help model_stats

% Last Modified by GUIDE v2.5 12-May-2011 17:28:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @model_stats_OpeningFcn, ...
    'gui_OutputFcn',  @model_stats_OutputFcn, ...
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


% --- Executes just before model_stats is made visible.
function model_stats_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to model_stats (see VARARGIN)

% Choose default command line output for model_stats
handles.output = hObject;


handles.view = 1;
set(handles.uipanel1,'Visible','on');
set(handles.uipanel2,'Visible','off');
%There is one input, a complete reconstruction model.
handles.model = varargin{1};



set(handles.model_rxns,'string',size(handles.model.rxns,1));
set(handles.model_mets,'string',size(handles.model.mets,1));
set(handles.model_genes,'string',size(handles.model.genes,1));
set(handles.model_drxns,'string',size(handles.model.disabled));
compartments = {};
for i = 1:size(handles.model.mets,1)
    met = handles.model.mets{i};
    comp = met(regexpi(met,'[')+1);
    if ~any(strcmp(comp,compartments))
        compartments{end+1} = comp;
    end
end
cmp =[];
for i = 1:length(compartments)
    cmp = [cmp '  ' compartments{i}];
end

set(handles.model_comp,'string',cmp);


%reactions to be added to model
handles.newrxns = {};
%Dead ends
%handles.deadends controls listbox 1 and 2 and handles.newrxns
%Columns
%   1-deadends
%   2-fix, true or false -> listbox 1 if false listbox 2 for true
%   3-fix reaction, abbreviation
%   4-fix (id), number of row.
%handles.newrxns is not size dependent on handles.deadends

deadends = handles.model.mets(detectDeadEnds(handles.model));
handles.deadends = cell(size(deadends,1),4);
handles.deadends(:,1) = deadends;

if ~isempty(deadends)
    load rxn.mat;
    handles.rxn = rxn;
    for i = 1:size(handles.deadends,1)
        for k = 1:size(handles.rxn,1)
            split = regexpi(handles.rxn{k,3}, ']','split');
            if (length(split) == 2) && strcmp([split{1} ']'],handles.deadends{i,1})
                
                met = split{1};
                if strcmp(met(end),'e') %add all extracellular deadends automaticly
                    handles.deadends(i,2:4) = {1,handles.rxn{k,2},k};
                    handles.newrxns(end+1,:) = handles.rxn(k,:);
                else
                    handles.deadends(i,2:4) = {0,handles.rxn{k,2},k};
                end
                
                break;
            else
                handles.deadends(i,2:4) = {0, '', 0};
            end
        end
    end
    
    %print data to listboxes
    listbox1 = {};
    listbox2 = {};
    for i = 1:size(handles.deadends,1)
        if handles.deadends{i,2} == 0
            listbox1{end+1} = handles.deadends{i,1};
        else
            listbox2{end+1} = handles.deadends{i,3};
        end
    end
    
    set(handles.listbox1,'string',listbox1);
    set(handles.listbox2,'string',listbox2);
else
    handles.deadends = {0,0,0,0};
end


%Disable button.
set(handles.act_add,'Enable','off');


%Met cnt
met_data = cell(size(handles.model.mets,1),2);

for i = 1:size(handles.model.S,1) %for all the metabolites
    met_data{i,1} = handles.model.mets{i};
    met_data{i,2} = 0;
    for k = 1:size(handles.model.S,2) %for all the reactions
        if handles.model.S(i,k) ~= 0
            met_data{i,2} = met_data{i,2} + 1;
        end
    end
end
handles.met_data = met_data;
set(handles.met_table,'data',met_data);

%selected values of listboxes, is not a values, it's a string
handles.listbox1_select = [];
handles.listbox2_select = [];


%Reaction listbox
set(handles.listbox_rxns,'String',handles.model.rxns);

%set rxn information
%set(handles.rxn_table,'data',neighborRxn2data(handles.model,1));
set(handles.rxn_text,'String',printRxnFormula(handles.model,handles.model.rxns{1}));
handles.rxn_selection = []; %selection of table

%Spy plot 
axes(handles.axes1);
spy(handles.model.S);
ylabel('Metabolites');
xlabel('Reactions');
title('Sparsity Pattern Of S');

guidata(hObject,handles);



% --- Outputs from this function are returned to the command line.
function varargout = model_stats_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
% --- Executes on button press in act_close.
function act_close_Callback(hObject, eventdata, handles)
% hObject    handle to act_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)


% --- Executes on button press in act_out.
function act_out_Callback(hObject, eventdata, handles)
% hObject    handle to act_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = model2data(handles.model);
rxns = data{1};
description = data{2};

if isempty(handles.newrxns)
    return
end

newrxns = cell(size(handles.newrxns,1),size(rxns,2));
for i = 1:size(handles.newrxns,1)
    newrxns{i,1} = 1; %enable
    newrxns(i,2:5) = handles.newrxns(i,1:4);  % abb,description,formula, rev
    newrxns{i,6} = ''; %gpr
    if handles.newrxns{i,4} == 0%LB
        newrxns{i,7} = 0;
    else
        newrxns{i,7} = -1000;
    end
    
    newrxns{i,8} = -1000;%UB
    newrxns{i,9} = handles.newrxns{i,5};%CS
    % 10 subsystem
    newrxns{i,11} = handles.newrxns{i,7};%ref
    newrxns{i,12} = 'Added automaticly with Reconstruction Analyzer'; %notes, we don't use defult notes
    newrxns{i,13} = handles.newrxns{i,8};
    newrxns{i,14} = handles.newrxns{i,9};
end

rxns = [rxns; newrxns];

if ~(size(unique(rxns(:,2)),1) == size(rxns,1))
    for i = 1:size(newrxns,1)
        if (sum(strcmp(newrxns{i,2},rxns(:,2))) >= 2) %two entries of the same reaction
            msgbox(['Your exchange reaction ' newrxns{i,2} ' creates a dead end '...
                ' and cannot be fixed by adding another exchange reaction.'...
                ' Please remove the reaction and try again.'],'Warning','warn');
        return;
        end
    end
end
    
model = data2model(rxns,description);

if isempty(model)
    return
end
[filename,pathname] = uiputfile( ...
    {'*.mat', 'Model Files (*.mat)';...
    '*.*','All Files (*.*)'},...
    'Save model');
if pathname == 0 %if the user pressed cancelled, then we exit this callback
    return
end
name = filename(1:regexpi(filename,'\.')-1);
v = genvarname(name);
eval([v ' = model']);
save(fullfile(pathname, filename),name);

handles.model = model;
ReconstructionCreator(handles.model);
model_stats(handles.model);
guidata(hObject,handles)



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
%value = get(hObject,'Value');
contents = cellstr(get(hObject,'String'));

met = contents{get(hObject,'Value')};
value = find(strcmp(handles.deadends(:,1),met));
if handles.deadends{value,4} == 0
    set(handles.act_add,'Enable','off');
else
    set(handles.act_add,'Enable','on');
end
handles.listbox1_select = contents{get(hObject,'Value')};

guidata(hObject,handles);


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


% --- Executes on button press in act_add.
function act_add_Callback(hObject, eventdata, handles)
% hObject    handle to act_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.listbox1_select)%if nothing is selected.
    return;
end
value = find(strcmp(handles.deadends(:,1),handles.listbox1_select));
handles.newrxns(end+1,:) = handles.rxn(handles.deadends{value,4},:);
handles.deadends{value,2} = 1;

%print data to listboxes
listbox1 = {};
listbox2 = {};
for i = 1:size(handles.deadends,1)
    if handles.deadends{i,2} == 0
        listbox1{end+1} = handles.deadends{i,1};
    else
        listbox2{end+1} = handles.deadends{i,3};
    end
end

% set(handles.listbox1,'value',value-1);
% guidata(hObject,handles);
%listbox bug from matlab, this should fix it. (Highlighting out of bounce
%item).
val = get(handles.listbox1,'value'); 
if length(listbox1) < val && val ~= 1
    set(handles.listbox1,'value',val-1);
end
set(handles.listbox1,'string',listbox1);
set(handles.listbox2,'string',listbox2);



guidata(hObject,handles)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.view == 1
    handles.view = 0;
    set(handles.uipanel1,'visible','off');
    set(handles.uipanel2,'visible','on');
else
    handles.view = 1;
    set(handles.uipanel2,'visible','off');
    set(handles.uipanel1,'visible','on');
end

guidata(hObject,handles);


% --- Executes on button press in act_plot.
function act_plot_Callback(hObject, eventdata, handles)
% hObject    handle to act_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text_esc,'string','Press Esc or Enter to stop marking metabolites.');
axes(handles.axes2);
met_data = sortrows(handles.met_data,-2);
plot(cell2mat(met_data(:,2)),'+');
gname(met_data(:,1));
ylabel('Connectivity');
xlabel('Metabolites');
set(handles.text_esc,'string','');
guidata(hObject,handles);



% --- Executes on button press in act_remove.
function act_remove_Callback(hObject, eventdata, handles)
% hObject    handle to act_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear handles.newrxns
rxn = strcmp(handles.newrxns(:,2),handles.listbox2_select);
    
handles.newrxns(rxn,:) = '';

%set listbox
value = strcmp(handles.deadends(:,3),handles.listbox2_select);
handles.deadends{value,2} = 0;



%print data to listboxes
listbox1 = {};
listbox2 = {};
for i = 1:size(handles.deadends,1)
    if handles.deadends{i,2} == 0  
        listbox1{end+1} = handles.deadends{i,1};
    else
        listbox2{end+1} = handles.deadends{i,3};
    end
end
% a=get(handles.listbox2,'value');
% set(handles.listbox2,'value',a-1);
% guidata(hObject,handles);

%if end is removed listbox selection is out of bounce, this is a quick fix.
val = get(handles.listbox2,'value'); 
if length(listbox2) < val && val ~= 1
    set(handles.listbox2,'value',val-1);
end
set(handles.listbox1,'string',listbox1);
set(handles.listbox2,'string',listbox2');

guidata(hObject,handles);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
contents = cellstr(get(hObject,'String'));

handles.listbox2_select = contents{get(hObject,'Value')};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(gcf);


% --- Executes on selection change in listbox_rxns.
function listbox_rxns_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_rxns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_rxns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_rxns


set(handles.rxn_text,'String',printRxnFormula(handles.model,handles.model.rxns{get(hObject,'Value')}));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listbox_rxns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_rxns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in act_tab.
function act_tab_Callback(hObject, eventdata, handles)
% hObject    handle to act_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.view == 1
    set(handles.uipanel1,'visible','off');
    set(handles.uipanel2,'visible','on');
    handles.view = 0;
else
    set(handles.uipanel2,'visible','off');
    set(handles.uipanel1,'visible','on');
    handles.view = 1;
end

guidata(hObject,handles)


% --------------------------------------------------------------------
function keggmapper_ec_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

data = get(handles.rxn_table,'data');
str = data{handles.rxn_selection(1),5};

webKeggMapper('ec',str);

% --------------------------------------------------------------------
function keggmapper_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

data = get(handles.rxn_table,'data');
str = data{handles.rxn_selection(1),6};

webKeggMapper('kegg',str);


% --------------------------------------------------------------------
function databases_ec_Callback(hObject, eventdata, handles)
% hObject    handle to databases_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

data = get(handles.rxn_table,'data');
str = data{handles.rxn_selection(1),5};
webDatabases('ec',str);


% --------------------------------------------------------------------
function databases_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to databases_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxn_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

data = get(handles.rxn_table,'data');
str = data{handles.rxn_selection(1),6};
webDatabases('kegg',str,1);


% --- Executes when selected cell(s) is changed in rxn_table.
function rxn_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to rxn_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.rxn_selection = eventdata.Indices;
guidata(hObject,handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%set(handles.rxn_table,'data',neighborRxn2data(handles.model,get(hObject,'Value')));

%set(handles.figure1,'Pointer','watch');
data = neighborRxn2data(handles.model,get(handles.listbox_rxns,'Value'));
set(handles.rxn_table,'data',data);
%set(handles.figure1,'Pointer','arrow');
guidata(hObject,handles)

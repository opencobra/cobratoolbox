% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
% -------------------- handles. ------------------ Very incomplete
%
% handles.searchOutcome:    search_search_rxn outcome from Search1 for rxn
% handles.searchOutcome2:   search_search_rxn outcome from search_search_met for metabolites
% handles.rxn:              reaction databse
% handles.metab:            metabolite database
% handles.dispdata_rxn:     dispdlayed data in metatable
% handles.dispdata_met:     displayed data in rxntable
% handles.meta_meta:        Added metabolites for new rxn, displayed data in meta_table
% handles.newrxn:           new rxn created by generate rxn, saved in
%                           database in rxn_save.
% handles.similar:          Used to store similarity
%
% Stefan G. Thorleifsson July 2010



function varargout = ReconstructionTool(varargin)
% RECONSTRUCTIONTOOL M-file for ReconstructionTool.fig
%      RECONSTRUCTIONTOOL, by itself, creates a new RECONSTRUCTIONTOOL or raises the existing
%      singleton*.
%
%      H = RECONSTRUCTIONTOOL returns the handle to a new RECONSTRUCTIONTOOL or the handle to
%      the existing singleton*.
%
%      RECONSTRUCTIONTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECONSTRUCTIONTOOL.M with the given input arguments.
%
%      RECONSTRUCTIONTOOL('Property','Value',...) creates a new RECONSTRUCTIONTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReconstructionTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReconstructionTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReconstructionTool

% Last Modified by GUIDE v2.5 21-Sep-2011 14:21:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ReconstructionTool_OpeningFcn, ...
    'gui_OutputFcn',  @ReconstructionTool_OutputFcn, ...
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


% --- Executes just before ReconstructionTool is made visible.
function ReconstructionTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReconstructionTool (see VARARGIN)
%

handles.output = [];
%--------------- Initialize handles -----------------

handles.rxntable_selection = [];
handles.meta_table_selection = [];
handles.metatable_selection = [];
handles.dispdata_rxn = [];
handles.dispdata_met = [];
handles.rxn = [];
handles.metab = [];
handles.newmet = [];
handles.meta_meta = [];
handles.similar = [];
handles.last_path = '';


compartments = rBioNetSaveLoad('load','comp');
if isempty(compartments)
    delete(gcf)
    return
end

%load('compartments'); %Load in compartments (.mat)
set(handles.meta_compartment,'String',compartments);

%Handles tab1 and tab2 are visual tabs for interface, handles.tab1 contains
%all the handles for the rxn view and handles.tab2 for metabolite view.
handles.tab1 = [handles.rxntable, handles.shearch_list_rxn, handles.search_exact_rxn,...
    handles.search_search_rxn, handles.search_refresh_rxn, handles.search_tag_rxn];
handles.tab2 = [handles.metatable, handles.search_list_met, handles.search_exact_met...
    handles.search_search_met,handles.search_refresh_met, handles.search_tag_met];

handles.group_rxn1 = [handles.rxn_abbreviation, handles.rxn_description,...
    handles.rxn_reversible, handles.rxn_confidence,...
    handles.rxn_abbreviation_text, handles.rxn_description_text,...
    handles.rxn_reversible_text, handles.rxn_confidence_text,];
handles.group_rxn2 = [handles.rxn_notes,handles.rxn_notes_text,...
    handles.rxn_references, handles.rxn_references_text,...
    handles.rxn_ecnumber,handles.rxn_ecnumber_text, handles.rxn_keggid,...
    handles.rxn_keggid_text];


handles.group_meta1 = [handles.meta_abbreviation, handles.meta_compartment,...
    handles.meta_side, handles.meta_coefficient,handles.text13,...
    handles.text15, handles.text14, handles.text16];
handles.group_meta2 = [handles.meta_charge, handles.meta_chargedformula,...
    handles.meta_description,handles.text22, handles.text25, handles.text12];

% Start with tab1 and new uipanel_reaction visible

set(handles.tab1,'Visible','on');
set(handles.tab2,'Visible','off');

set(handles.uipanel_reaction,'Visible','on');
set(handles.uipanel_metabolite,'Visible','off');

set(handles.group_rxn2,'Visible','off');
set(handles.group_rxn1,'Enable','on');

set(handles.group_meta2,'Visible','off');
set(handles.group_meta1,'Enable','on');

%Empty tables
set(handles.metatable,'data','');
set(handles.rxntable,'data','');

% ---------- Open and display  -------------- begin



% dbase = load('rxn.mat');
% name = fieldnames(dbase);
% dbase = eval(['dbase.' name{1}]);
% handles.rxn = dbase;
% handles.dispdata_rxn = handles.rxn;


% dbase = load('metab.mat');
% name = fieldnames(dbase);
% dbase = eval(['dbase.' name{1}]);
% handles.metab = dbase;
% handles.dispdata_met = handles.metab;

handles.rxn = rBioNetSaveLoad('load','rxn');
if isempty(handles.rxn)
    delete(gcf)
    return
end
handles.dispdata_rxn = handles.rxn;

handles.metab = rBioNetSaveLoad('load','met');
if isempty(handles.metab)
    delete(gcf)
    return;
end
handles.dispdata_met = handles.metab;
 

% ---------- Open and display  -------------- end

%Adding data goes through searchOutcome so it needs to carry
%1:length(rxn or metab) when nothing has been searched for.
handles.searchOutcome = 1:length(handles.rxn);
handles.searchOutcome2 = 1:length(handles.metab);

% Choose default c2ommand line output for ReconstructionTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReconstructionTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReconstructionTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


% --- Executes on button press in search_refresh_rxn.
function search_refresh_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to search_refresh_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.rxn = rBioNetSaveLoad('load','rxn');
handles.dispdata_rxn = handles.rxn;
handles.searchOutcome = 1:length(handles.rxn); %set searchOutcome as default.


set(handles.rxntable,'data',handles.dispdata_rxn); %display rxn in rxntable

handles.output = hObject;
guidata(hObject, handles);



% --- Executes on button press in search_search_rxn.
function search_search_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to search_search_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%----------------------- search_search_rxn Engine ----------------------- begin

%----Get search_search_rxn value
str = get(handles.search_tag_rxn,'String');


%----Get search_search_rxn column
column = get(handles.shearch_list_rxn,'Value');

%----Get data from search_exact_rxn match checkbox
exact = get(handles.search_exact_rxn,'Value');
handles.dispdata_rxn = rBioNet_search('rxn',column,str,exact);

set(handles.rxntable,'Data',handles.dispdata_rxn);


handles.output = hObject;
guidata(hObject, handles);

%--------------------- search_search_rxn Engine --------------------------- End



% --- Executes when selected cell(s) is changed in rxntable.
function rxntable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to rxntable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

handles.rxntable_selection = eventdata.Indices;


guidata(hObject, handles);

%--------------------------------------------------------------------
%--------------------------------------------------------------------
%--------- Displaying selected rxn in New rxn -----------------------
%--------------------------------------------------------------------
%--------------------------------------------------------------------

% --- Executes on key press with focus on rxntable and none of its controls.
function rxntable_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to rxntable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


%---------------------------- Save new rxn -----------------------

% --- Executes on button press in rxn_save.
function rxn_save_Callback(hObject, eventdata, handles)
% hObject    handle to rxn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%------------------------ Generate Reaction ---------------------- begin

rxn = handles.rxn;
if isempty(handles.meta_meta)
    msgbox('No reaction to save.','No reaction','help');
    return
end

output = BalancePrep(handles.meta_meta);

leftside = output{1};
rightside = output{2};
charge_l = output{3};
charge_r = output{4};
balance = balancecheck(handles.meta_meta); %Verify that reaction is balanced.




if ~isempty(balance) || ~(charge_l == charge_r) %reaction is unbalanced
    charge = cell(3,1);
    charge(1:3,1) = {'Charge', charge_l, charge_r};
    
    balance_charge = [charge, balance];% All data is here
    
    con = unbalanced(balance_charge,get(handles.rxn_abbreviation,'String')); % Initiate unbalanced window
    
    if con == 0
        set(handles.formula,'String','');
        guidata(hObject, handles);
        return;
    end
end
%---------- Creating formula ---------------- end
% All cells in rxn database are cells, to simplefy all new rxn are also
% strings, that is col4 and col5.
% Seting (non)reversible sign
col4 = get(handles.rxn_reversible,'Value')-1;
if col4 == 0
    rev_str = ' -> ';
else
    rev_str = ' <=> ';
end

col1 = get(handles.rxn_abbreviation,'String');
col2 = get(handles.rxn_description,'String');

col3 = [leftside rev_str rightside];
set(handles.formula,'String',col3);
col4 = num2str(col4);
col5 = num2str(get(handles.rxn_confidence,'Value')-1);
col6 = get(handles.rxn_notes,'String');
col7 = get(handles.rxn_references,'String');
col8 = get(handles.rxn_ecnumber,'String');
col9 = get(handles.rxn_keggid,'String');
time = clock;
col10 = [];
for i = 1:length(time)-3
    if isempty(col10)
        col10 = [num2str(round(time(i)))];
    else
        col10 = [col10 '/' num2str(round(time(i)))];
    end
end

handles.newrxn = cell(1,10);

handles.newrxn(1,:) = {col1 col2 col3 col4 col5 col6 col7 col8 col9 col10};

similar = similarity(col3,rxn(:,3));
handles.similar = similar;
if ~isempty(similar)
    similarities(similar,rxn(similar,:));
    uiwait;
end

guidata(hObject,handles)
%------------------------ Generate Reaction ---------------------- end

%-------------------------- Save Reaction ------------------------ begin

if ~isempty(handles.similar)
    eq = ReactionEq(col3,rxn(handles.similar,:));
    if ~isempty(eq)
        
        msgbox(['The new reaction can be found in database under the'...
            ' abbreviation ' eq ' and will therefor not be saved.'],...
            'Reaction exist in database','warn');
        return
    end
end
newrxn = handles.newrxn;

if isempty(newrxn{1}) || ~isempty(strmatch(newrxn{1},'','exact'))
    msgbox('No rxn name specified.','Specify name.','help');
    return;
elseif ~isempty(strmatch(newrxn{1},rxn(:,1),'exact'))
    name = newrxn{1};
    str = [name ' already exists in rxn database.'];
    msgbox(str,'Name already exists','help');
    return;
else
    
    for i = 1:length(newrxn)
        if isa(newrxn{i},'cell')
            a = newrxn{i};
            newrxn{i} = a{1};
        end
    end
    
    save_rxn = questdlg('Are you sure you want to save?', ...
        'Save Data', ...
        'Yes', 'No', 'Yes');
    
    %perform the following operation depending on the option chosen
    switch save_rxn,
        case 'Yes',
            handles.rxn(end+1,:) = newrxn;
            handles.rxn = sortrows(handles.rxn,1);

            out = rBioNetSaveLoad('save','rxn',handles.rxn);
            if out == 1
                msgbox('Your reaction has been saved.','New reaction saved.','help')
            end
        case 'No',
            %Do nothing.
    end % switch
    
end

%-------------------------- Save Reaction ------------------------ end
guidata(hObject, handles);

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%-----------------------  Changing tabs ------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% --- Executes on button press in metaboliteviewtable.
function metaboliteviewtable_Callback(hObject, eventdata, handles)
% hObject    handle to metaboliteviewtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tab2,'Visible','on');
set(handles.tab1,'Visible','off');

% --- Executes on button press in rxnviewtable.
function rxnviewtable_Callback(hObject, eventdata, handles)
% hObject    handle to rxnviewtable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tab1,'Visible','on');
set(handles.tab2,'Visible','off');


%---------------------------------------------------------------------
%---------------------------------------------------------------------
%--------------  FUNCTIONS RELATED TO SEARCHING metab -----------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% --- Executes on button press in search_refresh_met.
function search_refresh_met_Callback(hObject, eventdata, handles)
% hObject    handle to search_refresh_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.metab = rBioNetSaveLoad('load','met');
handles.dispdata_met = handles.metab;
handles.searchOutcome2 = 1:length(handles.metab);


set(handles.metatable,'data',handles.dispdata_met);
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in search_search_met.
function search_search_met_Callback(hObject, eventdata, handles)
% hObject    handle to search_search_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------------------- search_search_metabolite Engine ----------------------- begin

%----Get search_search_rxn value
str = get(handles.search_tag_met,'String');

%----Get search_search_rxn column
colmn  = get(handles.search_list_met,'Value');
exact = get(handles.search_exact_met,'Value');

handles.dispdata_met = rBioNet_search('met',colmn',str,exact);

set(handles.metatable,'Data',handles.dispdata_met);


handles.output = hObject;
guidata(hObject, handles);
%--------------------- search_search_metabolite Engine --------------------------- End


% --- Executes when selected cell(s) is changed in metatable.
function metatable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to metatable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


handles.metatable_selection = eventdata.Indices;
S = size(handles.metatable_selection);
if S(1) == 1
    line = handles.metatable_selection(1);
    metaline = handles.dispdata_met(line,:);
    set(handles.meta_abbreviation,'String',metaline(1));
    set(handles.meta_description,'String',metaline(2));
    set(handles.meta_chargedformula,'String',metaline(4));
    set(handles.meta_charge,'String',metaline(5));
end
guidata(hObject, handles);








% Add metabolite to list
% --- Executes on button press in addmeta.
function addmeta_Callback(hObject, eventdata, handles)
% hObject    handle to addmeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Make sure right tab is open.
set(handles.tab2,'Visible','on');
set(handles.tab1,'Visible','off');

meta_meta = handles.meta_meta;
clmn1 = get(handles.meta_abbreviation,'String');
clmn2 = get(handles.meta_description,'String');
clmn3 = get(handles.meta_coefficient,'String');
clmn3 = str2num(clmn3);

if isempty(clmn1) % If no metabolite is selected
    msgbox('You have to select metabolite from the metabolite table (above) to add.'...
        ,'Select metabolite in metab viewer','help');
    return
elseif isempty(clmn3) % if coefficient is not valid
    msgbox('Coefficient must be a integer','Invalid Coefficient','help');
    return
elseif  clmn3 <= 0 || clmn3 >= 1000 % if coefficient is not valid
    msgbox('Coefficient must be a number larger than 0 and smaller than 1000'...
        ,'Invalid Coefficient','help');
    return
else
end

%-------------- COMPARTMENT ------------------ begin

str_cmp = get(handles.meta_compartment,'String');
val_cmp = get(handles.meta_compartment,'Value');
clmn4 = str_cmp{val_cmp};

%-------------- COMPARTMENT ------------------ end

%----------------- SUBSTATE/PRODUCT ---------------------- begin
str_side = get(handles.meta_side,'String');
val_side = get(handles.meta_side,'Value');
clmn5 = str_side{val_side};
%----------------- SUBSTRATE/PRODUCT ---------------------- end
clmn6 = get(handles.meta_chargedformula,'String');
clmn7 = get(handles.meta_charge,'String');


new_meta = [clmn1 clmn2 clmn3 clmn4 clmn5 clmn6 clmn7];
meta_meta = [meta_meta; new_meta];
handles.meta_meta = meta_meta;
set(handles.meta_table,'data',meta_meta);

%-----missing update formula
handles.output = hObject;
guidata(hObject,handles)

% --- Executes on button press in removemeta.
function removemeta_Callback(hObject, eventdata, handles)
% hObject    handle to removemeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



meta_meta = handles.meta_meta;
S = size(handles.meta_table_selection);
S2 = size(meta_meta);
if S2(1) == 0 %If no cell is selected
    msgbox('There are no metabolites in the meta_table.','No metabolites',...
        'help');
elseif S(1) == 1 && S2(1) >= 2 % If there are more then one metab. present
    i = handles.meta_table_selection(1);
    meta_meta(i:end-1,:) = meta_meta(i+1:end,:);
    meta_meta(end,:) = [];
elseif S(1) == 1 && S2(1) == 1 %If there is only on metab. present
    meta_meta = [];
else %If more than one line is selected
    msgbox('(Only) one metabolite must be selected at the time.','Remove metabolite'...
        ,'help');
end
set(handles.meta_table,'data',meta_meta); %Update meta_table
handles.meta_meta = meta_meta;

guidata(hObject, handles);

% --- Executes when selected cell(s) is changed in meta_table.
function meta_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to meta_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

handles.meta_table_selection = eventdata.Indices;
handles.output = hObject;
guidata(hObject, handles);





% --- Executes on button press in rxn_load.
function rxn_load_Callback(hObject, eventdata, handles)
% hObject    handle to rxn_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.rxntable_selection)
    return
end

answer = questdlg('Are you sure you want to load reaction?',...
    'Load reaction','Yes','No','Yes');
switch answer
    case 'Yes'
    otherwise
        return
end

%Make sure right tab is open.
set(handles.tab1,'Visible','on');
set(handles.tab2,'Visible','off');



dispdata = handles.dispdata_rxn;
metab = handles.metab;
S = size(handles.rxntable_selection);
compartment = get(handles.meta_compartment,'string');
rxnline = dispdata(handles.rxntable_selection(1),:); %All data on reaction.
if S(1) == 1
    meta_meta = LoadReaction(rxnline,metab,compartment);
    
    if isempty(meta_meta)
        return
    end
else
    return
end


set(handles.rxn_abbreviation,'String',rxnline(1));
set(handles.rxn_description,'String',rxnline(2));
set(handles.meta_table,'data',meta_meta);
set(handles.formula,'String',rxnline{3});
set(handles.rxn_reversible,'Value',str2double(rxnline{4})+1);
set(handles.rxn_confidence,'Value',str2double(rxnline{5})+1);
set(handles.rxn_notes,'String',rxnline(6));
set(handles.rxn_references,'String',rxnline(7));
set(handles.rxn_ecnumber,'String',rxnline(8));
set(handles.rxn_keggid,'String',rxnline(9));

handles.meta_meta = meta_meta;

guidata(hObject, handles);




% --- Executes on button press in meta_newrxn.
function meta_newrxn_Callback(hObject, eventdata, handles)
% hObject    handle to meta_newrxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Are you sure you want to clear all reaction properties?',...
    'New reaction','Yes','No','Yes');
switch answer
    case 'Yes'
    otherwise
        return
end

meta_meta = handles.meta_meta;
handles.generate_rxn = 0;
meta_meta = [];
new = '';
set(handles.meta_table,'data',meta_meta);

set(handles.rxn_abbreviation,'String',new);
set(handles.rxn_description,'String',new);
set(handles.rxn_notes,'String',new);
set(handles.rxn_references,'String',new);
set(handles.rxn_keggid,'String',new);
set(handles.rxn_ecnumber,'String',new);

set(handles.rxn_reversible,'Value',1);
set(handles.rxn_confidence,'Value',1);
handles.meta_meta = meta_meta;
guidata(hObject, handles);



% --------------------------------------------------------------------
function help_about_Callback(hObject, eventdata, handles)
% hObject    handle to help_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%msgbox({'Please see manual for tutorials and detailed Information.',...
 %   '','Created by Thorleifsson and Thiele.','2011','Center of Systems Biology',...
 %   'University of Iceland'},'Help','help');
rBioNetAbout;
% --------------------------------------------------------------------
function edit_compartment_Callback(hObject, eventdata, handles)
% hObject    handle to edit_compartment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmp = get(handles.meta_compartment,'String');

cmp_new = compartment(cmp); %Open add compartment window
%uiwait; %Wait until the window has been closed



if ~isempty(cmp_new) %new_compartment will be empty if cancel is hit.
    
    %new_compartment is only number when removing compartment
    if isa(cmp_new,'numeric')
        cmp(cmp_new) = '';
        compartments = sort(cmp);
        
        
    else %If not numeric then new compartmant has been added.
        cmp{end+1} = cmp_new;
        compartments = sort(cmp);
        
    end
    set(handles.meta_compartment,'String',compartments);
    rBioNetSaveLoad('save','comp',compartments);
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg('Do you want to close the GUI?',...
    'Close Reguest Function',...
    'Yes','No','Yes');

switch selection,
    case 'Yes'
        delete(gcf)
    case 'No'
        return
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in met_rxn.
function met_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to met_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of met_rxn
val = get(hObject,'Value');
if val == 1
    set(handles.uipanel_reaction,'Visible','off')
    set(handles.uipanel_metabolite,'Visible','on')
elseif val == 0
    set(handles.uipanel_reaction,'Visible','on')
    set(handles.uipanel_metabolite,'Visible','off')
end
guidata(hObject, handles);




% --- Executes on button press in newmet_newmet.
function newmet_newmet_Callback(hObject, eventdata, handles)
% hObject    handle to newmet_newmet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Are you sure you want to start a new metabolite?',...
        'New metabolite','Yes','No','Yes');
    switch answer
        case 'Yes'
        otherwise
            return
    end


set(handles.newmet_abbreviation,'String','');
set(handles.newmet_neutral,'String','');
set(handles.newmet_charged,'String','');
set(handles.newmet_charge,'String','');
set(handles.newmet_keggid,'String','');
set(handles.newmet_pubchemid,'String','');
set(handles.newmet_cheblid,'String','');
set(handles.newmet_description,'String','');
set(handles.newmet_inchi,'String','');
set(handles.newmet_smile,'String','');
handles.newmet = [];
guidata(hObject, handles);

% --- Executes on button press in newmet_loadmet.
function newmet_loadmet_Callback(hObject, eventdata, handles)
% hObject    handle to newmet_loadmet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Are you sure you want to load metabolite?',...
        'New metabolite','Yes','No','Yes');
    switch answer
        case 'Yes'
        otherwise
            return
    end

%Make sure metabolite view table is on
set(handles.tab2,'Visible','on');
set(handles.tab1,'Visible','off');

S = size(handles.metatable_selection);
if S(1) == 1
    metaline = handles.dispdata_met(handles.metatable_selection(1),:);
    set(handles.newmet_abbreviation,'String',metaline{1});
    set(handles.newmet_description,'String',metaline{2});
    set(handles.newmet_neutral,'String',metaline{3});
    set(handles.newmet_charged,'String',metaline{4});
    set(handles.newmet_charge,'String',metaline{5});
    set(handles.newmet_keggid,'String',metaline{6});
    set(handles.newmet_pubchemid,'String',metaline{7});
    set(handles.newmet_cheblid,'String',metaline{8});
    set(handles.newmet_inchi,'String',metaline{9});
    set(handles.newmet_smile,'String',metaline{10});
else
    msgbox('Select one cell from the metabolite you want to load.',...
        'To many selection.','warn');
end
guidata(hObject, handles);
% --- Executes on button press in newmet_savemet.
function newmet_savemet_Callback(hObject, eventdata, handles)
% hObject    handle to newmet_savemet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------------------- Generate metabolite ------------------
newmet{1}   = strtrim(get(handles.newmet_abbreviation,'String'));
newmet{2}   = strtrim(get(handles.newmet_description,'String'));
newmet{3}   = strtrim(get(handles.newmet_neutral,'String'));
newmet{4}   = strtrim(get(handles.newmet_charged,'String'));
newmet{5}   = strtrim(get(handles.newmet_charge,'String'));
newmet{5}   = str2double(strtrim(newmet{5})); %if not a number it becomes empty
newmet{6}   = strtrim(get(handles.newmet_keggid,'String'));
newmet{7}   = strtrim(get(handles.newmet_pubchemid,'String'));
newmet{8}   = strtrim(get(handles.newmet_cheblid,'String'));
newmet{9}   = strtrim(get(handles.newmet_inchi,'String'));
newmet{10}  = strtrim(get(handles.newmet_smile,'String'));
newmet{11}  = strtrim(get(handles.newmet_hmdb,'String'));

if isempty(newmet{1}) || isempty(newmet{2}) || isempty(newmet{4})
    msgbox('Edit box with marked with (*) must be filled out.',...
        'Data missing.','help')
    return
elseif isempty(newmet{5})
    msgbox('Charge must be a number.','Charge.','warn');
    return
end


charge_formula = []; %Check similar charge formula.
if ~isempty(strmatch(newmet{1},handles.metab(:,1),'exact'))
    msgbox(['Abbreviation ' newmet{1} ' already exists in database']...
        , 'Check Abbreviation.','warn');
    return
else
    a =  strmatch(newmet{4},handles.metab(:,4),'exact');
    if ~isempty(a)
        charge_formula = [handles.metab(a,:)];
        
    end
end


if ~isempty(charge_formula)
   sim_general(charge_formula)
    
    % msgbox([ charge_formula ' (has) have the same charged formula as your metabolite.']...
    %    , 'Similar charged formula.','help');
    uiwait;
end

handles.newmet = newmet;
guidata(hObject, handles);

%----------------------------- Generate metabolite ----------------- end



if ~isempty(handles.newmet)
    time = clock;
    t = [];
    for i = 1:length(time)-3
        if isempty(t)
            t = [num2str(round(time(i)))];
        else
            t = [t '/' num2str(round(time(i)))];
        end
    end
    
end
handles.newmet{end+1} = t;
handles.newmet{5} = num2str(handles.newmet{5});
save_met = questdlg('Are you sure you want to save?', ...
    'Save Data', ...
    'Yes', 'No', 'Yes');

%perform the following operation depending on the option chosen
switch save_met,
    case 'Yes',
        handles.metab(end+1,:) = handles.newmet;
        handles.metab = sortrows(handles.metab,1);
        rBioNetSaveLoad('save','met',handles.metab);
        msgbox('Your metabolite has been saved.','Metabolite saved','help');
    case 'No',
        %Do nothing.
end % switch


guidata(hObject, handles);



% --- Executes on button press in newmet_generate.
function newmet_generate_Callback(hObject, eventdata, handles)
% hObject    handle to newmet_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newmet{1} = get(handles.newmet_abbreviation,'String');
newmet{2} = get(handles.newmet_description,'String');
newmet{3} = get(handles.newmet_neutral,'String');
newmet{4} = get(handles.newmet_charged,'String');
newmet{5} = get(handles.newmet_charge,'String');
newmet{5} = str2num(newmet{5}); %if not a number it becomes empty
newmet{6} = get(handles.newmet_keggid,'String');
newmet{7} = get(handles.newmet_pubchemid,'String');
newmet{8} = get(handles.newmet_cheblid,'String');
newmet{9} = get(handles.newmet_inchi,'String');
newmet{10} = get(handles.newmet_smile,'String');



charge_formula = []; %Check similar charge formula.
for i = 1:length(handles.metab)
    if strmatch(newmet{1},handles.metab{i,1},'exact')
        msgbox(['Abbreviation ' newmet{1} ' already exists in database']...
            , 'Check Abbreviation.','warn');
        return
    elseif strmatch(newmet{4},handles.metab{i,4},'exact')
        charge_formula = [charge_formula,  [handles.metab{i,1} ', ']];
    end
end


if ~isempty(charge_formula)
    msgbox([ charge_formula ' (has) have the same charged formula as your metabolite.']...
        , 'Similar charged formula.','help')
end

handles.newmet = newmet;
guidata(hObject, handles);


% --------------------------------------------------------------------
function file_open_model_creator_Callback(hObject, eventdata, handles)
% hObject    handle to file_open_model_creator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ReconstructionCreator;



% --------------------------------------------------------------------
function addtxt_reactions_Callback(hObject, eventdata, handles)
% hObject    handle to addtxt_reactions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
meta_compartment = get(handles.meta_compartment,'string');
% addreactions(handles.rxn,handles.metab,meta_compartment,[]);
addreactions([]);
guidata(hObject,handles)

% --------------------------------------------------------------------
function addtxt_metabolites_Callback(hObject, eventdata, handles)
% hObject    handle to addtxt_metabolites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addmetabolites([],[]);

guidata(hObject,handles)



% --- Executes on button press in newmeta_more.
function newmeta_more_Callback(hObject, eventdata, handles)
% hObject    handle to newmeta_more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of newmeta_more
val = get(hObject,'Value');

if val == 0
    set(handles.group_meta2,'Visible','off');
    set(handles.group_meta1,'Visible','on');
else
    set(handles.group_meta1,'Visible','off');
    set(handles.group_meta2,'Visible','on');
end

% --- Executes on button press in rxn_more.
function rxn_more_Callback(hObject, eventdata, handles)
% hObject    handle to rxn_more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rxn_more

val = get(hObject,'Value');

if val == 0
    set(handles.group_rxn2,'Visible','off');
    set(handles.group_rxn1,'Visible','on');
else
    set(handles.group_rxn1,'Visible','off');
    set(handles.group_rxn2,'Visible','on');
end




% --------------------------------------------------------------------
function context_pubchem_Callback(hObject, eventdata, handles)
% hObject    handle to context_pubchem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.metatable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end

webDatabases('pubchem',handles.dispdata_met{handles.metatable_selection(1),7});


% --------------------------------------------------------------------
function context_chebi_Callback(hObject, eventdata, handles)
% hObject    handle to context_chebi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Nothing selected
if isempty(handles.metatable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webDatabases('chebi',handles.dispdata_met{handles.metatable_selection(1),8});

% --------------------------------------------------------------------
function context_hmdb_Callback(hObject, eventdata, handles)
% hObject    handle to context_hmdb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.metatable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webDatabases('hmdb',handles.dispdata_met{handles.metatable_selection(1),11});

% --------------------------------------------------------------------
function context_ec_Callback(hObject, eventdata, handles)
% hObject    handle to context_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxntable_selection)
    msgbox('Please a cell and then right-click.','Help','help');
    return;
end
webDatabases('ec',handles.dispdata_rxn{handles.rxntable_selection(1),8});

% --------------------------------------------------------------------
function context_kegg_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to context_kegg_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.rxntable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webDatabases('kegg',handles.dispdata_rxn{handles.rxntable_selection(1),9});

% --------------------------------------------------------------------
function context_kegg_met_Callback(hObject, eventdata, handles)
% hObject    handle to context_kegg_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.metatable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webDatabases('kegg',handles.dispdata_met{handles.metatable_selection(1),6});


% --- Executes during object deletion, before destroying properties.
function meta_table_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to meta_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function keggmapper_ec_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxntable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webKeggMapper('ec',handles.dispdata_rxn{handles.rxntable_selection(1),8});


% --------------------------------------------------------------------
function keggmapper_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.rxntable_selection)
    msgbox('Please select cell and then right-click.','Help','help');
    return;
end
webKeggMapper('kegg',handles.dispdata_rxn{handles.rxntable_selection(1),9});


% --------------------------------------------------------------------
function add_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to add_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.last_path)
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Mat files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select reconstruction file.',...
        'MultiSelect','off',handles.last_path);
else
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Mat files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select reconstruction file.',...
        'MultiSelect','off');
end

if pathname == 0
    return
end
handles.last_path = pathname;
guidata(hObject,handles);
dbase = load(fullfile(pathname,input_file));
name = fieldnames(dbase);
dbase = eval(['dbase.' name{1}]);
model= dbase;

output = model2data(model,1);
reactions = output{1};
%----reaction data lineup:
% 1.rxns
% 2.rxnNames
% 3.formula
% 4.reversible
% 5.grRules,
% 6.lb
% 7.ub
% 8.confidenceScores
% 9.subSystems
% 10.citations
% 11.comments
% 12.ecNumbers
% 13.KeggID.
%enable is set infront afterwards. 
%---------

reactions = [reactions(:,2:5) reactions(:,9) reactions(:,12) reactions(:,11),...
    reactions(:,13), reactions(:,14)];
%----input order in addreactions
% abbreviation
% description
% formula
% reversible
% Mechanism Confidence Score
% Notes
% References
% EC number
% Keggid
%----------
metabolites = output{5};
%metabolite neutral formula is column nr. 3 but that is normally not
%included in reconstructions. 

%Metabolite lineup
% Abbreviation
% Description
% Neutral formula
% charged formula
% charge
% KeggID
% PubChemID
% CheBiID
% Inchi String
% Smile
% HMDB
% Last modified


%metabolite line-up from model2data
% mets 
% metNames
% metFormulas chargeFormula
% metCharge
% metChebiID
% metKeggID
% metPubCHem
% metInchiString
% metSmile

metabolites = [metabolites(:,1:2) cell(size(metabolites,1),1) metabolites(:,3:end)];

addmetabolites(metabolites,reactions);

%get metabolites and reactions


% --------------------------------------------------------------------
function settings_Callback(hObject, eventdata, handles)
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rBioNetSettings;



function search_tag_met_Callback(hObject, eventdata, handles)
% hObject    handle to search_tag_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_tag_met as text
%        str2double(get(hObject,'String')) returns contents of search_tag_met as a double
search_search_met_Callback(hObject, eventdata, handles);



function search_tag_rxn_Callback(hObject, eventdata, handles)
% hObject    handle to search_tag_rxn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_tag_rxn as text
%        str2double(get(hObject,'String')) returns contents of search_tag_rxn as a double
search_search_rxn_Callback(hObject, eventdata, handles);

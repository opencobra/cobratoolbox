% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

function varargout = ReconstructionCreator(varargin)
% RECONSTRUCTIONCREATOR M-file for ReconstructionCreator.fig
%      RECONSTRUCTIONCREATOR, by itself, creates a new RECONSTRUCTIONCREATOR or raises the existing
%      singleton*.
%
%      H = RECONSTRUCTIONCREATOR returns the handle to a new RECONSTRUCTIONCREATOR or the handle to
%      the existing singleton*.
%
%      RECONSTRUCTIONCREATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECONSTRUCTIONCREATOR.M with the given input arguments.
%
%      RECONSTRUCTIONCREATOR('Property','Value',...) creates a new RECONSTRUCTIONCREATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReconstructionCreator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReconstructionCreator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReconstructionCreator

% Last Modified by GUIDE v2.5 05-Oct-2011 10:40:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ReconstructionCreator_OpeningFcn, ...
    'gui_OutputFcn',  @ReconstructionCreator_OutputFcn, ...
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


% --- Executes just before ReconstructionCreator is made visible.
function ReconstructionCreator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReconstructionCreator (see VARARGIN)



% Choose default command line output for ReconstructionCreator
% Associate programs
%           printRxnFormula.m (Cobra Toolbox)
%           findRxnIDs.m (Cobra Toolbox)
%           createModel.m (Cobra Toolbox)
%           Keep_reactions.m, .asv & .gif (Thorleifsson)
%           addReaction.m (Cobra Toolbox)
%           changeGeneAssociation.m (Cobra Toolbox)
%           parseBoolean.m (Cobra Toolbox)
%           GPR2Genes.m (Thorleifsson)
%           CreateGPR.m , .asv & .fig (Thorleifsson)
%           formula2mets.m (Cobra Toolbox)
%           load_reaction.m, .asv & .fig (Thorleifsson)
%           model_description.m, .asv & .fig (Thorleifsson)
%           GenesReactions.m (Thorleifsson)


% handles.: genes, newrxns_data & description are the essentials for the
% creation of models.

handles.output = [];

handles.description = cell(1,7);


handles.group1 = [handles.addrxn_abbreviation, ...
    handles.addrxn_description, handles.addrxn_formula,...
    handles.addrxn_reversible, handles.addrxn_gpr, handles.addrxn_lb,...
    handles.addrxn_ub, handles.addrxn_cs,...
    handles.addrxn_subsystem, handles.addrxn_references,...
    handles.addrxn_notes handles.addrxn_ecnumber, handles.addrxn_keggid];
%addrxn_group
%When using group1 check make sure order is correctly used.

handles.group2 = [handles.text23, handles.text19, handles.addrxn_references...,
    handles.addrxn_notes];
set(handles.group2,'Enable','on');
set(handles.group2,'Visible','off');

handles.group3 = [handles.addrxn_gpr, handles.addrxn_subsystem, ...
    handles.addrxn_lb, handles.addrxn_ub, handles.addrxn_cs,...
    handles.gene_gpr, handles.text20, handles.text21, handles.text22,...
    handles.text16, handles.text18 ];
set(handles.group3,'Visible','on');


%load databases
handles.rxn = rBioNetSaveLoad('load','rxn');
if isempty(handles.rxn)
    delete(gcf);
    return
end


handles.metab = rBioNetSaveLoad('load','met');
if isempty(handles.metab)
    delete(gcf);
    return
end


handles.newrxns_selection = []; %Selection for new rxns



handles.output = hObject;
handles.model = [];             %model stored in model format
handles.newrxns = [];           %reactions in model table
handles.genes = [];
handles.genes_info = [];
handles.model = [];
handles.description = cell(7,1); %model description
handles.model_description = [];
handles.model_description.name = '';
handles.model_description.organism = '';
handles.model_description.author = '';
handles.model_description.geneindex = '';
handles.model_description.genedate = '';
handles.model_description.genesource = '';
handles.model_description.notes = '';
handles.addrxn_genes = [];
handles.last_path = '';
set(handles.new_rxns,'data','');


% Input
if ~isempty(varargin)
    output = model2data(varargin{1});
    %data
    handles.newrxns = output{1}
    set(handles.new_rxns,'data',output{1});
    %description
    handles.description = output{2};
    set(handles.model_text,'String',['Reconstruction: ' handles.description{1}]);
    %genes
    handles.genes = output{3};
    %model
    handles.model = output{4};
end

guidata(hObject, handles);

% UIWAIT makes ReconstructionCreator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReconstructionCreator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];




function addrxn_gpr_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_gpr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_gpr as text
%        str2double(get(hObject,'String')) returns contents of addrxn_gpr as a double


% --- Executes during object creation, after setting all properties.
function addrxn_gpr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_gpr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_genes_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_genes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_genes as text
%        str2double(get(hObject,'String')) returns contents of addrxn_genes as a double


% --- Executes during object creation, after setting all properties.
function addrxn_genes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_genes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_subsystem_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_subsystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_subsystem as text
%        str2double(get(hObject,'String')) returns contents of addrxn_subsystem as a double


% --- Executes during object creation, after setting all properties.
function addrxn_subsystem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_subsystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_notes_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_notes as text
%        str2double(get(hObject,'String')) returns contents of addrxn_notes as a double


% --- Executes during object creation, after setting all properties.
function addrxn_notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_lb_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_lb as text
%        str2double(get(hObject,'String')) returns contents of addrxn_lb as a double


% --- Executes during object creation, after setting all properties.
function addrxn_lb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_ub_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_ub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_ub as text
%        str2double(get(hObject,'String')) returns contents of addrxn_ub as a double


% --- Executes during object creation, after setting all properties.
function addrxn_ub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_ub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_cs_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_cs as text
%        str2double(get(hObject,'String')) returns contents of addrxn_cs as a double


% --- Executes during object creation, after setting all properties.
function addrxn_cs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function addrxn_references_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_references (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addrxn_references as text
%        str2double(get(hObject,'String')) returns contents of addrxn_references as a double


% --- Executes during object creation, after setting all properties.
function addrxn_references_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addrxn_references (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------Search










%--------------------------------------------------------------------------

% --- Executes on button press in addrxn_load.
function addrxn_load_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rxnline = load_reaction(handles.rxn);
if isempty(rxnline)
    return
end

set(handles.addrxn_abbreviation,'String',rxnline{1});
set(handles.addrxn_description,'String',rxnline{2});
set(handles.addrxn_formula,'String',rxnline{3});
set(handles.addrxn_reversible,'String',rxnline{4});
set(handles.addrxn_cs,'String',rxnline{5});
set(handles.addrxn_notes,'String',rxnline{6});
set(handles.addrxn_references,'String',rxnline{7});
set(handles.addrxn_ecnumber,'String',rxnline{8});
set(handles.addrxn_keggid,'String',rxnline{9});
set(handles.addrxn_gpr,'String','');

reversible = str2double(rxnline{4});
if reversible == 0
    lb = '0';
else
    lb = '-1000';
end

set(handles.addrxn_lb,'String',lb);
set(handles.addrxn_ub,'String','1000'); %ub default 1000.

guidata(hObject,handles);



% --- Executes on button press in addrxn_new.
function addrxn_new_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.group1,'String','')


guidata(hObject,handles)

% --- Executes on button press in addrxn_add.
function addrxn_add_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newrxn = get(handles.group1,'String');
newrxn(2:end+1) =newrxn;
newrxn{1} = true;
if isempty(newrxn{2})
    return
end

num_group = [5, 7, 8, 9]; %These columns can only be numbers

for i = 1:length(num_group)
    if isnan(str2double(newrxn{num_group(i)})) % str2double of empty resaults in error.
        a = size(newrxn{num_group(i)},2);
        if isa(newrxn{num_group(i)},'char') && a ~= 0
            msgbox('Reversible, LB, UB and CS cannot be characters')
            return
        end
        newrxn{num_group(i)} = [];
    else
        newrxn{num_group(i)} = str2double(newrxn{num_group(i)});
    end
end
% newrxns = get(handles.new_rxns,'data');
%newrxns = handles.newrxns;
s_newrxn = size(handles.newrxns);

if ~(s_newrxn == 0)
    %rxn abbreviations are in handles.new_rxns(:,2) after logical
    %mark was added at the beginning of the rxn table
    match=strcmp(newrxn{2},handles.newrxns(:,2));

    if any(match ~= 0)
        
        rxn_replace = questdlg('Your reaction already exist in model. Do you want to replace it?', ...
            'Reaction in model', ...
            'Yes','No','No');
        
        switch rxn_replace
            case 'Yes'
                handles.newrxns(match,:) = newrxn';
            case 'No'
                return
            otherwise
                return
        end
        
    else
        handles.newrxns = [handles.newrxns; newrxn'];
        handles.newrxns = sortrows(handles.newrxns,2);
    end
else %there is no other reaction in table.
    handles.newrxns = newrxn';
end


set(handles.new_rxns,'data',handles.newrxns);


%Set gene_index
GPR = get(handles.addrxn_gpr,'String');

if ~isempty(GPR)
    genes = GPR2Genes({GPR});
    gene_list = handles.genes;
    
    if isempty(gene_list)
        handles.genes = genes';
    else
        handles.genes = [handles.genes; genes'];
    end
    handles.genes = unique(handles.genes);
end



guidata(hObject,handles)



% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_open_Callback(hObject, eventdata, handles)
% hObject    handle to file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ReconstructionTool;


% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)



% --- Executes on button press in newrxns_remove.
function newrxns_remove_Callback(hObject, eventdata, handles)
% hObject    handle to newrxns_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sel = handles.newrxns_selection;
if isempty(sel)
    return
end
% data = get(handles.new_rxns,'data');




str = 'Are you sure you want to remove the selected reactions?';

answer = questdlg(str, 'Remove reaction','Yes','No','Yes');
switch answer
    case 'Yes'
    case 'No'
        return
    otherwise
        return
end

% guidata(hObject,handles)


data = get(handles.new_rxns,'data');

handles.newrxns(strcmp(handles.newrxns(:,2),data(unique(sel(:,1)),2)),:) = '';

handles.genes = unique(GPR2Genes(handles.newrxns(:,6))');% answer is unique


set(handles.new_rxns,'data',handles.newrxns);



guidata(hObject,handles)

% --- Executes when selected cell(s) is changed in new_rxns.
function new_rxns_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to new_rxns (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.newrxns_selection = eventdata.Indices;
guidata(hObject,handles)



% --- Executes on button press in gene_gpr.
function gene_gpr_Callback(hObject, eventdata, handles)
% hObject    handle to gene_gpr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.genes_info)
    GPR = CreateGPR(handles.genes_info,get(handles.addrxn_gpr,'string'));
    set(handles.addrxn_gpr,'String',GPR);
else
    msgbox('Please load in a gene index to create GPRs.'...
        ,'Load Gene index.','help');
end
guidata(hObject,handles)


% --- Executes on button press in addrxn_more.
function addrxn_more_Callback(hObject, eventdata, handles)
% hObject    handle to addrxn_more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addrxn_more
view = get(hObject,'Value');
if view == 1
    set(handles.group2,'Visible','on');
    set(handles.group3,'Visible','off');
else
    set(handles.group2,'Visible','off');
    set(handles.group3,'Visible','on');
end
guidata(hObject,handles);



% --- Executes on button press in genes_view.
function genes_view_Callback(hObject, eventdata, handles)
% hObject    handle to genes_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
geneindex = handles.genes_info;

%Get genes from GPR listed in alphabetical order and ther associated
%reactions.
% newrxns = get(handles.new_rxns,'data');
if ~isempty(handles.genes) && ~isempty(handles.newrxns)
    list = GenesReactions(handles.genes,handles.newrxns);
else
    list = [];
end
if isempty(list) && isempty(geneindex)
    msgbox('There is no Gene Index or genes in model.');
    return
end

%Put reactions in column X.
X = 8;
S = size(list);
S_g = size(geneindex);
if S_g(1) == 0
    geneindex = cell(S(1),X);
    geneindex(:,1) = list(:,1);
    geneindex(:,X) = list(:,2);
else
    for i = 1:S(1)
        line = strmatch(list(i,1),geneindex(:,1),'exact');
        S2 = size(line);
        if isempty(line) %gene not in geneIndex
            geneindex(end+1,1) = list(i,1);
            geneindex(end,X) = list(i,2);
        elseif S2(1) > 1
            msgbox(['Gene ' list(i,1) ' has numeros matches in Gene Index. ',...
                'Please check your Gene Index for duplicity.'],...
                'Multiple matches','error');
            return
        else
            geneindex(line,X) = list(i,2);
        end
    end
end

geneindex = sortrows(geneindex,1);
GenesAndReactions(geneindex);


guidata(hObject,handles)


% --- Executes on button press in model_description.
function model_description_Callback(hObject, eventdata, handles)
% hObject    handle to model_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%IF description is changed in size make sure to change it aswell in the
%opening function

description  = model_description(handles.description);

if ~isempty(description)
    handles.description = description;
    %Model_description is used when saving model.
    set(handles.model_text,'String',['Reconstruction: ' description{1}]);
end

guidata(hObject,handles)


% --- Executes on button press in newrxns_edit.
function newrxns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to newrxns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel = handles.newrxns_selection;
% data = get(handles.new_rxns,'data');

if isempty(sel)
    return
end

answer = questdlg(['Are you sure you want to load reaction from'...
    ' reconstruction?'],'Reaction in model', ...
    'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
    otherwise
        return
end

data = get(handles.new_rxns,'data');

rxnline = data(sel(1),:);

set(handles.addrxn_abbreviation,'String',rxnline{2});
set(handles.addrxn_description,'String',rxnline{3});
set(handles.addrxn_formula,'String',rxnline{4});
set(handles.addrxn_reversible,'String',rxnline{5});
set(handles.addrxn_cs,'String',rxnline{9});
set(handles.addrxn_gpr,'String',rxnline{6});
set(handles.addrxn_notes,'String',rxnline{12});
set(handles.addrxn_references,'String',rxnline{11});
set(handles.addrxn_ecnumber,'String',rxnline{13});
set(handles.addrxn_keggid,'String',rxnline{14});
set(handles.addrxn_lb,'String',rxnline{7});
set(handles.addrxn_ub,'String',rxnline{8});
set(handles.addrxn_subsystem,'String',rxnline{10});


guidata(hObject,handles);



% --------------------------------------------------------------------
function file_save_model_Callback(hObject, eventdata, handles)
% hObject    handle to file_save_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




result = LegalRxnFormula(handles.newrxns(:,4),handles.newrxns(:,2));
if result == false
    return
end


%---------------------------- Generate Model -------------------------
% data = get(handles.new_rxns,'data');

model = data2model(handles.newrxns,handles.description);

if isempty(model)
    return;
end

%------------------------------ Save Model ---------------------------

save_model = questdlg(['Do you want to save your reconstruction? ']...
    ,'New Model','Yes', 'No', 'Yes');

%perform the following operation depending on the option chosen
switch save_model,
    case 'Yes',
        
        if ~isempty(handles.last_path)
            [filename,pathname] = uiputfile( ...
                {'*.mat', 'Model Files (*.mat)';...
                '*.*','All Files (*.*)'},...
                'Save model',handles.last_path);
        else
            [filename,pathname] = uiputfile( ...
                {'*.mat', 'Model Files (*.mat)';...
                '*.*','All Files (*.*)'},...
                'Save model');
        end
        if pathname == 0 %if the user pressed cancelled, then we exit this callback
            return
        end
        name = filename(1:regexpi(filename,'\.')-1);
        v = genvarname(name);
        eval([v ' = model']);
        save(fullfile(pathname, filename),name);
    case 'No'
        return
    otherwise
        return
end % switch
handles.last_path = pathname;
handles.model = model;

guidata(hObject,handles)



% --------------------------------------------------------------------
function file_save_mat_Callback(hObject, eventdata, handles)
% hObject    handle to file_save_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.last_path)
    [filename,pathname] = uiputfile( ...
        {'*.mat', 'Mat Files (*.mat)'},...
        'Save model',handles.last_path);
else
    [filename,pathname] = uiputfile( ...
        {'*.mat', 'Mat Files (*.mat)'},...
        'Save model');
end
if pathname == 0 %if the user pressed cancelled, then we exit this callback
    return
end
handles.last_path = pathname;
name = filename(1:regexpi(filename,'\.')-1);
v = genvarname(name);
model.genes = handles.genes;
% data = get(handles.new_rxns,'data');
model.data = handles.newrxns;
model.description = handles.description;

eval([v ' = model']);
save(fullfile(pathname, filename),name);


guidata(hObject,handles)


% --------------------------------------------------------------------
function file_open_model_Callback(hObject, eventdata, handles)
% hObject    handle to file_open_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%What should be updated:
%   handles.genes
%   handles.model
%   set hanndles.new_rxns
%   description yes or no
%   gene index yes or no

if ~isempty(handles.last_path)
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Model Files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select file',...
        'MultiSelect','off',handles.last_path);
else
    
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Model Files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select file',...
        'MultiSelect','off');
end
if pathname == 0
    return
end
handles.last_path = pathname;

model = load([pathname input_file]);
name = fieldnames(model);
name2 = ['model.' name{1}];
handles.model= eval(name2);

output = model2data(handles.model);

data = output{1};
description = output{2};
genes_new = output{3};
handles.model = output{4}; % Add fields if they don't exist.
genes_old = handles.genes;

% newrxns = get(handles.new_rxns,'data');

if ~isempty(handles.newrxns);
    answer = questdlg({'Do you want to keep loaded reactions?','',...
        ['Warning: if reactions in reaction table exist in loaded reconstruction'...
        ', then they will be overwritten.']},'Keep reactions','Yes','No','Cancel','Yes');
    switch answer
        case 'Cancel'
            return;
        case 'Yes'
            handles.genes = unique([genes_new; genes_old]);
            pre_data = handles.newrxns;
            %add logical for first column
            handles.newrxns = data;
            S2 = size(pre_data);
            for i = 1:S2(1)
                match = find(strcmp(pre_data{i,2},handles.newrxns(:,2)));

                if ~isempty(match)
                    handles.newrxns(match,:) = '';
                end
                handles.newrxns(end+1,1:S2(2)) = pre_data(i,:);
            end
            handles.newrxns = sortrows(handles.newrxns,2);
        case 'No'
            handles.newrxns = data;
            handles.genes = genes_new;
        otherwise
            return;
    end
else
    handles.newrxns = data;
    handles.genes = genes_new;
end
set(handles.new_rxns,'data',handles.newrxns);

answer = questdlg('Do you want to use reconstruction description?',...
    'Description','Yes','No','No');
switch answer
    case 'Yes'
        handles.description = description;
        set(handles.model_text,'String',['Reconstruction: ' description{1}]);
    case 'No'
        %Do nothing
    otherwise
        %Do nothing
end


guidata(hObject,handles)




str1 = 'Do you want to load Gene Index with model? ';


GeneIndex = questdlg(str1,...
    'Load Gene Index','Yes','No','What is Gene Index?','Yes');
switch GeneIndex
    case 'Yes'
        [input_file,pathname] = uigetfile( ...
            {'*.txt', 'Text files (*.txt)';...
            '*.*','All Files (*.*)'},...
            'Select files',...
            'MultiSelect','off');
        if pathname == 0
            return
        end
        
        
        data = getgenelist([pathname input_file]);
        
        set(handles.gene_index,'String',['Gene Index: ' input_file]);
        handles.genes_info = data;
    case 'No'
        
        
    case 'What is Gene Index?'
        msgbox({[ 'The Gene index is used to create GPRs. It is a .txt'...
            ' file with one gen per line with information devided into'...
            ' columns by tabs.'],'' ,['Column order: Locus name*, Gene Symbol,'...
            'Chromosome, 5 coordinates, 3 coordinates, Gene Type,'...
            'Purative,(*) is mandatory.'],'',['You can load your gene index'...
            'by going to the file menu and click "Load Gene Index"'...
            '. For more information see manual and the',...
            ' ExampleGeneIndex.txt text file located in the example folder']}...
            , 'Gene Index','help');
        uiwait;
        
        GeneIndex2 = questdlg(str1,...
            'Load Gene Index','Yes','No','No');
        switch GeneIndex2
            case 'Yes'
                [input_file,pathname] = uigetfile( ...
                    {'*.txt', 'Text files (*.txt)';...
                    '*.*','All Files (*.*)'},...
                    'Select files',...
                    'MultiSelect','off');
                if pathname == 0
                    return
                end
                
                data = getgenelist([pathname input_file]);
                set(handles.gene_index,'String',['Gene Index: ' input_file]);
                handles.genes_info = data;
            case 'No'
                %Do nothing
                
        end
end


guidata(hObject,handles);

% --------------------------------------------------------------------
function file_open_mat_Callback(hObject, eventdata, handles)
% hObject    handle to file_open_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Essentials: handles.genes, newrxns
%handles.description,handles.model_description

if ~isempty(handles.last_path)
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Model Files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select file',...
        'MultiSelect','off',handles.last_path);
else
    [input_file,pathname] = uigetfile( ...
        {'*.mat', 'Model Files (*.mat)';...
        '*.*','All Files (*.*)'},...
        'Select file',...
        'MultiSelect','off');
end

if pathname == 0
    return
end

model = load([pathname input_file]);
name = fieldnames(model);
name2 = ['model.' name{1}];

A = eval(name2);
a = fieldnames(A);
names = {'genes','data','description'};
match = zeros(size(name));
for i = 1:size(names,2)
    match(i) = strcmp(names{i},a{i});
end 

if ~(sum(match) == size(names,2))
    msgbox(['This file is not propper format. If you are trying to',...
        ' open previous reaconstruction created with the Cobra',...
        ' Toolbox try opening it as an complete reconstruction.'],...
        'File incorrect format','help')
    return
end

%Check for reactions in model
% newrxns = get(handles.new_rxns,'data');
pre = handles.newrxns;

if isempty(pre)
    handles.newrxns = A.data;
    handles.genes = A.genes;
    set(handles.new_rxns,'data',A.data)
    
    handles.description = A.description;
    set(handles.model_text,'String',['Reconstruction: ' A.description{1}]);
else
    
    %-----Check for dublicity in reactions begin
    S = size(A.data);
    matches = [];
    for i = 1:S(1)
        match = any(strcmp(A.data{i,2},handles.newrxns(:,2)));
        if match == 1
            matches = [matches i];
        end
    end

    if ~isempty(matches)
        msgbox([ A.data(matches,2)' 'is/are already in reconstruction. Only one version'...
            'can exist of each reaction. Please remove the '...
            'reactions in question to proceed.'],...
            'Reaction already in reconstruction','help');
        return
        %-----Check for dublicity in reactions end
    else
        %----Add new reactions
        handles.newrxns = [handles.newrxns; A.data];
        handles.newrxns = sortrows(handles.newrxns,2);
        set(handles.new_rxns,'data',handles.newrxns);
        %----Add new genes
        handles.genes = unique([handles.genes; A.genes]);
    end
    
    answer = questdlg('Do you want to overwrite the reconstruction description?',...
        'Replace model description','Yes','No','Yes');
    switch answer
        case 'Yes'
            
            handles.description = A.description;
            set(handles.model_text,'String',['Reconstruction: ' A.description{1}]);
        otherwise
            %do nothing
    end
    
    
end

handles.model = '';
guidata(hObject,handles)


% --------------------------------------------------------------------
function file_model_new_Callback(hObject, eventdata, handles)
% hObject    handle to file_model_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonName = questdlg('Are you sure you want to create a new model?', ...
    'New Model', ...
    'Yes', 'No', 'Yes');

%perform the following operation depending on the option chosen
switch ButtonName,
    case 'Yes',
        %add code here for saving data
    case 'No',
        return;
    otherwise
        return
end % switch
handles.newrxns = [];
handles.genes = [];
handles.description = cell(7,1);
handles.model = [];

set(handles.model_text,'String','Reconstruction: Empty');
set(handles.new_rxns,'data',handles.newrxns);


guidata(hObject,handles)


% --------------------------------------------------------------------
function file_geneindex_load_Callback(hObject, eventdata, handles)
% hObject    handle to file_geneindex_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.last_path)
    [input_file,pathname] = uigetfile( ...
        {'*.txt', 'Text files (*.txt)';...
        '*.*','All Files (*.*)'},...
        'Select files',...
        'MultiSelect','off',handles.last_path);
else
    [input_file,pathname] = uigetfile( ...
        {'*.txt', 'Text files (*.txt)';...
        '*.*','All Files (*.*)'},...
        'Select files',...
        'MultiSelect','off');
end

if pathname == 0
    return
end

data = getgenelist([pathname input_file]);


set(handles.gene_index,'String',['Gene Index: ' input_file]);
handles.genes_info = data; 
guidata(hObject,handles)


% --------------------------------------------------------------------
function stats_Callback(hObject, eventdata, handles)
% hObject    handle to stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function model_stats_Callback(hObject, eventdata, handles)
% hObject    handle to model_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%load rxn.mat;
%load met.mat;
if isempty(handles.model)
    msgbox(['There is no ready reconstruction, please save your reactions as complete',...
        ' reconstruction or load an complete reconstruction to continue.'],...
        'Reconstruction missing','help');
else
    %rxn is loaded in model_stats
    model_stats(handles.model); %met not used at the moment
end



% --------------------------------------------------------------------
function context_db_ec_Callback(hObject, eventdata, handles)
% hObject    handle to context_db_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.newrxns_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

% data = get(handles.new_rxns,'data');
str = handles.newrxns{handles.newrxns_selection(1),13};
webDatabases('ec',str);


% --------------------------------------------------------------------
function context_db_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to context_db_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.newrxns_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

% data = get(handles.new_rxns,'data');
str = handles.newrxns{handles.newrxns_selection(1),14};
webDatabases('kegg',str,1);


% --------------------------------------------------------------------
function keggmapper_ec_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.newrxns_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

% data = get(handles.new_rxns,'data');
str = handles.newrxns{handles.newrxns_selection(1),13};

webKeggMapper('ec',str);


% --------------------------------------------------------------------
function keggmapper_kegg_Callback(hObject, eventdata, handles)
% hObject    handle to keggmapper_kegg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.newrxns_selection)
    msgbox('Please select cell and then right-click','Help','help');
    return;
end

% data = get(handles.new_rxns,'data');
str = handles.newrxns{handles.newrxns_selection(1),14};
webKeggMapper('kegg',str);


% --- Executes when uipanel4 is resized.
function uipanel4_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_about_Callback(hObject, eventdata, handles)
% hObject    handle to help_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rBioNetAbout;


% --------------------------------------------------------------------
function file_save_text_Callback(hObject, eventdata, handles)
% hObject    handle to file_save_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_open_text_Callback(hObject, eventdata, handles)
% hObject    handle to file_open_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in search.
function search_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.search_str,'String');

%----Get search_search_rxn column
column = get(handles.search_popup,'Value')+1;% Enable/Disable button

%----Get data from search_exact_rxn match checkbox
exact = get(handles.search_exact,'Value');
if isempty(handles.newrxns)
    return;
end

set(handles.new_rxns,'Data',rBioNet_search(handles.newrxns,column,str,exact));

handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in search_refresh.
function search_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to search_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.new_rxns,'Data',handles.newrxns);
guidata(hObject,handles);



function search_str_Callback(hObject, eventdata, handles)
% hObject    handle to search_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_str as text
%        str2double(get(hObject,'String')) returns contents of search_str as a double
search_Callback(hObject, eventdata, handles)
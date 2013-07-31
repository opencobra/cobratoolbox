% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011 
function varargout = addreactions(varargin)
% ADDREACTIONS M-file for addreactions.fig
%      ADDREACTIONS, by itself, creates a new ADDREACTIONS or raises the existing
%      singleton*.
%
%      H = ADDREACTIONS returns the handle to a new ADDREACTIONS or the handle to
%      the existing singleton*.
%
%      ADDREACTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDREACTIONS.M with the given input arguments.
%
%      ADDREACTIONS('Property','Value',...) creates a new ADDREACTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addreactions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addreactions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addreactions

% Last Modified by GUIDE v2.5 08-Apr-2012 21:15:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @addreactions_OpeningFcn, ...
    'gui_OutputFcn',  @addreactions_OutputFcn, ...
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


% --- Executes just before addreactions is made visible.
function addreactions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addreactions (see VARARGIN)

% Choose default command line output for addreactions
handles.output = [];

if ~isempty(varargin{1})
    data = varargin{1};
    for i =1:size(data,1)
        data{i,10} = datestr(clock,'yyyy-mm-dd HH:MM:SS');%TIME
        data{i,4} = num2str(data{i,4});%REV
        if isempty(data{i,5})%MCS
            data{i,5} = '0';
        end
    end
    set(handles.uitable1,'data',data)
end


% Update handles structure
handles.edit_check = [];
handles.CellSelection =[];
handles.data = {};
handles.check = 0; % 0 if check has not been done, 1 if it has. 

guidata(hObject, handles);


% UIWAIT makes addreactions wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = addreactions_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in act_load.
function act_load_Callback(hObject, eventdata, handles)
% hObject    handle to act_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%------------------- Read text file -----------------------
[input_file,pathname] = uigetfile( ...
    {'*.txt', 'Text files (*.txt)';...
    '*.*','All Files (*.*)'},...
    'Select files',...
    'MultiSelect','off');
if pathname == 0
    return
end
data = cell(1,20);
fid = fopen([pathname input_file]);
line = fgetl(fid);
cnt = 0;
while line ~= -1 %Read text file
    cnt = cnt + 1;
    if strcmp(line(1),'*');
        cnt = cnt - 1;
    else
        data_line = regexp(line, '\t','split');
        Sd = size(data_line);
        if Sd(2) > 20
            msgbox(['Line ' cnt ' exceeds allowed colmns with ' Sd(2) '.'],...
                'Please check your text file.','error');
            return
        end
        data(cnt,1:Sd(2)) = data_line;
    end
    line = fgetl(fid);
end
fclose(fid);

quest_yes = 0;
S = size(data);
%MSC and rev are taken in as strings but changed later to numbers. 
%add time and reversible and MSC (default 0) if it is missing. 
for i = 1:S(1) 
    if isempty(data{i,5}) %default MSC 0
        data{i,5} = '0';
    else
        if isa(data{i,5},'numeric') %Change to string
            data{i,5} = num2str(data{i,5});
        elseif isnan(str2double(data{i,5}))
           msgbox(['Line ' num2str(i) ' Mechanical Confidece Score is not numeric'],'Error','error'); 
           return
        end
    end
    
    if isempty(data{i,4}) %Reversability
        
        if isempty(data{i,3})
            msgbox(['No reaction formula. Error at line ' num2str(i) '.'],'Error','error')
            return
        end
        rev =  regexpi(data{i,3},'<=>','match');

        if isempty(rev)
            rev = regexpi(data{i,3},'->','match');
            if isempty(rev)
                msgbox(['Line ' num2str(i) ': reaction formula has neither'...
                    ' <=> nor ->, that is not right'],'Error','error');
                return
            else
                data{i,4} = '0'; %non reversible
            end
        else
            data{i,4} = '1'; % reversible
        end
    else
        if isa(data{i,4},'numeric')
            data{i,4} = num2str(data{i,4});
        elseif isnan(str2double(data{i,4}))
            msgbox(['Line ' num2str(i) ' reversability is not numeric'],'Error','error');
            return
        end
    end
    data{i,10} = datestr(clock,'yyyy-mm-dd HH:MM:SS');    
        
end 

%-------------- Read text file ------------------------------ end

set(handles.uitable1,'data',data);
handles.check = 0;

guidata(hObject,handles)


% --- Executes on button press in act_remove.
function act_remove_Callback(hObject, eventdata, handles)
% hObject    handle to act_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.uitable1,'data'); % uitable 1
S_data = size(data);
if S_data(1) == 1 % If only on reaction remains. 
   set(handles.uitable1,'data','');
   set(handles.listbox1,'String','Empty');
   set(handles.uitable2,'data','');
   handles.check = 0;
   guidata(hObject,handles)
   return
end

line = handles.CellSelection;

if isempty(line)
    return
end
line = unique(line(:,1));
S = size(line);
cnt = 0;


for i = 1:S(1)
    data(line(i)-cnt,:) = ''; % Uitable1
    cnt = cnt + 1;
end


set(handles.uitable1,'data',data);% New reactions


guidata(hObject,handles);



% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(gcf)

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.CellSelection = eventdata.Indices;
guidata(hObject, handles)
    


% --- Executes on button press in act_save.
function act_save_Callback(hObject, eventdata, handles)
% hObject    handle to act_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rbionetGlobal;
gui_save = waitbar(0,'Saving please wait');

if rbionetGlobal.saveRxn(get(handles.uitable1,'data'));
    msgbox('Reactions have been saved');
else
    msgbox('Not all reactions were saved. See Command Window for detailes.');
end
close(gui_save);
uiwait;

answer = questdlg('Do you want to exit?',...
    'Go to reactions','Yes','No','Yes');
switch answer
    case 'Yes'
        delete(gcf)
    otherwise
        %do nothing
end



% --- Executes on button press in act_help.
function act_help_Callback(hObject, eventdata, handles)
% hObject    handle to act_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox(['Add text file with same order as table 1. It is recommended to'...
    ' write reactions in Excel and then copy to notepad. Columns should'...
    ' be divided by taps if reactions are written directly in notepad.'...
    ' Perform the database check and finish if similarities are acceptable.']...
    ,'Info','help');

    


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.check = 0;
guidata(hObject,handles);


% --------------------------------------------------------------------
function sims_Callback(hObject, eventdata, handles)
% hObject    handle to sims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Similarities_Callback(hObject, eventdata, handles)
% hObject    handle to Similarities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rbionetGlobal;
data = get(handles.uitable1,'data');
form = data{handles.CellSelection(1),3};
if ~isempty(form)
    similarities(rbionetGlobal.rxnSimilarities(form));
end


% --- Executes on button press in balance_check.
function balance_check_Callback(hObject, eventdata, handles)
% hObject    handle to balance_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rbionetGlobal;
rxns = get(handles.uitable1,'data');
unbalanced_rxns = cell(size(rxns,1),1);
% mets = cell(size(rxns,1),1); % rxns broken down into tables of metabolites
AllRxnsBalanced = true;
unbalanced_cnt = 0;
for i = 1:size(rxns,1)
    [met, present] = rbionetGlobal.rxn2mets(rxns{i,3});
    if ~present % Metabolite is not in database
        % If so which one
        for k = 1:size(met,1) 
            if isempty(met{k,4})
                disp(rbionetGlobal.MissingMetabolite(rxns{i,1},met{k,1}));
            end
        end 
    else % Everything is A Okay
        balance = rbionetGlobal.RxnBalanceCheck(met);
        if ~isempty(balance)
            unbalanced_rxns{i} = balance;
            AllRxnsBalanced = false;
            unbalanced_cnt = unbalanced_cnt + 1;
        end
    end
end

if ~AllRxnsBalanced
   unbal_abb = cell(unbalanced_cnt,1);
   unbal_data = cell(unbalanced_cnt,1);
   k = 1;
   for i = 1:size(rxns,1)
      if ~isempty(unbalanced_rxns{i})
          unbal_abb{k} = rxns{i,1};
          unbal_data{k} = unbalanced_rxns{i};
          k = k+1;
      end
   end
   unbalanced( unbal_abb,unbal_data);
else
    msgbox(['All reactions that were able to go through the balance test'...
        ' are balanced. If a reaction has missing metabolites it cannnot be'...
        ' checked. ' ],'Balance Test','help');
end











    
    
    

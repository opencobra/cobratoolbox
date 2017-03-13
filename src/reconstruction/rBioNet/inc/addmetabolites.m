% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = addmetabolites(varargin)
% ADDMETABOLITES M-file for addmetabolites.fig
%      ADDMETABOLITES, by itself, creates a new ADDMETABOLITES or raises the existing
%      singleton*.
%
%      H = ADDMETABOLITES returns the handle to a new ADDMETABOLITES or the handle to
%      the existing singleton*.
%
%      ADDMETABOLITES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDMETABOLITES.M with the given input arguments.
%
%      ADDMETABOLITES('Property','Value',...) creates a new ADDMETABOLITES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addmetabolites_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addmetabolites_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addmetabolites

% Last Modified by GUIDE v2.5 25-Nov-2010 15:42:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addmetabolites_OpeningFcn, ...
                   'gui_OutputFcn',  @addmetabolites_OutputFcn, ...
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


% --- Executes just before addmetabolites is made visible.
function addmetabolites_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addmetabolites (see VARARGIN)
handles.CellSelection = [];
% Choose default command line output for addmetabolites
handles.output = [];

%set(handles.uitable1,'data',cell(1,13));
% Update handles structure


if ~isempty(varargin{1})
    data = varargin{1};
    time = clock;
    colmn = [];
    for i = 1:length(time)-3;
        if isempty(colmn)
            colmn = num2str(round(time(i)));
        else
            colmn = [colmn '/' num2str(round(time(i)))];
        end
    end
    S = size(data);
    for i = 1:S(1) % Add time and remove compartment
        %pubchem stored as strings
        if ~isempty(data{i,7}) && isa(data{i,7},'numeric')
            data{i,7} = num2str(data{i,7});
        end
        %chebi stored as strings
        if ~isempty(data{i,8}) && isa(data{i,8},'numeric')
            data{i,8} = num2str(data{i,8});
        end
        data{i,12} = colmn;
        data{i,5} = num2str(data{i,5});
        abb = regexpi(data{i,1},'[','split');
        if ~isempty(abb)
            data{i,1} = abb{1};
        end
    end
    s_break = S(1);
    data = sortrows(data,1); %make sure data is in aplhabetical order.
    for i = 1:S(1)
        if s_break == i
            break
        end

        while strcmp(data{i,1},data{i+1,1}) %remove the duplicate metabolites.
            data(i+1,:) = '';
            s_break = size(data,1);
            if s_break == i
                break
            end
        end

        if s_break == i
            break
        end


    end

    %------
    set(handles.uitable1,'data',data);
end

if ~isempty(varargin{2})
    %continues mode. Reaction list follows and is put through to
    %addreactions if addmetabolites is succesfull. This option is called
    %from Add reconstruction to db.
    handles.reactions = varargin{2};
else
    handles.reactions = [];
end
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = addmetabolites_OutputFcn(hObject, eventdata, handles)
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
time = clock;
colmn = [];
for i = 1:length(time)-3;
    if isempty(colmn)
        colmn = num2str(round(time(i)));
    else
        colmn = [colmn '/' num2str(round(time(i)))];
    end
end
S = size(data);
for i = 1:S(1) % Add time and remove compartment
    data{i,12} = colmn;
    abb = regexpi(data{i,1},'[','split');
    if ~isempty(abb)
        data{i,1} = abb{1};
    end
end
%-------------- Read text file ------------------------------


set(handles.uitable1,'data',data);

guidata(hObject,handles)

% --- Executes on button press in act_continue.
function act_continue_Callback(hObject, eventdata, handles)
% hObject    handle to act_continue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1,'data');

S = size(data);
empty_lines = [];
for i = 1:S(1)
    if isempty(data{i,1})
        data(i,:) = '';
    elseif isempty(data{i,4}) || isempty(data{i,5}) || isempty(data{i,2})
        empty_lines = [empty_lines i];
        %msgbox(['Abbreviation, description, charged formula and charge'...
        %    ' are mandatory.'],'Data missing','error');
       % return
    end
end

if ~isempty(empty_lines)
    msgbox({'Abbreviation, description, charged formula and charge are mandatory.',...
        '', 'Lines that are missing data:','',num2str(empty_lines)},'Missing data','warn');
    return;
end
S = size(data);
if S(1) == 0 || isempty(data{1})
    return
end


lines = [];
exist = {};exist_d = {};
charge_formula1 = {}; charge_formula2 = {};charge_formula3 = {};


metab = rBioNetSaveLoad('load','met');



showprogress(0,'Please wait...');

for i = 1:S(1)
    showprogress(i / S(1))
    newmet = data(i,:);
    match = strcmp(newmet{1},metab(:,1));

    if any(match)

        exist_d = [exist_d; metab(match,:)];
        exist = [exist; newmet(:)'];
        lines = [lines i];
    else
        match2 = strcmp(newmet{4},metab(:,4));
        if any(match2)
            mets = metab(match2);
            charge_formula1 = [charge_formula1; newmet{1}];
            charge_formula3 = [charge_formula3; newmet{4}];
            same_charge = [];
            for k = 1:size(mets,1)
                same_charge = [same_charge, mets{k} ' '];
%                 charge_formula = [charge_formula,  [mets{k} ', ']];
%                 charge_formula2 = [charge_formula2, [newmet{1} ', ']];
            end
            charge_formula2 = [charge_formula2; same_charge];
        end

    end
end

S1 = size(exist);
if S1(1) == S(1)
    %msgbox('All metabolites are already in databse.','Database.','error')
    if ~isempty(handles.reactions)
        answer = questdlg('All metabolites already in database. Do you want to continue with the reactions?',...
            'Go to reactions','Yes','No','Yes');
        switch answer
            case 'Yes'
                delete(gcf)
                addreactions(handles.reactions)
            otherwise
                %do nothing
        end
    else
        msgbox('All metabolites are already in database','No new data','help');
    end
    return;
end

if ~isempty(exist)
    exist_b = cell(1,20);
    S = size(exist);
    Sd = size(exist_d);

    for i = 1:S(1)
        exist_b(2*i-1,1:Sd(2)) = exist_d(i,1:Sd(2));
        exist_b(2*i,1:S(2)) = exist(i,1:S(2));
    end
    answer = metabolites_in_database(exist_b);
    if answer == 0
        return
    else
        %Cut out existing metabolites
        data(lines,:) = '';
    end

end

if ~isempty(charge_formula1)

    answer = met_charge_formula([charge_formula1,charge_formula2, charge_formula3]);
%     ButtonName = questdlg({'In same order: ', charge_formula2, '(has / have) the same charge formula as ', charge_formula}, ...
%         'Same charge formula', ...
%         'Continue', 'Cancel', 'Continue');

    %perform the following operation depending on the option chosen
    switch answer,
        case 'Continue',
            %add code here for saving data
        otherwise
            return
    end % switch

end




S = size(data);
Sd = size(metab);
for i = 1:S(1)
    metab(end+1,:) = data(i,1:Sd(2));
end



metab = sortrows(metab,1);

answer = questdlg('Metabolites are ready to be saved, do you wish to save?',...
    'Do you want to save?','Yes','No','Yes');
switch answer
    case 'Yes'
        rBioNetSaveLoad('save','met',metab);
        if ~isempty(handles.reactions)
            disp([num2str(S(1)) ' metabolites saved.']);
            delete(gcf)
            addreactions(handles.reactions)
        else
            delete(gcf)
        end
    otherwise
        return
end
%handles.output = metab;
%guidata(hObject,handles)



% --- Executes on button press in act_remove.
function act_remove_Callback(hObject, eventdata, handles)
% hObject    handle to act_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.uitable1,'data');
line = handles.CellSelection;
if isempty(line)
    return
end
line = unique(line(:,1));
S = size(line);
cnt = 0;
for i = 1:S(1)
    data(line(i)-cnt,:) = '';
    cnt = cnt + 1;
end

set(handles.uitable1,'data',data);
guidata(hObject,handles);

% --- Executes on button press in act_cancel.
function act_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to act_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = [];
guidata(hObject,handles)
delete(gcf)

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.CellSelection = eventdata.Indices;
guidata(hObject,handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.output = [];
guidata(hObject,handles)
delete(gcf)

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

% Last Modified by GUIDE v2.5 29-Jan-2012 13:01:36

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
open_gui = waitbar(0,'Opening');
%set(handles.uitable1,'data',cell(1,13));
% Update handles structure



if ~isempty(varargin{1})
    data = varargin{1};
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
        data{i,12} = datestr(clock,'yyyy-mm-dd HH:MM:SS');
        data{i,5} = num2str(data{i,5});
        abb = regexpi(data{i,1},'[','split');
        if ~isempty(abb)
            data{i,1} = abb{1};
        end
    end
    s_break = S(1);
    data = sortrows(data,1); % aplhabetical order.
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
close(open_gui);

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

S = size(data); 
for i = 1:S(1) % Add time and remove compartment
    data{i,12} = datestr(clock,'yyyy-mm-dd HH:MM:SS');
    abb = regexpi(data{i,1},'[','split');
    if ~isempty(abb)
        data{i,1} = abb{1};
    end
end
%-------------- Read text file ------------------------------


set(handles.uitable1,'data',data);

guidata(hObject,handles)

% --- Executes on button press in act_save.
function act_save_Callback(hObject, eventdata, handles)
% hObject    handle to act_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rbionetGlobal;
gui_save = waitbar(0,'Saving please wait');
data = get(handles.uitable1,'data');
S = size(data);
empty_lines = [];
for i = 1:S(1)
    if isempty(data{i,1})
        empty_lines = [empty_lines i];
    elseif isempty(data{i,4}) || isempty(data{i,5}) || isempty(data{i,2})
        empty_lines = [empty_lines i];
    end
end 

if ~isempty(empty_lines)
   close(gui_save);
    msgbox({'Abbreviation, description, charged formula and charge are mandatory.',...
        '', 'Lines that are missing data:','',num2str(empty_lines)},'Missing data','warn');
    return;
end


S = size(data);
if S(1) == 0 || isempty(data{1})
    return
end

if ~rbionetGlobal.saveMet(data);
    msgbox('Not all metabolites were saved. See Command Window for detailes.');
else
    msgbox('Metabolites saved');
end
uiwait;
close(gui_save);
if ~isempty(handles.reactions)
    answer = questdlg('Do you want to continue to the reactions?',...
        'Go to reactions','Yes','No','Yes');
    switch answer
        case 'Yes'
            delete(gcf)
            addreactions(handles.reactions)
        otherwise
            %do nothing
    end
else
    answer = questdlg('Do you want to exit?',...
        'Exit','Yes','No','Yes');
     switch answer
        case 'Yes'
            delete(gcf)
            
        otherwise
            %do nothing
    end
end



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

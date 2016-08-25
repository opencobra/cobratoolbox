% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function varargout = compartment(varargin)
% COMPARTMENT M-file for compartment.fig
%      COMPARTMENT, by itself, creates a new COMPARTMENT or raises the existing
%      singleton*.
%
%      H = COMPARTMENT returns the handle to a new COMPARTMENT or the handle to
%      the existing singleton*.
%
%      COMPARTMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPARTMENT.M with the given input arguments.
%
%      COMPARTMENT('Property','Value',...) creates a new COMPARTMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before compartment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to compartment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help compartment

% Last Modified by GUIDE v2.5 26-Jul-2010 11:02:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compartment_OpeningFcn, ...
                   'gui_OutputFcn',  @compartment_OutputFcn, ...
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


% --- Executes just before compartment is made visible.
function compartment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to compartment (see VARARGIN)

% Choose default command line output for compartment

handles.data = varargin{1};
set(handles.cmp_compartments,'String',handles.data);

 
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes compartment wait for user response (see UIRESUME)
uiwait


% --- Outputs from this function are returned to the command line.
function varargout = compartment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isa(handles.output,'struct')
    varargout{1} = [];
else
    varargout{1} = handles.output;
end
delete(gcf)


% --- Executes on button press in cmp_save.
function cmp_save_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



name = get(handles.cmp_name,'String');
abb = get(handles.cmp_abbreviation,'String');
if isempty(name) || isempty(abb) || length(abb) > 2 
    msgbox('Instructions (above) were not followed correctly.',...
        'Follow requirements.','warn');
    return
elseif isa(abb,'numeric')
    msgbox('The abbreviation cannot be a number.','Follow requirements.',...
        'warn');
    return
end

name = [upper(name(1)) lower(name(2:end))]; %Set upper and lower case. 
abb = lower(abb); %Set lower case.



cmps = handles.data;
abbs = ['(' abb ')'];
abb_find = strfind(cmps,abbs);

for i = 1:length(cmps)
    cmp_name = cmps{i};
    cmp_name = cmp_name(1:(regexpi(cmp_name,'\(')-2));
    
    if strcmp(cmp_name,name) % Compartment exist
        msgbox(['Compartment: ' name ' already exist.'],'Non unique.','warn');
        return
    elseif ~isempty(abb_find{i}) % Abbreviation exist
        text = ['The abbrevation ' abb ' already exists.'];
        
        msgbox(text,'Non unique.','warn');
        return
    end
    
end

handles.output= [name ' ' abbs];
guidata(hObject, handles);
uiresume




% --- Executes on button press in cmp_cancel.
function cmp_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;


function cmp_name_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmp_name as text
%        str2double(get(hObject,'String')) returns contents of cmp_name as a double
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cmp_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cmp_abbreviation_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_abbreviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmp_abbreviation as text
%        str2double(get(hObject,'String')) returns contents of cmp_abbreviation as a double


% --- Executes during object creation, after setting all properties.
function cmp_abbreviation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmp_abbreviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmp_compartments.
function cmp_compartments_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_compartments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmp_compartments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmp_compartments


% --- Executes during object creation, after setting all properties.
function cmp_compartments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmp_compartments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmp_remove.
function cmp_remove_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(handles.cmp_compartments,'Value');
guidata(hObject, handles);
uiresume


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume

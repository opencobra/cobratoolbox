function varargout = metCompareGUI(varargin)
% Creates a comparison GUI for deciding which metabolite are
% in a new or existing reaction.
% Called by `metCompare`, calls `findMetMatch`, `colText`, `addMetInfo`.
%
% USAGE:
%
%    [RxnInfo, stopFlag] = metCompareGUI(RxnInfo)
%
% INPUTS
%    RxnInfo:     Structure containing relevent info. See `metCompare` function
%                 `fillRxnInfo`.
%
% OPTIONAL OUTPUTS:
%    RxnInfo:     Update structure.
%    stopFlag:    Indicates if more metabolites need to be reviewed
%    CMODEL:      global input
%    TMODEL:      global input
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

gui_Singleton = 1; % Begin initialization code - DO NOT EDIT
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @metCompareGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @metCompareGUI_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

% --- Executes just before metCompareGUI is made visible.
function metCompareGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Declare globals
global CMODEL TMODEL

% workaround to enable java handles
axes(handles.axes1)
set(handles.axes1, 'Visible', 'off')

% Choose default command line output for metCompareGUI
handles.output = hObject;

% Load rxn, metabolite, and match data.
handles.RxnInfo = varargin{1};

% Populate reaction info.
cModelName = CMODEL.description ;
set(handles.staticCmodel, 'String', cModelName) ;
Tmodels = fieldnames(TMODEL.Models) ;
if length(Tmodels) == 1
    set(handles.staticTmodel, 'String', Tmodels{1})
end
rxnNum = num2str(handles.RxnInfo.rxnIndex) ;

% Set the reaction number if the metabolites all come from a reaction.
if handles.RxnInfo.rxnIndex
    set(handles.CRxnNumField, 'String', rxnNum) ;
else
    % Otherwise change how GUI appears.
    set(handles.staticCRxnNum, 'String', 'Met Number:') ;
    set(handles.staticRxnName, 'String', 'In Crxn(s):') ;
    set(handles.staticRxnEquation, 'String', 'In Trxn(s):') ;
    set(handles.staticTRxnNum, 'String', 'Current match in T.') ;
    set(handles.staticNewRxnEquation, 'Visible', 'Off') ;
    set(handles.newRxnEquationField, 'Visible', 'Off') ;
    % And disable the ability to skip checking the mets.
    set(handles.buttonSkip, 'Enable', 'off') ;
end
rxnName = handles.RxnInfo.rxnName ;
set(handles.rxnNameField, 'String', rxnName) ;
rxnEq = handles.RxnInfo.matchRxnEquation ;
set(handles.rxnEquationField, 'String', rxnEq) ;

rxnMatch = handles.RxnInfo.rxnMatch ;

% Indicate if the reaction is new, has already been matched, or N/A.
if ~rxnMatch && handles.RxnInfo.rxnIndex
    set(handles.TRxnNumField, 'String', 'New Rxn') ;
elseif ~rxnMatch && ~handles.RxnInfo.rxnIndex
    set(handles.TRxnNumField, 'String', 'N/A') ;
else
    set(handles.TRxnNumField, 'String', num2str(rxnMatch)) ;
    % You cannot choose new metabolite for reactions with matches.
    set(handles.chooseNew, 'Enable', 'off') ;
end

% List unseen metabolites.
if handles.RxnInfo.rxnIndex
  handles.RxnInfo.unseen = ~handles.RxnInfo.goodMatch ;
else
    % If just comparing metabolites, do not mark any as seen.
    handles.RxnInfo.unseen = ones(handles.RxnInfo.nMets, 1) ;
end

% Put metabolite names in the popup menu.
set(handles.popup_met, 'String', handles.RxnInfo.metData(1, :)) ;

% Populate first metabolite info and matches
% nowMet is the index of the metabolite in RxnInfo. It is selected for by
% the first metabolite that has not been seen.
handles.RxnInfo.nowMet = find(handles.RxnInfo.unseen == 1, 1) ;
if isempty(handles.RxnInfo.nowMet)
    handles.RxnInfo.nowMet = 1 ;
end
set(handles.popup_met, 'Value', handles.RxnInfo.nowMet) ;
popup_met_Callback(handles.popup_met, eventdata, handles)

% Create reaction equation based of best match suggestions.
handles = metMatchRxnEquation(hObject, handles) ;

% Update stats
fillStats(handles)

% Sets the cell selection callback feature for the uitables.
set(handles.uitable_matches, 'CellSelectionCallback', {@matchMetCallback, ...
                                                     handles})
set(handles.uitable_met, 'CellSelectionCallback', {@metTableCallback, ...
                                                 handles})

% Update handles structure ;
guidata(hObject, handles) ;

% UIWAIT makes metCompareGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = metCompareGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
handles.output = handles.RxnInfo ;
varargout{1} = handles.output ;
varargout{2} = handles.stopFlag ;
close
end

%% Button and Input Change Functions
% --- Executes on button press in buttonChoose.
function handles = buttonChoose_Callback(hObject, eventdata, handles)
global CMODEL
RxnInfo = handles.RxnInfo ;
% nowMetIndex is the index of the metabolite in CMODEL
nowMetIndex = RxnInfo.metIndex(RxnInfo.nowMet) ;

choice = get(get(handles.chooseMatch, 'SelectedObject'), 'Tag') ;

matchScores = RxnInfo.matchScores{RxnInfo.nowMet} ;
matchIndex  = RxnInfo.matchIndex{RxnInfo.nowMet} ;
% [matchScores, matchIndex] = findMetMatch(nowMetIndex,RxnInfo.rxnMatch) ;

switch choice
    case 'choose1'
        RxnInfo.matches(RxnInfo.nowMet) = matchIndex(1) ;
    case 'choose2'
        RxnInfo.matches(RxnInfo.nowMet) = matchIndex(2) ;
    case 'choose3'
        RxnInfo.matches(RxnInfo.nowMet) = matchIndex(3) ;
    case 'choose4'
        RxnInfo.matches(RxnInfo.nowMet) = matchIndex(4) ;
    case 'choose5'
        RxnInfo.matches(RxnInfo.nowMet) = matchIndex(5) ;
    case 'chooseNew'
        % if metabolite has been declared new, ensure that all reactions it is
        % involved in are also declared new.
        nowRxnIndex = find(CMODEL.S(nowMetIndex,:) ~= 0) ;
        if sum(RxnInfo.rxnList(nowRxnIndex) > 0) > 0

            set(handles.errorField, 'String',...
                [CMODEL.mets{nowMetIndex} 'Cannot be new, it is in matched Rxns.' ...
                num2str(nowRxnIndex(RxnInfo.rxnList(nowRxnIndex) > 0)) ])
            return
        end
        RxnInfo.matches(RxnInfo.nowMet) = 0 ;
    case 'chooseOther'
         newRxnIndex = str2double(get(handles.chooseOtherNo, 'String')) ;
         if newRxnIndex > 0
             RxnInfo.matches(RxnInfo.nowMet)
         else
             set(handles.errorField, 'String',...
                'Please enter a valid Rxn number.')
             return
         end
    otherwise
end

% Add data back to handle.
RxnInfo.matches = RxnInfo.matches ;

% Indicate the user has reviewed this match.
RxnInfo.goodMatch(RxnInfo.nowMet) = 1 ;

% Update metabolite as seen.
RxnInfo.unseen(RxnInfo.nowMet) = 0 ;

% Go to next metabolite in the list that has not been seen.
val = find(RxnInfo.unseen == 1, 1) ;
% If all matches are good then just go to the first metabolites.
if isempty(val)
    val = 1 ;
end
set(handles.popup_met, 'Value', val) ;

% Update handles.
handles.RxnInfo = RxnInfo ;
guidata(hObject, handles) ;

% Update new reaction equation. This also checks if the decision was good.
handles = metMatchRxnEquation(hObject, handles) ;

% Go to next met.
popup_met_Callback(handles.popup_met, eventdata, handles)
end

% --- Executes on selection change in popup_met.
function popup_met_Callback(hObject, eventdata, handles)
% Get index of choice and associate with met, save to handles.
val = get(hObject, 'Value') ;
handles.RxnInfo.nowMet = val ;
guidata(hObject, handles) ;
% Populate table with met and match information.
populateMetTables(handles) ;
end

% --- Executes on selection of item in uitable_matches
function matchMetCallback(hObject, eventdata, handles)
global TMODEL
if ~isempty(eventdata.Indices)
    % Declare variables
    RxnInfo = handles.RxnInfo ; % For convenience.
    RxnInfo.nowMet = get(handles.popup_met, 'Value') ;
    nowMetIndex = RxnInfo.metIndex(RxnInfo.nowMet) ;
    matchScores = RxnInfo.matchScores{RxnInfo.nowMet} ;
    matchIndex  = RxnInfo.matchIndex{RxnInfo.nowMet} ;
%     [matchScores,matchIndex] = findMetMatch(nowMetIndex,RxnInfo.rxnMatch) ;


    % Set match reaction number based on column clicked.
    set(handles.chooseOtherNo,'String', 'Met #')
    matchCol = eventdata.Indices(2) ;
    if matchCol == 1
        set(handles.chooseMatch, 'SelectedObject', handles.choose1) ;
    elseif matchCol == 2
        set(handles.chooseMatch, 'SelectedObject', handles.choose2) ;
    elseif matchCol == 3
        set(handles.chooseMatch, 'SelectedObject', handles.choose3) ;
    elseif matchCol == 4
        set(handles.chooseMatch, 'SelectedObject', handles.choose4) ;
    elseif matchCol == 5
        set(handles.chooseMatch, 'SelectedObject', handles.choose5) ;
    else
        set(handles.chooseMatch, 'SelectedObject', handles.chooseOther) ;
        set(handles.chooseOtherNo, 'String', num2str(matchIndex(matchCol)))
    end

    % Opens up KEGG ID site if KEGGID is selected
    matchRow = eventdata.Indices(1) ;
    % If we are in the right row
    if matchRow == 7
       % Grab the ID.
       cID = TMODEL.metKEGGID{matchIndex(matchCol)} ;
       if ~isempty(cID)
           % Enforce the cID is the right length.
           cID = cID(1:6) ;
           % Launch website.
           KEGGIDurl = ['http://www.genome.jp/dbget-bin/www_bget?' cID] ;
           web(KEGGIDurl, '-new', '-noaddressbox', '-notoolbar')
       end
    end
end
end

% --- Executes on selection of item in uitable_met
function metTableCallback(hObject, eventdata, handles)
if ~isempty(eventdata.Indices)
    RxnInfo.nowMet = get(handles.popup_met, 'Value') ;
    % Opens up KEGG ID site if KEGGID is selected
    matchRow = eventdata.Indices(1) ;
    % If we are in the right row.
    if matchRow == 7
       % Grab the ID.
       cID = handles.RxnInfo.metData{5, RxnInfo.nowMet} ;
       if ~isempty(cID)
           % Enforce the cID is the right length.
           cID = cID(1:6) ;
           % Launch browser.
           KEGGIDurl = ['http://www.genome.jp/dbget-bin/www_bget?' cID] ;
           web(KEGGIDurl, '-new', '-noaddressbox', '-notoolbar')
       end
    end
end
end

% --- Executes on button press in buttonAddMets.
function buttonAddMets_Callback(hObject, eventdata, handles)
% Do not stop the next iteration of calling metCompare.
handles.stopFlag = 0 ;
guidata(hObject, handles) ;
% Allows the wait command to be suspended, closing the GUI.
uiresume(handles.figure1)
end

% --- Executes on button press in buttonSkip.
function buttonSkip_Callback(hObject, eventdata, handles)
% Stop the next iteration of calling metCompare.
handles.stopFlag = 1 ;
guidata(hObject, handles) ;
% Allows the wait command to be suspended, closing the GUI.
uiresume(handles.figure1)
end

% --- Executes when selected object is changed in chooseMatch. NOT USED.
function chooseMatch_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in chooseMatch
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on change in buttonChoose. NOT USED.
function chooseOtherNo_Callback(hObject, eventdata, handles)
% hObject    handle to chooseOtherNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on change in editNMatches. NOT USED.
function editNMatches_Callback(hObject, eventdata, handles)
% hObject    handle to editNMatches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

%% Subfunctions
% Populates both met and match tables.
function populateMetTables(handles)
% Pull out variables for easier referencing. Declare globals.
RxnInfo = handles.RxnInfo ;
global CMODEL TMODEL

% resize Row headers uitable_met
jscroll = findjobj(handles.uitable_met) ;
rowHeaderViewport = jscroll.getComponent(4) ;
rowHeader = rowHeaderViewport.getComponent(0);
newWidth = 125 ;
rowHeaderViewport.setPreferredSize(java.awt.Dimension(newWidth, 0));
height = rowHeader.getHeight;
rowHeader.setPreferredSize(java.awt.Dimension(newWidth, height));
rowHeader.setSize(newWidth,height);
% format left
rend = rowHeader.getCellRenderer(1, 0);
rend.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
jscroll.repaint %apply changes

nowMetIndex = RxnInfo.metIndex(RxnInfo.nowMet) ;
metDataTable = RxnInfo.metData(:, RxnInfo.nowMet) ;
nowMetDataTable = [ {''} ; ...
                     metDataTable{1} ; ...
                     CMODEL.mets{nowMetIndex}(end-1) ; ...
                     metDataTable(2:end)] ;

% Index of the met in CMODEL.
nMatches = str2double(get(handles.editNMatches, 'String')) ;
metMatchTable = cell(7, nMatches) ;
if nMatches <= RxnInfo.nMets
    matchScores = RxnInfo.matchScores{RxnInfo.nowMet} ;
    matchIndex  = RxnInfo.matchIndex{RxnInfo.nowMet} ;
else
    [matchScores, matchIndex] = findMetMatch(nowMetIndex, RxnInfo.rxnMatch) ;
end
for iMatch = 1:nMatches
    metMatchTable{1, iMatch} = num2str(matchScores(iMatch) / ...
                                      sum(matchScores(1:nMatches)) ) ;
    metMatchTable{2, iMatch} = [TMODEL.mets{matchIndex(iMatch)}, ', ', ...
                               num2str(matchIndex(iMatch))] ;
    metMatchTable{3, iMatch} = TMODEL.mets{matchIndex(iMatch)}(end-1) ;
    metMatchTable{4, iMatch} = TMODEL.metNames{matchIndex(iMatch)} ;
    metMatchTable{5, iMatch} = TMODEL.metFormulas{matchIndex(iMatch)} ;
    metMatchTable{6, iMatch} = num2str(TMODEL.metCharge(matchIndex(iMatch))) ;
    metMatchTable{7, iMatch} = TMODEL.metKEGGID{matchIndex(iMatch)} ;
    metMatchTable{8, iMatch} = TMODEL.metSEEDID{matchIndex(iMatch)} ;
    metMatchTable{9, iMatch} = TMODEL.metID{matchIndex(iMatch)} ;
end

% weed out accidently remaining cells in cells
for iac = 1:numel(nowMetDataTable)
    if iscell(nowMetDataTable{iac})
        nowMetDataTable{iac} = [nowMetDataTable{iac}{:}] ;
    end
end
for iac = 1:numel(metMatchTable)
    if iscell(metMatchTable{iac})
        metMatchTable{iac} = [metMatchTable{iac}{:}] ;
    end
end

% If compartment doesn't match or if score is below 0.3
if ~strcmpi(metMatchTable{3, 1}, nowMetDataTable{3}) ...
        || str2double(metMatchTable{1, 1}) < 0.3
    set(handles.chooseNew, 'Value', 1)
else
    set(handles.choose1, 'Value', 1)
end

% Set color of good and bad correspondence in table.
colOptions = {'blue', 'red'} ;
for ic = 1:size(metMatchTable, 2)
    metMatchTable{1, ic} = ['<html><text>&nbsp; ' metMatchTable{1,ic} ...
        '</text><span style="background-color:' ...
        dec2hex(round(255 * (1 - str2num(metMatchTable{1, ic}))), 2) ...
        '00' ...
        dec2hex(round(255 * (str2num(metMatchTable{1, ic}))), 2) ...
        ';">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span></html>'] ;
    metMatchTable{2, ic} = colText(['&nbsp; ' metMatchTable{2, ic}], colOptions{ ...
        2 - strcmpi(metMatchTable{2, ic}(1:strfind(metMatchTable{2, ic}, ...
                                                ', ')-1), ...
        nowMetDataTable{2, 1}(1:strfind(nowMetDataTable{2, 1}, ',') - 1))}) ;
    for ir = 3:size(metMatchTable, 1)
        if ~isempty(metMatchTable{ir, ic}) && ...
                ~isempty(nowMetDataTable{ir, 1})
            metMatchTable{ir, ic} = colText(['&nbsp; ' metMatchTable{ir, ic}], ...
                colOptions{1 + isempty(strfind(metMatchTable{ir, ic}, nowMetDataTable{ir, 1}))}) ;
        else
            metMatchTable{ir, ic} = ['  ' metMatchTable{ir, ic}] ;
        end
    end
end

% If we are just comparing metabolites, put in information about what
% reactions that metabolite is involved in.
if ~RxnInfo.rxnIndex
    % Metabolite number in C.
    set(handles.CRxnNumField, 'String', nowMetIndex)
    % Current match in T.
    set(handles.TRxnNumField, 'String', RxnInfo.metList(nowMetIndex)) ;
    % Reactions it is involved in C.
    involvedRxns = find(CMODEL.S(nowMetIndex, :)) ;
    set(handles.rxnNameField, 'String', involvedRxns)
    % Reactions that it is matched to in T.
    set(handles.rxnEquationField, 'String', ...
        num2str(RxnInfo.rxnList(involvedRxns))) ;

    % Also give a hint as how best to proceed.
    if isempty(involvedRxns)
        hintString = 'Metabolite not in C, trivial problem, declare new.' ;
        set(handles.chooseNew, 'Value', 1)
    elseif ~RxnInfo.rxnList(involvedRxns)
    	hintString = ...
            'Metabolite not in a reaction matched to T, declare new' ;
        set(handles.chooseNew, 'Value', 1)
    else
        hintString = ...
            'Metabolite matched to a reaction in T. Best to keep match.' ;
        set(handles.choose1, 'Value', 1)
    end
    set(handles.errorField, 'String', hintString)
end

set(handles.uitable_matches, 'Data', metMatchTable, 'Fontsize', 10) ;

for ic = 1:size(nowMetDataTable, 2)
    for ir = 1:size(nowMetDataTable, 1)
        % add leading whitespace to all cells
        nowMetDataTable{ir, ic} = ['  ' nowMetDataTable{ir, ic}] ;
    end
end
set(handles.uitable_met, 'Data', nowMetDataTable, 'Fontsize', 10) ;

% Update unseen mets field
unseenMets = '' ;
for iMet = 1:RxnInfo.nMets
    if handles.RxnInfo.unseen(iMet) == 1
        unseenMets = [unseenMets RxnInfo.metData{1, iMet} '; '] ;
    end
end
set(handles.unseenMetsField, 'String', unseenMets) ;

end

% Makes reaction equation based on current best matches and checks the
% validity of the choices.
function handles = metMatchRxnEquation(hObject, handles)
% Declare some variables just to not have to type handles so much.
global CMODEL TMODEL
RxnInfo = handles.RxnInfo ;

% If metabolites come from a reaction, make the new equation.
% Disable choosing mets until checks have passed.
set(handles.buttonAddMets, 'Enable', 'off') ;
if RxnInfo.rxnIndex
    % Build the equation.
    reactants = cell(1, 1) ;
    products = cell(1, 1) ;
    for iMet = 1:RxnInfo.nMets
        % Reactants
        if RxnInfo.metStoichs(iMet) < 0
            % First reactant.
            if isempty(reactants{1})
               % Add Stoich
               reactants{1} = num2str(abs(RxnInfo.metStoichs(iMet))) ;
               % If a match has been found in TMODEL, choose that name.
               if RxnInfo.matches(iMet) ~= 0 && ...
                       (RxnInfo.matches(iMet) < length(TMODEL.mets))
                   reactants{2} = [' ' ...
                       TMODEL.mets{RxnInfo.matches(iMet)} ' '];
               else % Add met name from CMODEL.
                   reactants{2} = [' ' ...
                       CMODEL.mets{RxnInfo.metIndex(iMet)} ' '] ;
               end
            % nth reactants.
            else
               reactants{end + 1} = ' + ' ;
               reactants{end + 1} = num2str(abs(RxnInfo.metStoichs(iMet))) ;
               if RxnInfo.matches(iMet) ~= 0 && ...
                       (RxnInfo.matches(iMet) < length(TMODEL.mets))
                   reactants{end + 1} = [' ' ...
                                   TMODEL.mets{RxnInfo.matches(iMet)} ' '];
               else
                   reactants{end + 1} = [' ' ...
                             CMODEL.mets{RxnInfo.metIndex(iMet)} ' '] ;
               end
            end
        % Products
        else
            % First product
            if isempty(products{1})
                if RxnInfo.rev == 1
                    products{1} = '<==> ' ;
                else
                    products{1} = '--> ' ;
                end
                % Add stoich.
                products{2} = num2str(abs(RxnInfo.metStoichs(iMet))) ;
                % Add name.
                if RxnInfo.matches(iMet) ~= 0 && ...
                        (RxnInfo.matches(iMet) < length(TMODEL.mets))
                   products{3} = [' ' TMODEL.mets{RxnInfo.matches(iMet)}] ;
                else
                   products{3} = [' ' ...
                             CMODEL.mets{RxnInfo.metIndex(iMet)} ' '] ;
                end
            else % nth product.
                products{end + 1} = ' + ' ;
                products{end + 1} = num2str(abs(RxnInfo.metStoichs(iMet))) ;
                if RxnInfo.matches(iMet) ~= 0 && ...
                       (RxnInfo.matches(iMet) < length(TMODEL.mets))
                   products{end + 1} = [' ' ...
                                  TMODEL.mets{RxnInfo.matches(iMet)} ' '] ;
                else
                   products{end + 1} = [' ' ...
                             CMODEL.mets{RxnInfo.metIndex(iMet)} ' '] ;
                end
            end
        end
    end
    % If there were no products, must be exchange reaction.
    if isempty(products{1})
        products{1} = '-->' ;
    end
    % Combine both halves of the equation and print to field.
    matchRxnEquation = [reactants{1, :} products{1, :} ] ;
    set(handles.newRxnEquationField, 'String', matchRxnEquation) ;
    handles.RxnInfo.matchRxnEquation = matchRxnEquation ;


    % NaN in metList create problem, so remove them (really, they shouldn't
    % be there in the first place)
    RxnInfo.metList(isnan(RxnInfo.metList)) = 0 ;

    % Set addReaction button off, then check if all the mets in the
    % reaction have good matches, then allowing the user to add the
    % reaction. Also, check for errors.
    errorString = 'Review required.' ;
    bgcolor = [0.7 0.7 0.7] ;
    % All metabolites must be good matches and new metabolites must be
    % reviewed.
    if ~ismember(1, RxnInfo.unseen) && ~ismember(0, RxnInfo.goodMatch)
        errorString = 'All clear.' ;
        set(handles.buttonAddMets, 'Enable', 'on') ;
    else
        for iMet = 1:RxnInfo.nMets
            if RxnInfo.metList(RxnInfo.metIndex(iMet)) ~= ...
                    RxnInfo.matches(iMet) && ...
                    RxnInfo.metList(RxnInfo.metIndex(iMet))
                errorString = ['ERROR: cMet ' ...
                    num2str(RxnInfo.metIndex(iMet)) ...
                    ' already assigned to tMet ' ...
                    num2str(RxnInfo.metList(RxnInfo.metIndex(iMet))) ...
                    '.'] ;
                bgcolor = [1 0 0] ;
                set(handles.buttonAddMets, 'Enable', 'off') ;
            elseif ~RxnInfo.metList(RxnInfo.metIndex(iMet)) ...
                    && ~isempty(find(RxnInfo.metList ...
                    == RxnInfo.matches(iMet), 1)) ...
                    && RxnInfo.matches(iMet) ~= 0
                errorString = ['ERROR: Metabolite ' ...
                    num2str(RxnInfo.metIndex(iMet)) ...
                    's match (tMet ' ...
                    num2str(RxnInfo.matches(iMet)) ...
                    ') already matched to cMet ' ...
                    num2str(find(RxnInfo.metList ...
                    == RxnInfo.matches(iMet), 1)) ...
                    '.'] ;
                bgcolor = [1 0 0] ;
                set(handles.buttonAddMets, 'Enable', 'off') ;
            end
        end
    end
% Set the error bar color to indicate an error or not.
set(handles.errorField, 'String', errorString, 'BackgroundColor', bgcolor) ;
else
    if ~RxnInfo.unseen
        set(handles.buttonAddMets, 'Enable', 'on') ;
    end
end

guidata(hObject, handles) ;
end

% Update stats.
function fillStats(handles)
RxnInfo = handles.RxnInfo ;
rxnString = [num2str(length(find(RxnInfo.rxnList >= 0))) ' / ' ...
             num2str(length(RxnInfo.rxnList))] ;
metString = [num2str(length(find(RxnInfo.metList))) ' / ' ...
             num2str(length(RxnInfo.metList))] ;
set(handles.text_metsDeclared, 'String', metString)
set(handles.text_rxnsAdded, 'String', rxnString)
end

%% Object Creation Functions
function popup_met_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_met (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function chooseOtherNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseOtherNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function editNMatches_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNMatches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function pushbutton_addinfo_Callback(hObject, eventdata, handles)
nowmet = get(handles.popup_met, 'String') ;
nowmet = nowmet{get(handles.popup_met, 'Value')} ;
nowmet = regexp(nowmet, ',', 'split') ;
nowmet = str2double(nowmet{end}) ;
addMetInfo(nowmet)

popup_met_Callback(handles.popup_met, [], handles)

end

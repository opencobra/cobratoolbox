function varargout = reactionCompareGUI(varargin)
% Lauches a GUI compare reactions visually. After each
% reaction is declared, metabolites for that reaction are are also matched.
% `reactionCompareGUI` should be accessed exclusively through the function
% `reactionCompare`.
% Called by `reactionCompare`, calls `optimalScores`, `autoMatchReactions`, `findRxnMatch`, `metCompare`, `countC`, `compareCbModels`.
%
% USAGE:
%
%    [rxnList, metList, Stats] = reactionCompareGUI(InfoBall) ;
%
% INPUTS:
%    InfoBall:      Structure which contains relevent information, including:
%    rxnList:       Array which links reactions in `Cmodel` to `Tmodel`
%    metList:       Array which links metabolites in `Cmodel` to `Tmodel`.
%    cModelName:    Name of the model
%    Stats:         Contains weighting parameters.
%
% OUTPUTS:
%    rxnList:       Array pairs reactions in `CMODEL` with matches from `TMODEL` or
%                   declares them as new.
%    metList:       Array pairs metabolites in `CMODEL` with matches from `TMODEL`,
%                   new metabolites are given their new met number in `TMODEL`.
%    Stats:         Stats array that contains weighting information from previous
%                   scoring work.
%    CMODEL:        global input
%    TMODEL:        global input
%    SCORE:         global input
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
                   'gui_OpeningFcn', @reactionCompareGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @reactionCompareGUI_OutputFcn, ...
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
%
% --- Executes just before reactionCompareGUI is made visible.
function reactionCompareGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for reactionCompareGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global TMODEL

% Pull out information from varargin
if length(varargin) ~= 1
    disp('Incorrect input arguments')
elseif length(varargin) == 1
    InfoBall = varargin{1} ;
    handles.rxnList = InfoBall.rxnList ;
    handles.metList = InfoBall.metList ;
    handles.M.Stats = InfoBall.Stats ;
    set(handles.text_cmodel, 'String', InfoBall.CmodelName)
    % Set Tmodel name if there is only one model.
    Tmodels = fieldnames(TMODEL.Models) ;
    if length(Tmodels) == 1
        set(handles.text_tmodel, 'String', Tmodels{1})
    end
end

% Compute scoreTotal and stats.
if ~isstruct(handles.M.Stats)
    handles.M.Stats = optimalScores ;
end
handles.M.scoreTotal = handles.M.Stats.scoreTotal ;

% Initial data fill.
pushbutton_populatetable_Callback(hObject, eventdata, handles)
handles.cRxn = str2double(get(handles.edit_rxn_num, 'String')) ;
handles.nMatch = str2double(get(handles.edit_num_matches, 'String')) ;

% Sets the cell selection callback feature.
set(handles.uitable_matchrxn, 'CellSelectionCallback', {@matchRxnCallback,...
                                                      handles})
set(handles.uitable_rxn, 'CellSelectionCallback', {@rxnTableCallback,...
                                                      handles})

% fix RowName of metabolite reference table
metRowHeaders = get(handles.uitable_met, 'RowName') ;
set(handles.uitable_met, 'RowName', metRowHeaders(1:end-1)) ;


% Update handles structure
guidata(hObject, handles);

jButton = findjobj(handles.pushbutton_sponsoredbybrain);
jButton.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
jButton.setBorder([]); % remove border
jButton.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT); % align text

% UIWAIT makes reactionCompareGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = reactionCompareGUI_OutputFcn(hObject, eventdata, handles)
% This is what we are looking for!!!
varargout{1} = handles.rxnList ;
varargout{2} = handles.metList ;

% Compile Stats structure.
Stats = handles.M.Stats ;
Stats.scoreTotal = handles.M.scoreTotal ;
varargout{3} = Stats ;

close
end

%% Button and Input Change Functions
% --- Executes on button press in pushbutton_populatetable.
function pushbutton_populatetable_Callback(hObject, eventdata, handles)
% Get reaction information for concerned reaction from CMODEL and matches.
handles.cRxn = str2double(get(handles.edit_rxn_num, 'String')) ;
handles.nMatch = str2double(get(handles.edit_num_matches, 'String')) ;

% Function populates tables.
fillTables(handles)

% resize Row headers uitable_rxn
jscroll = findjobj(handles.uitable_rxn) ;
rowHeaderViewport = jscroll.getComponent(4) ; %row header viewport
rowHeader = rowHeaderViewport.getComponent(0); %row header table
newWidth = 125 ;
rowHeaderViewport.setPreferredSize(java.awt.Dimension(newWidth, 0));
height=rowHeader.getHeight;
rowHeader.setPreferredSize(java.awt.Dimension(newWidth, height));
rowHeader.setSize(newWidth, height);
% realign header:
rend=rowHeader.getCellRenderer(1, 0);
rend.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
jscroll.repaint %apply changes

% resize Row headers uitable_met
jscroll = findjobj(handles.uitable_met) ;
rowHeaderViewport = jscroll.getComponent(4) ;
rowHeader = rowHeaderViewport.getComponent(0);
newWidth = 125 ;
rowHeaderViewport.setPreferredSize(java.awt.Dimension(newWidth, 0));
height=rowHeader.getHeight;
rowHeader.setPreferredSize(java.awt.Dimension(newWidth, height));
rowHeader.setSize(newWidth, height);
% realign header:
rend=rowHeader.getCellRenderer(1, 0);
rend.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
jscroll.repaint %apply changes

% Update handles structure.
guidata(hObject, handles) ;
end

% --- Executes on button press in pushbutton_nextNewRxn.
function handles = pushbutton_nextNewRxn_Callback(hObject, eventdata, handles)
% Find first reaction in rxnList which has no match (0) and a SCORE greater
% than user-defined minimum
goodrxns = intersect(find(handles.rxnList < 0), ...
                     find(handles.M.Stats.bestMatch >= ...
                          get(handles.slider_minscore, 'Value')) ) ;
[~, idx] = min(handles.M.Stats.bestMatch(goodrxns));
handles.cRxn = goodrxns(idx) ;%str2double(get(handles.edit_rxn_num,'String'))+1 ;

if isempty(handles.cRxn)
    handles.cRxn = 1 ;
end
set(handles.edit_rxn_num, 'String', handles.cRxn);
handles.nMatch = str2double(get(handles.edit_num_matches, 'String'));

% Function populates tables.
fillTables(handles)

% Update handles structure.
guidata(hObject, handles) ;
end

% --- Executes on button press in pushbutton_choose.
function pushbutton_choose_Callback(hObject, eventdata, handles)
global CMODEL
% Update rxnList.
selectedRxn = str2double(get(handles.edit_select_match, 'String')) ;
if ~isnan(selectedRxn)
    % If the reaction has not already been declared.
    if isempty(find(handles.rxnList == selectedRxn, 1))
        handles.rxnList(handles.cRxn) = selectedRxn ;

        % Compare metabolites from reaction.
        handles.metList = prepareMetCompare(handles) ;

        % check that none of the metabolites of the reaction has been declared new
        if sum(handles.metList(CMODEL.S(:, handles.cRxn) ~= 0) == 0) > 0
            set(handles.text_error, 'String', 'Rxn cannot be matched, it contains unmatched metabolites.') ;
            handles.rxnList(handles.cRxn) = -1 ;
        else
            set(handles.text_error, 'String', 'All clear.') ;

            % Recompute stats (pie chart).
            fillStats(handles)
            set(handles.edit_select_match, 'String', '') ;

            % Move to the next reaction.
            handles = pushbutton_nextNewRxn_Callback(hObject, eventdata, handles);
        end
    else
        errorString = ['ERROR: tRxn ' num2str(selectedRxn) ...
                       ' already assigned to cRxn ' ...
                       num2str(find(handles.rxnList == selectedRxn))] ;
        set(handles.text_error, 'String', errorString) ;
    end
else
    errorString = 'ERROR: No reaction selected' ;
    set(handles.text_error, 'String', errorString) ;
end

% Update handles structure.
guidata(hObject, handles) ;
end

% --- Executes on button press in pushbutton_new.
function pushbutton_new_Callback(hObject, eventdata, handles)
if handles.rxnList(handles.cRxn) == -1 || ...
        handles.rxnList(handles.cRxn) == 0
    handles.rxnList(handles.cRxn) = 0 ;
    set(handles.text_error, 'String', 'All Clear') ;

    % Compare metabolites from reaction.
    handles.metList = prepareMetCompare(handles)  ;
else
    errorString = ['WARNING: Reaction ' num2str(handles.cRxn) ...
                   ' previously declared as tRxn ' ...
                   num2str(handles.rxnList(handles.cRxn))] ;
    set(handles.text_error, 'String', errorString) ;
    handles.rxnList(handles.cRxn) = 0 ;
end

set(handles.edit_select_match, 'String', '') ;

% Update stats.
fillStats(handles)

% Update handles structure.
guidata(hObject, handles) ;

handles = pushbutton_nextNewRxn_Callback(hObject, eventdata, handles) ;

% Update handles structure.
guidata(hObject, handles) ;
end

% --- Executes on button press in pushbutton_auto.
function pushbutton_auto_Callback(hObject, eventdata, handles)
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')
% Run automatch without optimizer.
% Get automatch parameters
cutoffMatch = str2double(get(handles.edit_high, 'String')) ;
margin = str2double(get(handles.edit_margin, 'String')) ;
cutoffNew = str2double(get(handles.edit_low, 'String')) ;
metHighCutoff = str2double(get(handles.edit_metmatch_high, 'String')) ;
metMargin = str2double(get(handles.edit_metmatch_margin, 'String')) ;
metLowCutoff = str2double(get(handles.edit_metmatch_low, 'String')) ;

% Run automatching

[handles.rxnList, handles.metList] = ...
    autoMatchReactions(handles.M.scoreTotal, ...
                       handles.rxnList, handles.metList, ...
                       cutoffMatch,margin,cutoffNew,...
                       metHighCutoff,metMargin,metLowCutoff) ;

% Update graphs
fillStats(handles)

set(h, 'Enable', 'on')
% Update handles
guidata(hObject, handles)
end

% --- Executes on button press in pushbutton_defaultweight.
function pushbutton_defaultweight_Callback(hObject, eventdata, handles)
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')

[handles.M.Stats] = optimalScores(handles.rxnList, 'none') ;

handles.M.scoreTotal = handles.M.Stats.scoreTotal ;

fillStats(handles)
guidata(hObject, handles)
set(h, 'Enable', 'on')

%pushbutton_auto_Callback(handles.pushbutton_auto, eventdata, handles)
end

% --- Executes on button press in pushbutton_svm.
function pushbutton_svm_Callback(hObject, eventdata, handles)
% Run SVM optimizer, with or without parameter optimizer.
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')

handles.M.Stats = ...
    optimalScores(handles.rxnList, 'svm') ;
handles.M.scoreTotal = handles.M.Stats.scoreTotal ;

fillStats(handles)
guidata(hObject, handles)
set(h, 'Enable', 'on')

end


% --- Executes on button press in pushbutton_RF.
function pushbutton_RF_Callback(hObject, eventdata, handles)
% Run Random Forest optimizer, with or without parameter optimizer.
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')

handles.M.Stats = ...
    optimalScores(handles.rxnList, 'RF') ;
handles.M.scoreTotal = handles.M.Stats.scoreTotal ;


fillStats(handles)
guidata(hObject, handles)
set(h, 'Enable', 'on')
end

% --- Executes on button press in pushbutton_optFun.
function pushbutton_optFun_Callback(hObject, eventdata, handles)
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')
% Run funOpt optimizer
[handles.M.Stats] = ...
    optimalScores(handles.rxnList, 'linear') ;

handles.M.scoreTotal = handles.M.Stats.scoreTotal ;
fillStats(handles)
guidata(hObject, handles)
set(h, 'Enable', 'on')
end

% --- Executes on button press in pushbutton_expopt.
function pushbutton_expopt_Callback(hObject, eventdata, handles)
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')
% Run funOpt optimizer
[handles.M.Stats] = ...
    optimalScores(handles.rxnList, 'exp') ;

handles.M.scoreTotal = handles.M.Stats.scoreTotal ;

fillStats(handles)
guidata(hObject, handles)
set(h, 'Enable', 'on')
end

% --- Executes on button press in pushbutton_reviewMets.
function pushbutton_reviewMets_Callback(hObject, eventdata, handles)
% Convenience variables.
global CMODEL
rxnList = handles.rxnList ;
metList = handles.metList ;

% Determine which metabolites need to be reviewed. (Find reactions that are
% matched or declared new that have undesignated metabolites.)
for iRxn = 1:length(rxnList)
    % If the reaction has been matched or declared new.
    if rxnList(iRxn) ~= -1
        % Find the metabolites in the reaction.
        involvedMets = find(CMODEL.S(:, iRxn)) ;
        % Do the involved mets have matches? If not add them to a list.
        if sum(~metList(involvedMets))
            if exist('rxnsWithUnmatchedMets', 'var')
                rxnsWithUnmatchedMets(end + 1, 1) = iRxn ;
            else
                rxnsWithUnmatchedMets(1, 1) = iRxn ;
            end
        end
    end
end

% Assemble information and look for mets via GUI.
if exist('rxnsWithUnmatchedMets', 'var')
    h = findobj(gcf, 'Enable', 'on') ;
    set(h, 'Enable', 'off')
    hWait = waitbar(0, 'Automatching') ;

    for iRxn = 1:length(rxnsWithUnmatchedMets)
        RxnInfo.rxnIndex = rxnsWithUnmatchedMets(iRxn) ;
        RxnInfo.rxnMatch = handles.rxnList(rxnsWithUnmatchedMets(iRxn)) ;
        RxnInfo.rxnList = handles.rxnList ;
        RxnInfo.metList = handles.metList ;
        RxnInfo.metAutoMatchLimits = [str2double(get( ...
                                handles.edit_metmatch_high, 'String')) ...
                                str2double(get( ...
                                handles.edit_metmatch_margin, 'String')) ...
                                str2double(get( ...
                                handles.edit_metmatch_low, 'String'))] ;

        % Launch comparison script.

        [handles.metList, stopFlag] = metCompare(RxnInfo) ;
        waitbar(iRxn/length(rxnsWithUnmatchedMets), hWait)

        % If metCompare was suspended, don't attempt to find matches for the
        % reamining reactions.
        if stopFlag
            break
        end
    end

    close(hWait)
    set(h, 'Enable', 'on')
else
    errorString = 'All metabolites currently reviewed.' ;
    set(handles.text_error, 'String', errorString) ;

end

fillStats(handles)

% Update handles structure.
guidata(hObject, handles) ;
end

% --- Executes on selection of item in uitable_matchrxn
function matchRxnCallback(hObject, eventdata, handles)
handles.cRxn = str2double(get(handles.edit_rxn_num, 'String')) ;
if ~isempty(eventdata.Indices)
    global CMODEL TMODEL

    % Set match reaction number based on column clicked.
    matchColumn = eventdata.Indices(2) ;
    matchTable = get(handles.uitable_matchrxn, 'Data') ;
    nowMatchIndex = matchTable{1, matchColumn} ;
    nowMatchIndex = nowMatchIndex(strfind(nowMatchIndex, ';') + 1:end) ;
    set(handles.edit_select_match, 'String', nowMatchIndex)

    % Pull out match data for following checks.
    handles.nMatch = str2double(get(handles.edit_num_matches, 'String')) ;
    if isnan(handles.nMatch) ; handles.nMatch = 2 ; end
    Data = findRxnMatch(handles.cRxn, handles.nMatch, handles.M.scoreTotal) ;

    % Check if compartments are the same.
    if strcmp(CMODEL.rxnComp{handles.cRxn}, TMODEL.rxnComp{str2double(nowMatchIndex)})
        set(handles.text_compartment, 'BackgroundColor', [0 0.2 1])
    else
        set(handles.text_compartment, 'BackgroundColor', [1 0 0])
    end

    % Check if stoichiometry is the same.
    if (strcmp(sort(Data.cMetTable{4, 1}), ...
               sort(Data.tMetTable{4, matchColumn})) ...
            && ...
            strcmp(sort(Data.cMetTable{11, 1}), ...
                   sort(Data.tMetTable{11, matchColumn})) ) ...
       || ... % allow reaction to be formulated in the reverse direction
       (strcmp(sort(Data.cMetTable{11, 1}), ...
               sort(Data.tMetTable{4, matchColumn})) ...
            && ...
            strcmp(sort(Data.cMetTable{4, 1}), ...
                   sort(Data.tMetTable{11, matchColumn})) )
        set(handles.text_stoich, 'BackgroundColor', [0 0.2 1])
    else
        set(handles.text_stoich, 'BackgroundColor', [1 0 0])
    end

    % check if sum formulas are present for all reactants
    if ~(formulasPresentCheck(Data.cMetTable{5, 1}) && ...
            formulasPresentCheck(Data.tMetTable{5, matchColumn}) && ...
            formulasPresentCheck(Data.cMetTable{12, 1}) && ...
            formulasPresentCheck(Data.tMetTable{12, matchColumn}))
        set(handles.text_cbalance, 'BackgroundColor', [1 1 1])
    else
        % Check carbon balance.
        cNum = [0 0 0 0] ;
        % C reactants.
        cNum(1) = CsInFormula(Data.cMetTable{5, 1},Data.cMetTable{4, 1}) ;
        % T reactants.
        cNum(2) = CsInFormula(Data.tMetTable{5, matchColumn}, ...
            Data.tMetTable{4, matchColumn}) ;
        % C products.
        cNum(3) = CsInFormula(Data.cMetTable{12, 1},Data.cMetTable{11, 1}) ;
        % T products.
        cNum(4) = CsInFormula(Data.tMetTable{12, matchColumn}, ...
            Data.tMetTable{11, matchColumn}) ;
        % Remove NaN's (in case of exchange reaction).
        cNum(isnan(cNum)) = [] ;
        % Set color according to match or not. All values should be the same.
        if length(unique(cNum)) == 1
            set(handles.text_cbalance, 'BackgroundColor', [0 0.2 1])
        else
            set(handles.text_cbalance, 'BackgroundColor', [1 0 0])
        end
    end

    % Opens up KEGG ID site if KEGGID is selected
    matchRow = eventdata.Indices(1) ;
    % If we are in the right row.
    if matchRow == 6
       % Grab the ID.
       rID = Data.tRxnTable{6, matchColumn} ;
       if ~isempty(rID)
           % Enforce the rID is the right length.
           rID = rID(1:6) ;
           KEGGIDurl = ['http://www.genome.jp/dbget-bin/www_bget?' rID] ;
           web(KEGGIDurl, '-new', '-noaddressbox', '-notoolbar')
       end
    end
end

end

% --- Executes on selection of item in uitable_rxn
function rxnTableCallback(hObject, eventdata, handles)
global CMODEL
handles.cRxn = str2double(get(handles.edit_rxn_num, 'String')) ;
if ~isempty(eventdata.Indices)
    % Opens up KEGG ID site if KEGGID is selected
    matchRow = eventdata.Indices(1) ;
    % If we are in the right row.
    if matchRow == 5
       % Grab the ID.
       rID = CMODEL.rxnKEGGID{handles.cRxn} ;
       if ~isempty(rID)
           % Enforce the rID is the right length.
           rID = rID(1:6) ;
           % Launch browser.
           KEGGIDurl = ['http://www.genome.jp/dbget-bin/www_bget?' rID] ;
           web(KEGGIDurl,'-new','-noaddressbox','-notoolbar')
       end
    end
end
end

% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% Allows the uiwait command to suspend, exiting the GUI
uiresume(handles.figure1)
end

function slider_minscore_Callback(hObject, eventdata, handles)

set(handles.text_slidervalue, 'String', num2str(get(hObject, 'Value')))
end


%% Subfunctions
function fillTables(handles)
% Call findRxnMatch to retrieve information
Data = findRxnMatch(handles.cRxn, handles.nMatch, handles.M.scoreTotal) ;

% Put information into the 4 tables.
nowtable = Data.cRxnTable ;
for ic = 1:size(nowtable, 2)
    for ir = 1:size(nowtable, 1)
        if iscell(nowtable{ir, ic})
            nowtable{ir, ic} = [nowtable{ir, ic}{:}] ;
        end
        % add leading whitespace to all cells
        nowtable{ir, ic} = ['  ' nowtable{ir, ic}] ;
    end
end
set(handles.uitable_rxn, 'Data', nowtable ) ;

nowtable = Data.cMetTable([2 3 5 6 7 9 10 12 13 14]) ;
for ic = 1:size(nowtable, 2)
    for ir = 1:size(nowtable, 1)
        if iscell(nowtable{ir, ic})
            nowtable{ir, ic} = [nowtable{ir, ic}{:}] ;
        end
        % add leading whitespace to all cells
        nowtable{ir,ic} = ['  ' nowtable{ir, ic}] ;
    end
end
set(handles.uitable_met,'Data', nowtable )

nowtable = Data.tMetTable([2 3 5 6 7 9 10 12 13 14],:) ;
for ic = 1:size(nowtable,2)
    for ir = 1:size(nowtable,1)
        if iscell(nowtable{ir,ic})
            nowtable{ir,ic} = [nowtable{ir,ic}{:}] ;
        end
        % add leading whitespace to all cells
        nowtable{ir,ic} = ['  ' nowtable{ir,ic}] ;
    end
end
set(handles.uitable_matchMet,'Data', nowtable)

ctable = Data.cRxnTable(2:length(Data.cRxnTable)) ;
colOptions = {'blue', 'red'} ;
nowtable = Data.tRxnTable ;

% Color the information in the table based on if it matches.
for ic = 1:size(nowtable, 2)
    for ir = 1:size(nowtable, 1)
        if ir == 1
            % add leading whitespace to all cells
            nowtable{ir, ic} = ['  ' nowtable{ir, ic}] ;
        elseif ~isempty(nowtable{ir, ic}) && ~isempty(ctable{ir - 1, 1}) && (ir ~= 4)
            nowtable{ir, ic} = colText(['&nbsp; ' nowtable{ir, ic}], ...
            colOptions{1+isempty(strfind(nowtable{ir, ic}, ctable{ir - 1, 1}))}) ;
        else
            % add leading whitespace to all cells
            nowtable{ir, ic} = ['  ' nowtable{ir, ic}] ;
        end
    end
end

set(handles.uitable_matchrxn, 'Data', nowtable)
set(handles.text_compartment, 'BackgroundColor', [1 1 1])
set(handles.text_stoich, 'BackgroundColor', [1 1 1])
set(handles.text_cbalance, 'BackgroundColor', [1 1 1])
fillStats(handles)
end

function fillStats(handles)
global CMODEL
rxnList = handles.rxnList ;
metList = handles.metList ;
bestMatch = handles.M.Stats.bestMatch ;

% Fill in selected match information for cRxn.
if rxnList(handles.cRxn) > 0
    matchString = num2str(rxnList(handles.cRxn)) ;
elseif rxnList(handles.cRxn) == 0
    matchString = 'New' ;
else
    matchString = 'None' ;
end
set(handles.text_currentMatch, 'String', matchString) ;

% Reactions and metabolites declared so far.
rxnString = [num2str(length(find(rxnList >= 0))) ' / ' ...
             num2str(length(rxnList))] ;
metString = [num2str(length(find(metList))) ' / ' ...
             num2str(length(metList))] ;

% Pie chart of current matches.
pieData = [length(find(rxnList > 0)) ...
           length(find(rxnList == 0)) ...
           length(find(rxnList < 0))] ;
set(handles.text_nMatch, 'String', num2str(pieData(1))) ;
set(handles.text_nNew, 'String', num2str(pieData(2))) ;
set(handles.text_nNeedReview, 'String', num2str(pieData(3))) ;

% Set colors, deal with possibility that a categorey may be empty.
if pieData(1) && pieData(2) && pieData(3)
    h = pie(handles.axes_pie, pieData) ;
    set(h(1), 'FaceColor', [0.597   0.594   0.594]) ;
    set(h(3), 'FaceColor', [0.796,  0.792,  0.792]) ;
    set(h(5), 'FaceColor', [1.000,  1.000,  1.000]) ;
elseif pieData(1) && pieData(2) && ~pieData(3)
    pieData = [pieData(1) pieData(2)] ;
    h = pie(handles.axes_pie,pieData) ;
    set(h(1), 'FaceColor', [0.597   0.594   0.594]) ;
    set(h(3), 'FaceColor', [0.796,  0.792,  0.792]) ;
elseif pieData(1) && ~pieData(2) && pieData(3)
    pieData = [pieData(1) pieData(3)] ;
    h = pie(handles.axes_pie, pieData) ;
    set(h(1), 'FaceColor', [0.597   0.594   0.594]) ;
    set(h(3), 'FaceColor', [1.000,  1.000,  1.000]) ;
elseif pieData(1) && ~pieData(2) && ~pieData(3)
    pieData = pieData(1);
    h = pie(handles.axes_pie,pieData) ;
    set(h(1), 'FaceColor', [0.597   0.594   0.594]) ;
elseif ~pieData(1) && pieData(2) && pieData(3)
    pieData = [pieData(2) pieData(3)] ;
    h = pie(handles.axes_pie, pieData) ;
    set(h(1), 'FaceColor', [0.796,  0.792,  0.792]) ;
    set(h(3), 'FaceColor', [1.000,  1.000,  1.000]) ;
elseif ~pieData(1) && pieData(2) && ~pieData(3)
    pieData = pieData(2) ;
    h = pie(handles.axes_pie, pieData) ;
    set(h(1), 'FaceColor', [0.796,  0.792,  0.792]) ;
elseif ~pieData(1) && ~pieData(2) && pieData(3)
    pieData = pieData(3) ;
    h = pie(handles.axes_pie,pieData) ;
    set(h(1), 'FaceColor', [1.000,  1.000,  1.000]) ;
end
pielabel = findobj(h, 'Type', 'text');
set(pielabel, 'FontWeight', 'bold', 'Color', [0.41 0.4 0.4]);

% Histogram of best matches
axes(handles.axes_hist)
[frequency, position] = hist(double(bestMatch),100) ;
bar(position, frequency, 'facecolor', [0.765,  0.082,  0.145], 'edgecolor', [0.765,  0.082,  0.145])
axis tight
xlim([0 1]) ;
title('Frequency of scores of best match per reaction')

% Check if there are any mets that need review.
set(handles.pushbutton_reviewMets, 'Enable', 'off')
for iRxn = 1:length(rxnList)
    % If the reaction has been matched or declared new.
    if rxnList(iRxn) ~= -1
        % Find the metabolites in the reaction.
        involvedMets = find(CMODEL.S(:, iRxn)) ;
        % Do the involved mets have matches? If not add them to a list.
        if sum(~metList(involvedMets))
            set(handles.pushbutton_reviewMets, 'Enable', 'on')
            break
        end
    end
end
end

function metList = prepareMetCompare(handles)
% Assemble RxnInfo structure which is passed to GUI.
RxnInfo.rxnIndex = handles.cRxn ;
RxnInfo.rxnMatch = handles.rxnList(handles.cRxn) ;
RxnInfo.rxnList = handles.rxnList ;
RxnInfo.metList = handles.metList ;
RxnInfo.metAutoMatchLimits = [str2double(get(handles.edit_metmatch_high,...
                                          'String')) ...
                           str2double(get(handles.edit_metmatch_margin, ...
                                          'String')) ...
                           str2double(get(handles.edit_metmatch_low, ...
                                          'String'))] ;
% Launch GUI, disable reactionCompare.
h = findobj(gcf, 'Enable', 'on') ;
set(h, 'Enable', 'off')
metList = metCompare(RxnInfo) ;
set(h, 'Enable', 'on')
end

%% Changes in number edit fields. Unused.
function edit_select_match_Callback(hObject, eventdata, handles)
end

function edit_num_matches_Callback(hObject, eventdata, handles)
end

function edit_rxn_num_Callback(hObject, eventdata, handles)
end

function edit_high_Callback(hObject, eventdata, handles)
end

function edit_margin_Callback(hObject, eventdata, handles)
end

function edit_low_Callback(hObject, eventdata, handles)
end

function edit_metmatch_low_Callback(hObject, eventdata, handles)
end

function edit_metmatch_margin_Callback(hObject, eventdata, handles)
end

function edit_metmatch_high_Callback(hObject, eventdata, handles)
end

%% Object Creation Functions
function edit_select_match_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_match (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_rxn_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rxn_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_score_table_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_score_table_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_num_matches_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_matches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,' BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_cmodel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_tmodel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_margin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function slider_minscore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_minscore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', [.9 .9 .9]);
end
end

function edit_metmatch_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_metmatch_margin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

function edit_metmatch_high_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
end

% additional function for counting carbons.
function Cs = CsInFormula(formulaString,stoicString)
Cs = 0 ;
scPos = [0 strfind(formulaString, ';') length(formulaString) + 1] ;
scPosS = [0 strfind(stoicString, ';') length(stoicString) + 1] ;
for isc = 1:length(scPos) - 1
    nowSubstring = formulaString(scPos(isc) + 1:scPos(isc + 1) - 1) ;
    stoic = abs(str2double(stoicString( ...
        scPosS(isc) + 1:scPosS(isc + 1) - 1))) ;
    Cs = Cs + stoic * countC(nowSubstring) ;
end
end

% check if for all metabolites Formulas were given
function allFormulas = formulasPresentCheck(nowstring)
    allFormulas = false ;
    if ~strcmp(nowstring, ';')
        singlestrings = splitString(nowstring, ';') ;
        if length(singlestrings) == (length(strfind(nowstring, ';')) + 1)
            allFormulas = true ;
        end
    end
end

global trGroup
global transcriptomicsDataSamples
global modelGroup
global mediumGroup

global thGroup
global thValueSelectionGroup
global upperThLabel
global upperThreshold

global gmGroup

global boundConstrGroup

global nonOptTasksGroup
global nonOptCompareSource
global nonOptCompareTarget
global nonOptLabel1
global nonOptLabel2

global postOptTasksGroup
global initCobraWithUpdates
global initCobraNoUpdates

addpath('Scripts');

openDlg();

function openDlg()
    d = dialog('Position',[550 50 610 650],'Name','IgemRNA');
    
    % Transcriptomics Data Input
    global trGroup
    trGroup = uibuttongroup('parent', d, 'Title', 'Load Transcriptomics Data','TitlePosition','lefttop','Position',[.01 .88 0.98 0.1]);
    e = uicontrol('parent',trGroup, 'Style', 'edit', 'HorizontalAlignment', 'left', 'enable', 'off', 'pos', [10, 10, 470, 20]);
    trDataPath = uicontrol('parent', trGroup, 'Style', 'pushbutton', 'String', 'Open', 'pos',[500, 10, 75, 20], 'Callback', {@Data_Selected,e});

    % Model Input
    global modelGroup
    modelGroup = uibuttongroup('parent', d, 'Title', 'Load Model','TitlePosition','lefttop','Position',[.01 .78 0.98 0.1]);
    e2 = uicontrol('parent',modelGroup, 'Style', 'edit', 'HorizontalAlignment', 'left', 'enable', 'off', 'pos', [10, 10, 470, 20]);
    modelPath = uicontrol('parent', modelGroup, 'Style', 'pushbutton', 'String', 'Open', 'pos',[500, 10, 75, 20], 'Callback', {@Data_Selected,e2});
    
    % Medium Data Input
    global mediumGroup
    mediumGroup = uibuttongroup('parent', d, 'Title', 'Load Medium Data','TitlePosition','lefttop','Position',[.01 .68 0.98 0.1]);
    e3 = uicontrol('parent',mediumGroup, 'Style', 'edit', 'HorizontalAlignment', 'left', 'enable', 'off', 'pos', [10, 10, 470, 20]);
    mediumDataPath = uicontrol('parent', mediumGroup, 'Style', 'pushbutton', 'String', 'Open', 'pos',[500, 10, 75, 20], 'Callback', {@Data_Selected,e3});

    global thValueSelectionGroup
    thValueSelectionGroup = uibuttongroup('parent',d,'Title','Global Threshold Value Selection','TitlePosition','lefttop','visible','off','Position',[.52 .48 0.47 0.2]);
    lowerThLabel = uicontrol('Style', 'text', 'parent', thValueSelectionGroup, 'String', 'Lower Threshold: ', 'HorizontalAlignment', 'left', 'pos', [5 70 100 20]);
    lowerThreshold = uicontrol('parent', thValueSelectionGroup, 'Style', 'edit', 'String', '0', 'HorizontalAlignment', 'left', 'pos', [120, 72, 100, 20], 'callback',@Numeric_Validate);
    global upperThLabel
    global upperThreshold
    upperThLabel = uicontrol('visible', 'off', 'Style', 'text', 'parent', thValueSelectionGroup, 'String', 'Upper Threshold: ', 'HorizontalAlignment', 'left', 'pos', [5 40 100 20]);
    upperThreshold = uicontrol('visible', 'off', 'parent', thValueSelectionGroup, 'Style', 'edit', 'HorizontalAlignment', 'left', 'pos', [120, 42, 100, 20], 'callback',@Numeric_Validate);
    isExactVal = uicontrol('Style', 'Radio', 'String', 'Exact Value','pos', [5 15 100 15], 'parent',thValueSelectionGroup);
    isPercentile = uicontrol('Style', 'Radio', 'String', 'Percentile','pos', [110 15 100 15], 'parent',thValueSelectionGroup);
    thValueSelectionGroup.Visible = 'on';
    
    % Thresholding Approach Radio Buttons
    global thGroup
    thGroup = uibuttongroup('parent',d,'Title','Thresholding Approach','TitlePosition','lefttop','visible','off','Position',[.01 .48 0.5 0.2]);
    t1 = uicontrol('Style','Radio','String','Global T1 (one global)','pos',[10 70 400 15],'parent',thGroup, 'callback',{@Threshold_Approach_changed});
    t2 = uicontrol('Style','Radio','String','Local T1 (one global + local)','pos',[10 50 400 15],'parent',thGroup, 'callback',{@Threshold_Approach_changed});
    t3 = uicontrol('Style','Radio','String','Local T2 (two global + local)','pos',[10 30 400 15],'parent',thGroup, 'callback',{@Threshold_Approach_changed});
    thGroup.Visible = 'on';
    
    % Gene Mapping Approach Radio Buttons
    global gmGroup
    gmGroup = uibuttongroup('parent',d,'Title','Gene Mapping Approach (AND/OR)','TitlePosition','lefttop','visible','off','Position',[.01 .38 0.3 0.1]);
    gmMinMax = uicontrol('Style','Radio','String','Min/Max','pos',[10 30 70 15],'parent',gmGroup);
    gmMinSum = uicontrol('Style','Radio','String','Min/Sum','pos',[10 10 70 15],'parent',gmGroup);
    gmGmMax = uicontrol('Style','Radio','String','GM/Max','pos',[90 30 70 15],'parent',gmGroup);
    gmGmSum = uicontrol('Style','Radio','String','GM/Sum','pos',[90 10 70 15],'parent',gmGroup);
    gmGroup.Visible = 'off';
    
    % Bound Constraining Options
    global boundConstrGroup
    boundConstrGroup = uibuttongroup('parent',d,'Title','Constraining Options','TitlePosition','lefttop','visible','off','Position',[.32 .38 0.67 0.1]);
    constrIrreversible = uicontrol('Style','Radio','String','Only irreversible reactions','pos',[10 30 310 15],'parent',boundConstrGroup);
    consrtAll = uicontrol('Style', 'Radio', 'String', 'All reactions','pos', [10 10 310 15], 'parent',boundConstrGroup);
    % Preserve growth requirements options
    growthNotAffectingGeneDel = uicontrol('parent',boundConstrGroup,'Style','checkbox','String','Growth not affecting gene deletion only', 'pos',[180 30 400 15],'Enable','off');
    meetMinimumGrowthReq = uicontrol('parent',boundConstrGroup,'Style','checkbox','String','Meet minimum growth requirements', 'pos',[180 10 400 15]);
    boundConstrGroup.Visible = 'off';
    
    global nonOptTasksGroup
    global nonOptCompareSource
    global nonOptCompareTarget
    global nonOptLabel1
    global nonOptLabel2
    nonOptTasksGroup = uibuttongroup('parent',d,'Title','Non-optimization Tasks','TitlePosition','lefttop','visible','off','Position',[.01 .08 0.5 0.3]);
    nonOptT1 = uicontrol('parent',nonOptTasksGroup,'Style','checkbox','String','Filter highly and lowly expressed genes', 'pos',[10 150 400 15]);
    nonOptT2 = uicontrol('parent',nonOptTasksGroup,'Style','checkbox','String','Filter lowly expressed genes', 'pos',[10 130 400 15]);
    nonOptT3 = uicontrol('parent',nonOptTasksGroup,'Style','checkbox','String','Filter up-/down-regulated genes between phenotypes', 'pos',[10 110 400 15],'callback',{@NonOptComparePhenotypes_changed});
    nonOptLabel1 = uicontrol('visible','off','Style', 'text', 'parent', nonOptTasksGroup, 'String', 'Compare', 'HorizontalAlignment', 'left', 'pos', [10 80 45 15]);
    nonOptCompareSource = uicontrol('visible','off','Style','popupmenu','parent',nonOptTasksGroup, 'String',{},'HorizontalAlignment', 'left', 'pos',[60 82 80 15]); 
    nonOptLabel2 = uicontrol('visible','off','Style', 'text', 'parent', nonOptTasksGroup, 'String', 'with', 'HorizontalAlignment', 'left', 'pos', [145 80 45 15]);
    nonOptCompareTarget = uicontrol('visible','off','Style','popupmenu','parent',nonOptTasksGroup, 'String',{},'HorizontalAlignment', 'left', 'pos',[170 82 80 15]); 
    
    global postOptTasksGroup
    global postOptLabel1
    global postOptCompareSource
    global postOptLabel2
    global postOptCompareTarget
    global initCobraWithUpdates
    global initCobraNoUpdates
    postOptTasksGroup = uibuttongroup('parent',d,'Title','Post-optimization Tasks','TitlePosition','lefttop','visible','off','Position',[.52 .08 0.47 0.3]);
    useExistingModels = uicontrol('parent',postOptTasksGroup,'Style','checkbox','String','Use existing context-specific models','fontweight', 'bold', 'pos',[10 165 400 15]);
    postOptT1 = uicontrol('parent',postOptTasksGroup,'Style','checkbox','String','Filter non-flux reactions', 'pos',[10 148 400 15]);
    postOptT2 = uicontrol('parent',postOptTasksGroup,'Style','checkbox','String','Filter rate limitting reactions', 'pos',[10 131 400 15],'callback',{@PostOpt_changed});
    postOptT3 = uicontrol('parent',postOptTasksGroup,'Style','checkbox','String','Calculate flux shifts between phenotypes', 'pos',[10 114 400 15],'callback',{@PostOpt_changed});
    postOptLabel1 = uicontrol('visible','off','Style', 'text', 'parent', postOptTasksGroup, 'String', 'Compare', 'HorizontalAlignment', 'left', 'pos', [10 90 45 15]);
    postOptCompareSource = uicontrol('visible','off','Style','popupmenu','parent',postOptTasksGroup, 'String',{},'HorizontalAlignment', 'left', 'pos',[60 92 80 15]); 
    postOptLabel2 = uicontrol('visible','off','Style', 'text', 'parent', postOptTasksGroup, 'String', 'with', 'HorizontalAlignment', 'left', 'pos', [145 90 45 15]);
    postOptCompareTarget = uicontrol('visible','off','Style','popupmenu','parent',postOptTasksGroup, 'String',{},'HorizontalAlignment', 'left', 'pos',[170 92 80 15]); 
    
    % Objective select
    objectiveFuctionLabel = uicontrol('Style', 'text', 'parent', postOptTasksGroup, 'String', 'Objective function Id: ', 'HorizontalAlignment', 'left', 'pos', [10 60 110 20]);
    objectiveFunction = uicontrol('parent', postOptTasksGroup, 'String','r_1761', 'Style', 'edit', 'HorizontalAlignment', 'left', 'pos', [120, 63, 140, 20]);
    %Biomass exclusion
    excludeBiomass = uicontrol('parent',postOptTasksGroup,'Style','checkbox','String','Exclude biomass', 'pos',[10 40 110 20]);
    biomassId = uicontrol('parent', postOptTasksGroup, 'String','r_4041', 'Style', 'edit', 'HorizontalAlignment', 'left', 'pos', [120, 45, 140, 20]);
    
    initCobraNoUpdates = uicontrol('visible','off','Style','Radio','String','Initialize CobraToolbox Without Updates','pos',[10 20 400 15],'parent',postOptTasksGroup);
    initCobraWithUpdates = uicontrol('visible','off','Style', 'Radio', 'String', 'Initialize CobraToolbox With Updates','pos', [10 5 400 15], 'parent',postOptTasksGroup);
    
    Okbtn = uicontrol('parent', d, 'Style', 'pushbutton', 'String', 'OK', 'pos',[445, 10, 75, 20], 'Callback', {@OK});
    Cancelbtn = uicontrol('parent', d, 'Style', 'pushbutton', 'String', 'Close', 'pos',[520, 10, 75, 20], 'Callback', 'delete(gcf)');
end

function Data_Selected(sender, event, textInput)
global postOptTasksGroup
global transcriptomicsDataSamples
global nonOptTasksGroup
global gmGroup
global boundConstrGroup
global initCobraWithUpdates
global initCobraNoUpdates
    [FileName, FilePath] = uigetfile({'*.xlsx; *.xls'});
    if ~ischar(FileName)
       return;
    end
    set(textInput, 'String', fullfile(FilePath, FileName));
    disp(textInput.Parent());
    if contains(textInput.Parent().Title,"Model")
        postOptTasksGroup.Visible = 'on';
        gmGroup.Visible = 'on';
        boundConstrGroup.Visible = 'on';
        initCobraWithUpdates.Visible = 'on';
        initCobraNoUpdates.Visible = 'on';
    end
    if contains(textInput.Parent().Title,"Transcriptomics")
        trDataPath = textInput.String;
        [theMessage, sheetNames] = xlsfinfo(trDataPath);
        transcriptomicsDataSamples = sheetNames;
        nonOptTasksGroup.Visible = 'on';
    end
end

function PostOpt_changed(sender, event)
    disp(sender);
    global postOptCompareSource 
    global postOptCompareTarget
    global postOptLabel1
    global postOptLabel2
    global transcriptomicsDataSamples
    
    if contains(sender.String, 'flux shifts')
        if sender.Value == 1
            postOptCompareSource.String = transcriptomicsDataSamples;
            postOptCompareTarget.String = [transcriptomicsDataSamples 'All'];
            postOptCompareSource.Visible = 'on';
            postOptCompareTarget.Visible = 'on';
            postOptLabel1.Visible = 'on';
            postOptLabel2.Visible = 'on';
        else
            postOptCompareSource.Visible = 'off';
            postOptCompareTarget.Visible = 'off';
            postOptLabel1.Visible = 'off';
            postOptLabel2.Visible = 'off';
        end
    end
end

function NonOptComparePhenotypes_changed(sender, event)
    global nonOptCompareSource
    global nonOptCompareTarget
    global nonOptLabel1
    global nonOptLabel2
    global transcriptomicsDataSamples
    if sender.Value == 1
        nonOptCompareSource.String = transcriptomicsDataSamples;
        nonOptCompareTarget.String = [transcriptomicsDataSamples 'All'];
        nonOptCompareSource.Visible = 'on';
        nonOptCompareTarget.Visible = 'on';
        nonOptLabel1.Visible = 'on';
        nonOptLabel2.Visible = 'on';
    else
        nonOptCompareSource.Visible = 'off';
        nonOptCompareTarget.Visible = 'off';
        nonOptLabel1.Visible = 'off';
        nonOptLabel2.Visible = 'off';
    end
end

function Threshold_Approach_changed(sender, event)
    global upperThLabel
    global upperThreshold
    if contains(sender.String, "T2")
        upperThLabel.Visible = 'on';
        upperThreshold.Visible = 'on';
    else 
        upperThLabel.Visible = 'off';
        upperThreshold.Visible = 'off';
    end
end

function Numeric_Validate(src,eventdata)
    str=get(src,'String');
    if isempty(str2num(str))
        set(src,'string','0');
        warndlg('Input must be numerical');
    end
end

function OK(~,~)
    data = {};
    global trGroup
    global modelGroup
    global mediumGroup
    
    global thGroup
    global thValueSelectionGroup

    global gmGroup
    global boundConstrGroup
    
    global nonOptTasksGroup
    global postOptTasksGroup

    %Supplied data files
    data.trDataPath = trGroup.Children(2).String;
    data.modelPath = modelGroup.Children(2).String;
    data.mediumDataPath = mediumGroup.Children(2).String;
    
    %Thresholding approach
    data.globalT1 = thGroup.Children(3).Value;
    data.localT1 = thGroup.Children(2).Value;
    data.localT2 = thGroup.Children(1).Value; 
    
    %Global threshold values
    data.lowerGlobal = thValueSelectionGroup.Children(5).String;
    data.upperGlobal = thValueSelectionGroup.Children(3).String;
    data.exact = thValueSelectionGroup.Children(2).Value;
    data.percentile = thValueSelectionGroup.Children(1).Value;

    %Gene mapping approach
%     data.gmMAX = gmGroup.Children(2).Value;
%     data.gmSUM = gmGroup.Children(1).Value;
    data.gmGmSum = gmGroup.Children(1).Value;
    data.gmGmMax = gmGroup.Children(2).Value;
    data.gmMinSum = gmGroup.Children(3).Value;
    data.gmMinMax = gmGroup.Children(4).Value;

    %Bound constraining options
    data.constrIrreversible = boundConstrGroup.Children(4).Value;
    data.constrAll = boundConstrGroup.Children(3).Value;
    data.meetMinimumGrowthReq = boundConstrGroup.Children(1).Value;
    data.growthNotAffectingGeneDel = boundConstrGroup.Children(2).Value;
    
    %Non-optimization tasks
    data.filterHighlyLowlyExpressedGenes = nonOptTasksGroup.Children(7).Value;
    data.filterLowlyExpressedGenes = nonOptTasksGroup.Children(6).Value;
    data.ComparePhenotypeGenes = nonOptTasksGroup.Children(5).Value;
    data.nonOptCompareSource = {};
    if length(nonOptTasksGroup.Children(3).String()) > 0
        data.nonOptCompareSource = nonOptTasksGroup.Children(3).String(nonOptTasksGroup.Children(3).Value);
    end
    data.nonOptCompareTarget = {};
    if length(nonOptTasksGroup.Children(1).String())
        data.nonOptCompareTarget = nonOptTasksGroup.Children(1).String(nonOptTasksGroup.Children(1).Value);
    end
    
    %Post-optimization tasks
    data.useExistingModels = postOptTasksGroup.Children(14).Value;
    data.filterNonFluxReactions = postOptTasksGroup.Children(13).Value;
    data.filterRateLimittingReactions = postOptTasksGroup.Children(12).Value;
    data.calculateFluxShifts = postOptTasksGroup.Children(11).Value;
    data.fluxShiftsSource = {};
    if length(postOptTasksGroup.Children(9).String()) > 0
        data.fluxShiftsSource = postOptTasksGroup.Children(9).String(postOptTasksGroup.Children(9).Value);
    end
    data.fluxShiftsTarget = {};
    if length(postOptTasksGroup.Children(7).String()) > 0
        data.fluxShiftsTarget = postOptTasksGroup.Children(7).String(postOptTasksGroup.Children(7).Value);
    end
    
    data.objectiveFunction = postOptTasksGroup.Children(5).String;
    data.excludeBiomassEquation = postOptTasksGroup.Children(4).Value;
    data.biomassId = postOptTasksGroup.Children(3).String;
    
    data.initCobraWithUpdates = postOptTasksGroup.Children(1).Value;
    data.initCobraNoUpdates = postOptTasksGroup.Children(2).Value;
    
    main(data);
end
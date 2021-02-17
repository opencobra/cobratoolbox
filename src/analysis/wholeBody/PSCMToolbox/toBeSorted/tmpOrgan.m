% generate vanilla organ models
load Recon3D_Harvey_Used_in_Script_120502 % this model is leak free

modelConsistent.rxns = regexprep(modelConsistent.rxns,'\(','[');
modelConsistent.rxns = regexprep(modelConsistent.rxns,'\)',']');
modelConsistent.c = zeros(length(modelConsistent.c),1);
modelConsistent.c(find(ismember(modelConsistent.rxns,'biomass_maintenance')))=1;
modelConsistent.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(modelConsistent,1,0,0,[],0,'tomlab_cplex');toc

[TableChecksR3, Table_csourcesR3, CSourcesTestedRxnsR3, TestSolutionNameOpenSinksR3,TestSolutionNameClosedSinksr3] = performSanityChecksonRecon(modelConsistent,'Organ' );


[TableChecksR3, Table_csourcesR3, CSourcesTestedRxnsR3, TestSolutionNameOpenSinksR3,TestSolutionNameClosedSinksR3] = performSanityChecksonRecon(modelConsistent,'Organ' );
AllModels.('modelR3HH').sourcesData = 'Recon3D_Harvey_Used_in_Script_120502';
AllModels.('modelR3HH').model = modelConsistent;
AllModels.('modelR3HH').results.TableChecksR3 = TableChecksR3;
AllModels.('modelR3HH').results.Table_csourcesR3 = Table_csourcesR3;
AllModels.('modelR3HH').results.TestSolutionNameOpenSinksR3 = TestSolutionNameOpenSinksR3;

modelConsistent2 = modelConsistent;
    clear Table
% %
% %
FileList ={
    'a_colon'   'Colon' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ColonReconstruction\ColonStart.xls' 'C:\Users\ines.thiele\Desktop\HHSubmission\models\OrganCompendium\maleColon_diary.mat'
    % %   ''  'Nkcells' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\NkCellsReconstrcution\NkcellStart.xls'
    'a_liver'  'Liver' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\LiverReconstruction\LiverStart.xls'  'C:\Users\ines.thiele\Desktop\HHSubmission\models\OrganCompendium\maleLiver_diary.mat'
    % %   ''  'Gall' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\Gallbladder Reconstruction\GallBladderStart.xls'
    % %    '' 'Pancreas' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\PancreasReconstruction\PancreasStart.xls'
    % %   'a_kidney'  'Kidney' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\KidneyReconstruction\KidneyStart.xls'
    % %   'a_brain' 'Brain' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BrainReconstruction\BrainStart.xls'
    % %   'a_lung'  'Lung' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\LungReconstruction\LungStart.xls'
    % %   'a_muscle'  'Muscle' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\MuscleReconstruction\myocyteStart.xls'
    % %    'a_skin' 'Skin' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SkinReconstruction\SkinStart.xls'
    % %  'a_spleen'   'Spleen' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SpleenReconstruction\SpleenStart.xls'
    % %   ''  'Adipocytes' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\AdipocyteReconstruction\AdipocyteStart.xls'
    % %   'a_retina'  'Retina' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\RetinaReconstruction\RetinaStart.xls'
    % %  'a_heart'   'Heart' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\HeartReconstruction\HeartStartUp.xls'
    % %  ''   'Scord' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SpinalCordReconstruction\SpinalcordStart.xls'
    % %  ''   'Agland' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\AdrenalGlandRecononstruction\AdrenalglandStart.xls'
    % % %    'Esophagus' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\EsophagusReconstruction\EsophagusStart.xls'
    % %   %  'Rectum' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\RectumReconstruction\RectumStart.xls'
    % %     'Urinarybladder' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\UrinaryBladderReconstruction\UrinarybladderStart.xls'
    % %     'Testis' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\TestisReconstruction\TestisStart.xls'
    % %     'Prostate' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ProstrateReconstruction\ProstrateStart.xls'
    % %     'Ovary' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\OvaryReconstruction\OvaryStart.xls'
    % %     'Bcells' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BCellReconstuction\BcellStart.xls'
    % %     'CD4Tcells' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\CDcells\CD4Start.xls'
    % %    'CD8Tcells' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\CDcells\CD8Start.xls'
    % %     'Nkcells' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\NkCellsReconstrcution\NkcellStart.xls'
    % %     'Monocyte' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\MonocyteReconstruction\MonocyteStart.xls'
    % %     'Platelet' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\PlateletReconstruction\PlateletStart.xls'
    % %     'RBC' 'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\RBCReconstruction\RBCStart.xls'
    % %     'Thyroidgland'  'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ThyroidReconstruction\ThyroidglandStart.xls';
    % %     'Pthyroidgland'  'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ParathyroidReconstruction\ParathyroidglandStart.xls';
    % %     'Stomach'   'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\StomachReconstruction\StomachStart.xls';
    % % %    'Salv_gland'    'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SalivaryglandReconstruction\SalivaryglandStart.xls';
    % %     'Cervix'   'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\CervixReconstruction\CervixStart.xls';
    % %     'Uterus'    'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\UterusReconstruction\UterusStart.xls';
    % %     'Breast'    'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BreastReconstruction\BreastStart.xls';
    };

%% generate organ specific model only based on proteomic data
for i = 1 : size(FileList,1)
    tic;
    % enforce maintenance of model
    %[modelOrganP,CoreOrganRxnsOrganP] = createOrganSpecificModel(modelConsistent2,'a_liver','Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\LiverReconstruction\LiverStart.xls','[e]',0,0,0);
    [modelOrganP,CoreOrganRxnsOrganP] = createOrganSpecificModel(modelConsistent2,FileList{i,1},FileList{i,3},'[e]',0,0,0);
    toc;
    % set all sink reactions to 0
    Sk = strmatch('sink_',modelOrganP.rxns);
    modelOrganP.lb(Sk)=-10;
    modelOrganP.ub(Sk)=100;
    
    modelOrganP.lb(find(ismember(modelOrganP.rxns,'biomass_maintenance')))=0;
    modelOrganP.c = zeros(length(modelOrganP.c),1);
    modelOrganP.c(find(ismember(modelOrganP.rxns,'biomass_maintenance')))=1;
    modelOrganP.osense = -1;
    tic;[solution,LPProblem]=solveCobraLPCPLEX(modelOrganP,1,0,0,[],0,'tomlab_cplex');toc
    %
    modelOrganP.rxns = regexprep(modelOrganP.rxns,'\(e\)','[e]');
    modelOrganP.rxns = regexprep(modelOrganP.rxns,'\(','[');
    modelOrganP.rxns = regexprep(modelOrganP.rxns,'\)',']');
    
    [TableChecksOP, Table_csourcesOP, CSourcesTestedRxnsOP, TestSolutionNameOpenSinksOP,TestSolutionNameClosedSinksOP] = performSanityChecksonRecon(modelOrganP,'Organ' );
    AllModels.(FileList{i,2}).modelProt.model = modelOrganP;
    AllModels.(FileList{i,2}).modelProt.results.TableChecksOP = TableChecksOP;
    AllModels.(FileList{i,2}).modelProt.results.Table_csourcesOP = Table_csourcesOP;
    AllModels.(FileList{i,2}).modelProt.results.TestSolutionNameOpenSinksOP = TestSolutionNameOpenSinksOP;
    save tmp_OP
    %% create organ specific model based on proteomic and lit data
    
    tic;
    [modelOrgan,CoreOrganRxnsOrgan] = createOrganSpecificModel(modelConsistent2,'a_colon','Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ColonReconstruction\ColonStart.xls');
    toc;
    % set all sink reactions to 0
    Sk = strmatch('sink_',modelOrgan.rxns);
    modelOrgan.lb(Sk)=-10;
    modelOrgan.ub(Sk)=100;
    
    modelOrgan.c = zeros(length(modelOrgan.c),1);
    modelOrgan.c(find(ismember(modelOrgan.rxns,'biomass_maintenance')))=1;
    modelOrgan.osense = -1;
    tic;[solution,LPProblem]=solveCobraLPCPLEX(modelOrgan,1,0,0,[],0,'tomlab_cplex');toc
    %
    modelOrgan.rxns = regexprep(modelOrgan.rxns,'\(e\)','[e]');
    modelOrgan.rxns = regexprep(modelOrgan.rxns,'\(','[');
    modelOrgan.rxns = regexprep(modelOrgan.rxns,'\)',']');
    
    [TableChecksO, Table_csourcesO, CSourcesTestedRxnsO, TestSolutionNameOpenSinksO,TestSolutionNameClosedSinksO] = performSanityChecksonRecon(modelOrgan,'Organ' );
    
    AllModels.(FileList{i,2}).modelProtLit.model = modelOrgan;
    AllModels.(FileList{i,2}).modelProtLit.results.TableChecksO = TableChecksO;
    AllModels.(FileList{i,2}).modelProtLit.results.Table_csourcesO = Table_csourcesO;
    AllModels.(FileList{i,2}).modelProtLit.results.TestSolutionNameOpenSinksO = TestSolutionNameOpenSinksO;
    %% compare organ model with HH organ model
    load(FileList{i,4})
    % this model is leak free
    modelOrganHH = model;
    modelOrganHH.rev = zeros(length(modelOrganHH.rxns),1);
    modelOrganHH.rev(find(modelOrganHH.lb<0))=1;
    modelOrganHH.csense(end) = '';
    modelOrganHH.c(find(ismember(modelOrganHH.rxns,'biomass_maintenance')))=1;
    modelOrganHH.osense = -1;
    tic;[solution,LPProblem]=solveCobraLPCPLEX(modelOrganHH,1,0,0,[],0,'tomlab_cplex');toc
    % I will need to remove all biolfuid compartments
    
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\(','[');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\)',']');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bc\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bp\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[u\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[a\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[luLI\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[luSI\]','[e]');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[csf\]','[e]');
    
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bpC\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bpS\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bpL\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bpG\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[bcK\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[luC\]','');
    modelOrganHH.rxns = regexprep(modelOrganHH.rxns,'\[luS\]','');
    
    clear comp
    comp = {'[bpC]' '\[bpC\]'
        '[bpS]' '\[bpS\]'
        '[bpL]' '\[bpL\]'
        '[bpG]' '\[bpG\]'
        '[bcK]' '\[bcK\]'
        '[bpC]' '\[bpC\]'
        '[luC]' '\[luC\]'
        '[luS]' '\[luS\]'
        '[bp]' '\[bp\]'
        '[a]' '\[a\]'
        '[csf]' '\[csf\]'
        '[bc]' '\[bc\]'
        '[lu]' '\[lu\]'
        '[luLI]' '\[luLI\]'
        '[luSI]' '\[luSI\]'
        };
    for j = 1 : size(comp,1)
        M = modelOrganHH.mets(find(~cellfun(@isempty,strfind(modelOrganHH.mets,comp{j,1}))));
        ME = regexprep(M,comp{j,2},'[e]');
        % ensure that all M have matching ME
        for k = 1 : length(M)
            if ~isempty(strmatch(ME{k},modelOrganHH.mets,'exact'))
                [modelOrganHH] = merge2Mets(modelOrganHH,ME(k),M(k));
            else
                modelOrganHH.mets(strmatch(M{k},modelOrganHH.mets,'exact')) = regexprep(modelOrganHH.mets(strmatch(M{k},modelOrganHH.mets,'exact')),comp{j,2},'[e]');
            end
        end
    end
    
    % remove superfluous transport reactions
    EX = modelOrganHH.rxns(find(~cellfun(@isempty,strfind(modelOrganHH.rxns,'Tr_EX_'))));
    modelOrganHH = removeRxns(modelOrganHH,EX,0,1);
    
    [U,ia,ic] = unique(modelOrganHH.rxns),'stable';
    num=[1:length(modelOrganHH.rxns)];
    num(ia)=[];
    modelOrganHH = removeRxns(modelOrganHH,modelOrganHH.rxns(num),0,1);
    [U,ia,ic] = unique(modelOrganHH.rxns),'stable';
    num=[1:length(modelOrganHH.rxns)];
    num(ia)=[];
    modelOrganHH = removeRxns(modelOrganHH,modelOrganHH.rxns(num),0,1);
    
    for j = 1 : length(modelOrganHH.mets)
        if length(find(modelOrganHH.S(j,:)))==0
            rm(j)=1;
        end
    end
    
    [TableChecksH, Table_csourcesH, CSourcesTestedRxnsH, TestSolutionNameOpenSinksH,TestSolutionNameClosedSinksH] = performSanityChecksonRecon(modelOrganHH,'Organ' );
    
    
    AllModels.(FileList{i,2}).modelHH.modelOri = model;
    AllModels.(FileList{i,2}).modelHH.modelNoBioflComp = modelOrganHH;
    AllModels.(FileList{i,2}).modelHH.results.TableChecksH = TableChecksH;
    AllModels.(FileList{i,2}).modelHH.results.Table_csourcesH = Table_csourcesH;
    AllModels.(FileList{i,2}).modelHH.results.TestSolutionNameOpenSinksH = TestSolutionNameOpenSinksH;
    %% compare reaction content
    

    Table(1,i+1)= {FileList{i,2}};
    cnt = 2;
    Table(cnt,1) = {'Rxns of proteomics'};Table{cnt,i+1} = num2str(length(modelOrganP.rxns)); cnt = cnt +1;
    Table(cnt,1) = {'Mets of proteomics'};Table{cnt,i+1} = num2str(length(modelOrganP.mets)); cnt = cnt +1;
    Table(cnt,1) = {'Genes of proteomics'};Table{cnt,i+1} = num2str(length(modelOrganP.genes)); cnt = cnt +1;
    Table(cnt,1) = {'Rxns of proteomics + lit'};Table{cnt,i+1} = num2str(length(modelOrgan.rxns)); cnt = cnt +1;
    Table(cnt,1) = {'Mets of proteomics + lit'};Table{cnt,i+1} = num2str(length(modelOrgan.mets)); cnt = cnt +1;
    Table(cnt,1) = {'Genes of proteomics + lit'};Table{cnt,i+1} = num2str(length(modelOrgan.genes)); cnt = cnt +1;
    Table(cnt,1) = {'Rxns of HH'};Table{cnt,i+1} = num2str(length(modelOrganHH.rxns)); cnt = cnt +1;
    Table(cnt,1) = {'Mets of HH'};Table{cnt,i+1} = num2str(length(modelOrganHH.mets)); cnt = cnt +1;
    Table(cnt,1) = {'Genes of HH'};Table{cnt,i+1} = num2str(length(modelOrganHH.genes)); cnt = cnt +1;
    
    OverlappingRxns = intersect(modelOrganP.rxns,modelOrganHH.rxns);
    Table(cnt,1) = {'OverlappingRxns - proteomics + HH'};Table{cnt,i+1} = num2str(length(OverlappingRxns)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingRxns (Perc of proteomics)'};Table{cnt,i+1} = num2str(length(OverlappingRxns)*100/length(modelOrganP.rxns)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingRxns (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingRxns)*100/length(modelOrganHH.rxns)); cnt = cnt +1;
    
    OverlappingMets= intersect(modelOrganP.mets,modelOrganHH.mets);
    Table(cnt,1) = {'OverlappingMets - proteomics + HH'};Table{cnt,i+1} = num2str(length(OverlappingMets)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingMets (Perc of proteomics )'};Table{cnt,i+1} = num2str(length(OverlappingMets)*100/length(modelOrganP.mets)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingMets (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingMets)*100/length(modelOrganHH.mets)); cnt = cnt +1;
    
    OverlappingGenes = intersect(modelOrganP.genes,modelOrganHH.genes);
    Table(cnt,1) = {'OverlappingGenes - proteomics + HH'};Table{cnt,i+1} = num2str(length(OverlappingGenes)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingGenes (Perc of proteomics)'};Table{cnt,i+1} = num2str(length(OverlappingGenes)*100/length(modelOrganP.genes)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingGenes (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingGenes)*100/length(modelOrganHH.genes)); cnt = cnt +1;
    
    
    OverlappingRxns = intersect(modelOrgan.rxns,modelOrganHH.rxns);
    Table(cnt,1) = {'OverlappingRxns - proteomics/lit + HH'};Table{cnt,i+1} = num2str(length(OverlappingRxns)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingRxns (Perc of proteomics + lit)'};Table{cnt,i+1} = num2str(length(OverlappingRxns)*100/length(modelOrgan.rxns)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingRxns (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingRxns)*100/length(modelOrganHH.rxns)); cnt = cnt +1;
    
    OverlappingMets= intersect(modelOrgan.mets,modelOrganHH.mets);
    Table(cnt,1) = {'OverlappingMets - proteomics/lit + HH'};Table{cnt,i+1} = num2str(length(OverlappingMets)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingMets (Perc of proteomics + lit)'};Table{cnt,i+1} = num2str(length(OverlappingMets)*100/length(modelOrgan.mets)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingMets (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingMets)*100/length(modelOrganHH.mets)); cnt = cnt +1;
    
    OverlappingGenes = intersect(modelOrgan.genes,modelOrganHH.genes);
    Table(cnt,1) = {'OverlappingGenes - proteomics/lit + HH'};Table{cnt,i+1} = num2str(length(OverlappingGenes)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingGenes (Perc of proteomics + lit)'};Table{cnt,i+1} = num2str(length(OverlappingGenes)*100/length(modelOrgan.genes)); cnt = cnt +1;
    Table(cnt,1) = {'OverlappingGenes (Perc of HH)'};Table{cnt,i+1} = num2str(length(OverlappingGenes)*100/length(modelOrganHH.genes)); cnt = cnt +1;
    
    
    DiffRxnsO_HH = setdiff(modelOrgan.rxns,modelOrganHH.rxns);
    DiffRxnsHH_O = setdiff(modelOrganHH.rxns,modelOrgan.rxns);
    
    % compare how many metabolic tests are passed
    total = size(TestSolutionNameOpenSinksR3,1);
    tmp = cell2mat(TestSolutionNameOpenSinksR3(:,2));
    F1 = find(abs(tmp)<=1e-6);
    F2 = find(isnan(tmp));
    totalR3 = total - length(F1)+length(F2);
    
    tmp = cell2mat(TestSolutionNameOpenSinksOP(:,2));
    F1 = find(abs(tmp)<=1e-6);
    F2 = find(isnan(tmp));
    F = length(F1)+length(F2);
    Table(cnt,1) = {'Met tests passed - proteomics'};Table{cnt,i+1} = strcat(num2str((totalR3-F)),'/', num2str(totalR3),'(',num2str(round((totalR3-F)*100/totalR3)),'%)'); cnt = cnt +1;
    tmp = cell2mat(TestSolutionNameOpenSinksO(:,2));
    F1 = find(abs(tmp)<=1e-6);
    F2 = find(isnan(tmp));
    F = length(F1)+length(F2);
    Table(cnt,1) = {'Met tests passed - proteomics + lit'};Table{cnt,i+1} = strcat(num2str((totalR3-F)),'/', num2str(totalR3),'(',num2str(round((totalR3-F)*100/totalR3)),'%)'); cnt = cnt +1;
    tmp = cell2mat(TestSolutionNameOpenSinksH(:,2));
    F1 = find(abs(tmp)<=1e-6);
    F2 = find(isnan(tmp));
    F = length(F1)+length(F2);
    Table(cnt,1) = {'Met tests passed - HH'};Table{cnt,i+1} = strcat(num2str((totalR3-F)),'/', num2str(totalR3),'(',num2str(round((totalR3-F)*100/totalR3)),'%)'); cnt = cnt +1;
    
    AllModels.Table = Table;
    save AllModelsGen AllModels
end
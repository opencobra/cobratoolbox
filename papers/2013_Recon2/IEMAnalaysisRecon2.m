%
% This scripts permits to reproduce the IEM analysis performed with Recon 2 (model version),
% as published. Newer versions of Recon 2 may be used but may result in
% different statistics.
%
% Results obtained with Recon 2 (model version) will result in:
% R2.SwagatikaIEM_biomarker
%
% ans =
%
%               UU: 66
%               DD: 10
%               UD: 18
%               DU: 5
%              NBB: 108
%      Sensitivity: 0.7857
%      Specificity: 0.6667
%        Precision: 0.9296
%         Accuracy: 0.7677
%     FischerExact: 7.9346e-04
%
% This script requires
%  - the COBRA toolbox - https://github.com/opencobra/cobratoolbox
%  - IBM clpex or GLPK LP solver
% - fastFVA (Gudmunsson, S., Thiele, I., "Computationally efficient flux
% variability analysis", BMC Bioinf, 11:489 (2010).)
%
%
% - Please note that this script performs more than 400 fastFVA
% calculations, each of which takes at least 35 sec depending on computer
% configuration and the number of parallel nodes (default 4).
%
% Please cite: Thiele, I.et al. "A community-driven global reconstruction of human
% metabolism", Nat Biotech, 31(5):419-25 (2013).
%
%
% Ines Thiele, http://thielelab.eu, 2013, 2017

initCobraToolbox;
%% define variables:
% define solver for fastFVA
solver ='cplex';
% give number of workers for parallelization of fastFVA
nworkers=4;
% define input file name
File ='121114_Recon2betaModel';

load(File);
modelRecon2 = modelRecon2beta121114;
modelRecon2Model = modelRecon2beta121114;

% set all uptakes to -1 and all secretions to 1000
modelRecon2Model.lb(strmatch('EX_',modelRecon2Model.rxns))=-1;
modelRecon2Model.ub(strmatch('EX_',modelRecon2Model.rxns))=1000;
clear R2;
R2.model = modelRecon2Model;

modelRecon2=findSExRxnInd(modelRecon2);
modelRecon2Model=findSExRxnInd(modelRecon2Model);
modelRecon2.EXRxnBool=modelRecon2.ExchRxnBool;
modelRecon2Model.EXRxnBool=modelRecon2Model.ExchRxnBool;
R2.model=findSExRxnInd(R2.model);
R2.model.EXRxnBool= R2.model.ExchRxnBool;

%% Map IEMs onto genes
IEMCompendium;
% unique genes
[tok,rem]=strtok(modelRecon2.genes,'.');
R2.UniqueGenes=unique(tok);
R2.IEMGenes=IEMs(ismember(IEMs(:,2),R2.UniqueGenes),2);
R2.IEMNames=IEMs(ismember(IEMs(:,2),R2.UniqueGenes),1);
%% perform fastFVA calculations
SetWorkerCount(nworkers);

ExR2 = modelRecon2Model.rxns(modelRecon2Model.EXRxnBool);
ExR2ID = find(modelRecon2Model.EXRxnBool);
% find all genes that are in model
[R2.NonuniqueGenes,rem]=strtok(modelRecon2Model.genes,'.');
% delete IEM gene
for i =1 :length(R2.IEMGenes)
    i
    tmp = strmatch(R2.IEMGenes(i),R2.NonuniqueGenes,'exact');
    Genes = modelRecon2Model.genes(tmp);
    [modelR2IEM,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(modelRecon2Model,Genes);
    if hasEffect
        % test IEM case
            tic;[R2.IEMs.(char(strcat('G_',R2.IEMGenes(i)))).Disease.minFlux,R2.IEMs.(char(strcat('G_',R2.IEMGenes(i)))).Disease.maxFlux] = fastFVA(modelR2IEM,0,'max', solver);toc
        % test healthy case for IEM gene - healthy state --> force flux through
        % all gene asso rxns
        [modelR2Up,hasEffect,constrRxnNames,upregulatedGenes] = upRegulateModelGenes(modelRecon2Model,Genes,0.05);
        [R2.IEMs.(char(strcat('G_',R2.IEMGenes(i)))).Healthy.minFlux,R2.IEMs.(char(strcat('G_',R2.IEMGenes(i)))).Healthy.maxFlux] = fastFVA(modelR2Up,0,'max', solver);
    else
        R2.IEMEffectTestSolution(i,1)=-1;
    end
    save R2Results_tmp R2
end

%% % data analysis IEM
tol = 1e-6;
cnt= 1;
Factor= 0.99;

clear UU DU DD UD cnt i j R*BDone  R*Biomarker R*Change Change Biomarker R*ShlomiOmim WW tmp c ans NBB ExR* FR* Omim R*Genes

%%R2
clear R2Biomarker
FR2= fieldnames(R2.IEMs);
ExR2 = find(R2.model.EXRxnBool);

%ExR2=find(ismember(R2.model.rxns,R2.IEMs.(FR2{1}).Biomarkers));
cnt= 1;
for i = 1 : length(FR2)
    R2.IEMs.(FR2{i}).Biomarker=[];
    R2.IEMs.(FR2{i}).Healthy.minFlux(abs(R2.IEMs.(FR2{i}).Healthy.minFlux)<=tol)=0;
    R2.IEMs.(FR2{i}).Healthy.maxFlux(abs(R2.IEMs.(FR2{i}).Healthy.maxFlux)<=tol)=0;
    R2.IEMs.(FR2{i}).Disease.minFlux(abs(R2.IEMs.(FR2{i}).Disease.minFlux)<=tol)=0;
    R2.IEMs.(FR2{i}).Disease.maxFlux(abs(R2.IEMs.(FR2{i}).Disease.maxFlux)<=tol)=0;
    for j = 1 : length(ExR2)
        a1 = R2.IEMs.(FR2{i}).Healthy.minFlux(ExR2(j));
        a2 = R2.IEMs.(FR2{i}).Healthy.maxFlux(ExR2(j));
        b1 = R2.IEMs.(FR2{i}).Disease.minFlux(ExR2(j));
        b2 = R2.IEMs.(FR2{i}).Disease.maxFlux(ExR2(j));

        % disease secreted
        if a2 < Factor*b1
            % AAAAAAAAAA
            %            BBBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 2;%strong
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
            % disease more taken up
        elseif b2 < Factor*a1
            %            AAAAAAAAAA
            % BBBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -2;%strong
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;

        elseif b1>=0 && a1 <= b1 && a2 < Factor*b2
            %      AAAAAAAAAA
            %       0  BBBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)=num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif b1>=0 && a1 < Factor*b1 && a2 <= b2
            %       AAAAAAAAAA
            %       0  BBBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif a1>=0 && b1 < Factor*a1 && b2 <= a2
            %  0    AAAAAAAAAA
            %     BBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif a1>=0 && b1 <= a1 && b2 < Factor*a2
            %  0  AAAAAAAAAA
            % BBBBBBBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;

        elseif b1<=0 && b2 >= 0 && Factor*a1 < b1 && a2 <= b2
            % AAAAAAAAAA
            %   BBBBB0BBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif b1<=0 && b2 >= 0 && a1 <= b1 && a2 < Factor*b2
            % AAAAAAA0AAA
            %   BBBBB0BBBB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;

        elseif a1<=0 && a2>=0 && b1 <= a1 && b2 < Factor*a2
            %    AAAAA0AAAA
            %  BBBBBBB0BB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)=num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif a1<=0 && a2>=0 && Factor*b1 < a1 && b2 <= a2
            %    AAAAA0AAAA
            %  BBBBBBB0BB
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)=num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;

        elseif b2 <= 0 && Factor*a1 < b1 && a2 <= b2
            % AAAAAAAAAA   0
            %    BBBBBBBBB 0
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif a2<=0 && Factor*b1 < a1 && b2 <= a2
            %    AAAAAAAAA 0
            %  BBBBBBBBB   0
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)=num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif b2 <= 0 && a1 <= b1 && Factor*a2 < b2
            % AAAAAAAAAA   0
            %    BBBBBBBBB 0
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        elseif a2<=0 && b1 <= a1 && Factor*b2 < a2
            %    AAAAAAAAA 0
            %  BBBBBBBBB   0
            R2.IEMs.(FR2{i}).Biomarker(j,1) = -1;%weak
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)=num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;

        else
            R2.IEMs.(FR2{i}).Biomarker(j,1) = 0;%none
            R2.IEMsList(cnt,1)= FR2(i);
            R2.IEMsList(cnt,2)= R2.model.rxns(ExR2(j));
            R2.IEMsList(cnt,3)= num2cell(R2.IEMs.(FR2{i}).Biomarker(j,1));
            R2.IEMsList(cnt,4)= num2cell(a1);
            R2.IEMsList(cnt,5)= num2cell(a2);
            R2.IEMsList(cnt,6)= num2cell(b1);
            R2.IEMsList(cnt,7)= num2cell(b2);
            cnt = cnt +1;
        end
    end
    R2Biomarker(:,i)=R2.IEMs.(FR2{i}).Biomarker;
end

R2.Biomarker=R2Biomarker;
% compounds that are no biomarker
a = 1 ;
for i = 1 :size(R2.Biomarker,1)
    if nnz(R2.Biomarker(i,:)) > 0
        R2.BiomarkerReal(a,:) = R2.Biomarker(i,:);
        R2.BiomarkerRealName(a,1) = R2.model.rxns(ExR2(i));
        a = a+1;
    end
end
% disease without biomarker

a = 1 ;
b=1;
R2.BiomarkerRealDisease=[];
for i = 1 :size(R2.Biomarker,2)
    if nnz(R2.Biomarker(:,i)) > 0
        R2.BiomarkerRealDisease(:,a) = R2.BiomarkerReal(:,i);
        R2.BiomarkerRealGenes(a,1) = regexprep(FR2(i),'G_','');
        a = a+1;
    else
        R2.NoBiomarkerGenes(b,1) = FR2(i);
        b = b +1;
    end
end

%IEMs without biomarker
R2.IEMsWOBiomarker= setdiff(R2.IEMGenes,R2.BiomarkerRealGenes);

R2Genes=regexprep(R2.IEMsList(:,1),'G_','');
% map swagatikas biomarkers and see what's happening
load IEM_biomarkerList;

if strcmp('2017_03_22_Recon3d_consistencyCheck',File)
    Swagatika_IEM_biomarker(:,2) = regexprep(Swagatika_IEM_biomarker(:,2),'\(','\[');
    Swagatika_IEM_biomarker(:,2) = regexprep(Swagatika_IEM_biomarker(:,2),'\)','\]');
    Swagatika_IEM_biomarker(:,2) = regexprep(Swagatika_IEM_biomarker(:,2),'EX_glc\[e\]','EX_glc_D[e]');
    Swagatika_IEM_biomarker(:,2) = regexprep(Swagatika_IEM_biomarker(:,2),'\(','\[');
    % check that all exchanges are matching
    Swagatika_IEM_biomarker(:,2) = strcat(Swagatika_IEM_biomarker(:,2),'[e]');
    Swagatika_IEM_biomarker(:,2) = regexprep(Swagatika_IEM_biomarker(:,2),'\[e\]\[e\]','\[e\]');
    setdiff(Swagatika_IEM_biomarker(:,2), R2.model.rxns(ExR2))
end

UU=0;DD=0;UD=0;DU=0;NBB=0;
cnt = 1;
R2BDone = {};
R2BD={};   c = 1;
for i = 1 : size(Swagatika_IEM_biomarker,1)
    tmp = strmatch(Swagatika_IEM_biomarker(i,1),R2.IEMNames,'exact');

    if ~isempty(tmp)
        List=strmatch(R2.IEMGenes(tmp(1)),R2Genes,'exact');
        Biomarker = Swagatika_IEM_biomarker(i,2);
        Change = str2num(Swagatika_IEM_biomarker{i,3});
        for j = 1 : length(List)
            R2Biomarker = R2.IEMsList(List(j),2);
            R2BD=strcat(R2Biomarker,'_',Swagatika_IEM_biomarker(i,1));
            R2Change = R2.IEMsList(List(j),3);

            if strcmp(Biomarker, R2Biomarker) && isempty(strmatch(R2BD,R2BDone,'exact'))
                % get change
                R2Change = R2.IEMsList{List(j),3};
                if R2Change ==2
                    R2Change =1;
                elseif R2Change== -2
                    R2Change=-1;
                end
                if Change ==R2Change
                    if Change==-1
                        DD = DD + 1;
                    elseif  Change==1
                        UU = UU +1;
                    end
                elseif  Change==-1 && R2Change == 1
                    DU = DU + 1;
                elseif  Change==1 && R2Change == -1
                    UD = UD + 1;
                elseif R2Change ==0
                    NBB = NBB +1;
                end
                R2.Swagatika_IEM_biomarker(cnt,1) = Swagatika_IEM_biomarker(i);
                R2.Swagatika_IEM_biomarker(cnt,2) = Biomarker;
                R2.Swagatika_IEM_biomarker(cnt,3) = Swagatika_IEM_biomarker(i,3);
                R2.Swagatika_IEM_biomarker(cnt,4) = R2Biomarker;
                R2.Swagatika_IEM_biomarker(cnt,5) = R2.IEMsList(List(j),3);
                R2.Swagatika_IEM_biomarker(cnt,6) = R2.IEMsList(List(j),4);
                R2.Swagatika_IEM_biomarker(cnt,7) = R2.IEMsList(List(j),5);
                R2.Swagatika_IEM_biomarker(cnt,8) = R2.IEMsList(List(j),6);
                R2.Swagatika_IEM_biomarker(cnt,9) = R2.IEMsList(List(j),7);
                cnt = cnt +1;
                R2BDone(c)=R2BD;
                c=c+1;
            end
        end
    end
end

R2.SwagatikaIEM_biomarker.UU =UU;
R2.SwagatikaIEM_biomarker.DD =DD;
R2.SwagatikaIEM_biomarker.UD =UD;
R2.SwagatikaIEM_biomarker.DU =DU;
R2.SwagatikaIEM_biomarker.NBB =NBB;
R2.SwagatikaIEM_biomarker.Sensitivity = UU/(UU+UD); %Recall
R2.SwagatikaIEM_biomarker.Specificity = DD/(DD+DU); %True negative rate
R2.SwagatikaIEM_biomarker.Precision = UU/(UU+DU);
R2.SwagatikaIEM_biomarker.Accuracy = (DD+UU)/(UU+DD+UD+DU);
%[p,x2] = chisquarecont([UU UD; DU DD]);
%R2.SwagatikaIEM_biomarker.chiSq = ((UU*DD-DU*UD)^2*(UU+DD+UD+DU))/((UU+UD)*(DU+DD)*(UU+DU)*(UD+DD));
% calculates the hypergeometric p value
R2.SwagatikaIEM_biomarker.FischerExact= (factorial(UU + UD)* factorial(DD + DU)* factorial(UU + DU)* factorial(DD + UD))/(factorial(UU)*factorial(DD)*factorial(UD)*factorial(DU)*factorial(UU+DD+UD+DU));

%% table for IEMs
Biomarkers = unique(R2.Swagatika_IEM_biomarker(:,2));
IEMsSS = unique(R2.Swagatika_IEM_biomarker(:,1));
clear IEMMatrix IEMx
cntR=2;
cntC=2;
cnt = 1;
IEMMatrix(1,1)={''};
for i =1  : size(R2.Swagatika_IEM_biomarker,1)
    Change = str2num(R2.Swagatika_IEM_biomarker{i,3});
    if Change ~= 0
        IEMx(cnt,1)=R2.Swagatika_IEM_biomarker(i,1);
        cnt = cnt+1;
    end
end

IEMx = unique(IEMx);

% this matrix contains  predicted and reported biomarkers
IEMMatrix(2:length(IEMx)+1,1)=IEMx;
for i = 1 : size(R2.Swagatika_IEM_biomarker,1)
    Change = str2num(R2.Swagatika_IEM_biomarker{i,3});
    R2Change = R2.Swagatika_IEM_biomarker{i,5};
    % if R2Change ~= 0  || ~isempty(strmatch(R2.Swagatika_IEM_biomarker(i),IEMMatrix(1,:),'exact')) || ~isempty(strmatch(R2.Swagatika_IEM_biomarker(i),IEMMatrix(:,1),'exact'))
    C=strmatch(R2.Swagatika_IEM_biomarker(i,2),IEMMatrix(1,:),'exact');
    R=strmatch(R2.Swagatika_IEM_biomarker(i,1),IEMMatrix(:,1),'exact');
    if ~isempty(R)
        if isempty(C)
            IEMMatrix(1,cntC)= R2.Swagatika_IEM_biomarker(i,2);
            C= cntC;cntC = cntC+1;
        end
        if R2Change ==2
            R2Change =1;
        elseif R2Change== -2
            R2Change=-1;
        end
        if Change ==R2Change
            if Change==-1
                IEMMatrix(R,C)={'DD'};
            elseif  Change==1
                IEMMatrix(R,C)={'UU'};
            end
        elseif  Change==-1 && R2Change == 1
            IEMMatrix(R,C)={'DU'};
        elseif  Change==1 && R2Change == -1
            IEMMatrix(R,C)={'UD'};
        elseif  Change==1 && R2Change == 0
            IEMMatrix(R,C)={'U0'};
        elseif  Change==-1 && R2Change == 0
            IEMMatrix(R,C)={'D0'};
        end
    end
end

G = R2.IEMGenes(ismember(R2.IEMNames,IEMx));
G= strcat('G_',G);
I =  find(ismember(R2.IEMsList(:,1),G));
x=1;
for i = 1 : length(I)
    C=strmatch(R2.IEMsList(I(i),2),IEMMatrix(1,:),'exact');
    if ~isempty(C)
        TMP(x,1:3)=R2.IEMsList(I(i),1:3);

        R2Change = R2.IEMsList{I(i),3};
        X=regexprep(R2.IEMsList(I(i),1),'G_','');
        Y=strmatch(X,R2.IEMGenes,'exact');
        TMP(x,4)=R2.IEMNames(Y(1));
        x=x+1;
        R=strmatch(R2.IEMNames(Y(1)),IEMMatrix(:,1),'exact');
        if ~isempty(R) && isempty(IEMMatrix{R,C})
            if R2Change <0
                IEMMatrix(R,C)={'0D'};
            elseif R2Change >0
                IEMMatrix(R,C)={'0U'};
            end
        end
    end
end

% this matrix contains only those biomarkers that have been reported in the
% literature
clear IEMMatrix2
IEMMatrix2(1,1)={''};
IEMMatrix2(2:length(IEMx)+1,1)=IEMx;
cntR=2;
cntC=2;
for i = 1 : size(R2.Swagatika_IEM_biomarker,1)
    Change = str2num(R2.Swagatika_IEM_biomarker{i,3});
    R2Change = R2.Swagatika_IEM_biomarker{i,5};
    % if R2Change ~= 0  || ~isempty(strmatch(R2.Swagatika_IEM_biomarker(i),IEMMatrix2(1,:),'exact')) || ~isempty(strmatch(R2.Swagatika_IEM_biomarker(i),IEMMatrix2(:,1),'exact'))
    C=strmatch(R2.Swagatika_IEM_biomarker(i,2),IEMMatrix2(1,:),'exact');
    R=strmatch(R2.Swagatika_IEM_biomarker(i,1),IEMMatrix2(:,1),'exact');
    if ~isempty(R)
        if  Change==1 && R2Change == 0 ||Change==-1 && R2Change == 0
        else
            if isempty(C)
                IEMMatrix2(1,cntC)= R2.Swagatika_IEM_biomarker(i,2);
                C= cntC;cntC = cntC+1;
            end
            if R2Change ==2
                R2Change =1;
            elseif R2Change== -2
                R2Change=-1;
            end
            if Change ==R2Change
                if Change==-1
                    IEMMatrix2(R,C)={'DD'};
                elseif  Change==1
                    IEMMatrix2(R,C)={'UU'};
                end
            elseif  Change==-1 && R2Change == 1
                IEMMatrix2(R,C)={'DU'};
            elseif  Change==1 && R2Change == -1
                IEMMatrix2(R,C)={'UD'};
            end
        end
    end
end

save('ResultsIEManalysis.mat');
% clear unneccessary variables.
clear G I Genes IEMs* R NBB List IEMs R2BD* U* i b* a* Y X c cnt* cons* dele* has* tok rem modelR2* solv* upreg* x tmp Ex* FR* D* Bioma* C* j TMP R2B* R2G* R2C* IEMx

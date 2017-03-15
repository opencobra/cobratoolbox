%% Example of how to use fastGapFill
% Ines Thiele, Dec 2013.
%
% define model to be loaded by choosing one or more models from the list below or by
% adding a model file name.
Filename={'iTZ479_v2.mat'; % Thermotoga maritima as published in Nogales et al., Int J Hydrogen Energ, 37(17), 12205–12218 (2012)
    'iJN678_Published.mat'; % Synechocystis sp. PCC6803 as published in Nogales et al., PNAS, 109(7):2678-83 (2012)
    'iAF1260.mat'; % E. coli as published in Feist et al., Mol Syst Biol (2007)
    'IEC1907.mat'; % small intestinal entercyte as published in Sahoo et al., Human Mol Genet, 22(13):2705-2722 (2012)
    '121114_Recon2betaRecon.mat'; % Human metabolic reconstruction as published in Thiele et al., Nat. Biotech., 31(5):419-25 (2013)
    };

% define weights for reactions to be added - the lower the weight the
% higher the priority
weights.MetabolicRxns = 0.1; % Kegg metabolic reactions
weights.ExchangeRxns = 0.5; % Exchange reactions
weights.TransportRxns = 10; % Transport reactions

% performance of algorithm is best if the weighting parameter is not 1 
%
% all reactions are equally weighted
% weights.MetabolicRxns = 1000; % Kegg metabolic reactions
% weights.ExchangeRxns = 1000; % Exchange reactions
% weights.TransportRxns = 1000; % Transport reactions

%% Do not change below here
% Prepare the output table with statistics
cnt = 1;
Stats{cnt,1} = 'Model name';cnt = cnt+1;
Stats{cnt,1} = 'Size S (original model)';cnt = cnt+1;
Stats{cnt,1} = 'Number of compartments';cnt = cnt+1;
Stats{cnt,1} = 'List of compartments';cnt = cnt+1;
Stats{cnt,1} = 'Number of blocked reactions';cnt = cnt+1;
Stats{cnt,1} = 'Number of solvable blocked reactions';cnt = cnt+1;
Stats{cnt,1} = 'Size S (flux consistent)';cnt = cnt+1;
Stats{cnt,1} = 'Size SUX (including solvable blocked reactions)';cnt = cnt+1;
Stats{cnt,1} = 'Number of added reactions (all)';cnt = cnt+1;
Stats{cnt,1} = 'Number of added metabolic reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Number of added transport reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Number of added exchange reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Time preprocessing';cnt = cnt+1;
Stats{cnt,1} = 'Time fastGapFill';cnt = cnt+1;

col = 1;
RxnList={};
for i =1 : 3%length(Filename)
    cnt = 1;
    % load model containing .mat file
    PFilename = strcat(Filename{i});
    content = load(PFilename);
    F = fieldnames(content);
    model = content.(F{1});
    clear F content PFilename ;
    SFilename = strcat('ResultGapFill_',Filename{i},'3');
    % remove constraints from exchange reactions
    EX = strmatch('EX_',model.rxns);
    model.lb(EX)=-100;
    model.ub(EX)=100;
    clear EX
    % get stats
    Stats{cnt,i+1} = Filename{i};cnt = cnt+1;
    [a,b] = size(model.S);
    Stats{cnt,i+1} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    % Number of compartments
    [tok,rem] = strtok(model.mets,'\[');
    rem = unique(rem);
    Stats{cnt,i+1} = num2str(length(rem));cnt = cnt+1;
    Rem = rem{1};
    for j = 2:length(rem)
        Rem = strcat(Rem,',',rem{j});
    end
    Stats{cnt,i+1} = Rem;cnt = cnt+1;
    clear Rem tok rem;
    
    %Prepare fastGapFill
    tic; [consistModel,consistMatricesSUX,BlockedRxns] = prepareFastGapFill(model);
    tpre=toc;
    Stats{cnt,i+1} = num2str(length(BlockedRxns.allRxns));cnt = cnt+1;
    Stats{cnt,i+1} = num2str(length(BlockedRxns.solvableRxns));cnt = cnt+1;
    [a,b] = size(consistModel.S);
    Stats{cnt,i+1} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    [a,b] = size(consistMatricesSUX.S);
    Stats{cnt,i+1} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    save(SFilename);
    
    % fastGapsFill
    epsilon = 1e-4;
    tic; [AddedRxns] = fastGapFill(consistMatricesSUX,epsilon, weights);
    tgap=toc;
    Stats{cnt,i+1} = num2str(length(AddedRxns.rxns));cnt = cnt+1;
    save(SFilename);
    
    % clear consistMatricesSUX consistModel
    
    % Postprocessing
    [AddedRxnsExtended] = postProcessGapFillSolutions(AddedRxns,model,BlockedRxns,0);
    clear AddedRxns;
    
    Stats{cnt,i+1} = num2str(AddedRxnsExtended.Stats.metabolicSol);cnt = cnt+1;
    Stats{cnt,i+1} = num2str(AddedRxnsExtended.Stats.transportSol);cnt = cnt+1;
    Stats{cnt,i+1} = num2str(AddedRxnsExtended.Stats.exchangeSol);cnt = cnt+1;
    
    Stats{cnt,i+1} = num2str(tpre);cnt = cnt+1;
    Stats{cnt,i+1} = num2str(tgap);cnt = cnt+1;
    clear a b
    
    % Reaction List
    RxnList{1,col}=SFilename;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.rxns; col = col + 1;
    RxnList{1,col}=SFilename;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.rxnFormula; col = col + 1;
    RxnList{1,col}=SFilename;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.subSystem; col = col + 1;
    
    save(SFilename);
    clear AddedRxnsExtended tgap tpre j BlockedRxns;
end
clear i cnt consistM*


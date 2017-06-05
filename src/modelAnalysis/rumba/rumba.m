function [RUMBA_outputs, UpRegulated, DownRegulated, MetConnectivity1, MetConnectivity2] = rumba(model1, model2, completeModel, sampling, maxMetConn, RxnsOfInterest, GenesOfInterest, NormalizePointsOption, PValCuttoff, MaxNumPoints, LoopRxnsToIgnore, verboseTag)
% RUMBA predicts which reactions significantly change their
% flux at metabolic branch points under two conditions
%
% USAGE:
%
%    [RUMBA_outputs, UpRegulated, DownRegulated, MetConnectivity1, MetConnectivity2] = rumba(model1, model2, completeModel, sampling, maxMetConn, RxnsOfInterest, GenesOfInterest, NormalizePointsOption, PValCuttoff, MaxNumPoints, LoopRxnsToIgnore, verboseTag)
%
% INPUTS:
%    model1:                     Model under first condition, exchange reactions
%                                are constrained with the data related to the first
%                                condition. If model already sampled
%                                ('sampling' = 0). The sampling points is in an
%                                mxn matrix with m reactions and n points included
%                                as a field in the model(i.e., `model1.points`).
%                                Set 'sampling' = 1 to set the model constrained
%                                under the first conditions
%    model2:                     Model under second condition. Same
%                                format as `model1`.
%    completeModel:              The complete reference model. This is used
%                                to verify consistency between the sampled models.
%    sampling:                   0, if no sampling needed (default)
%                                1, if sampling of the models under both
%                                conditions
%    maxMetConn:                 The maximum connectivity of a metabolite to
%                                consider. All branch points with a higher
%                                connectivity will be ignored. (default = 30)
%    RxnsOfInterest:             Reactions for which predictions are desired.
%                                Specifying only desired reactions speeds up
%                                algorithm.
%    GenesOfInterest:            Genes associated with the reactions of interest.
%    NormalizePointsOption:      Option to normalize sample points to (1) the
%                                same median of magnitude of flux through all
%                                non-loop gene-associated reactions, or (2) the
%                                optimal growth rate. (default = 1)
%    PValCuttoff:                P-value cutoff used to decide which changes in
%                                branch point flux to call significant (two-
%                                tailed p-value, so .05 will mean 0.25 on both
%                                tails). (default = 0.05)
%    MaxNumPoints:               Maximum number of points to use form the
%                                sampled models. Extra points will be removed
%                                to improve memory usage and speed up
%                                calculations. (default = minimum number of
%                                points in the model or 500 points, whichever
%                                is smaller)
%    verboseTag:                 1 = print out progress and use waitbars. 0 =
%                                print only minimal progress to screen.
%    LoopRxnsToIgnore:           list of rxns associated with loop within the model,
%                                default- reaction loops defined usinf FVA
%
% OUTPUTS:
%    RUMBA_outputs:              Structure containing all information about
%                                each gene-reaction pair. For gene-reaction pair
%                                for which the differential branch-point
%                                information is possible to calculate: the list of
%                                connected metabolites ('ConnectedMets'), the associated
%                                up-regulation p-value ('pValue_up'), the associated
%                                down-regulation p-value ('pValue_down')and
%                                the reaction directionality for both model
%                                ('direction').The structure also contains the list of gene-reaction
%                                pairs for which no differential branch-point
%                                information can be determined (because of
%                                loops, unused pathways, etc.).
%    UpRegulated:                first column : Gene-reaction pairs towards which flux is
%                                significantly upregulated during the shift;
%                                second column : list of metabolites
%                                connected to the gene-reaction pair;
%                                third column : Magnitude of absolutes flux change
%    DownRegulated:              same structure as `UpRegulated` but for gene-reaction pairs
%                                from which flux is significantly
%                                downregulated during the shift
%    MetConnectivity1:           A structure that present for each metabolite present in model1
%                                the following sets of fields:
%
%                                  * ConnRxns - the reactions that are connected
%                                    to the metabolite
%                                  * Sij - The stoichiometric coefficient for the
%                                    metabolite in each reaction in ConnRxns
%                                  * RxnScore - Score for each reaction in ConnRxns
%                                  * Direction - The direction of reaction flux
%                                    for each sample point
%                                  * MetNotUsed - Whether or not the metabolite is
%                                    used in the condition
%    MetConnectivity2:           Same as `MetConnectivity1` but for `model2`
%
%
% .. Authors:
%       - Nathan E. Lewis, May 2010-May 2011
%       - Anne Richelle, May 2017

if nargin < 11  || isempty(LoopRxnsToIgnore)
    tmp = completeModel;
    tmpExc = findExcRxns(tmp);
    tmp.lb(tmpExc) = 0;
    tmp.lb(tmp.lb >0) = 0;
    tmp.ub(tmpExc) = 0;
    [MinFVA MaxFVA] = fluxVariability(tmp,0,'max',tmp.rxns);
    LoopRxnsToIgnore = tmp.rxns(or(MinFVA<-1e-10, MaxFVA>1e-10));
    LoopRxnsToIgnore = {};
    tmpRxnForm = printRxnFormula(tmp,LoopRxnsToIgnore);
end


if sampling == 1
    %Sampling of the model 1
    [model1Sampling,samples1] = sampleCbModel(model1,'model1Sampling');
    model1=model1Sampling;
    model1.points=samples1;
    %Sampling of the model 2
    [model2Sampling,samples2] = sampleCbModel(model2,'model2Sampling');
    model2=model2Sampling;
    model2.points=samples2;
end


% Set the function to not use waitbars and lots of status text.
if nargin < 12  || isempty(verboseTag)
    verboseTag = 0;
end

% Set the maximum number of points to look at to 500 or the minimum number of points in the model
if nargin < 10 || isempty(MaxNumPoints)
    MaxNumPoints = min([500;length(model1.points(1,:)); length(model2.points(1,:))]);
end

% Set the minimum p-value cutoff to 0.05 for determining significant shifts at metabolites
if nargin <9 || isempty(PValCuttoff)
    PValCuttoff = 0.05;
end

% Default is to normalize the points between the two models by net flux
if nargin < 8  || isempty(NormalizePointsOption)
    NormalizePointsOption = 1;
end

% If no set of genes is provided, look at all genes
if nargin <6
    [tmp_r,tmp_r2] = findRxnsFromGenes(completeModel,completeModel.genes,0,1);
    RxnsOfInterest = tmp_r2(:,1);
    GenesOfInterest = tmp_r2(:,5);
end

% if no metabolite connectivity filter is provided, filter out all
% metabolite with a connectivity greater than 30
if nargin < 5 || isempty(maxMetConn)
    maxMetConn = 30;
end

% if no sampling option, models are already sampled
if nargin < 4 || isempty(sampling)
    sampling = 0;
    if ~isfield(model1,'points'),
        warning 'Model1 is not sampled, sampling will be performed using sampleCbModel'
        sampling = 1;
    end
    if ~isfield(model2,'points'),
        warning 'Model2 is not sampled, sampling will be performed using sampleCbModel'
        sampling = 1;
    end
end

% since the statistics should be two-tailed, divide the p-value by 2
PValCuttoff = PValCuttoff/2;

% preprocessing step: Make sure all reactions from complete model are
% are in the sampled models
model1 = addMissingReactions(model1,completeModel);
model2 = addMissingReactions(model2,completeModel);

% Normalize the sampled points by scaling by the net network flux (1 = by
% net flux, 2 = by growth rate
    [model1,model2] = normalizePoints(model1,model2,NormalizePointsOption,LoopRxnsToIgnore);

% Rename genes to avoid incompatibilities
model1.genes = regexprep(model1.genes,'[_\-]','');% remove underscores and hyphens
model2.genes = regexprep(model2.genes,'[_\-]','');
completeModel.genes = regexprep(completeModel.genes,'[_\-]','');
GenesOfInterest = regexprep(GenesOfInterest,'[_\-]','');

% check to make sure there is enough sample points
if MaxNumPoints > min([length(model1.points(1,:));length(model2.points(1,:))])
    MaxNumPoints = min([length(model1.points(1,:));length(model2.points(1,:))]);
    warning('Number of sample points desired is more than available number in models!')
    display(cat(2,'you need to use ',num2str(MaxNumPoints),' points.'))
end

% for each metabolite get all incoming and outgoing reaction and score them
display('Processing first condition.')
[MetConnectivity1, ConnectedMet1] = classifyRxns(completeModel,model1,maxMetConn,MaxNumPoints,verboseTag,LoopRxnsToIgnore);
display('Processing second condition.')
[MetConnectivity2, ConnectedMet2] = classifyRxns(completeModel,model2,maxMetConn,MaxNumPoints,verboseTag,LoopRxnsToIgnore);
display('Comparing conditions.')
[MetsAndRxns,pVal_up,pVal_down,Dir_model1,Dir_model2] = compareConditions(MetConnectivity1, ConnectedMet1,MetConnectivity2, ConnectedMet2);

% process the 'compareCondtions' results
RUMBA_Struc_Pred = struct;
RUMBA_Struc_noPred = struct;
UpRegulated = {};
DownRegulated = {};
UpRegulated_mets = {};
DownRegulated_mets = {};
RUMBA_outputs=struct;
noPred={}


display('Classifying reaction/gene pair changes')
% step through all reactions of interest and determine if they
% significantly change
for i=1:length(RxnsOfInterest)
    % find whether split flux is increasing or decreasing for each reaction
    Ind = find(ismember(MetsAndRxns(:,2),RxnsOfInterest{i}));
    if ~isempty(Ind)

        Pred.ConnectedMets = regexprep(MetsAndRxns(Ind,1),'Met_',''); % metabolites to which the reaction is connected
        Pred.pValue_up = pVal_up(Ind); % p-value that flux is diverted to this reaction in each node in which it participates
        Pred.pValue_down = pVal_down(Ind); % p-value that flux is diverted away from this reaction in each node in which it participates
        Pred.Direction = [Dir_model1(Ind) Dir_model2(Ind)]'; % reaction directionality for both model (1 producing metabolite, -1 consuming the metabolite)

        RUMBA_outputs.(cat(2,GenesOfInterest{i},'_',RxnsOfInterest{i}))=Pred;

        % if the rxn/gene pair goes up for at least one metabolite, but not
        % down, and is above the p-value cutoff, then put it in the list of
        % gene-reaction pairs that significantly go up
        if min(pVal_up(Ind))<PValCuttoff && max(pVal_up(Ind))<=(1-PValCuttoff)
            UpRegulated{end+1} = cat(2,GenesOfInterest{i},'_',RxnsOfInterest{i});
            UpRegulated_mets{end+1} = regexprep(MetsAndRxns(Ind(pVal_up(Ind)<PValCuttoff),1),'Metab_','');
        end

        % if the rxn/gene pair goes down for at least one metabolite, but
        % not up  and is above the p-value cutoff, then put it in the list
        % of gene-reaction pairs that significantly go down
        if min(pVal_down(Ind))<PValCuttoff && max(pVal_down(Ind))<=(1-PValCuttoff)
            DownRegulated{end+1} = cat(2,GenesOfInterest{i},'_',RxnsOfInterest{i});
            DownRegulated_mets{end+1} = regexprep(MetsAndRxns(Ind(pVal_down(Ind)<PValCuttoff),1),'Metab_','');
        end

    else
        noPred{end+1}=([GenesOfInterest{i},'_',RxnsOfInterest{i}]);
    end
end
RUMBA_outputs.NotPredicted=noPred;

[UpRegulated,Ind] = sort(UpRegulated');
UpRegulated_mets = UpRegulated_mets(Ind)';
[DownRegulated,Ind] = sort(DownRegulated');
DownRegulated_mets = DownRegulated_mets(Ind)';

%filter out genes that go up and down
tmpUp = regexprep(UpRegulated,'_[0-9A-Za-z\-_\.\,\''\"\(\)\[\]]+$','');    % get all up gene IDs
tmpDwn = regexprep(DownRegulated,'_[0-9A-Za-z\-_\.\,\''\"\(\)\[\]]+$',''); % get all down gene IDs
ToDelU = ismember(tmpUp,tmpDwn);                                           % find Up genes also in the Down category
ToDelD = ismember(tmpDwn,tmpUp);                                           % find Down genes also in the Up category

UpRegulated(ToDelU)=[];
DownRegulated(ToDelD)=[];
UpRegulated_mets(ToDelU)=[];
DownRegulated_mets(ToDelD)=[];

UpRegulated = ([UpRegulated UpRegulated_mets]);
DownRegulated = ([DownRegulated DownRegulated_mets]);

% rank each reaction by the median magnitude change
[rxnsInCommon,MedRxnChange] = pValDistForModelOverlap(model1,model2);
tmpUp = regexprep(UpRegulated(:,1),'^[0-9A-Za-z\-\.\,\''\"\(\)\[\]]+_','');
tmpDwn = regexprep(DownRegulated(:,1),'^[0-9A-Za-z\-\.\,\''\"\(\)\[\]]+_','');

MagnitudeUp = zeros(length(tmpUp),1);
for i = 1:length(tmpUp)
	Ind = find(ismember(rxnsInCommon,tmpUp{i}));
	if isempty(Ind)
    	display(cat(2,'Reaction: ',tmpUp{i},' is missing!'))
    elseif length(Ind)>1
    	display(cat(2,'Reaction: ',tmpUp{i},' is duplicated in model!'))
    else
    	MagnitudeUp(i) = abs(MedRxnChange(Ind));
    end
end

MagnitudeDown = zeros(length(tmpDwn),1);
for i = 1:length(tmpDwn)
	Ind = find(ismember(rxnsInCommon,tmpDwn{i}));
	if isempty(Ind)
    	display(cat(2,'Reaction: ',tmpDwn{i},' is missing!'))
    elseif length(Ind)>1
        display(cat(2,'Reaction: ',tmpDwn{i},' is duplicated in model!'))
    else
    	MagnitudeDown(i) = abs(MedRxnChange(Ind));
    end
end

UpRegulated = ([UpRegulated num2cell(MagnitudeUp)]);
DownRegulated = ([DownRegulated num2cell(MagnitudeDown)]);

end

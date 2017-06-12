function [MetConnectivity, ConnectedMet] = classifyRxns(completeModel, sampledModel, maxMetConn, maxNumPnts, verboseTag, LoopRxnsToIgnore)
% This function get all incoming and outgoing reaction for each metabolite
% of the 'sampledModel'and score them (fraction of all incoming/outgoing flux that passes
% through the metabolite).
%
% USAGE:
%   model = addMissingReactions(SampledModel,completeModel)
%
% INPUTS:
%   completeModel:              The complete reference model
%   SampledModel:               Sampled model
%   maxMetConn:                 The maximum connectivity of a metabolite to
%                               consider. All branch points with a higher
%                               connectivity will be ignored. (default =
%                               30)
%   MaxNumPnts:                 Maximum number of points to use form the
%                               sampled models. Extra points will be removed
%                               to improve memory usage and speed up
%                               calculations. (default = minimum number of
%                               points in the model or 500 points, whichever
%                               is smaller)
%   verboseTag:                 1 = print out progress and use waitbars. 0 =
%                               print only minimal progress to screen.
%   LoopRxnsToIgnore:           list of rxns associated with loop within the model,
%                               default- reaction loops defined usinf FVA
%
% OUTPUTS:
%   MetConnectivity:            A structure that present for each
%                               metabolite present in 'sampledModel'
%                               the following sets of fields:
%                                   ConnRxns - the reactions that are connected
%                                   to the metabolite
%                                   Sij - The stoichiometric coefficient for the
%                                   metabolite in each reaction in ConnRxns
%                                   RxnScore - Score for each reaction in ConnRxns
%                                   Direction - The direction of reaction flux
%                                   for each sample point
%                                   MetNotUsed - Whether or not the metabolite is
%                                   used in the condition
%   ConnectedMet:               List of metabolites described in
%   'MetConnectivity'
%
% Authors: - Nathan E. Lewis, May 2010-May 2011
%          - Anne Richelle, May 2017


model=completeModel;
if nargin>3 
    sampledModel.points(:,maxNumPnts+1:end)=[];
end

% Rename metabolites to make compatible with structure field names
model.mets = regexprep(model.mets,'\[','_p1_');
model.mets = regexprep(model.mets,'\]','_p2_');
model.mets = regexprep(model.mets,'\-','_d1_');

% filter out highly connected metabolites
Sbin = double(and(1,full(model.S)));
Ax = Sbin*Sbin';
Ax=diag(Ax);

% clear the highly connected mets from the S matrix
model.S(Ax > maxMetConn,:) = 0; 
metIDs=findMetIDs(model,model.mets(Ax <= maxMetConn));

% make a structure with a field for each metabolite and all connecting
% reactions
for i = 1:length(metIDs)
    Met={};
    tmp = model.S(metIDs(i),:)~=0; 
    Met.ConnRxns=model.rxns(tmp);% list of rxns connected to metabolite
    Met.Sij=full(model.S(metIDs(i),tmp))';% stoichiometry of connected rxns
    MetConnectivity.(cat(2,'Met_',model.mets{metIDs(i)}))=Met;
    ConnectedMet{i,1}= cat(2,'Met_',model.mets{metIDs(i)});
end

% set low flux to zero
sampledModel.points(abs(sampledModel.points)<1e-10)=0;

% remove metabolites with loops
Mets2Ignore = {};
for i = 1:length(ConnectedMet)
    Met=MetConnectivity.(ConnectedMet{i});
    RxnInd = findRxnIDs(sampledModel,Met.ConnRxns);% get rxn indexes for the inputs/outputs
    if any(ismember(Met.ConnRxns,LoopRxnsToIgnore))
        Mets2Ignore{end+1,1} = ConnectedMet{i}; 
    end
end

ConnectedMet(ismember(ConnectedMet,Mets2Ignore)) = [];

sampledModelPoint = sampledModel.points; 
sampledModel.points = [];
NumPts = length(sampledModelPoint(1,:)); % number of samples

if verboseTag 
    showprogress(0/length(ConnectedMet),'Scoring reactions around metabolites');
end

for i = 1:length(ConnectedMet)
    if verboseTag
        showprogress(i/length(ConnectedMet),'Scoring reactions around metabolites');
    end
    
    Met=MetConnectivity.(ConnectedMet{i});
    
    % get the indexes for each reaction connected to metabolite i
    RxnInd = findRxnIDs(sampledModel,Met.ConnRxns);

    tmp_l = length(RxnInd); % number of reactions going in/out at the metabolite
    
    % for each point, first determine which are the incoming and outgoing
    % reactions, then compute a score
    Met.RxnScore(1:tmp_l,1:NumPts)=0;
    Met.Direction(1:tmp_l,1:NumPts)=0;
    for pnt = 1:NumPts
        % get the in/out determined
        tmp = sampledModelPoint(RxnInd,pnt).*Met.Sij;
        SumIn = sum(tmp(tmp>0)); % total flux producing the metabolite
        SumOut = sum(tmp(tmp<0)); % total flux consuming the metabolite
        
        % -SumIn should equal SumOut within some tolerance
        if abs(SumIn+SumOut)>1e-5
            error(cat(2,'ERROR: the flux in and out of ',ConnectedMet{i},' isn''t equal'))
        end
        
        % Compute the score and report the direction of the flux.
        % Score is fraction of all incoming/outgoing flux that passes
        % through the metabolite.
        for sc = 1:tmp_l
            if tmp(sc)>0               % reaction produces the metabolite
                Met.RxnScore(sc,pnt) = abs(tmp(sc)/SumOut);    % reaction score for point
                Met.Direction(sc,pnt) = 1;                      % direction of flux       
            elseif tmp(sc)<0           % reaction consumes the metabolite
                Met.RxnScore(sc,pnt) = abs(tmp(sc)/SumIn);     % reaction score for point
                Met.Direction(sc,pnt) = -1;                  % direction of flux
            end
        end
        
        if all(abs(tmp)<1.5e-10)
            Met.MetNotUsed(pnt) = 1;
        else
            Met.MetNotUsed(pnt) = 0;
        end
    end

    MetConnectivity.(ConnectedMet{i})=Met;
end

end

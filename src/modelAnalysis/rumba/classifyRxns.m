function [MetConnectivity, ConnectedMet] = classifyRxns(completeModel,sampledModel,maxMetConn,maxNumPnts,verboseTag,LoopRxnsToIgnore)
%for each metabolite get all incoming and outgoing reaction and score them
% Steps:
% 1. get all reactions connected to a metabolite
% 2. for the sampled model, determine, for each point for each metabolite,
% whether each reaction is incoming, outgoing, or zero flux
% 3. compute the score


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
    h = waitbar(0/length(MetRxnConnNames),'Scoring reactions around metabolites');
end

for i = 1:length(ConnectedMet)
    if verboseTag
        waitbar(i/length(ConnectedMet),h);
    end
    
 
    if verboseTag
        display(ConnectedMet{i});
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
            error(cat(2,'Hmmm.. Houston, we have a problem... Your flux in and out of ',MetRxnConnNames{i},' isn''t equal'))
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
if verboseTag
    close(h);
end

end



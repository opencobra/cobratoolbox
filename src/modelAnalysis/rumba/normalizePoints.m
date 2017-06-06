function [model1,model2] = normalizePoints(model1,model2,NormalizePointsParam,LoopRxnsToIgnore)
% Normalize the sampled points by the net network flux
% ('NormalizePointsParam' = 1) or by growth rate ('NormalizePointsParam' = 2)


% find the shared reactions
SharedRxns = intersect(model1.rxns,model2.rxns);

% filter down to only gene-associated reactions
m1GAR = model1.rxns(sum(model1.rxnGeneMat,2)>0);
m2GAR = model2.rxns(sum(model2.rxnGeneMat,2)>0);
SharedRxns = intersect(SharedRxns,[m1GAR;m2GAR]);

% find the index of shared reactions
Ind1 = findRxnIDs(model1,SharedRxns);
Ind2 = findRxnIDs(model2,SharedRxns);

ToRemove1 = find(ismember(model1.rxns(Ind1),LoopRxnsToIgnore));
ToRemove2 = find(ismember(model2.rxns(Ind2),LoopRxnsToIgnore));

Ind1(ToRemove1)=[];
Ind2(ToRemove2)=[];

if all(and(Ind1,Ind2))
    % sum up all fluxes through network in each point
    tmp1 = sum(abs(model1.points(Ind1,:)),1);
    tmp2 = sum(abs(model2.points(Ind2,:)),1);
    
    % normalize by net flux
    if NormalizePointsParam ==1 
        BOF1= median(tmp1);
        BOF2= median(tmp2);
    % normalize by Growth rate
    elseif NormalizePointsParam ==2 
        FBAsoln = optimizeCbModel(model1);
        BOF1= FBAsoln.f;
        FBAsoln = optimizeCbModel(model2);
        BOF2= FBAsoln.f;
    else
        warning('SAMPLE POINTS ARE NOT BEING NORMALIZED!!! ARE YOU CRAZY?? I HOPE YOU DON''T PUBLISH THIS!!')
    end
    % determine the ratio of the median point levels/growth rate between
    % the two growth conditions
    Ratio = BOF1/BOF2;
    % scale point in model 2 by ratio
    model2.points = model2.points*Ratio; 
    % scale bounds in model 2 by ratio
    model2.ub = model2.ub*Ratio; 
    model2.lb = model2.lb*Ratio;

else
    error('Error in normalization!')
end


end
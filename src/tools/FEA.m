function resultCellF = FEA(rxnSet,model,group)
% Significane analysis - Flux enrichment analysis using hypergeometric
% 1-sided test and FDR correction for multiple testing
% 
% resultCellF = FEA(1:10,modelEcore,'subSystems')
% 
% INPUTS  
% rxnSet        reaction set to be enriched (vector of reaction indices)
% model         COBRA structure model
% group         model.group structure e.g.
%              'subSystems' look for significantly enriched subsystem in rxnSet   
%       
% OUTPUT
% resultCellF    cell structure of enriched groups 
% 
% Marouen BEN GUEBILA 04/2016
    %%
    %compute frequency of enriched terms
    [uniquehSubsystemsA, ~, K]=unique(eval(['model.' group]));
    enRxns = eval(['model.' group '(rxnSet)']);
    m=length(uniquehSubsystemsA);
    allSubsystems=zeros(1,m);
    [uniquehSubsystems, ~, J]=unique(enRxns);
    occ = histc(J, 1:numel(uniquehSubsystems)); 
    [l,p]=intersect(uniquehSubsystemsA,uniquehSubsystems);
    allSubsystems(p)=occ;
    %%
    %compute total number of reactions per group
    occ = histc(K, 1:numel(uniquehSubsystemsA));
    nRxns = occ;%size of the unique susbsystems / organs (a.k.a the number of reactions per susbsystem)
    %%
    %Compute p-values
    gopvalues = hygepdf(allSubsystems',max(nRxns),max(allSubsystems),nRxns);
    [m,rxnInd]=sort(gopvalues);
    resultCell=num2cell(gopvalues(rxnInd));
    resultCell(:,2) = uniquehSubsystemsA(rxnInd);
    %count
    resultCell(:,3) = num2cell(allSubsystems(rxnInd))';
    %total
    resultCell(:,4) = num2cell(nRxns(rxnInd));
    %%
    %take out the zeros for one-sided test
    nonZerInd = find(cell2mat(resultCell(:,3)));
    resultCellF(:,1) = resultCell(nonZerInd,1);
    %correct for multiple testing with FDR
    resultCellF(:,2) = num2cell(mafdr(cell2mat(resultCellF(:,1)),'BHFDR', true));
    resultCellF(:,3) = resultCell(nonZerInd,2);
    resultCellF(:,4) = resultCell(nonZerInd,3);
    resultCellF(:,5) = resultCell(nonZerInd,4);
    resultCellFSave  = resultCellF;
    resultCellF(1,:) = {'P-value' 'Adjusted P-value' 'Group' 'Enriched set size' 'Total set size'};
    resultCellF(2:size(resultCellFSave,1)+1,:)      = resultCellFSave;
end
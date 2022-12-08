function [exchangedMetsTable,debugMets,fixedModel,exchangeMetsL] = getExchangedMetaboliteTable(model,exRxnsOrdered,L)

[m,n]=size(model.S);

fixedModel = model;

debugMets=[];

exRxns = cell(m,1);
for i=1:m
    j = find(strcmp(model.rxns,['EX_' model.mets{i}]));
    if isempty(j)
        exRxns{i}='';
    else
        if model.S(i,j)~=0
            exRxns{i} = model.rxns{j};
        else
            debugMets = [debugMets;model.mets{i}];
            
            warning(['missing exchange reaction coefficient for ' model.mets{i}])
            disp([model.mets{i},model.metNames{i},model.rxns(contains(model.rxns,model.mets{i})), model.mets{model.S(:,j)~=0}])
            fixedModel.S(i,:)=0;
            fixedModel.S(i,j)=-1;
        end
    end
end
exchangedMetsTable = table(model.mets,exRxns,(1:m)','VariableNames',{'mets','rns','ind'});

exMetsOrdered=cell(length(exRxnsOrdered),1);
if ~isempty(exRxnsOrdered)
    for k=1:length(exRxnsOrdered)
        exMetsOrdered{k} = strrep(exRxnsOrdered{k},'EX_','');
    end
    exchangedMetsTable = mapAontoB(exchangedMetsTable.mets,exMetsOrdered,exchangedMetsTable);
    bool = exchangedMetsTable.ind==0;
    if any(bool)
        L = [L,zeros(size(L,1),max(exchangedMetsTable.ind)-size(L,2))];
    end
    exchangedMetsTable.ind(bool)=size(L,2);
    %hack to deal with L from different model
    
    exchangeMetsL = L(:,exchangedMetsTable.ind);
    
    exchangeMetsL = exchangeMetsL(any(exchangeMetsL,2),:); 
    
end

figure
spy(exchangeMetsL)
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];


% did not work - ordering not diagonal.
% table(model.mets((getCorrespondingRows(model.S, true(size(model.S,1),1), ~model.SConsistentRxnBool, 'inclusive'))~=0),model.rxns(~model.SConsistentRxnBool),'VariableNames',{'mets','rns'});

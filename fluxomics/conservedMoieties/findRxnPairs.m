function rxnPairs = findRxnPairs(atomMets,metNrs,rxnNrs,reactantBool,instances)

mets = unique(atomMets);
s = zeros(size(mets));
for i = 1:length(mets)
    metBool = strcmp(atomMets,mets{i});
    
    if all(reactantBool(metBool))
        s(i) = -max(instances(metBool));
    else
        s(i) = max(instances(metBool));
    end
end

rxnPairs = sparse(length(atomMets),sum(reactantBool)^2);
rPairCount = 1;

for i = find(s < 0)'
    rid = mets{i};
    
    for j = 1:abs(s(i))
        rRxnNrs = rxnNrs(strcmp(atomMets,rid) & instances == j);
        
        for k = find(s > 0)'
            pid = mets{k};
            
            for l = 1:s(k)
                pRxnNrs = rxnNrs(strcmp(atomMets,pid) & instances == l);
                
                pairRxnNrs = intersect(rRxnNrs,pRxnNrs);
                
                if ~isempty(pairRxnNrs)
                    rMetNrs = metNrs(ismember(rxnNrs,pairRxnNrs) & reactantBool);
                    [~,xi] = ismember(rxnNrs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool),rxnNrs(ismember(rxnNrs,pairRxnNrs) & reactantBool));
                    %[~,xi] = sort(rxnNrs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool));
                    pMetNrs = rMetNrs(xi);
                    
                    if strcmp(regexprep(rid,'(\[\w\])$',''),regexprep(pid,'(\[\w\])$',''))
                        if ~all(pMetNrs == rMetNrs)
                            pMetNrs = rMetNrs;
                            rxnNrs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool) = rxnNrs(ismember(rxnNrs,pairRxnNrs) & reactantBool);
                        end
                    end
                    
                    rxnPairs(ismember(rxnNrs,pairRxnNrs) & reactantBool,rPairCount) = rMetNrs;
                    rxnPairs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool,rPairCount) = pMetNrs;
                    
                    rPairCount = rPairCount + 1;
                    
                end
            end
        end
    end
end

rxnPairs = rxnPairs(:,any(rxnPairs));


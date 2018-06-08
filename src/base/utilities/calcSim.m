function d = calcSim(s,t)

    s = char(s);
    t = char(t);
    m = length(s);
    n = length(t);
    distanceMatrix = zeros(m+1,n+1);
    %init the first line
    if n > m
        distanceMatrix(1,2:(n-m+1)) = 0.1 * (1:(n-m));
        distanceMatrix(1,(n-m+2):end) = 1:m;
    else
        distanceMatrix(1,2:n+1) = 1:n;
    end            
    distanceMatrix(2:m+1,1) = 1:m;
    for i = 1:n
        for j = 1:m
            repCost = distanceMatrix(j,i) + simDistance(s(j),t(i));
            tGapCost = distanceMatrix(j+1,i) + insertDist(j,i,m,n,0.5);
            sGapCost = distanceMatrix(j,i+1) + insertDist(i,j,n,m,0.1);
            distanceMatrix(j+1,i+1) = min([repCost,tGapCost,sGapCost]);
        end
    end
    d = distanceMatrix(end,end);
end

function dist = insertDist(posId,posComp,lenId,lenComp,edgeCost)
    if posId == lenId && posComp > lenId
        dist = edgeCost;
    else
        dist = 1;
    end
        
        
end
    


function dist = simDistance(a,b)
    charequal = lower(a) == lower(b);    
    capEqual = a == b;
    dist = (1-capEqual) * (0.05 + 0.95 * (1-charequal));                    
end

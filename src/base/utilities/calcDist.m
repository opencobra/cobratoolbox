function d = calcDist(searchString,databaseString)
% Calculate a Distance between the searchString and the database string.
% a perfect match will return a distance of 0.
% The distance is a modified levenshtein edit distance. 
% leading or trailing elements in the search string have a cost of 0.8
% leading or trailing elements in the database String have a cost of 0.1
% Uppercase <-> lower case edits have a cost of 0.05
% All other edit operations have a cost of 1
%
% USAGE: 
%    d = calcDist(searchString,databaseString)
%
% INPUTS:
%    searchString:      The string that is used as a query
%    databaseString:    The string in a database that the search string is
%                       compared to.
%
% OUTPUT:
%    d:                 A Distance between the searchString and the
%                       databaseString.
% NOTE:
%    This function is not a metric i.e. calcDist(a,b) ~= calcDist(b,a) !
%
% .. Author: - Thomas Pfau, June 2018

    searchString = char(searchString);
    databaseString = char(databaseString);
    m = length(searchString);
    n = length(databaseString);
    distanceMatrix = zeros(m+1,n+1);
    %init the first line
    if n > m
        distanceMatrix(1,2:(n-m+1)) = 0.1 * (1:(n-m));
        distanceMatrix(1,(n-m+2):end) = 1:m;
    else
        distanceMatrix(1,2:n+1) = 1:n;
    end            
    distanceMatrix(2:m+1,1) = 0.8 * 1:m;
    for i = 1:n
        for j = 1:m
            repCost = distanceMatrix(j,i) + simDistance(searchString(j),databaseString(i));
            tGapCost = distanceMatrix(j+1,i) + insertDist(j,i,m,n,0.1);
            sGapCost = distanceMatrix(j,i+1) + insertDist(i,j,n,m,0.8);
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

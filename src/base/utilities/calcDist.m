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
    %Get the length of the input strings.
    m = length(searchString);
    n = length(databaseString);
    %initialize the distance matrix (dynamic programming approach).
    distanceMatrix = zeros(m+1,n+1);
    %init the first line. Adding a GAp to the start or end is cheap (0.1),
    %while mapping a gap will cost 1.
    if n > m
        %Add 0.1 for all possible gaps on the edge (length of comparison String - length of search string)
        distanceMatrix(1,2:(n-m+1)) = 0.1 * (1:(n-m)); 
        %Other gaps cost 1
        distanceMatrix(1,(n-m+2):end) = distanceMatrix(1,(n-m+1))+(1:m);
        distanceMatrix(2:end,1) = 1:m;
    else
        %If the comparison string is longer, all gaps in the comparison String cost 1.
        distanceMatrix(1,2:n+1) = 1:n;
        %Any leading (or trailing) gap in the search string costs 0.8.
        distanceMatrix(2:(m-n+1),1) = 0.8 * (1:(m-n));         
        distanceMatrix((m-n+2):end,1) = distanceMatrix(m-n+1,1)+(1:n);
    end                        
    
    %Now build the distance matrix.
    for i = 1:n
        for j = 1:m
            %cost for extending the match by matching the current characters.
            repCost = distanceMatrix(j,i) + simDistance(searchString(j),databaseString(i));
            %Cost for extending the match by matching a gap to the element in the comparisonString
            tGapCost = distanceMatrix(j+1,i) + insertDist(j,i,m,0.1);
            %Cost for extending the match by matching a gap to the element in the search string
            sGapCost = distanceMatrix(j,i+1) + insertDist(i,j,n,0.8);
            %Determine the minimal cost
            distanceMatrix(j+1,i+1) = min([repCost,tGapCost,sGapCost]);
        end
    end
    %the final cost is the overall minimal distance.
    d = distanceMatrix(end,end);
end


function dist = insertDist(posSearch, posComp, lenSearch, edgeCost)
% Get the distance value for an insertion based on the cost of a value on
% the edge of the word. 
% USAGE:
%    dist = insertDist(posSearch, posComp, lenSearch, edgeCost)
%
% INPUTS:
%    posId:         Position of the insertion in the searched string
%    posComp:       Position in the comparison string.
%    lenSearch:     Length of the search string 
%    
% OUTPUT:
%    dist:          The distance. either 1 (if in the word), or 
    if posSearch == lenSearch && posComp > lenSearch || posSearch == 1        
        %If we are at either edge of the search String, we can insert a cheap gap. 
        dist = edgeCost;
    else
        dist = 1;
    end                
end
    


function dist = simDistance(charA,charB)
% Get the similarity Distance. It is 0 if the chars are identical, 0.05 if
% the chars are identical except for capitalization and 1 otherwise.
%
% USAGE:
%    dist = simDistance(charA,charB)
%
% INPUTS:
%    charA:     The first character in th comparison
%    charB:     The seconds character in the comparison.
%
% OUTPUT:
%    dist:      The distance between the two characters.

    charequal = lower(charA) == lower(charB);    
    capEqual = charA == charB;
    dist = (1-capEqual) * (0.05 + 0.95 * (1-charequal));                    
end

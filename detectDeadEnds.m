function outputMets = detectDeadEnds(model, removeExternalMets)
%findGaps returns a list(indices) of metabolites which either participate in only
%one reaction or can only be produced or consumed (check if stoich
%values are all -1 or all +1 and also check if lb is zero or not)
%
% outputMets = findGaps(model, removeExternalMets)
%
%INPUT
% model                 COBRA model structure
%
%OPTIONAL INPUT           
% removeExternalMets    Remove metabolites that participate in reactions
%                       only with themselves (Default = false)
%
%OUTPUT
% outputMets            List of indicies of metabolites which can ether
%                       only be produced or consumed.

if nargin < 2
    removeExternalMets = false;
end
mets = model.mets;
S= model.S;
[m,n] = size(S);

num_outputMets = 0;
outputMets = [];
metNames = {};
isOutputFlag = -1;

j=1;
i=1;


%scrolls through rows.
while(j<=m)
    %scrolls through cols.
    while(i<=n)
        %checks if there has already been an exception (either
        %metabolite participates in 2 reactions or participates in both
        %consumption and production)
        if(isOutputFlag==0)
            break
        end
        val = S(j,i);
        if(val~=0 && isOutputFlag~=1)
            %flag is raised and states that val is a possible output
            isOutputFlag=1;
            lowerBound = model.lb;
            valLB = lowerBound(i);
%                 if(lowerBound(i)<0)
%                     isOutputFlag=0;
%                 end
            for w =i+1:n
                %if there are exceptions than will not be output
                if(~(S(j, w)==0 || (S(j, w)==val && lowerBound(w)>=0 && valLB >=0)))
                    isOutputFlag = 0;
                end
            end
        end
        %there are no exceptions so val is output
        if(isOutputFlag==1)
            num_outputMets = num_outputMets+1;
            outputMets(num_outputMets,:) = j;
            metNames{num_outputMets} = mets(j);
            %terminates loop in row and moves onto next one
            i=n;
        end
        i=i+1;
        
    end
    
    i=1;
    isOutputFlag = -1;
    j=j+1;
end

%removeExternalMets gets rid of the external metabolites (metabolites thats
%participate in reactions with only themselves)
j=1;
isExternalMet = 0;
if(removeExternalMets == true)
    %go through all possible output mets
    while(j<=length(outputMets))
        %finds any reactions that the output met participates in
        outputRxns = find(S(outputMets(j),:));
        for(i=1:length(outputRxns))
            %find whether there any other mets in that reaction
            otherMets = find(S(:,outputRxns(i)));
            x = length(otherMets);
            %if there are no other mets than that met is removed from the
            %list of outputs
            if(x==1)
                isExternalMet =1;
            end
        end
        if(isExternalMet == 1)
            outputMets(j,:) = [];
            %j
            j= j-1;
        end
        isExternalMet =0;
        j=j+1;

    end
end       
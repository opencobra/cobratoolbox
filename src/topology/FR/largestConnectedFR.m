function [connectedRowsFRBool,connectedColsFRVBool]=largestConnectedFR(F,R,printLevel)
% compute the largest connected set of rows of [F,R] and the largest
% connected set of columns of [F;R] using gamic
%
% INPUT
% F         m x n
% R         m x n
%
% OUTPUT
% connectedRowsFRBool   m x 1 boolean vector indicating largests set of 
%                       connected rows
% connectedColsFRVBool  n x 1 boolean vector indicating largests set of 
%                       connected cols
%
if ~exist('printLevel','var')
    printLevel=0;
end

if ~exist('largest_component','file')
    error('Install gamic and add it to your path. (http://www.mathworks.com/matlabcentral/fileexchange/24134-gaimc-graph-algorithms-in-matlab-code)')
else
    [m,n]=size(F);
    F2=sparse(m,n);
    R2=sparse(m,n);
    F2(F~=0)=1;
    R2(R~=0)=1;
    %rows
    FR = [F2,R2];
    %cols
    FRV = [F2;R2];
    if 0
        A  = FR*FR';
        [Acc,connectedRowsFRBool] = largest_component(A);
        B   = [FRV'*FRV];
        [Acc,connectedColsFRVBool] = largest_component(B);
    else
        %rows
        if printLevel
            tic
        end
        A=convertHypergraphToBipartiteGraph(FR);
        if printLevel
            toc
        end
        if printLevel
            tic
        end
        [Acc,pA] = largest_component(A);
        if printLevel
            toc
        end
        connectedRowsFRBool=pA(1:m);
        
        %cols
        if printLevel
            tic
        end
        B=convertHypergraphToBipartiteGraph(FRV);
        if printLevel
            toc
        end
        if printLevel
            tic
        end
        [Acc,pB] = largest_component(B);
        if printLevel
            toc
        end
        connectedColsFRVBool=pB(1:m);
    end
end
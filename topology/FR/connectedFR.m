function [connectedRowsFRBool,connectedColsFRVBool]=connectedFR(F,R)
% compute the connected sets of rows of [F,R] and the largest
% connected set of columns of [F;R] using gamic
%
% INPUT
% F         m x n
% R         m x n
%
% OUTPUT
% connectedRowsFRBool   m x z boolean vector indicating z sets of 
%                       connected rows
% connectedColsFRVBool  n x z boolean vector indicating z sets of 
%                       connected cols
%
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
    
    A=convertHypergraphToBipartiteGraph(FR);
    
    % SCOMPONENTS Compute the strongly connected components of a graph
    %[Acc,pA] = largest_component(A);
    [Asci,Asizes] = scomponents(A);
    connectedRowsFRBool=false(size(A,1),length(Asizes));
    for i=1:length(Asizes)
        connectedRowsFRBool(:,i)=Asci==i;
    end
    %omit rows
    connectedRowsFRBool=connectedRowsFRBool(1:m,:);
    sumComponent=sum(connectedRowsFRBool,1);
    %omit columns
    connectedRowsFRBool=connectedRowsFRBool(:,sumComponent~=0);
            
    B=convertHypergraphToBipartiteGraph(FRV);
    [Bsci,Bsizes] = scomponents(B);
    connectedColsFRVBool=false(size(B,1),length(Bsizes));
    for j=1:length(Bsizes)
        connectedColsFRVBool(:,j)=Bsci==j;
    end
    %omit rows
    connectedColsFRVBool=connectedColsFRVBool(1:n,:);
    sumComponent=sum(connectedColsFRVBool,1);
    %omit columns
    connectedColsFRVBool=connectedColsFRVBool(:,sumComponent~=0);
end
function [M,duplicateBool,C,IA,IC] = duplicates(A)
% create a map M between the first instance (row) and other instances (cols)
% of an equivalent set using [C,IA,IC]=unique(A,'rows','stable');
%
% INPUT
% A         m x n array (compatible with unique.m)
%
% OUTPUT
% M         m x m array where M(i,j) = 1 if the first instance of i has a
%           duplicate j,  and M(i,j) = 0 otherwise.
% C         unique first instances in the same order that they appear in A
% IA        C = A(IA,:)
% IC        A = C(IC,:)
%
% USAGE
% A=['a';'a';'b';'c';'d';'d';'b';'b';'e'];
% 
% M =
%      0     1     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     1     1     0
%      0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     1     0     0     0
%      0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0     0
%
% duplicateBool = 
%    0
%    1
%    0
%    0
%    0
%    1
%    1
%    1
%    0

N=size(A,1);

if iscell(A)
    [C,IA,IC]=unique(A,'stable');
else
    [C,IA,IC]=unique(A,'rows','stable');
end

M = sparse(N,N);
for i=1:N
    if any(i==IA) %first index of an equivalent set
        bool=i==IA(IC);
        bool(i)=0;
        M(i,bool)=1;
    end
end

duplicateBool = any(M,1)';



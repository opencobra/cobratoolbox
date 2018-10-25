function [neg,zer,nd,pos]=convertGene2PathwayInteractions(E,epSys,uSys,subSys1,subSys2)
%[neg,zer,nd,pos]=convertGene2PathwayInteractions(E,epCmpt,uComp,Cmpt1,Cmpt2)
%
% This function was written to find out the type of epistatic interactions
% that either exist between two compartments or within same subsystem

% INPUT:
% E: A square epistatic interaction matrix (or genes or reactions)
% epSys:   Subsystems belonging to the gene at that index (a second
%           order cell array) Each cell array may contain one or more
%           subsystems.
%           e.g. for first gene or reaction in E: 
%           epCmpt{1,1} = {'Glycolysis';'TCA cycle'}
% uSys:   Unique Subsystems in the epCmpt
% subSys1:    List 1 of unique subsystems
% subSys2 (optional): List 2 of unique subsystems, first compartment (default)
% % % % use this arguments if interested in interactions between selected
% % % % compartments
% OUTPUT:
% neg:  number of aggravating (negative) interactions
% zer:  number of no-epistatic interactions
% nd:   number of non-decisive interactions
% pos:  number of buffering (positive) interactions
%
% Written by:
% Chintan Joshi when at CSU in 2014. See figures in following publication:
% Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
% depend upon environmental conditions", Mol. BioSyst., 10, 2578– 2589. 

if (nargin<3)
    uSys = unique(convertMyCell2List(epSys,2));
end
if (nargin<4)
    subSys1 = uSys;
end
if (nargin<5)
    subSys2=subSys1;
end
if isempty(strcmp(subSys1,uSys)) || isempty(strcmp(subSys2,uSys))
    error('One of the compartmetns do not exist, check again!!!');
end

g1=0;
g2=0;
for i=1:length(epSys)
    cnt1=0;% counter for existence of 1st compt
    cnt2=0;% counter for existence of 2nd compt
    for j=1:length(epSys{i,1})
        if strcmp(subSys1,epSys{i,1}{j,1})==1
            cnt1=cnt1+1;
        end
        if strcmp(subSys2,epSys{i,1}{j,1})==1
            cnt2=cnt2+1;
        end
    end
    if cnt1~=0 % determines if loop was ever satisfied for 1st compartment existence of the gene
        g1=g1+1;
        ind1(g1,1)=i; % if yes, store the gene index
    end
    if cnt2~=0 % determines if loop was ever satisfied for 2nd compartment existence of the gene
        g2=g2+1;
        ind2(g2,1)=i; % if yes, store the gene index
    end
end

% E1=E(ind1,:); % reduces epistasis matrix to only genes involved in these compartments
% newE=E1(:,ind2); % reduces epistasis matrix to only genes involved in these compartments

% Now vectorize epistasis matrix
c=0;
newE=[];
for i=1:length(ind1)
    for j=1:length(ind2)
        if ind1(i,1)~=ind2(j,1)
            c=c+1;
            newE(c,1)=E(ind1(i,1),ind2(j,1));
        end
    end
end
% newE=reshape(newE,size(newE,1)*size(newE,2),1);
neg=0;
zer=0;
nd=0;
pos=0;
if ~isempty(newE)
    for k=1:length(newE)
        if newE(k,1)<-0.25
            neg=neg+1; % count number of aggravating interactions
        elseif newE(k,1)>=-0.25 && newE(k,1)<0.25
            zer=zer+1; % count number of non-epistatic interactions
        elseif newE(k,1)>=0.25 && newE(k,1)<0.85
            nd=nd+1; % count number of non-decisive interactions
        else
            pos=pos+1; % count number of buffering interactions
        end
    end
end

function B = convertMyCell2List(A,dimSense)

% This function linearizes a cell array if some of the cells in the array are another embbedded cell arrays.
% (hence, two degrees of cell array)

% This will only work for atmost two degrees of cell array.

% A=cell array to be linearized.
% dimSense=determines if inner cells are row (dimSense=1) vectors or columns (dimSense=2, default)

cnt=0;
if nargin<2
    dimSense=2;
end
for i=1:length(A)
    for j=1:length(A{i,1})
        cnt=cnt+1;
        if dimSense==1
            B{cnt,1}=A{i,1}{1,j};
        elseif dimSense==2
            B{cnt,1}=A{i,1}{j,1};
        end
    end
end
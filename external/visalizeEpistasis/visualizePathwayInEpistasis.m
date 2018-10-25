function [np,pos,neg]=visualizePathwayInEpistasis(Nall,radius)
% This function creates a circular network such that all the nodes are
% arranged in a circle. The nodes represent a pathway, the color of the
% node represents whether the interactions within a pathway are none, positive,
% negative, or mixed. The edges represent which pathways are sharing which
% type of interaction. The color of the edge represents if the interactions
% are positive negative or mixed. The with of the edge represent the total number
% of interactions between any two given pathways.

% INPUT:
% % Nall: a structure representing the epistatic interaction networks:
% % % % Nall.pos: a square matrix representing number of positive interactions shared by any two pathways.
% % % % Nall.neg: a square matrix representing number of negative interactions shared by any two pathways.
% % radius: radius of the circles for clock diagram.

% Written by:
% Chintan Joshi when at CSU in 2014. See figures in following publication:
% Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
% depend upon environmental conditions", Mol. BioSyst., 10, 2578– 2589. 

if nargin<2
    radius=40;
end

pos=Nall.pos;
neg=Nall.neg;
np=Nall.pos+Nall.neg;
indn=[]; indp=[]; mix_=[];
ps=find(diag(pos)~=0); ns=find(diag(neg)~=0); nps=find(diag(np)~=0);
if ~isempty(nps) && ~isempty(ps)
    indp=intersect(ps,nps);
end
if ~isempty(nps) && ~isempty(ns)
    indn=intersect(ns,nps);
end
if isempty(indn)
    p_=indp; n_=[]; mix_=[];
elseif isempty(indp)
    p_=[]; n_=indn; mix_=[];
else
    p_=setdiff(indp,indn); n_=setdiff(indn,indp); mix_=intersect(indp,indn);
end
c=0;
for i=1:length(np)
    for j=1:length(np)
        if np(i,j)~=0 && pos(i,j)~=0 && neg(i,j)~=0
            c=c+1;
            indm1(c,1)=i;
            indm2(c,1)=j;
        end
    end
end
theta=linspace(0,2*pi,length(pos)+1);
theta=theta(1:end-1);
[x,y]=pol2cart(theta,1);
tx=x;ty=y;
x=x*0.9;y=y*0.9;
[indp1,indp2]=ind2sub(size(pos),find(pos(:)));
[indn1,indn2]=ind2sub(size(neg),find(neg(:)));
plot(x,y,'.','MarkerEdgeColor',[150 150 150]./255,'markersize',radius);hold on
plot(x(p_),y(p_),'.','MarkerEdgeColor',[0 150 0]./255,'markersize',radius+length(p_)*5);hold on
plot(x(n_),y(n_),'.','MarkerEdgeColor',[175 0 0]./255,'markersize',radius+length(n_)*5);hold on
plot(x(mix_),y(mix_),'.','MarkerEdgeColor',[255 215 0]./255,'markersize',radius+length(mix_)*5);hold on
set(gca,'DataAspectRatio',[1 1 1]);
for i=1:length(x)
    text(tx(i),ty(i),num2str(i));
end
if ~isempty(indp1)
    arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)],'Color',[0 150 0]./255,'LineWidth',pos(p,q)),indp1,indp2);
end
if ~isempty(indn1)
    arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)],'Color',[175 0 0]./255,'LineWidth',neg(p,q)),indn1,indn2);
end
if exist('indm1')
    arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)],'Color',[255 215 0]./255,'LineWidth',np(p,q)),indm1,indm2);
end
axis equal off
hold off;
function [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,metAbbr,varargin)
% Create directed metabolite-metabolite interaction network using given metabolites and the model.
% The produced network consists of given metabolites and its first neighbours.
% Colour and width of edges will be adjusted based on flux values If fluxes of the model are given.
% Another metabolite-metabolite interaction network will be generated if the node is clicked;
%
% Left click :Generate sub-metabolite-metabolite interaction network from the created figure. 
%            This functionality was added for better looking at the created network 
%            and showing flux values on edges lines.
%
% Right click :Generate metabolite-metabolite interaction network from model. This
%             functionality was added for creating metabolite-metabolite network using
%             clicked metabolite and model.
% The produced figure by right and left click on the main figure also 
% has same property with the main figure, and it is clickable too.
%                   
% Note : If the fluxes are not given, irreversible COBRA model structure should use for 
%        representing reversible reactions. See convertToIrreversible function at github page of cobratoolbox
%        https://opencobra.github.io/cobratoolbox/stable/modules/reconstruction/refinement/
% USAGE:
%
%    [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,metAbbr,varargin)
%
% INPUTS:
%
%    model:             COBRA model structure
%    metAbbr:           List of metabolite abbreviation as a cell array
%
% OPTIONAL INPUT:
%    varargin:      Optional Inputs provided as 'ParameterName', Value
%                   pairs. the following parameternames are available:    
%
%                   * fluxes:        flux vector
%                   * Graphtitle:    Title for a figure as a string 
%                   * excludedMets:  As a cell array, Metabolite abbreviations that desired for exclude 
%                   * nodeColour:    Colour for nodes (RGB Triplet) e.g. [0 1 0]
%                                    see https://www.mathworks.com/help/matlab/ref/colorspec.html
%                   * Hnodecolor:    Colour for nodes that will be highlighted e.g. [0 1 1]  
%                   * scaleMin       Minimum value for scaling colorbar
%                   * scaleMax       Maximum value for scaling colorbar
%                   * nodeSize       Size of Nodes
%                   * HnodeSize      Highlighted node size
%                   * arrowSize      Arrow Size
% OUTPUT:
%    GraphObj:              Matlab digraph object
%    tableMetRxnsFormulas:  Table consists reaction names,formulas and fluxes
%
% EXAMPLES:
%    1) create network with succ[c] and akg[c] 
%       [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,{'succ[c]','akg[c]'})
%    2) create network with flux values
%       [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,{'succ[c]','akg[c]'},'fluxes',fluxvector)         
%    3) create network with flux values, and exculude exclude very employed metabolites 
%       [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,{'succ[c]','akg[c]'},'fluxes',fluxvector,'excludedMets',{'atp[c]','adp[c]'})
%    4) create network with scaling colorbar, [0 1]
%       [GraphObj,tableMetRxnsFormulas]=createMetIntrcNetwork(model,{'succ[c]','akg[c]'},'fluxes',fluxvector,'excludedMets',{'atp[c]','adp[c]'},'scaleMax',1,'scaleMin',0)
%
% .. Author: - Kadir KOCABAÞ November/2020


defaultGraphtitle ='Metabolite-Metabolite Interaction Network';
defaultexcludedMets ={};
defaultFluxes=ones(size(model.rxns,1),1);
defaultnodeColour=[0.9 0.7 1];
defaultHnodecolor=[0 1 0];
defaultscaleMax=1e-6;
defaultscaleMin=0;
defaultNodeSize=15;
defaultHNodeSize=25;
defaultarrowSize=9;

p = inputParser;
addRequired(p,'model',@isstruct);
addRequired(p,'metAbbr',@iscell);
addParameter(p,'fluxes',defaultFluxes,@isvector);
addParameter(p,'Graphtitle',defaultGraphtitle,@(x) isstring(x) || ischar(x));
addParameter(p,'excludedMets',defaultexcludedMets,@iscell);
addParameter(p,'nodeColor',defaultnodeColour,@isvector);
addParameter(p,'Hnodecolor',defaultHnodecolor,@isvector);
addParameter(p,'nodeSize',defaultNodeSize,@isnumeric);
addParameter(p,'HnodeSize',defaultHNodeSize,@isnumeric);
addParameter(p,'arrowSize',defaultarrowSize,@isnumeric);
addParameter(p,'scaleMax',defaultscaleMax,@isnumeric);
addParameter(p,'scaleMin',defaultscaleMin,@isnumeric);

parse(p,model,metAbbr,varargin{:});
p.KeepUnmatched = true;
model=p.Results.model;
metAbbr=p.Results.metAbbr;
fluxes=p.Results.fluxes;
Graphtitle=p.Results.Graphtitle;
excludedMets=p.Results.excludedMets;
nodeColor=p.Results.nodeColor;
Hnodecolor=p.Results.Hnodecolor;
scaleMin=p.Results.scaleMin;
scaleMax=p.Results.scaleMax;
nodeSize=p.Results.nodeSize;
HnodeSize=p.Results.HnodeSize;
arrowSize=p.Results.arrowSize;

if ~(scaleMax>scaleMin)
    error('scaleMax should bigger than scaleMin');
end
    
if (sum(fluxes)==size(model.rxns,1))    
    fcont=1;
    
else
    fcont=0;
end


if ~all(ismember(metAbbr,model.mets))    
    str = strjoin( metAbbr(~ismember(metAbbr,model.mets)), ' ' );
    warning(['These metabolites are not found in model : ' str])
end

%Create table, creating table without fluxrates if fluxes are not supplied 
IndexesofMets=find(ismember(model.mets,metAbbr));
metMatrix=~ismember(model.S(IndexesofMets,:),0);
Rxns=model.rxns(any(metMatrix,1));
RxnsFormula=printRxnFormula(model,'rxnAbbrList',Rxns,'printFlag',false);
FluxRes=fluxes(ismember(model.rxns,Rxns));
if ~(all(ismember(fluxes,1)))
    tableMetRxnsFormulas=table(Rxns,RxnsFormula,FluxRes);
else
    tableMetRxnsFormulas=table(Rxns,RxnsFormula);
end
%
%Get sub S matrix from S matrix 
RxnsMatrx=~ismember(model.S(:,any(metMatrix,1)),0);    
InvolvedMets=model.mets(any(RxnsMatrx,2));
adjunc_mat=model.S(any(RxnsMatrx,2),any(metMatrix,1));
%
%Multiply sub S matrix with flux values to keep flux value information
FluxMatrix  =FluxRes+1e-6;
FluxMatrix = repmat(FluxMatrix',size(adjunc_mat,1),1);
adjunc_mat=adjunc_mat.*FluxMatrix;

%Create left and right matrix( left matrix : comsumed metabolites, righ matrix:
%produced metabolites)
leftMatrix=adjunc_mat;
leftMatrix(leftMatrix > 0)=0;
rightMatrix=adjunc_mat;
rightMatrix(rightMatrix < 0)=0;
rightMatrix(rightMatrix > 0)=1;

%create adjacency matrix
A=(leftMatrix*rightMatrix')*(-1);

%Delete metabolites that is not first neighbour of metAbbr 
idx=ismember(InvolvedMets,metAbbr);
newadjMtrx=zeros(size(A));
newadjMtrx(idx,:)=A(idx,:);
newadjMtrx(:,idx)=A(:,idx);
rows=any(newadjMtrx,1);
cols=any(newadjMtrx,2);
indofMets=rows'|cols;
metnames=InvolvedMets(indofMets);
newadjMtrx=newadjMtrx(indofMets,indofMets);
A=newadjMtrx;

%create graph object.
G = digraph(A,metnames);

GraphObj=G;
excludedMets=excludedMets(~ismember(excludedMets,metAbbr));

%Exclude given metabolites
G=rmnode(G,excludedMets);

figure;
hold on
G.Edges.LWidths = (G.Edges.Weight-min(G.Edges.Weight))/(max(G.Edges.Weight)-min(G.Edges.Weight))+0.00001;
h=plot(G,'MarkerSize',nodeSize,'NodeColor',nodeColor,'ArrowSize',arrowSize,'NodeLabelMode','auto','Layout','force','UseGravity',true);
metAbbr=metAbbr(ismember(metAbbr,G.Nodes.Name));
highlight(h,metAbbr,'NodeColor',Hnodecolor,'MarkerSize',HnodeSize);
nl = h.NodeLabel;
h.NodeLabel = '';
xd = get(h, 'XData');
yd = get(h, 'YData');
title(Graphtitle,'Interpreter', 'none');
txt=text(xd, yd, nl, 'FontSize',8, 'FontWeight','bold', 'HorizontalAlignment','center', 'VerticalAlignment','middle');
set(txt,'Interpreter', 'none');
%Define function for texts 
set(txt,'ButtonDownFcn',{@hit_node,A,metnames,model,fluxes,excludedMets,Graphtitle,nodeColor,Hnodecolor,fcont,scaleMin,scaleMax,nodeSize,HnodeSize,arrowSize});

%define color and width of edges if fluxes are given 

if  fcont==1
    h.LineWidth=1;
elseif ~any(isnan(G.Edges.LWidths))  
    h.LineWidth=G.Edges.LWidths*2.5;
    colormap jet(10)
    h.EdgeCData=G.Edges.Weight; 
    hcb=colorbar;
    colorTitleHandle = get(hcb,'Title');
else  
    h.LineWidth=1;
    colormap jet(10)
    h.EdgeCData=G.Edges.Weight; 
    hcb=colorbar;
    colorTitleHandle = get(hcb,'Title');

end   

if fcont==0
if ~(scaleMax==1e-6 && scaleMin==0) 
    caxis([scaleMin scaleMax])
    titleBar = ['Scaled Fluxes',' ', '(', num2str(scaleMin),' - ',num2str(scaleMax),')'];
    set(colorTitleHandle ,'String',titleBar,'FontWeight','Bold');
else
    set(colorTitleHandle ,'String','Fluxes','FontWeight','Bold');
end
end

set(gca,'XTickLabel',{' '});
set(gca,'YTickLabel',{' '});
set(gca,'YTick',[]);
set(gca,'XTick',[]);
    
end
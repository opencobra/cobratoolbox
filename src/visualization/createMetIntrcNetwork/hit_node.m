function hit_node(varargin)
%Function for generating Another metabolite-metabolite interaction network
%if the node is clicked in the figure that produced by createMetIntrcNetwork.
%Right click and left click has different properties.
%Left click :Generate sub-metabolite-metabolite network from the created figure, 
%            this functionality was added for better looking at the created network 
%            and showing flux values on edges lines.
%
%Right click :Generate metabolite metabolite network from model, this
%             functionality were added for creating metabolite-metabolite network using
%             clicked metabolite and model.
%The produced figure from main figure also has same property with main
%figure, and it is clickable too.

    f = varargin{1}.Parent.Parent;
    if (strcmp(f.SelectionType, 'normal') | strcmp(f.SelectionType, 'alt'))
        metofInt=varargin{1}.String;
        adjncMtrx=varargin{3};
        mets=varargin{4};
        model=varargin{5} ;
        excludedMets=varargin{7};
        fluxes=varargin{6};
        Graphtitle=varargin{8};
        nodecolour=varargin{9};
        Hnodecolour=varargin{10};
        fcont=varargin{11};
        scaleMin=varargin{12};
        scaleMax=varargin{13};
        nodeSize=varargin{14};
        HnodeSize=varargin{15};
        arrowSize=varargin{16};
        threshold=varargin{17};
        excNodesWithDeg=varargin{18};
        
% Define function of left click        
        if strcmp(f.SelectionType, 'normal')        
            idx=ismember(mets,metofInt);
            newadjMtrx=zeros(size(adjncMtrx));
            newadjMtrx(idx,:)=adjncMtrx(idx,:);
            newadjMtrx(:,idx)=adjncMtrx(:,idx);
            rows=any(newadjMtrx,1);
            cols=any(newadjMtrx,2);
            indofMets=rows'|cols;
            metnames=mets(indofMets);
            newadjMtrx=newadjMtrx(indofMets,indofMets);
            A=newadjMtrx;
            G = digraph(A,metnames);
            ttl=['Sub-', ' ',Graphtitle];
        end
% Define function of right click
        if strcmp(f.SelectionType, 'alt')
            IndexesofMets=find(ismember(model.mets,metofInt));    
            metMatrix=~ismember(model.S(IndexesofMets,:),0);
            Rxns=model.rxns(any(metMatrix,1));
            FluxRes=fluxes(ismember(model.rxns,Rxns));
            metmatrix=~ismember(model.S(:,any(metMatrix,1)),0);    
            metnames=model.mets(any(metmatrix,2));
            adjunc_mat=model.S(any(metmatrix,2),any(metMatrix,1));
            FluxMatrix  =FluxRes + 1e-6;
            FluxMatrix = repmat(FluxMatrix',size(adjunc_mat,1),1);
            adjunc_mat=adjunc_mat.*FluxMatrix;
            leftMatrix=adjunc_mat;
            leftMatrix(leftMatrix > 0)=0;
            rightMatrix=adjunc_mat;
            rightMatrix(rightMatrix < 0)=0;
            rightMatrix(rightMatrix > 0)=1;
            metMatrix=leftMatrix*rightMatrix';
            A=metMatrix*(-1);            
            idx=ismember(metnames,metofInt);
            newadjMtrx=zeros(size(A));
            newadjMtrx(idx,:)=A(idx,:);
            newadjMtrx(:,idx)=A(:,idx);
            rows=any(newadjMtrx,1);
            cols=any(newadjMtrx,2);
            indofMets=rows'|cols;
            metnames=metnames(indofMets);
            newadjMtrx=newadjMtrx(indofMets,indofMets);
            A=newadjMtrx;
            G = digraph(A,metnames);
            ttl=Graphtitle;
        end    
        
        G = rmnode(G,excludedMets);
        G.Edges.Weight(G.Edges.Weight < 1e-4)=1e-6;
        G.Edges.LWidths = (G.Edges.Weight-min(G.Edges.Weight))/(max(G.Edges.Weight)-min(G.Edges.Weight))+0.00001;
        G.Edges.LWidths((isnan(G.Edges.LWidths)))=1e-6;
        
        if threshold~=1e-7 
            edesBelowTresholdIdx=find(G.Edges.Weight<threshold);
            G=rmedge(G,edesBelowTresholdIdx);
        end
        
        nodesIndegree=indegree(G); 
        nodesoutdegree=outdegree(G);
        totalDegree=nodesIndegree+nodesoutdegree;
        G=rmnode(G,find(totalDegree<1));

        figure;
        hold on
        h=plot(G,'MarkerSize',(nodeSize+5),'NodeColor',nodecolour,'ArrowSize',(arrowSize+5),'NodeLabelMode','auto');
        layout(h,'layered','Direction','right')
        highlight(h,metofInt,'NodeColor',Hnodecolour,'MarkerSize',(HnodeSize+5));
        nl = h.NodeLabel;
        h.NodeLabel = '';
        xd = get(h, 'XData');
        yd = get(h, 'YData');
        title([metofInt,' ', 'Centred', ' ',ttl],'Interpreter', 'none');
        txt=text(xd, yd, nl, 'FontSize',8, 'FontWeight','bold', 'HorizontalAlignment','center', 'VerticalAlignment','middle');
        set(txt,'Interpreter', 'none');
        set(txt,'ButtonDownFcn',{@hit_node,A,metnames,model,fluxes,excludedMets,Graphtitle,nodecolour,Hnodecolour,fcont,scaleMin,scaleMax,nodeSize,HnodeSize,arrowSize,threshold,excNodesWithDeg});
        if  fcont==1
            h.LineWidth=1;
        elseif ~any(isnan(G.Edges.LWidths))
            h.EdgeLabel=G.Edges.Weight;  
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
        
        if  fcont==0
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
        set(gca,'XColor', 'none','YColor','none');
    end
  
end



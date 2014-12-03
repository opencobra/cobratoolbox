function options = setMapOptions(options, map, varargin)
%setMapOptions set the values of the options fields
%
% options = setMapOptions(options, map, model,'property name',value,...)
% options = setMapOptions(options, map, 'property name',value,...)
%
%INPUT
% options           The options whose properties are to be set.
%
% map               The map corresponding to the options.  
% 
%
%
%OPTIONAL INPUT
%
% model             The model which the values of the properties are
%                   corresponding to.
% property          Name of any field of the options to be set.
% value             The corresponding value of the property.
%
% The function returns an options with it fields set to the values passed
% to it.
% The input arguments can be passed in two manner:
%       If passed with no map and model it is assumed that the values are
%       already processed and corresponds to the map structure so they are
%       simply assigned to the fields of options.
%
%       If there is map and model passed the values will be checked to see
%       if they are ready to be assigned or they need more prosseccing by
%       matching up the map struct with model's.
%
% options
%   nodeColor           A nx3 matrix corresponds to the color of the metabolite
%                       nodes on the map. This color scale represent the
%                       concentration of the metabolites.
%   edgeColor           A nx3 matrix corresponds to the color of the rxn edges
%                       on the map. This color scale represent the
%                       fluxes of the reactions.
%   edgeArrowColor      A nx3 matrix corresponding to the color of the rxn
%                       edges arrowheads on the map.
%   nodeWeight          A nx1 matrix corresponds to the diameter of the nodes.
%                       it is representative of the confidance of the
%                       concentrations.
%   edgeWeight          A nx1 matrix corresponds to the width of the edges.
%                       it is representative of the confidance of the
%                       fluxes.
%   maxEdgeWeight       Scalar giving max width of any edge, default = 5.
%   textColor           A nx3 matrix corresponds to the color of the
%                       metabolites labels on the map.
%   textSize            A nx1 matrix corresponds to the size of the
%                       metabolites labels on the map.
%   fileName            Name of output file
%   lb                  Lower limit to round smaller values up to.
%   ub                  Upper limit to round larger values down to.
%   colorScale          Colormap (Default = cool(100))
%
%                       drawFlux options
%   zeroFluxWidth       Width of arrows of reactions which carry zero flux.
%                       (Default = edgeWeight)
%   zeroFluxColor       Color of arrows of reactions which carry zero flux.
%                       (Default = edgeColor set by drawFlux)
%   rxnDirFlag          Scale arrowheads based on flux directionality.
%                       (Default = false)
%   rxnDirMultiplier    Scaling value of arrows denoting flux direction.
%                       (Default = 2.5) (only used if rxnDirFlag = true)
%
%                       drawFluxVariability options
%   bidircolor          Bi-directional flux color (Default = [0 255 0])
%   unidirirrcolor      Irreversible reaction color 
%                       (Default = [0 0 255])
%   unidirfwdcolor      Only forward direction flux color
%                       (Default = [255 0 255])
%   unidirrevcolor      Only reverse direction flux color
%                       (Default = [0 255 255])
%
%OUTPUT
% options       Options structure

nNodes = size(map.molName,1);
nEdges = size(map.connectionName,1);
% if map and model are passed the data will be processed before assignment
if ~isstr(varargin{1}) && isstr(varargin{2})
    model = varargin{1};
    for i = 2:2:size(varargin,2)
        switch lower(varargin{i})
            case 'nodecolor'
                conc = cell2mat(varargin(i+1));
                if size(conc,1)==1
                    conc = repmat(conc,nNodes,1);
                elseif all(size(conc) == [nNodes 3])
                    %directly assign to options struct
                    options.nodeColor = conc;
                    continue;
                end
                if(size(conc,2)==1)
                    color = getColorFromColorScale(conc);
                 elseif(size(conc,2)== 3)   %colors maped
                     color = conc;
                else %wrong size
                    warning('Invalid size for nodeColor entry');
                    continue;
                end
                %   match map with model and find out the missing parts
                if isfield(model,'metNames')
                    mapMol = 'molName';
                    modelMol = 'metNames';
                else
                    mapMol = 'molAbbreviation';
                    modelMol = 'mets';
                end
                %generate default color vector
                options.nodeColor = ones(nNodes,3)*191;
                %map known concentrations
                [known index] = ismember(map.(mapMol),model.(modelMol));
                index = index(index~=0);
                options.nodeColor(known,:) = color(index,:);
                %Clear variables
                clear('conc','mapMol','modelMol','color','known','index');
            case 'edgecolor'
                flux = cell2mat(varargin(i+1));
                if size(flux,1)==1
                    flux = repmat(flux,nEdges,1);
                elseif all(size(flux) == [nEdges 3])
                    %directly assign to options struct
                    options.edgeColor = flux;
                    continue
                elseif size(flux) ~= length(model.rxns)
                    warning('Invalid size for edgeColor entry');
                    continue;
                end
                % Map to color if flux vector
                if(size(flux,2)==1)
                    color = getColorFromColorScale(flux);
                 elseif(size(flux,2)== 3)   %colors maped
                     color = flux;
                else %wrong size
                    warning('Invalid size for edgeColor entry');
                    continue;
                end
                % Generate default color vector
                options.edgeColor = ones(nEdges,3)*191;
                %map known connections
                [known index] = ismember(map.connectionAbb,model.rxns);
                index = index(index~=0);
                options.edgeColor(known,:) = color(index,:);
                %Clear variables
                clear('flux','color','known','index');
            case 'edgearrowcolor'
                arrowColor = cell2mat(varargin(i+1));
                if size(arrowColor,1)==1
                    arrowColor = repmat(arrowColor,nEdges,1);
                end
                if size(arrowColor,2)~=3
                    warning('Invalid size for arrowColor entry');
                    continue
                end
                options.edgeArrowColor = arrowColor;
                %Clear variables
                clear('arrowColor');
            case 'nodeweight'
                nodeWeight = cell2mat(varargin(i+1));
                if size(nodeWeight,1)==1
                    nodeWeight = repmat(nodeWeight,nNodes,1);
                    options.nodeWeight = nodeWeight;
                elseif size(nodeWeight,1)==length(model.mets) %assumes concentration confidence
                    %Match map with model and find out the missing parts
                    if isfield(model,'metNames')
                        mapMol = 'molName';
                        modelMol = 'metNames';
                    else
                        mapMol = 'molAbbreviation';
                        modelMol = 'mets';
                    end
                    %scale
                    if max(nodeWeight)~=0, nodeWeight = round(24*nodeWeight/max(nodeWeight))+1; end
                    %default node weight
                    options.nodeWeight = ones(nNodes,1)*25;
                    %Map to nodes
                    [known index] = ismember(map.(mapMol),model.(modelMol));
                    index = index(index~=0);
                    options.nodeWeight(known) = nodeWeight(index);
                elseif size(nodeWeight,1)==nNodes
                    %directly assign to options struct
                    options.nodeWeight=nodeWeight;
                else %wrong size
                    warning('Invalid size for nodeWeight entry');
                end
                if ~isfield(options,'nodeWeightSecondary')
                    options.nodeWeightSecondary = options.nodeWeight*15/25;
                end
                %Clear variables
                clear('nodeWeight','mapMol','modelMol','known','index');
            case 'nodeweightsecondary'
                 nodeWeight = cell2mat(varargin(i+1));
                if size(nodeWeight,1)==1
                    nodeWeight = repmat(nodeWeight,nNodes,1);
                    options.nodeWeightSecondary = nodeWeight;
                elseif size(nodeWeight,1)==length(model.mets) %assumes concentration confidence
                    %Match map with model and find out the missing parts
                    if isfield(model,'metNames')
                        mapMol = 'molName';
                        modelMol = 'metNames';
                    else
                        mapMol = 'molAbbreviation';
                        modelMol = 'mets';
                    end
                    %scale
                    if max(nodeWeight)~=0, nodeWeight = round(24*nodeWeight/max(nodeWeight))+1; end
                    %default node weight
                    options.nodeWeightSecondary = ones(nNodes,1)*25;
                    %Map to nodes
                    [known index] = ismember(map.(mapMol),model.(modelMol));
                    index = index(index~=0);
                    options.nodeWeightSecondary(known) = nodeWeight(index);
                elseif size(nodeWeight,1)==nNodes
                    %directly assign to options struct
                    options.nodeWeightSecondary=nodeWeight;
                else %wrong size
                    warning('Invalid size for nodeWeight entry');
                end
                %Clear variables
                clear('nodeWeight','mapMol','modelMol','known','index');
            case 'maxedgeweight'
                %this allows more flexibilty over thickest width
                options.maxEdgeWeight=cell2mat(varargin(i+1));
            case 'edgeweight'
                edgeWeight = cell2mat(varargin(i+1));
                if size(edgeWeight,1) == 1
                    %set edgeWeight for all reactions
                    options.edgeWeight = repmat(edgeWeight,nEdges,1);
                elseif size(edgeWeight,1) == length(model.rxns)
                    %Assume flux confidence scale
                    if max(edgeWeight)~=0
                        edgeWeight = round(4*edgeWeight/max(edgeWeight))+1;
                    end
                    %default edge weight
                    options.edgeWeight = ones(nEdges,1)*4;
                    %map known connections
                    [known index] = ismember(map.connectionAbb,model.rxns);
                    index = index(index~=0);
                    options.edgeWeight(known) = edgeWeight(index);
                elseif size(edgeWeight,1) == nEdges
                    %Directly assign to options struct
                    options.edgeWeight = edgeWeight;
                else
                    warning('invalid size for nodeWeight entry');
                end
                %Clear variables
                clear('edgeWeight','known','index');
            case 'textsize'
                textSize = cell2mat(varargin(i+1));
                nNodes = size(map.molName,1);
                if length(textSize)==1
                    textSize = ones(nNodes,1)*textSize;
                end
                for j = 1:nNodes
                    str = map.molName(j);
                    index = find(strcmp(model.metNames(:),str));
                    if isempty(index)
                        options.textSize(j,1) = 8;
                    elseif length(index) == 1
                        options.textSize(j,1) = textSize(index);
                    else
                        options.textSize(j,1) = textSize(index(1));
                    end
                end
            case 'textcolor'
                tColor = cell2mat(varargin(i+1));
                nNodes = size(map.molName,1);
                if size(tColor,1)==1
                    tColor = repmat(tColor,nNodes,1);
                end
                for j = 1:nNodes
                    str = map.molName(j);
                    index = find(strcmp(model.metNames(:),str));
                    if isempty(index)
                        options.textColor(j,:) = [0 0 0];
                    elseif length(index) == 1
                        options.textColor(j,:)= tColor(index,:);
                    else
                        options.textColor(j,:)= tColor(index(1),:);
                    end
                end
            case 'othertextcolor'
                otColor = cell2mat(varargin(i+1));
                nNodes = size(map.molName,1);
                if size(ltColor,1)==1
                    otColor = repmat(otColor,nNodes,1);
                end
                options.otherTextColor = otColor;
            case 'lb', options.lb = varargin{i+1};
            case 'ub', options.ub = varargin{i+1};
            case 'scaletype', options.scaleType = varargin{i+1};
            case 'colorscale', options.colorScale = varargin{i+1};
            case 'zerofluxwidth', options.zeroFluxWidth = varargin{i+1};
            case 'zerofluxcolor', options.zeroFluxColor = varargin{i+1};
            case 'zeroconccolor', options.zeroConcColor = varargin{i+1};
            case 'filename', options.fileName = varargin{i+1};
            case 'rxndirflag', options.rxnDir = varargin{i+1};
            case 'rxndirmultiplier', options.rxnDirMultiplier = varargin{i+1};
            case 'bidircolor', options.fluxVarColor.biDirColor = varargin{i+1};
            case 'unidirirrcolor', options.fluxVarColor.uniDirIrrColor = varargin{i+1};
            case 'unidirfwdcolor', options.fluxVarColor.uniDirFwdColor = varargin{i+1};
            case 'unidirrevcolor', options.fluxVarColor.uniDirRevColor = varargin{i+1};
            otherwise
                if isstr(varargin{i})       % The property doesn't match any of the feilds
                    warning('Unknown Property: "%s"',varargin{i});
                end
        end
    end
    
    if isfield(options,'maxEdgeWeight')
        options.edgeWeight = round((options.maxEdgeWeight-1)*options.edgeWeight/max(options.edgeWeight))+1;
    end
    % if map and model are not passed.
else
    for i = 1:2:size(varargin,2)
        switch lower(varargin{i})
            case 'nodeweight', options.nodeWeight = cell2mat(varargin(i+1));
            case 'nodecolor', options.nodeColor = cell2mat(varargin(i+1));
            case 'edgeweight', options.edgeWeight = cell2mat(varargin(i+1));
            case 'edgecolor', options.edgeColor = cell2mat(varargin(i+1));
            case 'edgearrowcolor', options.edgeArrowColor = cell2mat(varargin(i+1));
            case 'textsize', options.textSize = cell2mat(varargin(i+1));
            case 'textcolor', options.textColor = cell2mat(varargin(i+1));
            case 'othertextsize', options.otherTextSize = cell2mat(varargin(i+1));
            case 'othertextcolor', options.otherTextColor = cell2mat(varargin(i+1));
            case 'lb', options.lb = varargin{i+1};
            case 'ub', options.ub = varargin{i+1};
            case 'scaletype', options.scaleType = varargin{i+1};
            case 'colorscale', options.colorScale = varargin{i+1};
            case 'zerofluxwidth', options.zeroFluxWidth = varargin{i+1};
            case 'zerofluxcolor', options.zeroFluxColor = varargin{i+1};
            case 'zeroconccolor', options.zeroConcColor = varargin{i+1};
            case 'filename', options.fileName = varargin{i+1};
            case 'rxndirflag', options.rxnDirFlag = varargin{i+1};
            case 'rxndirmultiplier', options.rxnDirMultipler = varargin{i+1};
            case 'bidircolor', options.fluxVarColor.biDirColor = varargin{i+1};
            case 'unidirirrcolor', options.fluxVarColor.uniDirIrrColor = varargin{i+1};
            case 'unidirfwdcolor', options.fluxVarColor.uniDirFwdColor = varargin{i+1};
            case 'unidirrevcolor', options.fluxVarColor.uniDirRevColor = varargin{i+1};
            otherwise
                if isstr(varargin{i})        % The property doesn't match any of the feilds
                    warning('Unknown Property: "%s"',varargin{i});
                end
        end
    end
end
function options = drawFluxVariability(map,model,minFlux,maxFlux,options,varargin)
%drawFluxVariablity Overlay flux variability data on a metabolic map
%
% options = drawFluxVariability(map,model,minFlux,maxflux,options,varargin)
%
%INPUTS
% map           COBRA map structure
% model         COBRA model structure
% minFlux       Vector containing minimum flux values for each reaction
% maxFlux       Vector containing maximum flux values for each reaction
%
%OPTIONAL INPUTS
% options       options structure
% varargin      parameter, parameter value inputs for optional parameters
%
%OUTPUT
% options       options structure used to generate map
%
%Richard Que (03/2010)

if nargin<5, options = []; end
if ~isfield(options,'fluxVarColor'), options.fluxVarColor = []; end
if mod(length(varargin),2)==0
    for i=1:2:length(varargin)-1
        options = setMapOptions(options,map,model,varargin{i},varargin{i+1});
%         switch lower(varargin{i})
%             case 'bidircolor', options.fluxVarColor.biDirColor = varargin{i+1};
%             case 'unidirirrcolor', options.fluxVarColor.uniDirIrrColor = varargin{i+1};
%             case 'unidirfwdcolor', options.fluxVarColor.uniDirFwdColor = varargin{i+1};
%             case 'unidirrevcolor', options.fluxVarColor.uniDirRevColor = varargin{i+1};
%             case 'filename', options.fileName = varargin{i+1};
%             case 'rxndirflag', options.rxnDirFlag = varargin{i+1};
%             case 'rxndirmultiplier', options.rxnDirMultiplier = varargin{i+1};
%             otherwise
%                 options.(varargin{i}) = varargin{i+1};
%                 fprintf('Unrecognized parameter %s\n',varargin{i});
%         end
    end
else
    error('Invalid number of parameters/values');
end
color = zeros(length(model.rxns),3);
%set defaults
if ~isfield(options.fluxVarColor,'biDirColor')
    options.fluxVarColor.biDirColor = [0 255 0];
end
if ~isfield(options.fluxVarColor,'uniDirIrrColor')
    options.fluxVarColor.uniDirIrrColor = [0 0 255];
end
if ~isfield(options.fluxVarColor,'uniDirFwdColor')
    options.fluxVarColor.uniDirFwdColor = [255 0 255];
end
if ~isfield(options.fluxVarColor,'uniDirRevColor')
    options.fluxVarColor.uniDirRevColor = [0 255 255];
end
if isfield(options,'rxnDirMultiplier')
    options.rxnDirFlag = true;
end
if ~isfield(options,'rxnDirFlag')
    rxnDirFlag = false;
else
    rxnDirFlag = options.rxnDirFlag;
end


%assign colors
for i=1:length(model.rxns)
    if minFlux(i)*maxFlux(i)>=0 
        %unidirectional
        if model.rev(i) 
            %reversible
            if minFlux(i)<0 || maxFlux(i)<0
                %reverse direction: Cyan 0 255 255
                color(i,:) = options.fluxVarColor.uniDirRevColor;
            else
                %forward direction: Magenta 255 0 255
                color(i,:) = options.fluxVarColor.uniDirFwdColor;
            end
        else
            %irreversible: Blue 0 0 255
            color(i,:) = options.fluxVarColor.uniDirIrrColor;
        end    
    else
        %bidirectional: Green 0 255 0
        color(i,:) = options.fluxVarColor.biDirColor;        
    end
end

if rxnDirFlag
    options.rxnDir = zeros(length(map.rxnIndex),1);
    options.rxnDir(ismember(map.connectionAbb,model.rxns((maxFlux>0) & (minFlux>=0)))) = 1;
    options.rxnDir(ismember(map.connectionAbb,model.rxns((maxFlux<=0) & (minFlux<0)))) = -1;
end

options = setMapOptions(options,map,model,'edgeColor',color);
drawCbMap(map,options);
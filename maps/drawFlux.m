function options = drawFlux(map,model,flux,options,varargin)
%drawFlux overlays a flux distribution onto a reaction map
%
% options = drawFlux(map,model,flux,options,varargin)
%
%INPUTS
% map               map structure
% model             COBRA model structure
% flux              Flux vector to overlay
%
%OPTIONAL INPUTS
% Optional parameters can be set using either the options structure, a
% parameter name / value pair input arguments, or a combination of both.
%
% options            Structure containing optional parameters
%   lb                Lower limit to round smaller values up to.
%   ub                Upper limit to round larger values down to.
%   colorScale        Colormap
%   zeroFluxWidth     Width of arrows of reactions which carry zero flux.
%   zeroFluxColor     Color of arrows of reactions which carry zero flux.
%   fileName          Name of output file
%   rxnDirMultiplier  scaling value of arrows denoting flux direction
%
%  Note: see setMapOptions for additional options.
%
% varargin          optional parameter name / parameter value pairs
%
%OUTPUT
% options           Structure containing optional parameters.
%
%
%

if nargin<4, options=[]; end
%Parse optional parameters
if mod(length(varargin),2)==0
    for i=1:2:length(varargin)-1
        options = setMapOptions(options,map,model,varargin{i},varargin{i+1});
    end
else
    error('Invalid number of parameters/values');
end

if ~isfield(options,'colorScale')
    options.colorScale = cool(100);
end
if ~isfield(options,'scaleType'), options.scaleType=1; end
if ~isfield(options,'lb'), lb=[];else lb = options.lb; end
if ~isfield(options,'ub'), ub=[];else ub = options.ub; end
if ~isfield(options,'rxnDirMultiplier'), options.rxnDirMultiplier = 2; end
if ~isfield(options,'rxnDirFlag'), rxnDirFlag = false; else rxnDirFlag = options.rxnDirFlag; end
rxnListZero = model.rxns(abs(flux)<=1e-9);
absFlag=false;
switch lower(options.scaleType)
    case {1, 'linear'}
        options.scaleTypeLabel='Linear;';
    case {2 ,'linear absolute'}
        flux=abs(flux);
        absFlag=true;
        options.scaleTypeLabel='Linear absolute;';
    case {3,'log10'}
        flux = log10(abs(flux));
        rxnListZero = model.rxns(isinf(flux));
        options.scaleTypeLabel='Log10;';
end
if ~isempty(ub)
    flux(flux>ub)=ub;
    options.overlayUB = [num2str(ub) '+'];
    fluxMax = ub;
else
    options.overlayUB = num2str(max(flux));
    fluxMax = max(flux);
end
if ~isempty(lb)
    flux(flux<lb)=lb;
    options.overlayLB = [num2str(lb) '-'];
    fluxMin = lb;
elseif absFlag
    options.overlayLB = '0';
    fluxMin = 0;
else
    fluxMin = min(flux(~isinf(flux)));
    options.overlayLB = num2str(fluxMin);
end
if isempty(find(options.colorScale>1, 1))
    options.colorScale = round(options.colorScale*255);
end
flux2 = flux-fluxMin;
if (fluxMax-fluxMin~=0), flux2 = flux2/(fluxMax-fluxMin); end
color = getColorFromColorScale(flux2,options.colorScale);
if isfield(options,'zeroFluxWidth')
    global CB_MAP_OUTPUT
    if ~isfield(options,'edgeWeight')
        s= size(map.connection);      
        if strcmp(CB_MAP_OUTPUT,'svg')
            options.edgeWeight = ones(s(1),1)*9;
        else
            options.edgeWeight = ones(s(1),1)*2;
        end
    end
    options.edgeWeight(ismember(map.connectionAbb,rxnListZero))=options.zeroFluxWidth;
end
if isfield(options,'zeroFluxColor')
    zeroFluxRxns = find(ismember(model.rxns,rxnListZero));
    color(zeroFluxRxns,:)=repmat(options.zeroFluxColor,size(zeroFluxRxns,1),1);
end

%rxnDirectionality
if rxnDirFlag
    options.rxnDir = zeros(length(map.connectionAbb),1);
    for i = 1:length(map.connectionAbb)
        options.rxnDir(ismember(map.connectionAbb,model.rxns(flux>0))) = 1;
        options.rxnDir(ismember(map.connectionAbb,model.rxns(flux<0))) = -1;
    end
end



options = setMapOptions(options,map,model,'edgeColor',color);
options.colorScale=options.colorScale;
options.lb = fluxMin;
options.ub = fluxMax;
options.overlayType = 'Flux';
drawCbMap(map,options);
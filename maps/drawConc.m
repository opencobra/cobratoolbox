function options = drawConc(map,model,conc,options,varargin)
%drawConc overlays a flux distribution onto a reaction map
%
% options = drawConc(map,model,conc,options,varargin)
%
%INPUTS
% map               COBRA map structure
% model             COBRA model structure
% conc              Vector containing concentration values
%
%OPTIONAL INPTUS
% Optional parameters can be set using either the options structure, a
% parameter name / value pair input arguments, or a combination of both.
%
% options           Structure containing optional parameters
%   lb              Lower limit to round smaller values up to.
%   ub              Upper limit to round larger values down to.
%   colorScale      Colormap
%   scaleType       {1 - 'linear', 2 - 'log10'} (Default = 1)
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
%Parse optinal parameters
if mod(length(varargin),2)==0
    for i=1:2:length(varargin)-1
        options = setMapOptions(options,map,model,varargin{i},varargin{i+1});
%         switch lower(varargin{i})
%             case 'lb', options.lb = varargin{i+1};
%             case 'ub', options.ub = varargin{i+1};
%             case 'scaletype', options.absFlag = varargin{i+1};
%             case 'colorscale', options.colorScale = varargin{i+1};
%             case 'filename', options.fileName = varargin{i+1};
%         end
    end
else
    error('Invalid number of parameters/values');
end
if ~isfield(options,'colorScale')
    options.colorScale = cool(100);
end
metListZero = (abs(conc)<=1e-9);
if ~isfield(options,'scaleType'), options.scaleType=1; end
if ~isfield(options,'lb'), lb=[]; else lb = options.lb; end
if ~isfield(options,'ub'), ub=[]; else ub = options.ub; end
switch lower(options.scaleType)
    case {1,'linear'}
        options.scaleTypeLabel='Linear;';
    case {2,'log10'}
        conc = log10(abs(conc));
        metListZero = model.mets(isinf(conc));
        options.scaleTypeLabel='Log10;';
    otherwise
        error('Invalid scaleType input')
end
if ~isempty(ub)
    conc(conc>ub)=ub;
    options.overlayUB = [num2str(ub) '+'];
    concMax = ub;
else
    options.overlayUB = num2str(max(conc));
    concMax = max(conc);
end
if ~isempty(lb)
    conc(conc<lb)=lb;
    if lb==0
        options.overlayLB = '0';
    else
        options.overlayLB = [num2str(lb) '-'];
    end
    concMin = lb;
else
    concMin = min(conc(~isinf(conc)));
    options.overlayLB = num2str(concMin);
end
if find(options.colorScale>1)
else
    options.colorScale = round(options.colorScale*255);
end
if max(conc)~=0
    conc = repmat(conc,1,3)/max(conc);
else
    conc=repmat(conc,1,3);
end
color = getColorFromColorScale(conc,options.colorScale);
if isfield('zeroConcColor',options)
   color(metListZero,:) = repmat(options.zeroConcColor,length(metListZero),1);
end
options = setMapOptions(options,map,model,'nodeColor',color);
options.overlayType = 'Concentration';
options.lb = concMin;
options.ub = concMax;
drawCbMap(map,options);
function cmap = crameri(ColormapName,varargin) 
% crameri returns perceptually-uniform scientific colormaps created
% by Fabio Crameri. 
% 
%% Syntax 
% 
%  crameri 
%  cmap = crameri('ColormapName') 
%  cmap = crameri('-ColormapName') 
%  cmap = crameri(...,NLevels)
%  cmap = crameri(...,'pivot',PivotValue) 
%  crameri(...)
% 
%% Description 
% 
% crameri without any inputs displays the options for colormaps. 
% 
% cmap = crameri('ColormapName') returns a 256x3 colormap.  For a visual
% depiction of valid colormap names, type |crameri|. 
%
% cmap = crameri('-ColormapName') a minus sign preceeding any ColormapName flips the
% order of the colormap. 
%
% cmap = crameri(...,NLevels) specifies a number of levels in the colormap.  Default
% value is 256. 
%
% cmap = crameri(...,'pivot',PivotValue) centers a diverging colormap such that white 
% corresponds to a given value and maximum extents are set using current caxis limits. 
% If no PivotValue is set, 0 is assumed. 
%
% crameri(...) without any outputs sets the current colormap to the current axes.  
% 
%% Examples 
% For examples, type: 
% 
%  showdemo crameri_documentation
%
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas
% Institute for Geophysics (UTIG), August 2018, using Fabio Crameri's 
% scientific colormaps, version 4.0. http://www.fabiocrameri.ch/colourmaps.php
% 
%% Citing this colormap: 
% Please acknowledge the free use of these colormaps by citing
% 
% Crameri, F. (2018). Scientific colour-maps. Zenodo. http://doi.org/10.5281/zenodo.1243862
% 
% Crameri, F. (2018), Geodynamic diagnostics, scientific visualisation and 
% StagLab 3.0, Geosci. Model Dev., 11, 2541-2562, doi:10.5194/gmd-11-2541-2018.
% 
% For more on choosing effective and accurate colormaps for science, be sure
% to enjoy this fine beach reading: 
% 
% Thyng, K.M., C.A. Greene, R.D. Hetland, H.M. Zimmerle, and S.F. DiMarco. 2016. True 
% colors of oceanography: Guidelines for effective and accurate colormap selection. 
% Oceanography 29(3):9-13, http://dx.doi.org/10.5670/oceanog.2016.66.
% 
% See also colormap and caxis.  

%% Display colormap options: 

if nargin==0
   figure('menubar','none','numbertitle','off','Name','crameri options:')
   
   if license('test','image_toolbox')
      imshow(imread('crameri7.0.png')); 
   else
      axes('pos',[0 0 1 1])
      image(imread('crameri7.0.png')); 
      axis image off
   end
   
   return
end

%% Error checks: 

assert(isnumeric(ColormapName)==0,'Input error: ColormapName must be a string.') 

%% Set defaults: 

NLevels = 256; 
autopivot = false; 
PivotValue = 0; 
InvertedColormap = false; 

%% Parse inputs: 

% Does user want to flip the colormap direction? 
dash = strncmp(ColormapName,'-',1); 
if any(dash) 
   InvertedColormap = true; 
   ColormapName(dash) = []; 
end

% Standardize all colormap names to lowercase: 
%ColormapName = lower(ColormapName); 

% Oleron's too hard for me to remember, so I'm gonna use dem or topo. 
if ismember(ColormapName,{'dem','topo'})
   ColormapName = 'oleron'; 
end

% Does the user want to center a diverging colormap on a specific value? 
% This parsing support original 'zero' syntax and current 'pivot' syntax. 
tmp = strncmpi(varargin,'pivot',3); 
if any(tmp) 
   autopivot = true; 
   try
      if isscalar(varargin{find(tmp)+1})
         PivotValue = varargin{find(tmp)+1}; 
         tmp(find(tmp)+1) = 1; 
      end
   end
   varargin = varargin(~tmp); 
end

% Has user requested a specific number of levels? 
tmp = isscalar(varargin); 
if any(tmp) 
   NLevels = varargin{tmp}; 
end

%% Load RGB values and interpolate to NLevels: 

try
   S = load('CrameriColourMaps7.0.mat',ColormapName); 
   cmap = S.(ColormapName); 
catch
   error(['Unknown colormap name ''',ColormapName,'''. Try typing crameri with no inputs to check the options and try again.'])
end

% Interpolate if necessary: 
if NLevels~=size(cmap,1) 
   cmap = interp1(1:size(cmap,1), cmap, linspace(1,size(cmap,1),NLevels),'linear');
end

%% Invert the colormap if requested by user: 

if InvertedColormap
   cmap = flipud(cmap); 
end

%% Adjust values to current caxis limits? 

if autopivot
   clim = caxis; 
   maxval = max(abs(clim-PivotValue)); 
   cmap = interp1(linspace(-maxval,maxval,size(cmap,1))+PivotValue, cmap, linspace(clim(1),clim(2),size(cmap,1)),'linear');
end

%% Clean up 

if nargout==0
   colormap(gca,cmap) 
   clear cmap  
end

%% Code to collect Fabio's data into a single .mat file: 
% Unzip the latest folder, navigate to that filepath, and run this.
% Update the file list as needed. 
%
% clear all
% f = {'acton','bam','bamO','bamako','batlow','batlowK','batlowW','berlin','bilbao','broc','brocO','buda','bukavu','cork',...
%    'corkO','davos','devon','fes','grayC','hawaii','imola','lajolla','lapaz','lisbon',...
%    'nuuk','oleron','oslo','roma','romaO','tofino','tokyo','turku','vanimo','vik','vikO'}; 
% 
% for k = 1:length(f)
%    load([f{k},'/',f{k},'.mat'])
% end
% 
% clear f k 
% save('CrameriColourMaps7.0.mat')

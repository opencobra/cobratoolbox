function [map, varargout] = AdvancedColormap(command, varargin)
% ADVANCEDCOLORMAP  Performs advaced colormap operations
%
% cmap = AdvancedColormap;
%       Returns current colormap, much like COLORMAP does,
%       but new figure is not created
%
% AdvancedColormap('AddColormapControls')
% h = AdvancedColormap('AddColormapControls')
%       Use this commands to add ADVANCEDCOLORMAP controls
%       to current figure.
%
% AdvancedColormap('HideColormapControls')
% h = AdvancedColormap('HideColormapControls')
%       Use this commands to hide ADVANCEDCOLORMAP controls
%       on current figure (controlas are not deleted for later use).
%
% AdvancedColormap('ShowColormapControls')
% h = AdvancedColormap('ShowColormapControls')
%       Use this commands to show ADVANCEDCOLORMAP controls
%       on current figure which were previously hidden by
%       HIDECOLORMAPCONTROLS command.
%
% AdvancedColormap('ToggleColormapControls')
% h = AdvancedColormap('ToggleColormapControls')
%       Use this commands to toggle visibility of
%       ADVANCEDCOLORMAP controls on current figure.
%
% AdvancedColormap('DeleteColormapControls')
% h = AdvancedColormap('DeleteColormapControls')
%       Use this commands to permanently delete
%       ADVANCEDCOLORMAP controls from current figure.
%
% cmaps = AdvancedColormap('GetSupportedColormaps')
%       Returns cell array of strings of all predefined colormaps.
%
% AdvancedColormap('ShowSupportedColormaps')
% AdvancedColormap('ShowSupportedColormaps','OnBlack')
% AdvancedColormap('ShowSupportedColormaps','OnWhite')
%       Displays all predefined colormaps as a color+grayscale image
%       or white (default) or black background.
% img = AdvancedColormap('ShowSupportedColormaps',...)
%       The image is returned if output parameter is specified.
%
% str = AdvancedColormap('GetCurrentColormapString')
%       Returns current colormap string.
%       May not work properly if colormap was modified with commands below.
%
% AdvancedColormap('Reverse')
% AdvancedColormap('Invert')
% AdvancedColormap('ShiftUp')
% AdvancedColormap('ShiftDown')
% AdvancedColormap('RGB>RBG')
% AdvancedColormap('RGB>BRG')
% AdvancedColormap('RGB>GRB')
% AdvancedColormap('RGB>BGR')
% AdvancedColormap('RGB>GBR')
% AdvancedColormap('Brighten')
% AdvancedColormap('Brighten',Amount)
% AdvancedColormap('Darken')
% AdvancedColormap('Darken',Amount)
%       Performs advanced command on current colormap.
%
% AdvancedColormap('MakeUniformByGrayValue')
%       Tries to adjust current colormap so its gray values grow linearly.
%
% AdvancedColormap(MatLabColorMapName)
% AdvancedColormap(MatLabColorMapName,Length)
%       This is equivalent to MatLab
%           colormap(cmap)
%       and
%           colormap(cmap,n)
%       respectively.
%
% AdvancedColormap(ColorMapString)
% AdvancedColormap(ColorMapString,Length)
% AdvancedColormap(ColorMapString,Length,ColorPositions)
% AdvancedColormap(ColorMapString,Length,ColorPositions,InterpolationMode)
%       ColorMapString      String representation of colormap
%                           Each character represents one color
%                           and must belong to the following set
%
%                               char    color           R-  G-  B- values
%                               k       black           0.0 0.0 0.0
%                               r       red             1.0 0.0 0.0
%                               p       pink            1.0 0.0 0.5
%                               o       orange          1.0 0.5 0.0
%                               g       green           0.0 1.0 0.0
%                               l       lime            0.5 1.0 0.0
%                               a       aquamarine      0.0 1.0 0.5
%                               b       blue            0.0 0.0 1.0
%                               s       sky blue        0.0 0.5 1.0
%                               v       violet          0.5 0.0 1.0
%                               c       cyan            0.0 1.0 1.0
%                               m       magenta         1.0 0.0 1.0
%                               y       yellow          1.0 1.0 0.0
%                               w       white           1.0 1.0 1.0
%
%                           If the string does not contain spaces, each
%                           character represents one color in colormap.
%                           For example, 'kryw' defines black-red-yellow-white (hot-like) colormap
%                           If string contains spaces then each group of space-delimited characters
%                           define one color. RGB components of the color are formed
%                           by averagin of RGB components of each color from the group.
%                           For example, 'bw k rw' defines lightblue-black-lightred colormap
%
%                           Colors in the generated colormap are evenly spaced
%                           covering values from 0 to 1
%       Length              Length of generated colormap
%       ColorPositions      Vector of color positions
%                           If colors from the ColorMapString should be
%                           placed at custom data values, provide their positions in this vector.
%                           Length of the ColorPositions should be equal
%                           to length of the ColorMapString if ColorMapString does not contain spaces
%                           or to number of color groups in ColorMapString
%       InterpolationMode   'nearest'   {'linear'}    'spline'    'cubic'
%                           Interpolation mode for colormap
%                           See INTERP2 for details
%
% cmap = AdvancedColormap(ColorMapString,...)
%       ADVANCEDCOLORMAP returns applied colormap to caller
%
% ctable = AdvancedColormap(ColorMapString,0);
% [ctable,cpos] = AdvancedColormap(ColorMapString,0);
%       When requested length of colormap is zero, ADVANCEDCOLORMAP returns
%       original table of colors used to generate the colormap in CTABLE.
%       This can be applied only for predefined or generated-on-the-fly colormaps.
%       ADVANCEDCOLORMAP also returns vector CPOS of positions of the colors returned in CTABLE
%
% Examples
%       By inverting and reversing standard BONE colormap one can obtain nice sepia colormap
%
%       figure;
%       imagesc(peaks(256));
%       AdvancedColormap('bone');
%       AdvancedColormap('invert');
%       AdvancedColormap('reverse');
%
%       figure;
%       imagesc(peaks(256));
%       AdvancedColormap('kryw');
%
%       See ADVANCEDCOLORMAPDEMO scropt for more examples
%
%   See also    colormap, brighten, FEX#23342, FEX#23865, FEX#24870, FEX#20848
%
% Copyright 2009-2010 A. Nych

%============================================================================
%  Author: Andriy Nych             n y c h . a n d r i y @ g m a i l . c o m
% Created: 2009.10.23
% Version: 2013.04.30.003
%============================================================================

SafelySaveCurrentColormapString('');
% SaveCurrentColormapString(S);

% If no command supplied, we return current colormap like COLORMAP
% If there is no open figure this function returns default colormap
if nargin == 0
    %     map = GetCurrentColorMap;
    %     return;
    %     %     %     if WeHaveOpenFigure
    %     %     %         if ( isappdata(gcf,'AdvColormapCCMString') && ~isempty(getappdata(gcf,'AdvColormapCCMString')) )
    %     %     %             [m,p] = AdvColormap(getappdata(gcf,'AdvColormapCCMString'))
    %     %     %         else
    %     %     %         end
    %     %     %             setappdata(gcf,'AdvColormapCCMString',S);
    %     %     %         end
    %     %     %     else
    %     %     %         map = GetCurrentColorMap;
    %     %     %     end
    %     %     %     return;
    map = GetCurrentColorMap;
    if nargout > 1
        varargout{1} = [];
    end
    return;
end

%=================================================================================
% These are built-in MatLab colormaps
%---------------------------------------------------------------------------------
MatLabColorMapNames = {'autumn'    'bone'      'colorcube' 'cool'      'copper' ...
                        'flag'      'gray'      'hot'       'hsv'       'jet'    ...
                        'lines'     'pink'      'prism'     'spring'    'summer' ...
                        'white'     'winter'};

%=================================================================================
% Examples of generated colormaps
%---------------------------------------------------------------------------------
% These colormaps (and many others) can be generated programmatically
% These colormaps are added in case one needs a list of supported colormaps
AutoGenCMapsExamples = {
                'kr'        'kg'        'kb'        ...
                'kc'        'km'        'ky'        ...
                'wr'        'wg'        'wb'        ...
                'wc'        'wm'        'wy'        ...
                'krk'       'kryrk'     'krwrk'     ...
                'rkr'       'yrkry'     'wrkrw'     ...
                'rgb'       'krkgkbk'   'krgbcmyw'  ...
                'cmy'       'kckmkyk'   'rygcb'     ...
                'rygcbmr'   'krywyrk'               ...
                'krpoglabsvcmyw'};

%=================================================================================
% Definitions of new colormaps
%---------------------------------------------------------------------------------
CmapsData = {...
    % Colormap name      Value   Red     Green   Blue
    'cobratoolbox'      [
                      0.00    50 / 256    101 / 256   102 / 256;
                      0.25    89 / 256    158 / 256   200 / 256;
                      0.50    173 / 256   188 / 256   85 / 256;
                      0.75    236 / 256   179 / 256   31 / 256;
                      1.00    234 / 256   85 / 256    37 / 256]; ...
    'jet2'          [0.00    0.0000  0.0000  0.0000;
                        0.20    0.0000  0.0000  0.5000;
                        0.40    0.0000  1.0000  1.0000;
                        0.60    1.0000  1.0000  0.0000;
                        0.80    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet3'          [0.00    0.0000  0.0000  0.5000;
                        0.20    0.0000  0.0000  0.8000;
                        0.40    0.0000  0.9000  0.9000;
                        0.60    1.0000  1.0000  0.0000;
                        0.80    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet4'          [0.00    0.0000  0.0000  0.5000;
                        0.30    0.0000  0.0000  0.8000;
                        0.50    0.0000  0.9000  0.9000;
                        0.70    1.0000  1.0000  0.0000;
                        0.90    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet5'          [0.00    0.0000  0.0000  0.5000;
                        0.20    0.0000  0.0000  0.8000;
                        0.40    0.0000  0.9000  0.9000;
                        0.70    1.0000  1.0000  0.0000;
                        0.90    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet6'          [0.00    0.0000  0.0000  0.5000;
                        0.10    0.0000  0.0000  0.8000;
                        0.30    0.0000  0.9000  0.9000;
                        0.70    1.0000  1.0000  0.0000;
                        0.90    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet7'          [0.00    0.0000  0.0000  0.5000;
                        0.10    0.0000  0.0000  0.8000;
                        0.40    0.0000  0.9000  0.9000;
                        0.70    1.0000  1.0000  0.0000;
                        0.90    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'jet8'          [0.00    0.0000  0.0000  0.5000;
                        0.10    0.0000  0.0000  0.8000;
                        0.45    0.0000  0.9000  0.9000;
                        % 0.57    0.0000  1.0000  0.5000;
                        0.70    1.0000  1.0000  0.0000;
                        0.90    1.0000  0.0000  0.0000;
                        1.00    0.5000  0.0000  0.0000]; ...
    'thermal'       [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.2500  0.3000  0.0000  0.7000;
                        0.5000  1.0000  0.2000  0.0000;
                        0.7500  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'thermal2'      [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.2500  0.5000  0.0000  0.0000;
                        0.5000  1.0000  0.2000  0.0000;
                        0.7500  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'thermal3'      [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.2500  0.5000  0.0000  0.0000;
                        0.5000  1.0000  0.2000  0.0000;
                        0.7500  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  0.8000]; ...
    'bled'          [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.1667  0.1667  0.1667  0.0000;
                        0.3333  0.0000  0.3333  0.0000;
                        0.5000  0.0000  0.5000  0.5000;
                        0.6667  0.0000  0.0000  0.6667;
                        0.8333  0.8333  0.0000  0.8333;
                        1.0000  1.0000  0.0000  0.0000]; ...
    'bright'        [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.1429  0.3071  0.0107  0.3925;
                        0.2857  0.0070  0.2890  1.0000;
                        0.4286  1.0000  0.0832  0.7084;
                        0.5714  1.0000  0.4447  0.1001;
                        0.7143  0.5776  0.8360  0.4458;
                        0.8571  0.9035  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'copper2'       [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.2500  0.2651  0.2426  0.2485;
                        0.5000  0.6660  0.4399  0.3738;
                        0.7500  0.8118  0.7590  0.5417;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'dusk'          [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.0570  0.0000  0.0000  0.5000;
                        0.3505  0.0000  0.5000  0.5000;
                        0.5000  0.5000  0.5000  0.5000;
                        0.6495  1.0000  0.5000  0.5000;
                        0.9430  1.0000  1.0000  0.5000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'earth'         [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.0714  0.0000  0.1104  0.0583;
                        0.1429  0.1661  0.1540  0.0248;
                        0.2143  0.1085  0.2848  0.1286;
                        0.2857  0.2643  0.3339  0.0939;
                        0.3571  0.2653  0.4381  0.1808;
                        0.4286  0.3178  0.5053  0.3239;
                        0.5000  0.4858  0.5380  0.3413;
                        0.5714  0.6005  0.5748  0.4776;
                        0.6429  0.5698  0.6803  0.6415;
                        0.7143  0.5639  0.7929  0.7040;
                        0.7857  0.6700  0.8626  0.6931;
                        0.8571  0.8552  0.8967  0.6585;
                        0.9286  1.0000  0.9210  0.7803;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'hicontrast'    [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.1140  0.0000  0.0000  1.0000;
                        0.2990  1.0000  0.0000  0.0000;
                        0.4130  1.0000  0.0000  1.0000;
                        0.5870  0.0000  1.0000  0.0000;
                        0.7010  0.0000  1.0000  1.0000;
                        0.8860  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'hsv2'          [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.1667  0.5000  0.0000  0.5000;
                        0.3333  0.0000  0.0000  0.9000;
                        0.5000  0.0000  1.0000  1.0000;
                        0.6667  0.0000  1.0000  0.0000;
                        0.8333  1.0000  1.0000  0.0000;
                        1.0000  1.0000  0.0000  0.0000]; ...
    'pastel'        [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.1429  0.4709  0.0000  0.0180;
                        0.2857  0.0000  0.3557  0.6747;
                        0.4286  0.8422  0.1356  0.8525;
                        0.5714  0.4688  0.6753  0.3057;
                        0.7143  1.0000  0.6893  0.0934;
                        0.8571  0.9035  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'pink2'         [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.0714  0.0455  0.0635  0.1801;
                        0.1429  0.2425  0.0873  0.1677;
                        0.2143  0.2089  0.2092  0.2546;
                        0.2857  0.3111  0.2841  0.2274;
                        0.3571  0.4785  0.3137  0.2624;
                        0.4286  0.5781  0.3580  0.3997;
                        0.5000  0.5778  0.4510  0.5483;
                        0.5714  0.5650  0.5682  0.6047;
                        0.6429  0.6803  0.6375  0.5722;
                        0.7143  0.8454  0.6725  0.5855;
                        0.7857  0.9801  0.7032  0.7007;
                        0.8571  1.0000  0.7777  0.8915;
                        0.9286  0.9645  0.8964  1.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'sepia'         [0.0000  0.0000  0.0000  0.0000;  % FEX#23342
                        0.0500  0.1000  0.0500  0.0000;
                        0.9000  1.0000  0.9000  0.8000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'temp'          [0.0000  0.1420  0.0000  0.8500;  % FEX#23342
                        0.0588  0.0970  0.1120  0.9700;
                        0.1176  0.1600  0.3420  1.0000;
                        0.1765  0.2400  0.5310  1.0000;
                        0.2353  0.3400  0.6920  1.0000;
                        0.2941  0.4600  0.8290  1.0000;
                        0.3529  0.6000  0.9200  1.0000;
                        0.4118  0.7400  0.9780  1.0000;
                        0.4706  0.9200  1.0000  1.0000;
                        0.5294  1.0000  1.0000  0.9200;
                        0.5882  1.0000  0.9480  0.7400;
                        0.6471  1.0000  0.8400  0.6000;
                        0.7059  1.0000  0.6760  0.4600;
                        0.7647  1.0000  0.4720  0.3400;
                        0.8235  1.0000  0.2400  0.2400;
                        0.8824  0.9700  0.1550  0.2100;
                        0.9412  0.8500  0.0850  0.1870;
                        1.0000  0.6500  0.0000  0.1300]; ...
    % Colormap name      Value   Red     Green   Blue
    'cold'          [0.0000  0.0000  0.0000  0.0000;  % FEX#23865
                        0.2500  0.0000  0.0000  1.0000;
                        0.6500  0.0000  1.0000  1.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'fireice'       [0.0000  0.5000  1.0000  1.0000;  % FEX#24870
                        0.1400  0.0000  1.0000  1.0000;
                        0.3200  0.0000  0.0000  1.0000;
                        0.5000  0.0000  0.0000  0.0000;
                        0.6800  1.0000  0.0000  0.0000;
                        0.8600  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  0.5000]; ...
    'fireicedark'   [0.0000  0.3500  1.0000  0.8700;  % FEX#24870-based
                        0.0588  0.1500  0.9150  0.8130;
                        0.1176  0.0300  0.8450  0.7900;
                        0.1765  0.0000  0.7600  0.7600;
                        0.2353  0.0000  0.5280  0.6600;
                        0.2941  0.0000  0.3240  0.5400;
                        0.3529  0.0000  0.1600  0.4000;
                        0.4118  0.0000  0.0520  0.2600;
                        0.4706  0.0000  0.0000  0.0800;
                        0.5294  0.0800  0.0000  0.0000;
                        0.5882  0.2600  0.0220  0.0000;
                        0.6471  0.4000  0.0800  0.0000;
                        0.7059  0.5400  0.1710  0.0000;
                        0.7647  0.6600  0.3080  0.0000;
                        0.8235  0.7600  0.4690  0.0000;
                        0.8824  0.8400  0.6580  0.0000;
                        0.9412  0.9030  0.8880  0.0300;
                        1.0000  0.8580  1.0000  0.1500]; ...
    'Topographic'   [0.0000  0.0000  0.0000  0.2000;
                        0.0500  0.0000  0.0000  0.6600;
                        0.1700  0.3300  0.6600  1.0000;
                        0.2200  0.1500  0.5000  0.0000;
                        0.3500  0.2500  0.6000  0.1000;
                        0.5700  0.5000  0.9000  0.4000;
                        0.7100  0.9500  0.9000  0.4000;
                        0.7400  0.9500  0.9000  0.3500;
                        0.8600  0.9500  0.7000  0.2000;
                        0.9500  0.6500  0.5000  0.0500;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'Royal'         [0.0000  0.0000  0.0000  0.0000;
                        0.0100  0.2500  0.0000  0.3200;
                        0.2500  0.4700  0.0000  0.6600;
                        0.5000  1.0000  1.0000  1.0000;
                        0.7500  1.0000  1.0000  0.0000;
                        1.0000  0.2500  0.0000  0.3200]; ...
    'RoyalGold'     [0.0000  0.0000  0.0000  0.0000;
                        0.0100  0.2500  0.0000  0.3200;
                        0.2500  0.4700  0.0000  0.6600;
                        0.5000  1.0000  1.0000  0.0000;  % 0.75    1.00    1.00    0.00;      ...
                        1.0000  1.0000  1.0000  1.0000]; ...
    'RoyalGoldDark' [0.0000  0.0000  0.0000  0.0000;
                        0.0100  0.2500  0.0000  0.3200;
                        0.2500  0.4700  0.0000  0.6600;
                        0.5000  0.7500  0.7500  0.0000;
                        0.7500  1.0000  1.0000  0.0000;  % 0.75    1.00    1.00    0.00;      ...
                        1.0000  1.0000  1.0000  1.0000]; ...
    'FCPM_001'      [0.0000  0.0000  0.0000  0.0000;
                        0.2000  0.0000  0.0000  1.0000;
                        0.5000  0.0000  1.0000  0.0000;
                        0.8000  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'FCPM_002'      [0.0000  0.0000  0.5000  0.0000;
                        0.1000  0.0000  0.0000  1.0000;
                        0.3500  1.0000  0.0000  1.0000;
                        0.6000  1.0000  0.0000  0.0000;
                        0.8000  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'FCPM_LCI'      [0.0000  0.0000  0.0000  0.0000;
                        0.2000  0.0000  1.0000  0.0000;
                        0.4000  0.0000  0.0000  1.0000;
                        0.6000  1.0000  0.0000  0.0000;
                        0.8000  1.0000  1.0000  0.0000;
                        1.0000  1.0000  1.0000  1.0000]; ...
    'krywyrk2'      [0.0000  0.0000  0.0000  0.0000;
                        0.2000  1.0000  0.0000  0.0000;
                        0.4000  1.0000  1.0000  0.0000;
                        0.5000  1.0000  1.0000  1.0000;
                        0.6000  1.0000  1.0000  0.0000;
                        0.8000  1.0000  0.0000  0.0000;
                        1.0000  0.0000  0.0000  0.0000]; ...
    'AFM'           [0.0000	0.2314	0.0000	0.0000
                        0.0039	0.2314	0.0000	0.0000
                        0.0078	0.2314	0.0000	0.0000
                        0.0118	0.2314	0.0000	0.0000
                        0.0157	0.2314	0.0000	0.0000
                        0.0196	0.2314	0.0000	0.0000
                        0.0235	0.2314	0.0000	0.0000
                        0.0275	0.2314	0.0000	0.0000
                        0.0314	0.2314	0.0000	0.0000
                        0.0353	0.2314	0.0000	0.0000
                        0.0392	0.2314	0.0000	0.0000
                        0.0431	0.2314	0.0000	0.0000
                        0.0471	0.2314	0.0000	0.0000
                        0.0510	0.2314	0.0000	0.0000
                        0.0549	0.2314	0.0000	0.0000
                        0.0588	0.2314	0.0000	0.0000
                        0.0627	0.2314	0.0000	0.0000
                        0.0667	0.2314	0.0000	0.0000
                        0.0706	0.2314	0.0000	0.0000
                        0.0745	0.2314	0.0000	0.0000
                        0.0784	0.2314	0.0000	0.0000
                        0.0824	0.2314	0.0000	0.0000
                        0.0863	0.2314	0.0000	0.0000
                        0.0902	0.2314	0.0000	0.0000
                        0.0941	0.2314	0.0000	0.0000
                        0.0980	0.2314	0.0000	0.0000
                        0.1020	0.2314	0.0000	0.0000
                        0.1059	0.2314	0.0000	0.0000
                        0.1098	0.2314	0.0000	0.0000
                        0.1137	0.2314	0.0000	0.0000
                        0.1176	0.2353	0.0000	0.0000
                        0.1216	0.2392	0.0000	0.0000
                        0.1255	0.2431	0.0000	0.0000
                        0.1294	0.2471	0.0000	0.0000
                        0.1333	0.2471	0.0000	0.0000
                        0.1373	0.2549	0.0000	0.0000
                        0.1412	0.2588	0.0000	0.0000
                        0.1451	0.2588	0.0000	0.0000
                        0.1490	0.2627	0.0000	0.0000
                        0.1529	0.2667	0.0000	0.0000
                        0.1569	0.2706	0.0000	0.0000
                        0.1608	0.2745	0.0000	0.0000
                        0.1647	0.2784	0.0000	0.0000
                        0.1686	0.2824	0.0000	0.0000
                        0.1725	0.2863	0.0000	0.0000
                        0.1765	0.2902	0.0000	0.0000
                        0.1804	0.2941	0.0000	0.0000
                        0.1843	0.2941	0.0000	0.0000
                        0.1882	0.2980	0.0000	0.0000
                        0.1922	0.3020	0.0000	0.0000
                        0.1961	0.3059	0.0000	0.0000
                        0.2000	0.3098	0.0000	0.0000
                        0.2039	0.3137	0.0000	0.0000
                        0.2078	0.3176	0.0000	0.0000
                        0.2118	0.3216	0.0000	0.0000
                        0.2157	0.3255	0.0000	0.0000
                        0.2196	0.3294	0.0000	0.0000
                        0.2235	0.3294	0.0000	0.0000
                        0.2275	0.3333	0.0000	0.0000
                        0.2314	0.3412	0.0000	0.0000
                        0.2353	0.3412	0.0000	0.0000
                        0.2392	0.3451	0.0000	0.0000
                        0.2431	0.3490	0.0000	0.0000
                        0.2471	0.3529	0.0000	0.0000
                        0.2510	0.3569	0.0000	0.0000
                        0.2549	0.3569	0.0000	0.0000
                        0.2588	0.3647	0.0000	0.0000
                        0.2627	0.3686	0.0000	0.0000
                        0.2667	0.3686	0.0000	0.0000
                        0.2706	0.3765	0.0000	0.0000
                        0.2745	0.3765	0.0000	0.0000
                        0.2784	0.3804	0.0000	0.0000
                        0.2824	0.3843	0.0000	0.0000
                        0.2863	0.3882	0.0000	0.0000
                        0.2902	0.3922	0.0000	0.0000
                        0.2941	0.3961	0.0000	0.0000
                        0.2980	0.4000	0.0000	0.0000
                        0.3020	0.4039	0.0000	0.0000
                        0.3059	0.4039	0.0000	0.0000
                        0.3098	0.4118	0.0000	0.0000
                        0.3137	0.4118	0.0000	0.0000
                        0.3176	0.4157	0.0000	0.0000
                        0.3216	0.4235	0.0000	0.0000
                        0.3255	0.4235	0.0000	0.0000
                        0.3294	0.4275	0.0000	0.0000
                        0.3333	0.4314	0.0000	0.0000
                        0.3373	0.4353	0.0000	0.0000
                        0.3412	0.4392	0.0000	0.0000
                        0.3451	0.4392	0.0000	0.0000
                        0.3490	0.4471	0.0000	0.0000
                        0.3529	0.4510	0.0000	0.0000
                        0.3569	0.4510	0.0078	0.0000
                        0.3608	0.4588	0.0196	0.0000
                        0.3647	0.4588	0.0275	0.0000
                        0.3686	0.4627	0.0431	0.0000
                        0.3725	0.4667	0.0510	0.0000
                        0.3765	0.4706	0.0627	0.0000
                        0.3804	0.4745	0.0745	0.0000
                        0.3843	0.4784	0.0863	0.0000
                        0.3882	0.4824	0.0980	0.0000
                        0.3922	0.4863	0.1059	0.0000
                        0.3961	0.4863	0.1216	0.0000
                        0.4000	0.4902	0.1294	0.0000
                        0.4039	0.4941	0.1412	0.0000
                        0.4078	0.4980	0.1529	0.0000
                        0.4118	0.5020	0.1647	0.0000
                        0.4157	0.5059	0.1765	0.0000
                        0.4196	0.5098	0.1843	0.0000
                        0.4235	0.5137	0.1961	0.0000
                        0.4275	0.5176	0.2118	0.0000
                        0.4314	0.5216	0.2196	0.0000
                        0.4353	0.5216	0.2314	0.0000
                        0.4392	0.5255	0.2392	0.0000
                        0.4431	0.5333	0.2549	0.0000
                        0.4471	0.5333	0.2667	0.0000
                        0.4510	0.5373	0.2745	0.0000
                        0.4549	0.5412	0.2863	0.0000
                        0.4588	0.5451	0.2980	0.0000
                        0.4627	0.5490	0.3098	0.0000
                        0.4667	0.5529	0.3216	0.0000
                        0.4706	0.5569	0.3294	0.0000
                        0.4745	0.5608	0.3451	0.0000
                        0.4784	0.5608	0.3529	0.0000
                        0.4824	0.5686	0.3647	0.0000
                        0.4863	0.5686	0.3765	0.0000
                        0.4902	0.5725	0.3882	0.0000
                        0.4941	0.5765	0.4000	0.0000
                        0.4980	0.5804	0.4078	0.0000
                        0.5020	0.5843	0.4235	0.0000
                        0.5059	0.5882	0.4314	0.0000
                        0.5098	0.5922	0.4431	0.0000
                        0.5137	0.5961	0.4549	0.0000
                        0.5176	0.5961	0.4667	0.0000
                        0.5216	0.6039	0.4784	0.0000
                        0.5255	0.6039	0.4863	0.0000
                        0.5294	0.6078	0.4980	0.0000
                        0.5333	0.6157	0.5137	0.0000
                        0.5373	0.6157	0.5216	0.0000
                        0.5412	0.6196	0.5333	0.0000
                        0.5451	0.6235	0.5412	0.0000
                        0.5490	0.6275	0.5569	0.0000
                        0.5529	0.6314	0.5686	0.0000
                        0.5569	0.6314	0.5765	0.0000
                        0.5608	0.6392	0.5882	0.0000
                        0.5647	0.6431	0.6000	0.0000
                        0.5686	0.6431	0.6118	0.0000
                        0.5725	0.6510	0.6235	0.0000
                        0.5765	0.6510	0.6314	0.0000
                        0.5804	0.6549	0.6471	0.0000
                        0.5843	0.6588	0.6549	0.0000
                        0.5882	0.6627	0.6667	0.0000
                        0.5922	0.6667	0.6745	0.0000
                        0.5961	0.6706	0.6745	0.0000
                        0.6000	0.6745	0.6745	0.0118
                        0.6039	0.6784	0.6745	0.0196
                        0.6078	0.6784	0.6745	0.0353
                        0.6118	0.6863	0.6745	0.0471
                        0.6157	0.6863	0.6745	0.0549
                        0.6196	0.6902	0.6745	0.0667
                        0.6235	0.6941	0.6745	0.0784
                        0.6275	0.6980	0.6745	0.0902
                        0.6314	0.7020	0.6745	0.0980
                        0.6353	0.7059	0.6745	0.1098
                        0.6392	0.7098	0.6745	0.1255
                        0.6431	0.7137	0.6745	0.1333
                        0.6471	0.7137	0.6745	0.1451
                        0.6510	0.7176	0.6745	0.1529
                        0.6549	0.7255	0.6745	0.1686
                        0.6588	0.7255	0.6745	0.1804
                        0.6627	0.7294	0.6745	0.1882
                        0.6667	0.7333	0.6745	0.2000
                        0.6706	0.7373	0.6745	0.2118
                        0.6745	0.7412	0.6745	0.2235
                        0.6784	0.7451	0.6745	0.2353
                        0.6824	0.7490	0.6745	0.2471
                        0.6863	0.7529	0.6745	0.2588
                        0.6902	0.7529	0.6745	0.2667
                        0.6941	0.7608	0.6745	0.2784
                        0.6980	0.7608	0.6745	0.2902
                        0.7020	0.7647	0.6745	0.3020
                        0.7059	0.7686	0.6745	0.3137
                        0.7098	0.7725	0.6745	0.3216
                        0.7137	0.7765	0.6745	0.3373
                        0.7176	0.7804	0.6745	0.3490
                        0.7216	0.7843	0.6745	0.3569
                        0.7255	0.7882	0.6745	0.3686
                        0.7294	0.7882	0.6745	0.3804
                        0.7333	0.7961	0.6745	0.3922
                        0.7373	0.7961	0.6745	0.4039
                        0.7412	0.8000	0.6745	0.4118
                        0.7451	0.8078	0.6745	0.4275
                        0.7490	0.8078	0.6745	0.4353
                        0.7529	0.8118	0.6745	0.4471
                        0.7569	0.8157	0.6745	0.4549
                        0.7608	0.8196	0.6745	0.4706
                        0.7647	0.8235	0.6745	0.4824
                        0.7686	0.8235	0.6745	0.4902
                        0.7725	0.8314	0.6745	0.5020
                        0.7765	0.8353	0.6745	0.5137
                        0.7804	0.8353	0.6745	0.5255
                        0.7843	0.8431	0.6745	0.5373
                        0.7882	0.8431	0.6745	0.5490
                        0.7922	0.8471	0.6745	0.5608
                        0.7961	0.8510	0.6745	0.5686
                        0.8000	0.8549	0.6745	0.5804
                        0.8039	0.8588	0.6745	0.5922
                        0.8078	0.8627	0.6745	0.6039
                        0.8118	0.8667	0.6745	0.6157
                        0.8157	0.8706	0.6745	0.6235
                        0.8196	0.8706	0.6745	0.6392
                        0.8235	0.8784	0.6745	0.6510
                        0.8275	0.8784	0.6745	0.6588
                        0.8314	0.8863	0.6745	0.6745
                        0.8353	0.8863	0.6745	0.6745
                        0.8392	0.8863	0.6745	0.6745
                        0.8431	0.8863	0.6745	0.6745
                        0.8471	0.8863	0.6745	0.6745
                        0.8510	0.8863	0.6745	0.6745
                        0.8549	0.8863	0.6745	0.6745
                        0.8588	0.8863	0.6745	0.6745
                        0.8627	0.8863	0.6745	0.6745
                        0.8667	0.8863	0.6745	0.6745
                        0.8706	0.8863	0.6745	0.6745
                        0.8745	0.8863	0.6745	0.6745
                        0.8784	0.8863	0.6745	0.6745
                        0.8824	0.8863	0.6745	0.6745
                        0.8863	0.8863	0.6745	0.6745
                        0.8902	0.8863	0.6745	0.6745
                        0.8941	0.8863	0.6745	0.6745
                        0.8980	0.8863	0.6745	0.6745
                        0.9020	0.8863	0.6745	0.6745
                        0.9059	0.8863	0.6745	0.6745
                        0.9098	0.8863	0.6745	0.6745
                        0.9137	0.8863	0.6745	0.6745
                        0.9176	0.8863	0.6745	0.6745
                        0.9216	0.8863	0.6745	0.6745
                        0.9255	0.8863	0.6745	0.6745
                        0.9294	0.8863	0.6745	0.6745
                        0.9333	0.8863	0.6745	0.6745
                        0.9373	0.8863	0.6745	0.6745
                        0.9412	0.9961	0.9961	0.9961
                        0.9451	0.9961	0.0000	0.0000
                        0.9490	0.0000	0.9961	0.0000
                        0.9529	0.0000	0.0000	0.0000
                        0.9569	0.4588	0.8314	0.0431
                        0.9608	0.5176	0.7216	0.7922
                        0.9647	0.3647	0.3569	0.6275
                        0.9686	0.5137	0.8510	0.9020
                        0.9725	0.9961	0.0000	0.0000
                        0.9765	0.0000	0.9961	0.9961
                        0.9804	0.0000	0.9961	0.0000
                        0.9843	0.9961	0.0000	0.9961
                        0.9882	0.0000	0.0000	0.9961
                        0.9922	0.9961	0.9961	0.0000
                        0.9961	0.9961	0.9961	0.9961
                        1.0000	0.0000	0.0000	0.0000]; 	};

if ischar(command)
    switch lower(command)

        case 'addcolormapcontrols'
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                if all(ishandle(hh))
                    warning('AdvancedColormap:ColormapControlsAlreadyPresent', 'Can not add colormap controls: they are already present in current figure.');
                    return;
                else
                    delete(hh(ishandle(hh)));
                    rmappdata(gcf, 'hColormapControls')
                end
            end
            ButtonHeit = 17;
            ButtonWidt = 113;
            ButtonWidt = 77;
            ButtonStep = 1;
            ButtonMarg = 5;
            DX = 0;
            DY = ButtonHeit + ButtonStep;
            sm = {'Style', 'popupmenu'};
            st = {'Style', 'pushbutton'};
            s = 'String';
            up = {'Unit', 'pixels'};
            p = 'Position';
            pp = '[ButtonMarg+DX*bi ButtonMarg+DY*bi ButtonWidt ButtonHeit]';
            pp2 = '[ButtonMarg+DX*bi ButtonMarg+DY*bi ButtonWidt*2 ButtonHeit]';
            t = 'Tag';
            cb = 'CallBack';
            % cbc = 'v=get(gcbo,''Value'');s=get(gcbo,''String'');n=s{v};m=''linear'';if isappdata(gcf,''hColormapControls''),h=getappdata(gcf,''hColormapControls'');s=get(h(2),''String'');v=get(h(2),''Value'');m=s{v};end;AdvancedColormap(n,[],[],m);';
            cbc = 'v=get(gcbo,''Value'');s=get(gcbo,''String'');AdvancedColormap(s{v});';

            hh = [];
            bi = -1;
            bi = bi + 1; h = uicontrol(gcf, sm{:}, s, AdvancedColormap('GetSupportedColormaps'),  up{:}, p, eval(pp), cb, cbc);                    hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Reverse',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''Reverse'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Invert',          up{:}, p, eval(pp), cb, 'AdvancedColormap(''Invert'');');                 hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Shift ^',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''ShiftDown'');');              hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Shift v',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''ShiftUp'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'RGB>RBG',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''RGB>RBG'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'RGB>BRG',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''RGB>BRG'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'RGB>GRB',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''RGB>GRB'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'RGB>BGR',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''RGB>BGR'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'RGB>GBR',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''RGB>GBR'');');                hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Darken ++',       up{:}, p, eval(pp), cb, 'AdvancedColormap(''Darken'',0.5);');             hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Darken +',        up{:}, p, eval(pp), cb, 'AdvancedColormap(''Darken'');');                 hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Brighten +',      up{:}, p, eval(pp), cb, 'AdvancedColormap(''Brighten'');');               hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Brighten ++',     up{:}, p, eval(pp), cb, 'AdvancedColormap(''Brighten'',0.5);');           hh = [hh h];
            % bi=bi+2; h = uicontrol(gcf,st{:}, s,'Plot cmap',       up{:}, p,eval(pp), cb,'cm=colormap;[r,c]=size(cm);figure(''Name'',''Colormap RGB plot'',''NumberTitle'',''off'',''WindowStyle'',''modal'');k=(0:(r-1))/(r-1);plot(k,cm(:,1),''r-'',k,cm(:,2),''g-'',k,cm(:,3),''b-'', ''LineWidth'',2);xlim([0 1]);ylim([0 1]);');   hh = [ hh h ];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Plot cmap',       up{:}, p, eval(pp), cb, 'cm=colormap;cn=AdvancedColormap(''GetCurrentColormapString'');[r,c]=size(cm);gm=rgb2gray(cm);figure(''Color'',''w'',''Name'',cn,''Units'',''Normalized'',''Position'',[0.2 0.4 0.6 0.2],''NumberTitle'',''off'',''WindowStyle'',''normal'',''ToolBar'',''none'');k=(0:(r-1))/(r-1);plot(k,cm(:,1),''r-'',k,cm(:,2),''g-'',k,cm(:,3),''b-'',k,gm(:,1),''k-'', ''LineWidth'',2);xlim([0 1]);ylim([0 1]);title(cn,''Interpreter'',''none'');');   hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Animate v',       up{:}, p, eval(pp), cb, 'm=colormap;[r,c]=size(m);for k=1:r,AdvancedColormap(''ShiftDown'');drawnow;end;');    hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Animate ^',       up{:}, p, eval(pp), cb, 'm=colormap;[r,c]=size(m);for k=1:r,AdvancedColormap(''ShiftUp'');drawnow;end;');      hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'UniGray',         up{:}, p, eval(pp), cb, 'AdvancedColormap(''MakeUniformByGrayValue'');'); hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Hide controls',   up{:}, p, eval(pp), cb, 'AdvancedColormap(''HideColormapControls'');');   hh = [hh h];
            bi = bi + 1; h = uicontrol(gcf, st{:}, s, 'Delete controls', up{:}, p, eval(pp), cb, 'AdvancedColormap(''DeleteColormapControls'');'); hh = [hh h];
            setappdata(gcf, 'hColormapControls', hh);
            if nargout > 0
                map = hh;
            end
            return;

        case 'showcolormapcontrols'
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                set(hh, 'Visible', 'on');
            end
            if nargout > 0
                map = hh;
            end
            return;

        case 'hidecolormapcontrols'
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                set(hh, 'Visible', 'off');
            end
            if nargout > 0
                map = hh;
            end
            return;

        case 'togglecolormapcontrols'
            OnOff = {'off' 'on'};
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                LL = length(hh);
                for i = 1:LL
                    OnOffIdx = sum(strcmpi(get(hh(i), 'Visible'), OnOff) .* (1:2));
                    set(hh(i), 'Visible', OnOff{3 - OnOffIdx});
                end
            end
            return;

        case 'deletecolormapcontrols'
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                delete(hh);
                rmappdata(gcf, 'hColormapControls')
            end
            return;

        case 'getsupportedcolormaps'
            % we are asked about supported colormaps
            map = {MatLabColorMapNames{:} CmapsData{:, 1} AutoGenCMapsExamples{:}}';
            return;

        case 'showsupportedcolormaps'
            % we are asked to show supported colormaps
            % maps        = { MatLabColorMapNames{:} CmapsData{:,1} AutoGenCMapsExamples{:} }';
            maps = AdvancedColormap('getsupportedcolormaps');
            NMaps = length(maps);
            % NMaps       = 10;
            % RowsPerMap  = 5;
            RowsPerMap = 15;
            Img = ones(NMaps * RowsPerMap, 256, 3);
            ImgSpc = ones(size(Img).*[1 0 1] + [0 13 0]);
            if ~isempty(varargin)
                if strcmpi(varargin{1}, 'OnWhite')
                elseif  strcmpi(varargin{1}, 'OnBlack')
                    Img = zeros(NMaps * RowsPerMap, 256, 3);
                    ImgSpc = zeros(size(Img).*[1 0 1] + [0 13 0]);
                end
            end

            for k = 1:NMaps
                m = AdvancedColormap(maps{k}, 256);
                % return;
                r0 = (k - 1) * RowsPerMap + 1;
                Img(r0, :, 1) = m(:, 1);
                Img(r0, :, 2) = m(:, 2);
                Img(r0, :, 3) = m(:, 3);
                for r = 1:RowsPerMap - 2
                    Img(r0 + r, :, :) = Img(r0, :, :);
                end
            end
            ImgGray(:, :, 1) = rgb2gray(Img);
            ImgGray(:, :, 2) = ImgGray(:, :, 1);
            ImgGray(:, :, 3) = ImgGray(:, :, 1);
            Img = [Img ImgSpc ImgGray];

            if nargout > 0
                map = Img;
            else
                figure;
                imshow(Img)
                title(['RGB' repmat(' ', 1, 64) 'Gray']);
            end
            return;

        case 'getcurrentcolormapstring'
            map = '';
            if isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                str = get(hh(1), 'String');
                idx = get(hh(1), 'Value');
                map = str{idx};
            end
            return;

        case 'reverse'
            % we are asked to reverse current colormap
            CMap = flipud(colormap);
            SaveCurrentColormapString('');

        case 'invert'
            % we are asked to invert current colormap
            CMap = 1 - colormap;
            SaveCurrentColormapString('');

        case 'shiftup'
            % we are asked to shift current colormap up
            CMap = colormap;
            CMap = [CMap(end, :); CMap(1:end - 1, :)];
            SaveCurrentColormapString('');

        case 'shiftdown'
            % we are asked to shift current colormap down
            CMap = colormap;
            CMap = [CMap(2:end, :); CMap(1, :)];
            SaveCurrentColormapString('');

        case 'rgb>rbg'
            CMap = colormap;
            CMap = [CMap(:, 1) CMap(:, 3) CMap(:, 2)];
            SaveCurrentColormapString('');

        case 'rgb>brg'  % shift right
            CMap = colormap;
            CMap = [CMap(:, 3) CMap(:, 1) CMap(:, 2)];
            SaveCurrentColormapString('');

        case 'rgb>grb'
            CMap = colormap;
            CMap = [CMap(:, 2) CMap(:, 1) CMap(:, 3)];
            SaveCurrentColormapString('');

        case 'rgb>bgr'
            CMap = colormap;
            CMap = [CMap(:, 3) CMap(:, 2) CMap(:, 1)];
            SaveCurrentColormapString('');

        case 'rgb>gbr'  % shift left
            CMap = colormap;
            CMap = [CMap(:, 2) CMap(:, 3) CMap(:, 1)];
            SaveCurrentColormapString('');

        case {'brighten', 'darken'}
            Amount = 0.1;
            if nargin > 1
                if (isreal(varargin{1}) && isscalar(varargin{1}))
                    Amount = varargin{1};
                end
            end
            % we are asked to brighten or darken current colormap
            % Amount = GetParameter( 'Amount',           varargin,     0.1   );
            if Amount < -1
                % warning('AdvColormap:BrightenRangeWarning','Brightening amount can not be less than -1. Performing brightening by -1.');
                Amount = -1;
            end;
            if Amount > 1
                % warning('AdvColormap:BrightenRangeWarning','Brightening amount can not be greater than 1. Performing brightening by 1.');
                Amount = 1;
            end;
            if strcmpi(command, 'darken')
                Amount = -Amount;
            end
            CMap = brighten(colormap, Amount);
            % colormap(CMap);
            SaveCurrentColormapString('');

        case 'makeuniformbygrayvalue'
            CurrentColormapName = GetSavedCurrentColormapString;
            LastColormapName = GetSavedLastColormapString;

            ColormapName = [];
            if isempty(CurrentColormapName)
                % Colormap was modified by one of the ADVANCEDCOLORMAP commands
                if isempty(LastColormapName)
                    % User performed one of the ADVANCEDCOLORMAP commands more than once, so
                    % previous colormap is lost.
                    % If there are at least one figure and it contains ADVANCEDCOLORMAP controls,
                    % then we can check popupmenu for last used colormap
                    if WeHaveOpenFigure
                        if isappdata(gcf, 'hColormapControls')
                            hh = getappdata(gcf, 'hColormapControls');
                            str = get(hh(1), 'String');
                            idx = get(hh(1), 'Value');
                            LastColormapName = str{idx};
                        end
                    end
                end
                if isempty(LastColormapName)
                    uiwait(warndlg({'Can not determine current colormap name!', 'Usually this happens after performing commands like BRIGHTEN or DARKEN.', 'Select proper colormap and try again.'}, mfilename, 'modal'));
                else
                    button = questdlg({'Can not determine current colormap name!', ...
                                            'Usually this happens after performing commands like BRIGHTEN or DARKEN.', ...
                                            sprintf('But last used colormap was "%s"', LastColormapName), ...
                                            'Should I use it?'}, ...
                                            mfilename, 'Yes', 'No', 'Yes');
                    if strcmpi(button, 'yes')
                        ColormapName = LastColormapName;
                    end
                end
            else
                ColormapName = CurrentColormapName;
            end
            Midx = sum(strcmpi(ColormapName, MatLabColorMapNames) .* (1:length(MatLabColorMapNames)));
            if Midx
                uiwait(warndlg({'Can not unify default matlab colormap!', ''}, mfilename, 'modal'));
                ColormapName = '';
            end
            if ~isempty(ColormapName)
                CurrentColorMap = GetCurrentColorMap;
                CurrentColorMapLen = size(CurrentColorMap, 1);
                [cTab, cPos] = AdvancedColormap(ColormapName, 0);
                cTabLen = length(cPos);
                cTabGray = rgb2gray(cTab);
                GrayVal = cTabGray(:, 1);
                Coeff = ones(size(GrayVal));
                GrayVal1 = cPos;
                %                 GrayVal1            = zeros(size(GrayVal));
                %                 for k=1:cTabLen
                %                     GrayVal1(k) = cPos(k);
                %                 end
                for k = 1:cTabLen
                    if abs(GrayVal1(k) - GrayVal(k)) < eps
                        Coeff(k) = 1;
                    else
                        Coeff(k) = GrayVal1(k) / GrayVal(k);
                    end
                end
                cTabNew = cTab .* repmat(Coeff, 1, 3);
                cTable = [cPos cTabNew];
                % % %                 figure; plot(cPos,GrayVal,'ok-', cPos,GrayVal1,'or-', cPos,Coeff,'ob-');
                % % %                 figure(cf);
                % CMap    = mm;
                [Length, ColorPos, InterpMode] = ParseParameters(varargin, nargin, cTabLen, CurrentColorMapLen, cPos, 'linear');
                CMap = InterpolateCTable(cTable, Length, InterpMode);
            else
                % fprintf('ColorMap Can not determine last colormap source!\n');
                warning('AdvancedColormap:ColorMapDataLost', 'Can not determine last colormap source!');
                map = [];
                return;
            end
            %             return;
            %             [cc,pp] = AdvancedColormap;
            %             mapg    = rgb2gray(cc);
            %             mapg    = mapg(:,1);
            %             figure;
            %             plot(pp,mapg,'ok-');
            %             CMap    = mapg;
            %             SaveCurrentColormapString('');

        case MatLabColorMapNames
            % we are asked to apply or retrieve one of MatLab standard colormaps
            % [Length,tt] = size(colormap);
            [Length, tt] = size(GetCurrentColorMap);
            if nargin > 1
                if (isreal(varargin{1}) && isscalar(varargin{1}))
                    Length = varargin{1};
                end
            end
            Midx = sum(strcmpi(command, MatLabColorMapNames) .* (1:length(MatLabColorMapNames)));
            CMap = eval(sprintf('%s(%d)', MatLabColorMapNames{Midx}, Length));
            if WeHaveOpenFigure && isappdata(gcf, 'hColormapControls')
                hh = getappdata(gcf, 'hColormapControls');
                ss = get(hh(1), 'String');
                vv = get(hh(1), 'Value');
                sidx = sum(strcmpi(command, {ss{:}}') .* (1:length(ss))');
                if (sidx > 0) && (sidx ~= vv)
                    set(hh(1), 'Value', sidx);
                end
            end
            SaveCurrentColormapString(command);

        otherwise
            % we are asked to apply or retrieve either predefined or generated colormap
            % AdvancedColormap(ColorMapString,Length,ColorPositions,InterpolationMode)

            % default parameters
            Length=size(GetCurrentColorMap, 1);
            ColorPos=[];
            InterpMode='linear';

            if nargin > 1
                if (isreal(varargin{1}) && isscalar(varargin{1}))
                    Length=varargin{1};
                end
            end
            if nargin > 2
                if (isreal(varargin{2}) && isvector(varargin{2}))
                    ColorPos=varargin{2};
                end
            end
            if nargin > 3
                if (ischar(varargin{3}) && isvector(varargin{3}))
                    InterpMode=varargin{3};
                end
            end

            % Idx = sum( strcmpi(command,{CmapsData{:,1}}) .* (1:length({CmapsData{:,1}})) );
            Idx=find(strcmpi(command, {CmapsData{:, 1}}));
            if Idx > 0
                % we are asked to apply or retrieve predefined colormap
                CTable=CmapsData{Idx, 2};
            else
                % we are asked to apply or retrieve generated colormap
                if length(command) > 1
                    if IsColormapNameValid(command)
                        CTable=String2CMapData(command, 'ColorPositions', ColorPos);
                    else
                        error('AdvancedColormap:InvalidColormapString', 'Invalid colormap string: "%s"', command);
                    end
                else
                    error('AdvancedColormap:ColormapStringTooShort', 'Colormap string too short: "%s"', command);
                end
            end

            % update colormap controls
            if WeHaveOpenFigure && isappdata(gcf, 'hColormapControls')
                hh=getappdata(gcf, 'hColormapControls');
                ss=get(hh(1), 'String');
                vv=get(hh(1), 'Value');
                sidx=sum(strcmpi(command, {ss{:}}') .* (1:length(ss))');
                if ((sidx > 0) && (sidx ~= vv))
                    set(hh(1), 'Value', sidx);
                end
            end
            CMap=InterpolateCTable(CTable, Length, InterpMode);
            SaveCurrentColormapString(command);
    end
else
    error('AdvancedColormap:CommandNotAString', 'Command MUST be a string!');
end

% Once we are here we have to either return the colormap data or apply it
if nargout > 0
    map=CMap;
    if nargout > 1  % This is a special case
        if exist('CTable', 'var')
            varargout{1}=CTable(:, 1);
        end
    end
else
    % colormap(CMap);

    % Trick was offered here: http://www.mathworks.com/matlabcentral/fileexchange/26026-bipolar-colormap
    if isempty(get(0, 'currentfigure'))
        % no figures are open so far, so we will keep everything quiet
        % fprintf('%s: no figures are open so far, so we will keep everything quiet\n',mfilename);
    else
        % there is an open figure
        colormap(CMap);
    end
end

end

%============================================================================
% This functions checks whether we have at least one open figure or not
%============================================================================
function res=WeHaveOpenFigure
res= ~isempty(get(0, 'currentfigure'));
end

%============================================================================
% This functions returns current colormap
% If no figures are open so far it returns default colormap without opening new one.
%============================================================================
function CurrCMap=GetCurrentColorMap
    if WeHaveOpenFigure
        % there is an open figure
        CurrCMap=get(gcf, 'colormap');
    else
        % no figures are open so far
        CurrCMap=get(0, 'defaultfigurecolormap');
    end
end

%============================================================================
% This functions check wether string is a valid colormap name
%============================================================================
function Result=IsColormapNameValid(s)
Result=all(ismember(s, 'krpoglabsvcmyw '));
% Result = true;
% for k=1:length(s)
%     Result = Result & ~isempty(strfind('krpoglabsvcmyw',s(k)));
%     if ~Result
%         break;
%     end
% end
end

%============================================================================
% This function converts string of characters into valid colormap data
%============================================================================
function res=String2CMapData(s, varargin)
HaveSpaces= ~isempty(strfind(s, ' '));
if HaveSpaces

    cGroups={};
    rem=s;
    while ~isempty(rem)
        [tok, rem]=strtok(rem);
        cGroups{end + 1}=tok;
    end
    LL=length(cGroups);
    pos0=(0:(LL - 1)) / (LL - 1);
    pos=Get_Parameter('ColorPositions',   varargin,   pos0(:));
    if isempty(pos)
        pos=pos0;
    end
    if LL ~= length(pos)
        error('AdvancedColormap:InvalidColorPositionsLength', 'Lengths of ColorPos vector (%d) does not match number of groups (%d) in colormap string "%s"', length(pos), LL, s);
    end
    res=zeros(LL, 4);
    res(:, 1)=pos(:);
    for k=1:LL
        LGroup=length(cGroups{k});
        for p=1:LGroup
            res(k, 2:4)=res(k, 2:4) + Char2RGB(cGroups{k}(p));
        end
        res(k, 2:4)=res(k, 2:4) / LGroup;
    end

else

    LL=length(s);
    pos0=(0:(LL - 1)) / (LL - 1);
    pos=Get_Parameter('ColorPositions',   varargin,   pos0(:));
    if isempty(pos)
        pos=pos0;
    end
    if LL ~= length(pos)
        error('AdvancedColormap:InvalidColorPositionsLength', 'Lengths of ColorPos vector (%d) does not match length (%d) of colormap string "%s"', length(pos), LL, s);
    end
    res=zeros(LL, 4);
    res(:, 1)=pos;
    for k=1:LL
        res(k, 2:4)=Char2RGB(s(k));
    end

end

end

function res=String2CMapData_old(s, varargin)
LL=length(s);
pos0=(0:(LL - 1)) / (LL - 1);
pos=Get_Parameter('ColorPositions',   varargin,   pos0(:));
% InterpMode  = Get_Parameter( 'InterpMode',       varargin,   'linear'    );
res=zeros(LL, 4);
res(:, 1)=pos;
for k=1:LL
    res(k, 2:4)=Char2RGB(s(k));
end
end

%============================================================================
% This function converts COLORSPEC character into RGB triplet
%============================================================================
function res=Char2RGB(c)
% The following colors were used from FEX:20848 "Vivid Colormap"
% and remain here for compatibility
%   p   pink
%   o   orange
%   l   lime green
%   a   aquamarine
%   s   sky blue
%   v   violet
ColorTable=[0.0 0.0 0.0  % k     black
                1.0 0.0 0.0  % r     red
                1.0 0.0 0.5  % p     pink
                1.0 0.5 0.0  % o     orange
                0.0 1.0 0.0  % g     green
                0.5 1.0 0.0  % l     lime green
                0.0 1.0 0.5  % a     aquamarine
                0.0 0.0 1.0  % b     blue
                0.0 0.5 1.0  % s     sky blue
                0.5 0.0 1.0  % v     violet
                0.0 1.0 1.0  % c     cyan
                1.0 0.0 1.0  % m     magenta
                1.0 1.0 0.0  % y     yellow
                1.0 1.0 1.0  % w     white
                ];
ColorCodes='krpoglabsvcmyw';
idx=find(double(ColorCodes) == double(c), 1, 'first');
if idx
    res=ColorTable(idx, :);
else
    error('AdvancedColormap:Char2RGB:UnknownColor', 'Color character MUST be one of the following characters: "%s"! (character "%s" is not)', ColorCodes, c);
end
end

%==============================================================
% res = Get_Parameter(PName,NameValueArray,DefaultValue)
%
% This function looks for parameter named PNAME in NAMEVALUEARRAY cell array of name-value pairs
% and returns its vaule.
% If name is not found, DEFAULTVALUE is returned.
%==============================================================
function res=Get_Parameter(PName, NameValueArray, DefaultValue)
res=DefaultValue;   % in case PName is not present in PNameValArray
for i=1:1:length(NameValueArray)
    if strcmpi(NameValueArray{i}, PName)
        if length(NameValueArray) > i
            res=NameValueArray{i + 1};
            break;
        else
            error('%s: Parameter "%s" present, but its value absent', mfilename, PName);
        end
    end
end
end

function S=GetSavedCurrentColormapString
S='';
if WeHaveOpenFigure
    if isappdata(gcf, 'AdvColormapCCMString')
        S=getappdata(gcf, 'AdvColormapCCMString');
    end
end
end

function S=GetSavedLastColormapString
S='';
if WeHaveOpenFigure
    if isappdata(gcf, 'AdvColormapCCMStringLast')
        S=getappdata(gcf, 'AdvColormapCCMStringLast');
    end
end
end

function SafelySaveCurrentColormapString(S)
if WeHaveOpenFigure
    if ~isappdata(gcf, 'AdvColormapCCMString')
        setappdata(gcf, 'AdvColormapCCMString', S);
    end
end
end

function SaveCurrentColormapString(S)
if WeHaveOpenFigure
    if isappdata(gcf, 'AdvColormapCCMString')
        setappdata(gcf, 'AdvColormapCCMStringLast', getappdata(gcf, 'AdvColormapCCMString'));
    else
        setappdata(gcf, 'AdvColormapCCMStringLast', '');
    end
    setappdata(gcf, 'AdvColormapCCMString', S);
end
end

function CMap=InterpolateCTable(CTable, Length, InterpMode)
[CR, CC]=size(CTable);
if Length < 0
    error('AdvancedColormap:NegativeColormapLength', 'Colormap length can not be negative!');
elseif Length == 0
    CMap=CTable(:, 2:4);
else
    if Length < CR
        Length=CR;
    end
    ii0=0:(CR - 1);     tt0=CTable(:, 1);
    iin=0:(Length - 1); ttn=iin / (Length - 1);
    [x0, y0]=meshgrid(1:3, tt0);
    [xn, yn]=meshgrid(1:3, ttn);
    CMap=interp2(x0, y0, CTable(:, 2:4), xn, yn, InterpMode);  % 'nearest'   'linear'    'spline'    'cubic'
    CMap(CMap < 0)=0;
    CMap(CMap > 1)=1;
    % colormap(CMap);
end
end

function [Length, ColorPos, InterpMode]=ParseParameters(varin, nin, tL, Length, ColorPos, InterpMode)
if nin > 1
    if (isreal(varin{1}) && isscalar(varin{1}))
        Length=varin{1};
    end
end
if nin > 2
    if (isreal(varin{2}) && isvector(varin{2}) && (numel(varin{2}) == tL))
        ColorPos=varin{2};
    end
end
% InterpMode = 'linear';
if nin > 3
    InterpMode='linear';
    if (ischar(varin{3}) && isvector(varin{3}))
        InterpMode=varin{3};
    end
end
end

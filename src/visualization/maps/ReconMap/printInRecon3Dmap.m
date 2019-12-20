function printInRecon3Dmap(rxnList, colorValues, outputDir)
% This function generates a TXT file that can be integrated in the VMH
% database (vmh.life) to overlay certain reactions 
%
% USAGE:
%
%    printInRecon3Dmap(rxnList, output, values)
%
% INPUTS:
%    rxnList:                 List of rxn to be higligted
%    colorValues:             Numerical value for each reaction (to assign 
%                             different colors (default: 0
%    outputDir:               Directory where the file will be created 
%                             (default: current directory)  
%
% OUTPUTS
%    
%    Text file used as an input for the VMH database
%
% .. Author: - German Preciat, November 2019

if nargin < 2 || isempty(colorValues)
    for i = 1:length(rxnList)
        colorValues(i) = 1;
    end
end
if nargin < 3 || isempty(outputDir)
    outputDir = pwd;
end

assert(length(rxnList) == length(colorValues), ...
    'The number of reactions do not match with the number of colorValues');

% define the colors
hex = {'#00008F','#00009F', '#0000AF', '#0000BF', '#0000CF', '#0000DF', ...
    '#0000EF', '#0000FF', '#0010FF', '#0020FF', '#0030FF', '#0040FF', ...
    '#0050FF', '#0060FF', '#0070FF', '#0080FF', '#008FFF', '#009FFF', ...
    '#00AFFF', '#00BFFF', '#00CFFF', '#00DFFF', '#00EFFF', '#00FFFF', ...
    '#10FFEF', '#20FFDF', '#30FFCF', '#40FFBF', '#50FFAF', '#60FF9F', ...
    '#70FF8F', '#80FF80', '#8FFF70', '#9FFF60', '#AFFF50', '#BFFF40', ...
    '#CFFF30', '#DFFF20', '#EFFF10', '#FFFF00', '#FFEF00', '#FFDF00', ...
    '#FFCF00', '#FFBF00', '#FFAF00', '#FF9F00', '#FF8F00', '#FF8000', ...
    '#FF7000', '#FF6000', '#FF5000', '#FF4000', '#FF3000', '#FF2000', ...
    '#FF1000', '#FF0000', '#EF0000', '#DF0000', '#CF0000', '#BF0000', ...
    '#AF0000', '#9F0000', '#8F0000', '#800000'};

hexColor{1, 1} = "RXN";
hexColor{1, 2} = "color";
colorRange = max(colorValues) / 64;
for i = 1:length(colorValues)
    hexColor{i + 1, 1} = rxnList{i};
    color = round(colorValues(i) / colorRange);
    if color > 0
        hexColor{i + 1, 2} = hex{color};
    else
        hexColor{i + 1, 2} = hex{1};
    end 
end
[mlt, nlt] = size(hexColor);

%name	reactionIdentifier	lineWidth	color
for n = 1:nlt - 1
    fid = fopen(['C__fakepath_data4ReconMap3_' num2str(n) '.txt'], 'w');
    fprintf(fid, '%s\t%s\t%s\t%s\n', 'name', 'reactionIdentifier', 'lineWidth', 'color');
    for m = 2:mlt %ignore first row
        %note the R_ prefix
        if ~isequal(hexColor{m, n + 1}, '#000000')            
        fprintf(fid, '%s\t%s%s\t%f4\t%s\n', [], 'R_', strrep(hexColor{m, 1}, '''', ''), 8, strrep(hexColor{m, n + 1}, '''', ''));
        end
    end
end
function [activeProteins, inactiveProteins] = activeProteinList(proteomicsEx, proteomicsGenes, treshold, printLevel)
%
% USAGE:
%   [activeProteins, inactiveProteins] = activeProteinList(proteomicsEx, proteomicsGenes, treshold, printLevel)
%
% INPUTS:
%  proteomicsEx:
%  proteomicsGenes:
%  treshold: 
%  printLevel:
%
% OUTPUTS:
%  activeProteins:
%  inactiveProteins:
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Aga W

if printLevel>2
    figure()
    histogram(proteomicsEx)
    ylim = get(gca, 'ylim');
    hold on
    line([2 2], [ylim(1) ylim(2)], 'color', 'r', 'LineWidth', 2);
    t = text(2, ylim(2) - [ylim(2) * 0.05], 'Threshold');
    t.FontSize = 14;
    hold off
    title('Expression threshold')
    ylabel('Number of proteins')
    xlabel('Logarithmic mean expression value')
end

    activeProteins = proteomicsGenes(proteomicsEx>=treshold);
    inactiveProteins = proteomicsGenes(proteomicsEx>treshold);
end
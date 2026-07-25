function [activeProteins, inactiveProteins] = activeProteinList(proteomicsEx, proteomicsGenes, treshold, printLevel)
% Split a list of proteins into active and inactive sets using an expression threshold
%
% USAGE:
%
%    [activeProteins, inactiveProteins] = activeProteinList(proteomicsEx, proteomicsGenes, treshold, printLevel)
%
% INPUTS:
%    proteomicsEx:    logarithmic mean proteomic expression value for each protein
%    proteomicsGenes:    gene identifiers corresponding to each expression value
%    treshold:    expression threshold used to classify a protein as active
%    printLevel:    set greater than 2 to plot a histogram of the expression values
%
% OUTPUTS:
%    activeProteins:    genes whose expression is at or above the threshold
%    inactiveProteins:    genes classified as inactive
%
% EXAMPLE:
%
% NOTE:
%
% .. Author(s): Aga W

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
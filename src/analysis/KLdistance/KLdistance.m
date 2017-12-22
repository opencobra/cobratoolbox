function dist = KLdistance(data1, data2, num_iter, parameters)
% This function calculates the Kullback-Leibler Distance (KLD) between two
% distributions then runs a certain number of iterations where the labels
% are randomised and the KLD is calculated. Then, the distribution of the
% Disergences is plotted.

% USAGE:
%
%    dist = KLdistance(data1, data2, num_iter, parameters);
%
% INPUTS:
%     data1:        n x m matrix where each column reprensents the values
%                   of a certain parameter for one of the populations (e.g. controls)
%     data2:        same as data1 for the population to compare
%     num_iter:     number of randomisations
%     parameters:   a cell array of strings containing the name of each
%                   parameter
%
% OUTPUTS:
%     dist:         an array of KL Distances at each iteration
%
% .. Author: Siham Hachi 29/06/2017

data1(:, end + 1) = zeros(1, size(data1, 1));
data2(:, end + 1) = ones(1, size(data2, 1));
data = [data1; data2];

data_shuff = data;

for jj = 1: size(data, 2) - 1

    dataAll = data;

    [fWT, ~] = ksdensity(dataAll(1:length(find(dataAll(:, end) == 0)), jj));
    [fMUT, ~] = ksdensity(dataAll(length(find(dataAll(:, end) == 0)) + 1:end, jj));
    dist(1) = KLDis(fMUT, fWT);

    % randomly shuffle
    for ii = 2: num_iter
        % randomly permute
        data_shuff(:, end) = dataAll(randperm(size(dataAll, 1)), end);

        % find WT and MUT after shuffling
        data2_WT = data_shuff(find(data_shuff(:, end) == 0), :);
        data2_MUT = data_shuff(find(data_shuff(:, end) == 1), :);

        [fWT, ~] = ksdensity(data2_WT(:, jj));
        [fMUT, ~] = ksdensity(data2_MUT(:, jj));

        dist(ii) = KLDis(fMUT, fWT);
    end

    figure, h = histogram(dist, 'Normalization', 'probability', 'FaceColor', 'k', ...
                          'EdgeColor', 'k');
    maxProb = max(h.Values);
    hold on, stem(dist(1), maxProb, 'LineStyle', '-.', 'Color', 'red', 'LineWidth', 3)
    set(gca, 'FontSize', 30, 'FontWeight', 'bold', 'linewidth', 3)
    xlabel('KL Distance')
    ylabel('Probability')
    title(parameters{(jj)})
    box off
end

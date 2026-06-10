function [discretized, scaledExpression] = discretizeFPKM(fpkm, colnames, figflag, pathFigures,fileFormat)
%   The function discretizes gene expression data (FPKM values) into three categories:
%   expressed, not expressed, and unknown, based on a zFPKM transformation and
%   half-Gaussian density fitting.
%
% USAGE:
%
%   [discretized, scaledExpression] = discretizeFPKM(fpkm, colnames, figflag, pathFigures)
%
% INPUTS:
%   fpkm:              m x n matrix or table of FPKM expression values (genes x samples)
%   colnames:          1 x n cell array of sample names
%   figflag:           optional, flag to plot and save figures (default: 0)
%   pathFigures:       optional, path to save figures (default: current folder)
%   fileFormat:        optional, file format you want to store the figure as
%
% OUTPUTS:
%   discretized:       m x n matrix of discretized values
%                      *  1 : expressed
%                      *  0 : unknown
%                      * -1 : not expressed
%   scaledExpression:  scaled data after zFPKM transformation
%
% .. Authors:
%       - Maria Pires Pacheco, 2016, University of Luxembourg
%       - Leonie Thomas, 2026, University of Luxembourg, fixing thresholding when the data is left skewed

%% Discretize_Data
% script adapted from (c) Dr. Maria Pires Pacheco 2016

if nargin < 3
    figflag = 0;
end
if nargin < 4
    pathFigures = '';
end
if nargin < 5
    fileFormat = '.png';
end


%% Convert table input to array if needed
if istable(fpkm)
    fpkm = table2array(fpkm);
end

%% log2-transform the data
signal = log2(fpkm);
signal(isinf(signal)) = -1e6;
scaledExpression = [];

%% Discretize the data by creating half-gaussians
for j = 1:size(fpkm, 2) % for each sample
    signal_sample = signal(:, j);
    data_keep = fpkm(:, j);
    signal_sample = signal_sample(signal_sample > -1e6);
    
    % Histogram
    if figflag
        figure
        % create folder to save Figures if doesnt exist
        if ~strcmp(pathFigures, '')
            if ~exist([pathFigures, 'Figures/Discretization/'], 'dir')
                mkdir([pathFigures, 'Figures/Discretization/'])
            end
        else
            if ~exist('Figures/Discretization/', 'dir')
                mkdir('Figures/Discretization/')
            end
        end
        
        histogram((signal_sample), 100);
        ylabel('abundance');
        xlabel('log2(FPKM)');
        title({'Histogram of abundance', ['Sample: ', colnames{j}]}, 'Interpreter', 'none');
        if strcmp(pathFigures, '')
            saveas(gcf, ['Figures\Discretization\histogram_', colnames{j}, fileFormat])
        else
            saveas(gcf,[pathFigures,'Figures\Discretization\histogram_', colnames{j},fileFormat])
        end
    end
    
    % Density plot
    [probability_estimate, xi] = ksdensity((signal_sample));
    if figflag
        figure; 
        hold on;
        plot(xi, probability_estimate, '-k', 'LineWidth', 2);
        ylabel('Density'); xlabel('log2(FPKM)');
        title({'Density plot', ['Sample: ', colnames{j}]}, 'Interpreter', 'none');
        legend({'Signal'}, 'Location', 'best')
        saveas(gcf, [pathFigures, 'Figures\Discretization\density_', colnames{j}, fileFormat]);
    end

    %% =========================
    %% METHOD 1 (RIGHT-SIDE PEAK)
    peak_idx_r = find(probability_estimate == max(probability_estimate(50:100)));

    max_r_side = probability_estimate(peak_idx_r:end);
    max_l_side = flip(max_r_side);
    hybrid_r = [max_l_side(1:end-1), max_r_side];

    hybrid_curve_r = zeros(numel(probability_estimate),1);
    if numel(hybrid_r)> numel(probability_estimate)
        hybrid_curve_r(end+1-numel(hybrid_r(end-100+1:end)):end)=hybrid_r(end-100+1:end);
        x = xi;
    else
        hybrid_curve_r(end-numel(hybrid_r)+1:end) = hybrid_r;
        x = xi;
    end

    rest_curve_r = probability_estimate - hybrid_curve_r';
    rest_curve_r(rest_curve_r<0.0001)=0;
    
    if figflag
        plot(x, hybrid_curve_r, 'b--', 'LineWidth', 2);
        legend({'Signal','hybrid curve right'}, 'Location', 'best')
        title({'Density plot with hybrid curves', ['Sample: ', colnames{j}]}, 'Interpreter', 'none');
    end
    
    if figflag
        plot(xi, rest_curve_r, 'r--', 'LineWidth', 2);
        legend({'Signal', 'hybrid curve right', 'hybrid curve left'}, 'Location', 'best')
        saveas(gcf, [pathFigures,'Figures\Discretization\density_maxfit_', colnames{j}, fileFormat]);
    end

    %% fit half-Gaussian curves to right and left curves
    [fit_r_r, ~] = createFitR(xi, hybrid_curve_r);
    [fit_l_r, ~] = createFitL(xi, rest_curve_r);
    
    if figflag
        plot(fit_r_r, 'b');
        plot(fit_l_r, 'g');
        title({'Density plot with fitted curves', ['Sample: ', colnames{j}]}, 'Interpreter','none');
        ylabel('Density');
        xlabel('log2(FPKM)');
        legend({'Signal', 'hybrid curve right', 'hybrid curve left', 'fitted curve right', 'fitted curve left'}, 'Location','best')
        saveas(gcf, [pathFigures, 'Figures\Discretization\density_fitted_', colnames{j}, fileFormat]);
        close all;
    end
    
    %% zFPKM transform the data and plot the density
    
    sigma1_r = fit_r_r.c1/sqrt(2);
    mu1_r = fit_r_r.b1;
    mu2_r = fit_l_r.b1;
    ue_r = max(-3,(mu2_r-mu1_r)/sigma1_r);

    %% =========================
    %% METHOD 2 (GLOBAL PEAK)
    peak_idx_g = find(probability_estimate == max(probability_estimate));

    max_r_side = probability_estimate(peak_idx_g:end);
    max_l_side = flip(max_r_side);
    hybrid_g = [max_l_side(1:end-1), max_r_side];

    hybrid_curve_g = zeros(numel(probability_estimate),1);
    if numel(hybrid_g)> numel(probability_estimate)
        hybrid_curve_g(end+1-numel(hybrid_g(end-100+1:end)):end)=hybrid_g(end-100+1:end);
    else
        hybrid_curve_g(end-numel(hybrid_g)+1:end) = hybrid_g;
    end

    rest_curve_g = probability_estimate - hybrid_curve_g';
    rest_curve_g(rest_curve_g<0.0001)=0;

    [fit_r_g, ~] = createFitR(xi, hybrid_curve_g);
    [fit_l_g, ~] = createFitL(xi, rest_curve_g);

    sigma1_g = fit_r_g.c1/sqrt(2);
    mu1_g = fit_r_g.b1;
    mu2_g = fit_l_g.b1;
    ue_g = max(-3,(mu2_g-mu1_g)/sigma1_g);

    %% SELECT METHOD
    if ue_r < 0
        mu1 = mu1_r;
        mu2 = mu2_r;
        sigma1 = sigma1_r;
        ue = ue_r;
    else
        mu1 = mu1_g;
        mu2 = mu2_g;
        sigma1 = sigma1_g;
        ue = ue_g;
    end
    
    zFPKM = (signal_sample - mu1)/sigma1;
    [yFPKM, xFPKM] = ksdensity(zFPKM);
    
    %% do the analysis
    
    zFPKM = (signal(:, j) - mu1)/sigma1; %transform sample into zFPKM
    
    if figflag
        plot([mu1, mu1], [0, max(probability_estimate)])
        plot([mu2, mu2], [0, max(probability_estimate)])
        legend({'Signal', 'hybrid curve right', 'hybrid curve left',...
            'fitted curve right', 'fitted curve left',...
            ['expression threshold = ', num2str(mu1)], ['inexpression threshold = ', num2str(mu2)]}, 'Location', 'best')
    end
    
    discretized = zFPKM;
    
    e = 0;
    
    if figflag
        figure;
        hold on;
        plot(xFPKM, yFPKM, '-k', 'LineWidth', 2);
        xlabel('zFPKM');
        ylabel('density');
        line([0 0], [0.0 0.3],'color', [0, 1, 0])
        line([ue ue], [0.0 0.3],'color', [0, 1, 1]);
        legend({'zFPKM data', 'expression threshold', 'inexpression threshold'}, 'Location', 'best')
        title({'Expression thresholds', ['Sample: ', colnames{j}], ['inexpression threshold = ', num2str(ue)]}, 'Interpreter', 'none');
        
        saveas(gcf, [pathFigures, 'Figures\Discretization\zFPKM_', colnames{j}, fileFormat]);
        close all;
    end

    if ue_g > 0 
        disp("Your distribution was left skewed.")
    end
    
    zFPKM = reshape(zFPKM, size(data_keep, 1), size(data_keep, 2));
    scaledExpression = [scaledExpression, zFPKM];
    
    exp_threshold   = e;
    unexp_threshold = ue;
    
    expressed = find(discretized >= exp_threshold);
    not_exp = find(discretized <= unexp_threshold);
    unknown = find(discretized < exp_threshold & discretized > unexp_threshold);
    
    discretized(unknown) = 0;
    discretized(not_exp) = -1;
    discretized(expressed) = 1;
    
    discretized = (reshape(discretized, size(data_keep, 1), size(data_keep, 2)));
    discretized_keep(j, :) = discretized';
end

% Combine all samples
discretized = discretized_keep';

%% Density plot for all samples
if figflag
    figure; 
    hold on;
    for j = 1:length(colnames) %for each sample
        signal_sample = signal(:, j);
        signal_sample = signal_sample(exp(signal_sample) > 1e-6);
        
        % Density plot
        [probability_estimate, xi] = ksdensity((signal_sample));
        % plot(xi, probability_estimate, line_col{j}, 'LineWidth', 1); end
        plot(xi, probability_estimate, 'LineWidth', 1);
    end
    
    title({'Density curves for all samples'});
    ylabel('Density'); 
    xlabel('log2(FPKM)');
    % legend(colnames,'interpreter','none','Location','best')
    if strcmp(pathFigures, '')
        saveas(gcf, ['Figures\Discretization\density_all', fileFormat]); 
        close all
    else
        saveas(gcf,[pathFigures,'Figures\Discretization\density_all',fileFormat]); 
        close all
    end
end

%% Subplots for all samples
if figflag
    figure; 
    hold on;
    for j = 1:length(colnames) %for each sample
        signal_sample = signal(:, j);
        signal_sample = signal_sample(exp(signal_sample) > 1e-6);
        
        % Density plot
        [probability_estimate, xi] = ksdensity((signal_sample));
        subplot(5, 6, j)
        % plot(xi, probability_estimate, line_col{j}, 'LineWidth', 1);
        plot(xi, probability_estimate, 'LineWidth', 1);
        title({colnames{j}}, 'interpreter', 'none');
        % ylabel('Density'); 
        % xlabel('log2(FPKM)');
    end
    if strcmp(pathFigures, '')
        saveas(gcf, ['Figures\Discretization\density_plots',fileFormat]); 
        close all
    else
        saveas(gcf, [pathFigures, 'Figures\Discretization\density_plots',fileFormat]); 
        close all
    end
end

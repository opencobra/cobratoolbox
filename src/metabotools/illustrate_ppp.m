function illustrate_ppp(ResultsAllCellLines,mets,path,samples,label,fonts,tol)
% This function generates and saves heatmaps for the results of the function
% performPPP for all sample models.
%
% USAGE:
%
%     illustrate_ppp(ResultsAllCellLines, mets, path, samples, label, fonts, tol)
%
% INPUTS:
%    ResultsAllCellLines:     Result structure
%    mets:                    Metabolites that were tested in the phase plane analysis
%    step_size:               Step size of each metabololite tested
%    path:                    Path where output is saved
%    samples:                 Names of conditions
%    label:                   Defining label of X-axis, y-axis and z-axis, e.g., {`Glucose uptake (fmol/cell/hr)`; `Oxygen uptake
%                             (fmol/cell/hr)`; `Growth rate (hr-1)`} The z-axis is the growth rate which is color coded
%    fonts:                   Font size for labels on heatmap
%    tol:                     Fluxes are considered zero if they are below the tol
%
% Individual pdf files showing the result of the PPP are being saved automatically for each condition.
%
% .. Author: - Maike K. Aurich 19/02/15

k=1;

for i=1:length(samples)

    for p=1:size(mets,2)
        name  = ['phasePlane_' strtok(mets{1,p}, '(') '_' strtok(mets{2,p}, '(')];

        %load condition specific performPPP result
        growthRates = ResultsAllCellLines.(samples{i}).(name).growthRates;
        bounds = ResultsAllCellLines.(samples{k}).(name).bounds;

        %chop off the additional entries in bounds
        ivalues=bounds(1:size(growthRates,1),1);
        jvalues=bounds(1:size(growthRates,2),2);


        % to mark the reaction bounds in the pruned model onto the phase plane
        modelPruned = eval(['ResultsAllCellLines.' samples{i} '.modelPruned']);
        lb = modelPruned.lb(find(ismember(modelPruned.rxns, mets{1,p})));
        ub = modelPruned.ub(find(ismember(modelPruned.rxns, mets{1,p})));
        clear modelPruned

        %make title
        name = regexprep(samples{i},'_','-');
        title_name = ['Objective values under variation of ' regexprep(mets{1,p},'_','-') ' and ' regexprep(mets{2,p},'_','-') ' in ' name];
       % define max of z-axis, which is the growth rate and color coded
        zmax = eval(['ResultsAllCellLines.' samples{i} '.maxBiomass.f'])+ 0.001;

        B = growthRates;
        % set values below tol as zero
        B(find(abs(B)<abs(tol)))=0;
        B(find(B==0))=nan; % remove zero as value


        % 3D plot
        figure1=figure;
        axes1 = axes('Parent',figure1);
        surf(ivalues',jvalues',B','Parent',axes1,'SpecularStrength',0.4,...
            'AmbientStrength',0.55,...
            'LineStyle','none');

        colorbar('peer',axes1);


        lowToHigh = [2 15];
        caxis(lowToHigh + [-1 1]*diff(lowToHigh));


        % set viewpoint
        az = 0;
        el = 90;
        view(az, el);

        %hold off
        hold on
        plot3([lb,lb],[0,-1000],[zmax,zmax],'Color',[0 0 0],'LineWidth',1.2);

        hold on
        plot3([ub,ub],[-1000,0],[zmax,zmax],'Color',[0 0 0],'LineWidth',1.2);

        hold off
        xlabel(label(1,1),'FontSize',fonts);
        ylabel(label(2,1),'FontSize',fonts);
        zlabel(label(3,1),'FontSize',fonts);
        title(title_name,'FontSize',fonts);
        axis tight %% seems to limit the axis, excludes white edge
              set(gcf, 'PaperUnits', 'inches');
        zlim([0 32]) % z-axis now from 0 to 10
        x_width=8 ;y_width=6;
        set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
        name  = [ 'phasePlane_' samples{i} '_' strtok(mets{1,p}, '(') '_' strtok(mets{2,p}, '(')];
        saveas(gcf,[path filesep name '.pdf']);
        % saveas(gcf,[path filesep name '.png']);
        clear ivalues
        clear jvalues
    end



end
end

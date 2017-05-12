function make3Dplot(PHs, maximum_contributing_flux, fonts, path, diff_view)
% The function allows illustration on different phenotypes predicted in
% MetTB onto the 3D illustration plot. The phenotypes are defined as
% colors, the location of the points is based on the ATP flux predicted by the
% function `predictFluxSplits`.
%
% USAGE:
%
%    make3Dplot(PHs, maximum_contributing_flux, fonts, path, diff_view)
%
% INPUTS:
%    PHs:                          Phenotypes = [samples PHENOTYPE], is generated from different functions (`predictFluxSplits`,...)
%    maximum_contributing_flux:    Output of the function `predictFluxSplits`, option ATP.
%    fonts:                        Font size
%    path:                         Path to save output
%    diff_view:                    Next to the standard view, print graphic from 3 different(2D) viewpoints (default = 0/off)
%
% PDFs are automatically saved to the user-defined path
%
% .. Author: - Maike K. Aurich 27/08/15

if ~exist('diff_view','var') || isempty(diff_view)
    diff_view = 0;
end


% count number of phenotypes
data_sets = unique(PHs(:,2));


%generate the x values for the number of groups
for i=1:length(data_sets)
    m=find(ismember(PHs(:,2),data_sets(i,:)));
    x = maximum_contributing_flux(m,4);
    y = maximum_contributing_flux(m,5);
    z = maximum_contributing_flux(m,7);
    eval(['x' num2str(i) '=x']);
    eval(['y' num2str(i) '=y']);
    eval(['z' num2str(i) '=z']);
    %clear m
end
clear x

figure

set(0,'DefaultAxesColorOrder',[0,0.2,0.8;0,0.6,0.0;0.2,0.8,1;0,0.6,0.8;0.8,0,0.2;0.8,0.4,0.8;1,0.8,0.2])

% for i=1:length(data_sets)
%
%    if i==1
%        hold on
%    end
%    rxns =data_sets(i);
%  eval('h= scatter3(' ['x' num2str(i)],['y' num2str(i)],['z' num2str(i)] [,'s','filled','userdata',rxns] ))
% end




h= scatter3(x1,y1,z1, 's','filled','userdata',data_sets{1});

hold on
h = scatter3(x2,y2,z2,'s','filled','userdata',data_sets{2});


%uncomment legend if legend should be produced, however if picture and legend are generated seperately it looks better.
 legend(get(gca,'children'),get(get(gca,'children'),'userdata')) % correct
 xlabel('Glycolysis (%)' ,'FontSize', fonts)
 ylabel('ATP synthetase (%)','FontSize', fonts)
 zlabel('Succinate-CoA ligase (%)','FontSize', fonts)
%
set(gca,'FontSize',fonts,'Linewidth',2,'ZLim',[0,12])



titleString = 'ATP production strategies across samples';
h= title(strvcat(titleString ));
             set(h,'fontsize',fonts);



saveas(gcf, [path filesep 'FS_3D'], 'png');

if diff_view==1;
    % set viewpoint
    % ATP-GLY
    Xi = 0;
    Yi = 0;
    Zi =270;
    view([Xi Yi Zi])
    saveas(gcf, [path filesep 'FS_3D_ATP_GLY'], 'pdf');

    % SUCC-GLY
    Xi = 0;
    Yi = -90;

    Zi =0;
    view([Xi Yi Zi])
    saveas(gcf, [path filesep 'FS_3D_Succ_GLY'], 'pdf');
    % Succ-ATP
    Xi = 90;
    Yi = 0;
    Zi =0;
    view([Xi Yi Zi])

    saveas(gcf, [path filesep 'FS_3D_SUCC_ATP'], 'pdf');
end



end

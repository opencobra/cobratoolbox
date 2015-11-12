% VISUALIZE Visualizes time-course simulation data.
%
%   VISUALIZE(T,Y,SPECIES,TITLE,HEATMAP,STEP) draws the time-course data
%   [T,Y]. STEP is used as a marker for the heatmap mode. HEATMAP
%   determines whether a normal line diagram or a heatmap like
%   representation is drawn. TITLE determines the title of the diagram.
%   SPECIES is a cell array of strings containing all species of the
%   system.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function Visualize(t,y,cellspecies,strtitle,heatmap,step)


if nargin<4
    strtitle='';
end
if nargin<5
    heatmap=0;
end

if ~IsMatlab
    error('Odefy plotting not supported in Octave. Please use the regular plot function.');
end

if heatmap
    % interpolate first (only if non-discrete simulation)
    if sum(mod(t,1))>0
        newt=linspace(min(t),max(t),1000);
        y=interp1(t,y,newt);
    else
        newt=t;
    end
    % find good labeling
    h=figure('Visible','Off');
    plot(newt,1:numel(newt));
    xt=get(gca,'XTick');
    % fnd tic positions
    tickpos=[];
    for i=1:numel(xt)
        [dummy,cand]=min(abs(xt(i)-newt));
        if cand==size(y,1)
            break;
        end
        tickpos(i)=cand;
    end
    close(h);
    % heat map
    figure;
    imagesc(y');
    
    hold on;
    % axes labels+title
    xlabel('Time [a.u.]', 'FontSize', 14);
    ylabel('Species', 'FontSize', 14);
    title(strtitle, 'FontSize', 18);
    
    % species
    set(gca,'yticklabel',cellspecies,'ytick',1:numel(cellspecies))
    
    % time scale
    set(gca,'xtick',tickpos, 'xticklabel', xt(1:numel(tickpos)));
    colorbar;
    colormap(jet);
    hold off;
else
    % normal plot
    figure;
    plot(t,y);
    legend(cellspecies,'Interpreter','none');
    xlabel('Time [a.u.]', 'FontSize', 14);
end
end

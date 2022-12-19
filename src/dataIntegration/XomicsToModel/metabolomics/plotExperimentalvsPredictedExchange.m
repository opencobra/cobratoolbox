function plotExperimentalvsPredictedExchange(measuredFluxes, predictedFluxes, otherFluxes, extraFluxes, param)
% plot a comparison of experimental and predicted exchange reaction rates
%
% INPUT
% measuredFluxes:   table with the fluxes obtained from exometabolomics experiments with the following variables 
%           * .rxns:    k x 1 cell array of reaction identifiers
%           * .mean:    k x 1 double of measured mean flux
%           * .SD:      k x 1 double standard deviation of the measured flux
%           * .labels:  k x 1 cell array of labels to display on y axis
%           * .Properties.Description: string describing the data, used in plot legend
%
% predictedFluxes:   table with the following variables
%           * .rxns:    k x 1 cell array of reaction identifiers
%           * .v:       k x 1 double of predicted mean flux
%           * .lb:      k x 1 double lower bound on reaction flux
%           * .ub:      k x 1 double upper bound on reaction flux
%           * .labels:  k x 1 cell array of labels to display on y axis
%           * .Properties.Description: string describing the data, used in plot legend
%
% OPTIONAL INPUT
% otherFluxes:  table with the following variables
%           * .rxns:    k x 1 cell array of reaction identifiers
%           * .Properties.Description: sring describing the data, used in plot legend
%           * .labels:  k x 1 cell array of labels to display on y axis
%   and
%           * .mean:    k x 1 double of measured mean flux
%           * .SD:      k x 1 double standard deviation of the measured flux
%
%   or 
%           * .v:       k x 1 double of predicted mean flux
%           * .lb:      k x 1 double lower bound on reaction flux
%           * .ub:      k x 1 double upper bound on reaction flux
%
%
% param: paramters structure with the following fields
%           * .measuredFluxes  {(1),0} set to zero to not display experimental fluxes
%
%           * .labelType determines which y axes lables to display
%                       'metabolitePlatform' = platform left and metabolite name right
%                       'metabolite'         = metabolite only right  (default)
%                       'platform'           = platform only left
%           * .expOrder {(1),0} 
%                       1  = order reactions by value of experimental flux
%                       0  = order reactions by value of predicted flux (predictedFluxes) for each reaction corresponding to an experimental flux
%           * .saveFigures = 1 saves figure as .fig and .png to current directory 
%           * .plotTitle: title of the plot


if exist('measuredFluxes','var')
    expDescription = measuredFluxes.Properties.Description; 
else
    error('predictedFluxes missing: must provide a predicted solution');
end

if exist('predictedFluxes','var')
    predDescription = predictedFluxes.Properties.Description; 
else
    error('predictedFluxes missing: must provide a predicted solution');
end
if exist('otherFluxes','var') && ~isempty(otherFluxes)
    otherDescription = otherFluxes.Properties.Description; 
else
    otherFluxes = [];
    otherDescription = '';
end
if exist('extraFluxes','var') && ~isempty(extraFluxes)
    extraDescription = extraFluxes.Properties.Description; 
else
    extraFluxes = [];
    extraDescription = '';
end
if ~exist('param','var')
    param = struct(); 
end
if ~isfield(param,'measuredFluxes')
    param.measuredFluxes = 1;
end
if ~isfield(param,'labelType')
    param.labelType = 'metabolite';
end
if ~isfield(param,'saveFigures')
    param.saveFigures = 0;
end
if ~isfield(param,'expOrder')
    param.expOrder = 1;
end
if ~isfield(param,'plotTitle')
    param.plotTitle = [];
end
if ~isfield(param,'measuredBounds')
    param.measuredBounds = 1;
end
if ~isfield(param,'predictedBounds')
    param.predictedBounds = 1;
end
if ~isfield(param,'otherBounds')
    param.otherBounds = 1;
end
if ~isfield(param,'extraBounds')
    param.extraBounds = 1;
end
if ~isvar(measuredFluxes,'labels')
    if isvar(measuredFluxes,'metNames')
        measuredFluxes.labels = measuredFluxes.metNames;
    end
end
if isvar(measuredFluxes,'rxns')
    measuredFluxes.rxns = measuredFluxes.rxns;
end
if isvar(predictedFluxes,'rxns')
    predictedFluxes.rxns = predictedFluxes.rxns;
end
if ~isempty(otherFluxes)
    if isvar(otherFluxes,'rxns')
        otherFluxes.rxns = otherFluxes.rxns;
    end
    if ~isvar(otherFluxes,'rxns')
        error('otherFluxes.rxns missing - needed to map to other variables')
    end
end
if ~isempty(extraFluxes)
    if isvar(extraFluxes,'rxns')
        extraFluxes.rxns = extraFluxes.rxns;
    end
    if ~isvar(extraFluxes,'rxns')
        error('extraFluxes.rxns missing - needed to map to other variables')
    end
end
%%%%%
if param.expOrder
    %eliminate NaN experimental data
    measuredFluxes = measuredFluxes(~isnan(measuredFluxes.mean),:);
        
    %sort by the normal cumulative distribution function that the flux is an uptake (1) rather than a secretion (0)
    zerobool = (measuredFluxes.mean-measuredFluxes.SD)<=0 & (measuredFluxes.mean+measuredFluxes.SD)>=0;
    posbool = sign(measuredFluxes.mean)==1 & ~zerobool;
    negbool = sign(measuredFluxes.mean)==-1 & ~zerobool;
    
    measuredFluxes.uptakeProbability = normcdf(0,measuredFluxes.mean,measuredFluxes.SD,'upper');
    
    measuredFluxes.toRankOrder = zeros(length(measuredFluxes.mean),1);
    measuredFluxes.toRankOrder(zerobool) = measuredFluxes.uptakeProbability(zerobool);
    measuredFluxes.toRankOrder(posbool) =  measuredFluxes.mean(posbool)+1;
    measuredFluxes.toRankOrder(negbool) = measuredFluxes.mean(negbool);
    measuredFluxes.zerobool=zerobool;
    measuredFluxes.posbool=posbool;
    measuredFluxes.negbool=negbool;
    
    if 1
        [sortedUptakeProbability,xi] = sort(measuredFluxes.toRankOrder);
    else
        [sortedUptakeProbability,xi] = sort(measuredFluxes.uptakeProbability,'descend');
    end
    
    measuredFluxes = measuredFluxes(xi,:);
    zerobool = measuredFluxes.zerobool;
    posbool = measuredFluxes.posbool;
    negbool = measuredFluxes.negbool;
    
    %place the predicted exchanges in the same order as the measurements
    predictedFluxes = mapAontoB(predictedFluxes.rxns,measuredFluxes.rxns, predictedFluxes);
else
    for i=1:length(predictedFluxes.labels)
        labels2 = strrep(predictedFluxes.labels{i},' for ', ' of ');
        predictedFluxes.labels{i} = [predictedFluxes.labels{i} ', ' labels2];
    end
    
    %order the predicted exchanges
    predictedFluxes.zerobool = (predictedFluxes.v-1e-5)<=0 & (predictedFluxes.v+1e-5)>=0;
    predictedFluxes.posbool = sign(predictedFluxes.v)==1 & ~predictedFluxes.zerobool;
    predictedFluxes.negbool = sign(predictedFluxes.v)==-1 & ~predictedFluxes.zerobool;
    predictedFluxes.uptakeProbability = normcdf(0,predictedFluxes.v,abs(predictedFluxes.v)/10);
    
    toRankOrder = zeros(length(predictedFluxes.v),1);
    toRankOrder(predictedFluxes.zerobool) = predictedFluxes.uptakeProbability(predictedFluxes.zerobool);
    toRankOrder(predictedFluxes.posbool) =  predictedFluxes.v(predictedFluxes.posbool)+1;
    toRankOrder(predictedFluxes.negbool)=predictedFluxes.v(predictedFluxes.negbool);
    
    if 1
        [sortedUptakeProbability,xi] = sort(toRankOrder);
    else
        [sortedUptakeProbability,xi] = sort(predictedFluxes.uptakeProbability,'descend');
    end
    predictedFluxes = predictedFluxes(xi,:);
    zerobool = predictedFluxes.zerobool;
    posbool = predictedFluxes.posbool;
    negbool = predictedFluxes.negbool;
    
    %place the measurements in the same order as the predictions
    measuredFluxes = mapAontoB(measuredFluxes.rxns,predictedFluxes.rxns,measuredFluxes);
end

%log modulus transformation
x = logmod(measuredFluxes.mean,10);
xl = logmod(measuredFluxes.mean - measuredFluxes.SD,10);
xl = x - xl;
xu = logmod(measuredFluxes.mean + measuredFluxes.SD,10);
xu = xu - x;

%use log modulus transformation
v = logmod(predictedFluxes.v,10);
if isvar(predictedFluxes,'lb') && isvar(predictedFluxes,'ub')
    vl = logmod(predictedFluxes.lb,10);
    vl = v - vl;
    vu = logmod(predictedFluxes.ub,10);
    vu = vu - v;
else
    xl = logmod(measuredFluxes.mean - measuredFluxes.SD,10);
    xl = x - xl;
    xu = logmod(measuredFluxes.mean + measuredFluxes.SD,10);
    xu = xu - x;
end

if isempty(otherFluxes)
    if param.measuredFluxes
        min_v = min([v;x-xl]);
        max_v = max([v;x+xu]);
    else
        min_v = min(v);
        max_v = max(v);
    end
    bool=~isnan(v);
else
    if param.expOrder
        %place the other fluxes in the same order as the measurements
        otherFluxes = mapAontoB(otherFluxes.rxns,measuredFluxes.rxns, otherFluxes);
    else
        %place the other fluxes in the same order as the predictions
        otherFluxes = mapAontoB(otherFluxes.rxns,predictedFluxes.rxns, otherFluxes);
    end
    
    if isvar(otherFluxes,'v') && isvar(otherFluxes,'lb') && isvar(otherFluxes,'ub')
        %use log modulus transformation
        v2 = logmod(otherFluxes.v,10);
        v2l = logmod(otherFluxes.lb,10);
        v2l = v2 - v2l;
        v2u = logmod(otherFluxes.ub,10);
        v2u = v2u - v2;
    elseif isvar(otherFluxes,'mean') && isvar(otherFluxes,'SD')
        %use log modulus transformation
        v2 = logmod(otherFluxes.mean,10);
        v2l = logmod(otherFluxes.mean - otherFluxes.SD,10);
        v2l = v2 - v2l;
        v2u = logmod(otherFluxes.mean + otherFluxes.SD,10);
        v2u = v2u - v2;
    else
        error('Unrecognised input: otherFluxes')
    end
    
    %limits
    if param.measuredFluxes
        min_v = min([v;v2;x-xl]);
        max_v = max([v;v2;x+xu]);
    else
        min_v = min([v;v2]);
        max_v = max([v;v2]);
    end
    bool=~isnan(v) & ~isnan(v2);
end


if isempty(extraFluxes)
    if isempty(otherFluxes)
        if param.measuredFluxes
            min_v = min([v;x-xl]);
            max_v = max([v;x+xu]);
        else
            min_v = min(v);
            max_v = max(v);
        end
        bool=~isnan(v);
    else
        if param.measuredFluxes
            min_v = min([v;v2;x-xl]);
            max_v = max([v;v2;x+xu]);
        else
            min_v = min([v;v2]);
            max_v = max([v;v2]);
        end
        bool=~isnan(v) & ~isnan(v2);
    end
else
    if param.expOrder
        %place the other fluxes in the same order as the measurements
        extraFluxes = mapAontoB(extraFluxes.rxns,measuredFluxes.rxns, extraFluxes);
    else
        %place the other fluxes in the same order as the predictions
        extraFluxes = mapAontoB(extraFluxes.rxns,predictedFluxes.rxns, extraFluxes);
    end
    
    if isvar(extraFluxes,'v') && isvar(extraFluxes,'lb') && isvar(extraFluxes,'ub')
        %use log modulus transformation
        v3 = logmod(extraFluxes.v,10);
        v3l = logmod(extraFluxes.lb,10);
        v3l = v3 - v3l;
        v3u = logmod(extraFluxes.ub,10);
        v3u = v3u - v3;
    elseif isvar(extraFluxes,'mean') && isvar(extraFluxes,'SD')
        %use log modulus transformation
        v3 = logmod(extraFluxes.mean,10);
        v3l = logmod(extraFluxes.mean - extraFluxes.SD,10);
        v3l = v3 - v3l;
        v3u = logmod(extraFluxes.mean + extraFluxes.SD,10);
        v3u = v3u - v3;
    else
        error('Unrecognised input: extraFluxes')
    end
    
    %limits
    if param.measuredFluxes
        min_v = min([v;v2;v3;x-xl]);
        max_v = max([v;v2;v3;x+xu]);
    else
        min_v = min([v;v2;v3]);
        max_v = max([v;v2;v3]);
    end
    bool=~isnan(v) & ~isnan(v2) & ~isnan(v3);
end

%figure('Renderer', 'painters', 'Position', [10 10 900 1500])
%figure('units','normalized','outerposition',[0 0 1 1])
figure('units','normalized','Position',[0 0 0.5 1.5])
hold on

%patch in the background
X = [min_v max_v max_v min_v];

if param.expOrder
    Y = [nnz(negbool & bool)+nnz(zerobool & bool)+0.5 nnz(negbool & bool)+nnz(zerobool & bool)+0.5 length(measuredFluxes.mean(bool))+0.5 length(measuredFluxes.mean(bool))+0.5];
else
    Y = [nnz(negbool & bool)+nnz(zerobool & bool)+0.5 nnz(negbool & bool)+nnz(zerobool & bool)+0.5 length(predictedFluxes.v(bool))+0.5 length(predictedFluxes.v(bool))+0.5];
end

patch(X,Y,[221/255, 192/255, 237/255],'FaceAlpha',0.5)

Y = [nnz(negbool & bool)+0.5 nnz(negbool & bool)+0.5 nnz(negbool & bool)+nnz(zerobool & bool)+0.5 nnz(negbool & bool)+nnz(zerobool & bool)+0.5];
patch(X,Y,[192/255, 237/255, 207/255],'FaceAlpha',0.5)

Y = [0 0 nnz(negbool & bool)+0.5 nnz(negbool & bool)+0.5];
patch(X,Y,[192/255, 233/255, 237/255],'FaceAlpha',0.9)


if param.measuredFluxes
    if param.measuredBounds
        %errorbar
        errorbar(x(bool),(1:length(x(bool)))+0.2,xl(bool),xu(bool),'horizontal','*','LineWidth',2,'MarkerSize',12)
    else
        plot(x(bool),(1:length(x(bool)))+0.2,'*k','MarkerSize',12)%,'MarkerFaceColor',[1 1 1])
    end
end

if param.predictedBounds
    %predicted fluxes
    errorbar(v(bool),(1:length(v(bool))),vl(bool),vu(bool),'horizontal','dk','LineWidth',1.5,'MarkerSize',10)%,'MarkerFaceColor',[1 1 1])
else
    %predicted fluxes
    plot(v(bool),1:length(v(bool)),'dk','MarkerSize',12)%,'MarkerFaceColor',[1 1 1])
end

%x & y limits

if param.expOrder
    ylim([0,length(measuredFluxes.mean(bool))+0.5])
else
    ylim([0,length(predictedFluxes.v(bool))+0.5])
end

[comparisonStats,comparison] = quanQualAcc(measuredFluxes, predictedFluxes);

%other fluxes
if ~isempty(otherFluxes)
    if param.otherBounds
        errorbar(v2(bool),(1:length(v2(bool)))-0.2,v2l(bool),v2u(bool),'horizontal','o','LineWidth',1.5,'MarkerSize',10, 'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6])%,'MarkerFaceColor',[1 1 1])
    else
        %other fluxes
        plot(v2(bool),(1:length(v2(bool)))-0.2,'o','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6])
    end

    [comparisonStats,comparison] = quanQualAcc(measuredFluxes, otherFluxes);
    
    xlim([min_v max_v])
    %xlim([-0.5 0.5])
else
    xlim([min_v max_v])
    %xlim([-0.5 0.5])
    %title(['Comparison of \color{blue}measured \color{black}and \color{red}predicted \color{black}net exchange reaction rates. (Objective ' solution1 ')'])
end

%extra fluxes
if ~isempty(extraFluxes)
    if param.extraBounds
        errorbar(v3(bool),(1:length(v3(bool)))-0.4,v3l(bool),v3u(bool),'horizontal','x','LineWidth',1.5,'MarkerSize',10, 'MarkerEdgeColor','magenta','MarkerFaceColor',[1 .6 .6])%,'MarkerFaceColor',[1 1 1])
    else
        %extra fluxes
        plot(v3(bool),(1:length(v3(bool)))-0.4,'x','MarkerSize',10,'MarkerEdgeColor','magenta','MarkerFaceColor',[1 .6 .6])
    end

    [comparisonStats,comparison] = quanQualAcc(measuredFluxes, extraFluxes);
    
    xlim([min_v max_v])
    %xlim([-0.5 0.5])
else
    xlim([min_v max_v])
    %xlim([-0.5 0.5])
    %title(['Comparison of \color{blue}measured \color{black}and \color{red}predicted \color{black}net exchange reaction rates. (Objective ' solution1 ')'])
end

if isempty(param.plotTitle)
    if 0
    if param.measuredFluxes
        if isempty(otherFluxes)
            title(['Measured versus predicted (<>)' predDescription ' net exchange reaction rates.'])
        else
            if isempty(extraFluxes)
                title(['Measured versus predicted (<>)' predDescription ' and ' otherDescription '(O) net exchange reaction rates.'])
            else
                title(['Measured versus predicted (<>)' predDescription ' and ' otherDescription '(O), and ' extraDescription '(X) net exchange reaction rates.'])
            end
        end
    else
        title(['Predicted net reaction rates: ' predDescription ' vs ' otherDescription])
    end
    end
else
    title(param.plotTitle);
end
    
if param.measuredFluxes
    if isempty(otherFluxes)
        legend({'measured secretion','uncertain','measured uptake',expDescription,predDescription},'location','northwest');
    else
        if isempty(extraFluxes)
            legend({'measured secretion','uncertain','measured uptake',expDescription,predDescription,otherDescription},'location','northwest');
        else
            legend({'measured secretion','uncertain','measured uptake',expDescription,predDescription,otherDescription,extraDescription},'location','northwest');
        end
    end
else
    if isempty(otherFluxes)
        legend({predDescription},'location','northwest');
    else
        if isempty(extraFluxes)
            legend(['measured secretion','uncertain','measured uptake',predDescription,otherDescription],'location','northwest');
        else
            legend(['measured secretion','uncertain','measured uptake',predDescription,otherDescription,extraDescription],'location','northwest');
        end
    end
end
xlabel('Net flux (uMol/gDW/hr) on $\log_{10}$ scale: $\textrm{sign}(x) \times \log_{10}(1+x)$','interpreter','latex');


%labels
ax = gca;

%xtick=[-100:10:100];
%xticklab = cellstr(num2str(sign(xtick).*log10(1+abs(xtick)), '%d'));
%set(gca,'XTick',xtick,'XTickLabel',xticklab,'TickLabelInterpreter','tex')


if param.expOrder
    ax.YTick = 1:length(measuredFluxes.mean(bool));
    ax.YTickLabel = measuredFluxes.labels(bool);
else
    ax.YTick = 1:length(predictedFluxes.v(bool));
    ax.YTickLabel = predictedFluxes.labels(bool);
end

%hack to fix some metabolite lables
ax.YTickLabel = strrep(ax.YTickLabel,'Acetyl Isoleucine (Chemspider Id: 9964364)','Acetyl Isoleucine');
ax.YTickLabel = strrep(ax.YTickLabel,'Exchange of ','');
ax.YTickLabel = strrep(ax.YTickLabel,'3, 4-dihydroxy','3,4-dihydroxy');
ax.YTickLabel = strrep(ax.YTickLabel,'N-Acetyl-Tyrosine','N-Acetyl-L-tyrosine');
ax.YTickLabel = strrep(ax.YTickLabel,'Oxugen','Oxygen');
ax.YTickLabel = strrep(ax.YTickLabel,'Excahnge of ','');
ax.YTickLabel = strrep(ax.YTickLabel,'CYOR_u10mi','Oxidative phosphorylation (CYOR_u10mi)');
ax.YTickLabel = strrep(ax.YTickLabel,'NADH2_u10mi','NADH Dehydrogenase, Mitochondrial (NADH2_u10m)');

ax.TickLabelInterpreter='none';
ax.FontSize = 14;
switch param.labelType
    case 'metabolitePlatform'
        ax.YAxisLocation = 'right';
    case 'metabolite'
        ax.YAxisLocation = 'right';
    case 'platform'
        ax.YAxisLocation = 'left';
end

%         %right labels
%         plot(v,1:nnz(predictedExLOCB),'*r')
%         axL = gca;
%         axL.YAxisLocation = 'right';
%         axL.Color = 'none';
%         axL.Box = 'off';
%         yticks(1:length(measuredFluxes.mean))
%         axL.TickLabelInterpreter='latex';
%         axL.YColor ='black';
%         axL.FontSize = 10;
%         yt = yticks;
%         yticklabels(measuredFluxes.labelsR)

grid on
ax = gca;
ax.GridColor = [0 .5 .5];
ax.GridLineStyle = '--';
ax.GridAlpha = 0.5;
ax.Layer = 'top';

if 0
    xlim([-0.25 0.15])
    ylim([15.5 69.5])
    zoomed = 'zoom';
else
    zoomed = '';
end
if isempty(otherFluxes)
    descriptions = predDescription;
else
    descriptions = [predDescription '_vs_' otherDescription];
end

%%%% TODO %%% take the model name from the model structure
%     savefig(['iDN1_measured_vs_predicted_exchanges_' names '_' labelType zoomed])
%     saveas(gcf,['iDN1_measured_vs_predicted_exchanges_' names '_' labelType zoomed],'png')
if param.saveFigures
    savefig(['measured_vs_predicted_exchanges_' names '_' param.labelType zoomed])
    saveas(gcf,['measured_vs_predicted_exchanges_' names '_' param.labelType zoomed],'png')
end


function [] = isotopomerViewer(mdv1, mdv2, names)
% takes in an "experiment" and views the isotopomer as distributions
% between mdv1 and mdv2.  No output.

bins = round(sqrt(size(mdv1,2)));

for i = 1:size(mdv1,1)    
    subplot(4,4,mod(i-1,16)+1);
    [x1,x2]=hist(mdv1(i,:), bins);
    plot(x2,x1);
    if max(x2) < .02
        plot(x2,x1, 'k');
    end
    hold on;
    [x1,x2]=hist(mdv2(i,:), bins);
    plot(x2,x1, 'g');
    if max(x2) < .02
        plot(x2,x1, 'k');
    end
    title(names{i});
    hold off;
    if mod(i,16) == 0
        pause;
    end
end






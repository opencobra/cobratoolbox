function [mixing_times, step_times] = convPlot(dims, body_type, walk_type, test_type)

if nargin < 4
    test_type = 'halfspaceGood';
end

% dims = 10:10:200;
mixing_times = zeros(length(dims),1);
mt_max = zeros(length(dims),1);
mt_cond_avg = zeros(length(dims),1);
step_times = zeros(length(dims),1);
%the body below should be isotropic up to scaling. otherwise, should
%specify a covariance matrix to convTest (or could specify max/min singular
%value)
% body = 'rotated_cube';
% walk_type = 'CHAR';
% test_type = 'halfspaceGood';

it = 0;

for i = dims
    it = it+1;
    body = makeBody(body_type,i);
    
    [mixing_times(it), mt_max(it), mt_cond_avg(it), step_times(it)] = convTest(body,walk_type,test_type);
    fprintf('%d dimensions: %f (max: %f) steps to mix\n', i, mixing_times(it), mt_max(it));
end

if strcmp(body_type, 'birkhoff')==1
    dims = (dims-1).^2;
end

figure;
hold on;
ax1 = subplot(2,1,1);
hold on;
plot(ax1, dims, mixing_times);
plot(ax1,dims,mt_cond_avg);
title(ax1, strcat(body_type, ' ', walk_type, ' (red=cond)'));
xlabel(ax1, 'Dimension');
ylabel(ax1, 'Mixing time estimate (steps)');

ax2 = subplot(2,1,2);
plot(ax2, dims, step_times);
title(ax2, strcat(body_type, ' ', walk_type));
xlabel(ax2, 'Dimension');
ylabel(ax2, 'Time/step (sec)');

% ax3 = subplot(3,1,3);
% plot(ax3,dims,mt_cond_avg);
% title(ax3, strcat(body_type, ' ', walk_type, ' Conductance'));
% xlabel(ax3, 'Dimension');
% ylabel(ax3, 'Mixing time estimate (steps)');


save_string = strcat(body_type, '_', walk_type,'_',test_type,'.fig');
saveas(gcf, save_string);

end
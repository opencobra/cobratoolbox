% An example of how to use the histogram distance functions for image
% matching.
%
% Please note that this is a demo to show case the usage of the histogram
% functions. But, in general, matching images solely based on their color
% histograms ist - imho - not the best idea, unless you have a really large
% image database.
%
% Some of the histogram distance functions have been used for outlier
% reduction when learning color term/name models from web images, see:
%
% [1] B. Schauerte, G. A. Fink, "Web-based Learning of Naturalized Color 
%     Models for Human-Machine Interaction". In Proceedings of the 12th 
%     International Conference on Digital Image Computing: Techniques and 
%     Applications (DICTA), IEEE, Sydney, Australia, December 1-3, 2010. 
% [2] B. Schauerte, R. Stiefelhagen, "Learning Robust Color Name Models 
%     from Web Images". In Proceedings of the 21st International Conference
%     on Pattern Recognition (ICPR), Tsukuba, Japan, November 11-15, 2012
%
% If you use and like this code, you are kindly requested to cite some of 
% the work above. 
%
% Anyway, I hope it saves you some work. Have fun with it ;)
%
% @author: B. Schauerte
% @date:   2012,2013
% @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/

%%
% Build the .cpp files, if necessary
if ~exist('chi_square_statistics_fast','file') && exist('./build.m')
  build;
end

% Download some random sample images from the Google-512 dataset. For 
% information about the dataset see: 
%
% [1] B. Schauerte, G. A. Fink, "Web-based Learning of Naturalized Color 
%     Models for Human-Machine Interaction". In Proceedings of the 12th 
%     International Conference on Digital Image Computing: Techniques and 
%     Applications (DICTA), IEEE, Sydney, Australia, December 1-3, 2010. 
% [2] B. Schauerte, R. Stiefelhagen, "Learning Robust Color Name Models 
%     from Web Images". In Proceedings of the 21st International Conference
%     on Pattern Recognition (ICPR), Tsukuba, Japan, November 11-15, 2012

%colornames={'red','green','blue','yellow', ...
%  'pink','purple','brown','orange', ...
%  'black','grey','white'};
colornames={'red','green','blue','yellow'};
fendings={'jpeg','png','gif'};
tmp_foldername='google-512-samples';
n_samples = 100;

% download the images in a temporary folder
if ~exist(tmp_foldername,'dir'), mkdir(tmp_foldername); end % create temporary directory
filenames=cell(n_samples,1);
for i=1:n_samples
  colorname=colornames{randi(numel(colornames))};
  %colorname=colornames{1};
  for j=1:numel(fendings)
    url=sprintf('https://cvhci.anthropomatik.kit.edu/~bschauer/datasets/google-512/images-resized-128/%s+color/%d.%s',colorname,i,fendings{j});
    filename=sprintf('%s_%d.%s',colorname,i,fendings{j});
    [~,status] = urlwrite(url,fullfile(tmp_foldername,filename));
    if status
      filenames{i} = filename;
      break; 
    end
  end
end

%%
% We simply use all files that have already been downloaded
filenames=dir(fullfile(tmp_foldername,'*_*.*'));
filenames={filenames.name};
n_samples=numel(filenames);

%%
% calculate color image histograms
n_bins=4;
edges=(0:(n_bins-1))/n_bins;
histograms=zeros(n_samples,n_bins*n_bins*n_bins);
for i=1:n_samples
  I=imread(fullfile(tmp_foldername,filenames{i}));
  IR=imresize(I,[64 64]);
  IR=im2double(IR);
  
  [~,r_bins] = histc(reshape(IR(:,:,1),1,[]),edges); r_bins = r_bins + 1;
  [~,g_bins] = histc(reshape(IR(:,:,1),1,[]),edges); g_bins = g_bins + 1;
  [~,b_bins] = histc(reshape(IR(:,:,1),1,[]),edges); b_bins = b_bins + 1;
  
  histogram=zeros(n_bins,n_bins,n_bins);
  for j=1:numel(r_bins)
    histogram(r_bins(j),g_bins(j),b_bins(j)) = histogram(r_bins(j),g_bins(j),b_bins(j)) + 1;
  end
  histograms(i,:) = reshape(histogram,1,[]) / sum(histogram(:)); % normalize, better for all probabilistic methods
end

%%
% match histograms and show best matching pairs
dist_func=@chi_square_statistics_fast;
% 1. You can use pdist to calculate the distances, iff the distance measure
%    is symmetric
%D=squareform(pdist(histograms,dist_func)); % use pdist to calculate the distance for all image pairs 
% 2. Use the following loop to calculate the distances, iff the measure is
%    not symmetric
% D=zeros(size(histograms,1),size(histograms,1));
% for i=1:size(histograms,1)
%   for j=1:size(histograms,1)
%     D(i,j) = dist_func(histograms(i,:),histograms(j,:));
%   end
% end
% 2. ... alternatively, use pdist2
D=pdist2(histograms,histograms,dist_func);

D(D == 0) = NaN;
n_show_samples=5; % number of samples for the illustration
figure('name','Random images (left) with their best (middle) and worst (right) match');
c = 1;
rand_indices=randperm(numel(filenames));
for i=1:n_show_samples
  % image we want to match
  I=imread(fullfile(tmp_foldername,filenames{rand_indices(i)}));
  if numel(size(I)) > 3, I=I(:,:,1:3); end
  subplot(n_show_samples,3,c); imshow(I); c = c + 1;
  
  % best match
  %[d,j]=min(D(rand_indices(i),:)); % if distances are not symmetric, then
  % it might be useful to try the other order, see below, depending on the
  % definition of the metric
  [d,j]=min(D(:,rand_indices(i)));
  I=imread(fullfile(tmp_foldername,filenames{j}));
  if numel(size(I)) > 3, I=I(:,:,1:3); end
  subplot(n_show_samples,3,c); imshow(I); title(sprintf('Dist: %.3f',d*100)); c = c + 1;
  
  % worst match
  %[d,j]=max(D(rand_indices(i),:)); % if distances are not symmetric, then
  % it might be useful to try the other order, see below, depending on the
  % definition of the metric
  [d,j]=max(D(:,rand_indices(i)));
  I=imread(fullfile(tmp_foldername,filenames{j}));
  if numel(size(I)) > 3, I=I(:,:,1:3); end
  subplot(n_show_samples,3,c); imshow(I); title(sprintf('Dist: %.3f',d*100)); c = c + 1;
end
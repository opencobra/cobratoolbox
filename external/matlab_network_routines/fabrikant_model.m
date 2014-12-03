% Implements the Fabrikant model of internet growth
% Source: Fabrikant et al, "Heuristically Optimized Trade-offs: A New Paradigm for Power Laws in the Internet"
% Note: Assume the first point to be the center - easy to change by setting p(1,:) = [x0,y0]
% INPUTS: n - number of points, parameter alpha, [0,inf), plt='on'/'off', if [], then 'off' is default
% OUTPUTS: generated network (adjacency matrix) and plot [optional]
% Other functions used: simple_dijkstra.m
% GB, Last Updated: November 26, 2006


function [adj,p]=fabrikant_model(n,alpha,plt)


% create random point (polar) coordinates
p = zeros(n-1,2);
rad = rand(1,n-1);
theta = 2*pi*rand(1,n-1);
for i=1:n-1; p(i,:) = rad(i)*[cos(theta(i)),sin(theta(i))]; end
p=[[0 0]; p];               % add zero

h=zeros(n,1); % initialize centrality function
adj=zeros(n); % initialize adjacency matrix


for i=2:n   % a new point arrives at each iteration

    % compute min weight across all existing points
    d=[]; 
    for j=1:i-1; d=[d; alpha*norm(p(i,:)-p(j,:)) + h(j)]; end
    [~,indmin]=min(d);
    adj(i,indmin)=1; adj(indmin,i)=1;

    % compute centrality function for new point
    adjL = pdist2(p,p,'euclidean');
    h = simple_dijkstra(adjL,1);
    
end

if nargin<=2 | not(strcmp(plt,'on')); return; end

set(gcf,'color',[1,1,1])
for i=1:n
  axis off
  drawnow
  %plot(p(i,1),p(i,2),'.','Color',[0.5,0.5,0.5]); hold off; hold on;  % plot the new point
  for j=i+1:n
    if adj(i,j)>0
      line([p(i,1) p(j,1)],[p(i,2) p(j,2)],'Color',[0.5,0.5,0.5])
      hold off; hold on;
    end
  end
end


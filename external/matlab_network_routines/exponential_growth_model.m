% Grow a network exponentially
% Probability of node s having k links at time t: p(k,s,t)=1/t*p(k-1,s,t-1)+(1-1/t)*p(k,s,t-1)
% INPUTS: number of time-steps, t
% OUTPUTs: edgelist, mx3
% GB, Last Updated: May 7, 2007

function el=exponential_growth_model(t)

el=[1 2 1; 2 1 1]; % initialize with two connected nodes

% for all remaining time t
for i=3:t; r = randi(i-1); el=[el; i r 1; r i 1]; end
  
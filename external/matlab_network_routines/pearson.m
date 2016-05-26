% Calculating the Pearson coefficient for a degree sequence
% INPUTs: M - matrix, square
% OUTPUTs: r - Pearson coefficient
% Courtesy: Dr. Daniel Whitney, circa 2006

function prs = pearson(M)

%calculates pearson degree correlation of M
[rows,colms]=size(M);
won=ones(rows,1);
k=won'*M;
ksum=won'*k';
ksqsum=k*k';
xbar=ksqsum/ksum;
num=(won'*M-won'*xbar)*M*(M*won-xbar*won);
M*(M*won-xbar*won);
kkk=(k'-xbar*won).*(k'.^.5);
denom=kkk'*kkk;

prs=num/denom;


% ALTERNATIVE ===== BETTER-DOCUMENTED ====================================

% Calculating the Pearson coefficient for a degree sequence
% INPUTs: M - matrix, square
% OUTPUTs: r - Pearson coefficient
% source: "Assortative Mixing in Network", M.E.J. Newman, PhysRevLet 2002
% GB, March 15, 2006

% function r = pearson(M)
% 
% [degs,~,~] = degrees(M); % get the total degree sequence
% m = numedges(M);      % number of edges in M
% inc = adj2inc(M);      % get incidence matrix for convience
% 
% % j,k - remaining degrees of adjacent nodes for a given edge
% % sumjk - sum of all products jk
% % sumjplusk - sum of all sums j+k
% % sumj2plusk2 - sum of all sums of squares j^2+k^2
% 
% % compute sumjk, sumjplusk, sumj2plusk2
% sumjk = 0; sumjplusk = 0; sumj2plusk2 = 0;
% for i=1:m
%     [v] = find(inc(:,i)==1);
%     j = degs(v(1))-1; k = degs(v(2))-1; % remaining degrees of 2 end-nodes
%     sumjk = sumjk + j*k;
%     sumjplusk = sumjplusk + 0.5*(j+k);
%     sumj2plusk2 = sumj2plusk2 + 0.5*(j^2+k^2);
% end
% 
% % Pearson coefficient formula
% r = (sumjk - sumjplusk^2/m)/(sumj2plusk2-sumjplusk^2/m);
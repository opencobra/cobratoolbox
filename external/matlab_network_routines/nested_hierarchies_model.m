% Based on: Sales-Pardo et al, "Extracting the hierarchical organization of complex systems", PNAS, Sep 25, 2007; vol.104; no.39 
% Supplementary material: http://www.pnas.org/content/suppl/2008/02/27/0703740104.DC1/07-03740SItext.pdf
% INPUTs: N: number of nodes; L: number of hierarchy levels; [G1,G2,..,GL]: number of nodes in each group in each level
%         kbar: average degree, rho [optional]: ratio between average degrees at different levels (see supplementary material) 
% Example inputs (from paper): N=640, L=3, G=[10,40,160], kbar=16, rho=1
% OUTPUTs: edge list, in mx2 or mx3 format, where m = number of edges
% Other routines used: symmetrize_edgeL.m
% Last updated: Sep 19, 2011


function eL = nested_hierarchies_model(N,L,G,kbar,rho)


if length(G)~=L; fprintf('the number of levels don"t match'); return; end


eL = [];

for x=2:L
    if G(x)/G(x-1)~=ceil(G(x)/G(x-1)); fprintf('number of groups not an integer at level %2i; change input\n',x); return ; end
end
if N/G(L)~=ceil(N/G(L)); fprintf('number of groups not an integer at level %2i; change input\n',L); return ; end


% do group assignment
groups = {};

for x=1:L  % across all levels
   
    x = L-x+1;  % in reverse
    groups{x} = {};
    
    gr = [];
    for ii=1:N
        
        gr=[gr ii];
        if length(gr)==G(x); groups{x} = [groups{x} gr]; gr = []; end
        
    end
    
    
end

belongsto = {};
for ii=1:N; belongsto{ii} = zeros(1,L);  end % the level 1, 2, 3,... groups ii belongs to


for x=1:L  % across all levels
    
    for g=1:length(groups{x})

        for ii=1:length(groups{x}{g}); belongsto{groups{x}{g}(ii)}(x) = g; end

    end
    
end

% formula on page 3 of supplementary material
if nargin<5; rho = kbar/(G(L)-1) - 1 + 0.5; end;  % set to lower bound
if rho < kbar/(G(L)-1) - 1; fprintf('rho is below its theoretical lower bound, given kbar and G(L); fix values\n'); return; end

for i=1:N
    for j=i+1:N
        
        common_groups = belongsto{i}==belongsto{j};
        if sum(common_groups)==0
            pij = (rho/(1+rho))^(L) * kbar / (N - G(L));
            
        else
            x = L - sum(common_groups) + 1;  % level of commonality
            pij = rho^(L-x)/(1+rho)^(L-x+1) * kbar/(G(x)-1);
        end
        
        if rand < pij; eL = [eL; i j 1]; end
        
        
    end
end

eL = symmetrize_edgeL(eL);
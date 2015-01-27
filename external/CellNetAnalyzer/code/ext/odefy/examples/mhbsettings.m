% This file contains the codes required to run the Mid-hindbrain boundary
% examples in mhb.m

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy


%% define all the reference models
models = {};
sext = [3 4]; % external species
ncomp = 6; % number of compartments

% reference
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Gbx2&&Wnt1','Wnt1=~Gbx2&&Otx2&&Fgf8'};
% variant 2
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=Gbx2&&Wnt1','Wnt1=~Gbx2&&Otx2&&Fgf8'};
% variant 3
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Gbx2&&Wnt1','Wnt1=~Gbx2&&Fgf8'};
% variant 4
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Wnt1','Wnt1=~Gbx2&&Otx2&&Fgf8'};
% variant 5
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Gbx2&&Wnt1','Wnt1=Otx2&&Fgf8'};
% variant 6
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=Gbx2&&Wnt1','Wnt1=~Gbx2&&Fgf8'};
% variant 7
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Wnt1','Wnt1=Otx2&&Fgf8'};
% variant 8
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=Gbx2&&Wnt1','Wnt1=Otx2&&Fgf8'};
% variant 9
models{end+1} = {'Otx2=~Gbx2','Gbx2=~Otx2','Fgf8=~Otx2&&Wnt1','Wnt1=~Gbx2&&Fgf8'};


%% toy networks
players = {sprintf('Otx2'), sprintf('Gbx2'), sprintf('Fgf8'), sprintf('Wnt1')};

n=numel(players);

toymodels=1000;

eqs = {};
for t=1:toymodels
    eq = {};

    % create toy network
    for i=1:n
        bm{i}.NumOfInputs=round( 1+(n-1)*rand(1)^3 );
        bm{i}.Inputs=randsample(n, bm{i}.NumOfInputs);
        bm{i}.Update=[players{i} '= ( '];
        bm{i}.Table=zeros(1,n);
        z=1;
        for j=1:bm{i}.NumOfInputs
            if rand(1)<0.5
                neg=-1;
                bm{i}.Update=[bm{i}.Update, '~'];
            else
                neg=1;
            end
            %     bm{i}.Update=[bm{i}.Update, 'c(', num2str(bm{i}.Inputs(j)), ', t)'];
            bm{i}.Update=[bm{i}.Update, players{bm{i}.Inputs(j)}];
            bm{i}.Table(z, bm{i}.Inputs(j))=neg;
            if j<bm{i}.NumOfInputs
                if rand(1)<0.5
                    bm{i}.Update=[bm{i}.Update, ' ) | ( '];
                    z=z+1;
                else
                    bm{i}.Update=[bm{i}.Update, '&'];
                end
            else
                bm{i}.Update=[bm{i}.Update, ' )'];
            end
        end
        eq{i} = bm{i}.Update;
    end
    eqs{t} = eq;
end

models = [models eqs];


%% define the reference states
knownstate = [1 0 0 0 ; 1 0 0 0 ; 1 0 0 1 ; 0 1 1 0 ; 0 1 0 0 ; 0 1 0 0]';
knownstate = knownstate(:);
knownstate = knownstate'; % as vector

%% basic settings

simstruct = [];
simstruct.external = [];
simstruct.timeto = 10;
simstruct.initial = ref;
simstruct.type = 'hillcubenorm';
% MULTIMODEL  Generates multiple connected copies of a given model
%
%   NEWMODEL=MULTIMODEL(MODEL,EXT,N) generates N copies of MODEL in a row
%   which are connected via the external species given in EXT.
%
%   Species flagged as intercompartmental exhibit their influence towards
%   the two neighboring cells and are combined using an OR logic.
%
%   Example call:
%     single = ExpressionsToOdefy({'Otx2=~Gbx2','Gbx2=~Otx2', ...
%                 'Fgf8=~Otx2&&Gbx2&&Wnt1','Wnt1=~Gbx2&&Otx2&&Fgf8'});
%     multi = MultiModel(single, [3 4], 6);
%
%   Generates 6 copies of the single model in a row, where species 3 and 4
%   are used as external species.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function newmodel=MultiModel(model, ext, n)

nspecs = numel(model.species);

% generate model with two OR'ed inputs (for the borders)
model2 = oneOr(model,ext);
% generate model with three OR'ed inputs (in between)
model3 = oneOr(model2,ext);

% generate new species names
newspecs = cell(nspecs*n,1);
newmodel=[];
for i=1:n
    for j=1:nspecs
        ind=(i-1)*nspecs+j;
        % generate new species name
        newspecs{(i-1)*nspecs+j} = sprintf('%s_%d',model.species{j},i);
        if i>1 && i<n % core, has 2 neighbors
            % copy stuff, translate in-species
            newmodel.tables(ind).truth = model3.tables(j).truth;
            newmodel.tables(ind).inspecies = model3.tables(j).inspecies+(i-1)*nspecs;
            % duplicated one?
            if numel(model3.tables(j).dupl{1}) > 0
                % translate first duplication to left cell
                newmodel.tables(ind).inspecies(model3.tables(j).dupl{1}) = newmodel.tables(ind).inspecies(model3.tables(j).dupl{1}) - nspecs;
                % translate second duplication to right cell
                newmodel.tables(ind).inspecies(model3.tables(j).dupl{2}) = newmodel.tables(ind).inspecies(model3.tables(j).dupl{2}) + nspecs;
            end
        else
            % copy stuff, translate in-species 
            newmodel.tables(ind).truth = model2.tables(j).truth;
            newmodel.tables(ind).inspecies = model2.tables(j).inspecies+(i-1)*nspecs;
             % duplicated one?
            if numel(model2.tables(j).dupl{1}) > 0
                toadd = nspecs;
                if i==n 
                    toadd = -toadd;
                end
                newmodel.tables(ind).inspecies(model2.tables(j).dupl{1}) = newmodel.tables(ind).inspecies(model2.tables(j).dupl{1}) + toadd;
            end
        end
    end
end

newmodel.name = sprintf('%s_x_%d', model.name, n);
newmodel.species = newspecs;

%% one OR-step (one neighboring cell)
function newmodel=oneOr(model, ext)
nspecs = numel(model.species);
newmodel = model;
for i=1:nspecs
    if isfield(newmodel.tables(i),'dupl')
        duplnum = numel(newmodel.tables(i).dupl) + 1;
    else
        duplnum = 1;
    end
    newmodel.tables(i).dupl{duplnum} = [];
    % check whether input species is in there
    for j=1:numel(ext)
        e=ext(j);
        ind = find(newmodel.tables(i).inspecies==e,1,'first');
        if numel(ind) > 0
            newmodel.tables(i).truth = OrMatrix(newmodel.tables(i).truth,ind);
            newmodel.tables(i).inspecies(end+1) = e;
            newmodel.tables(i).dupl{duplnum}(end+1) = numel(newmodel.tables(i).inspecies);
        end
    end
end



function R=OrMatrix(A,s)

% iterate over new cube coordinates
n = numel(size(A));
% correct for one-dimensional functions
if numel(A)==2
    n=1;
end

R = zeros(repmat(2,1,n+1));

for i=0:2^(n+1)-1
    % translate to binary
    bin = num2bin(i,n+1);
    % generate combined value using OR
    comb = bin(s) || bin(n+1);
    % set it to the corresponding value in the old cube
    binold = bin(1:end-1);
    binold(s) = comb;
    eval(sprintf('R(%s)=A(%s);',genInd(bin),genInd(binold)));
end

% translates a binary vector e.g. [0 1 0 1 1]
% to a cube index string, e.g.     1,2,1,2,2ng, e.g.     1,2,1,2,2
function str=genInd(bin)
str = [];
for i=1:numel(bin)
    str = [str sprintf('%d', bin(i)+1)];
    if i<numel(bin)
        str = [str ','];
    end
end



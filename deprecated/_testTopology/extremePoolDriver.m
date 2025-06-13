if ~exist('iCore','var')
    load iCore
end

if ~exist('map','var')
    %create the filename
    mapCoordinateFilename = ['/home/rfleming/workspace/cobra-devel/testing/testMaps/ecoli_core_map.txt'];
    changeCbMapOutput('svg')
    %generate the map strucutre
    map = readCbMap(mapCoordinateFilename);
end

if ~exist('model','var')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(iCore);
    %Integerize 'CYTBD'
    %'2 h[c] + 0.5 o2[c] + q8h2[c]  -> h2o[c] + 2 h[e] + q8[c] '
    model.S(:,strcmp(model.rxns,'CYTBD'))=model.S(:,strcmp(model.rxns,'CYTBD'))*2;
    model.description='iCore';
end

if ~exist('Pl','var')
    fprintf('%s\n','Extreme pools')
    %calculates the matrix of extreme pools
    positivity=1;
    [Pl,Vl,A]=extremePools(model,positivity);
    %make the matrices full rather than sparse
    Pl=full(Pl);
    Vl=full(Vl);
end

if 1
    signPl=sign(Pl);
    nnzPl=sum(signPl,2);
    %pause(eps)
end

%draw certain pools within metabolites
conc = Pl(2,:)';
conc(conc~=0)=50;
options.maxNodeWeight=50;
%
flux=zeros(size(model.S,2),1);

%
options.maxEdgeWeight=1;

returnOptions = drawFluxConc(map,model,flux,conc);
%options = drawConc(map,model,conc,options,varargin);

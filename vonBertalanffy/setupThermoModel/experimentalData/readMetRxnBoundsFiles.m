function model=readMetRxnBoundsFiles(model,setDefaultConc,setDefaultFlux,defaultMetBounds,metBoundsFile,rxnBoundsFile)
%Set default concentration and flux bounds, and/or optionally read in upper and lower bounds from files.
%
%Upper and lower bounds on metabolite concentrations and reaction fluxes may be read in and
%mapped to the model. Bounds read from files overwrite reconstruction bounds, or default bounds.
%
%INPUT
% model.mets
% model.rxns
% setDefaultConc            1 = sets default bounds on conc    
% setDefaultFlux            1 = sets all reactions reversible [-1000,1000]
% defaultMetBounds.ub       Default upper bound on metabolite
%                           concentrations in M
% defaultMetBounds.lb       Default lower bound on metabolite
%                           concentrations in M
% 
%OPTIONAL INPUT
% metBoundsFile   name of tab delimited file with metabolite bounds
%                 format: '%s %f %f' 
%                         i.e. abbreviation lowerBound upperBound       
% rxnBoundsFile   name of tab delimited file with reaction bounds
%                 format: '%s %f %f' 
%                         i.e. abbreviation lowerBound upperBound  
%
%OUTPUT
% model.met(j).concMin
% model.met(j).concMax
% model.lb
% model.ub
%
% Ronan M.T. Fleming

if ~exist('metBoundsFile','var')
    metBoundsFile=[];
end
if ~exist('rxnBoundsFile','var')
    rxnBoundsFile=[];
end

[nMet,nRxn]=size(model.S);
if setDefaultConc
%     Passed in user defined default bounds instead of min = 1e-5 M and max 0.02 M. -Hulda
    %default Molar concentrations
    concMin = defaultMetBounds.lb; % M
    concMax = defaultMetBounds.ub; % M
        %set loose bounds on concentrations
    for m=1:nMet
        model.met(m).concMin=concMin;
        model.met(m).concMax=concMax;
    end
end
if setDefaultFlux    
    %default flux
    vMax=1000;
    %first set all reactions reversible
    for n=1:nRxn
        model.lb(n)=-vMax;
        model.ub(n)=vMax;
    end
end
        
if ~isempty(metBoundsFile)
    fid=fopen(metBoundsFile,'r');
    if fid==-1
        error(['Cannot open ' metBoundsFile]);
    else
        fprintf('%s\n',['Reading metabolite conc bounds from: ' metBoundsFile]);
    end
    C = textscan(fid,'%s %f %f');
    C1=C{1};
    C2=C{2};
    C3=C{3};

    for m=1:length(C1)
        ind=strcmp(C1{m,1},model.mets);
        if nnz(ind)==0
            warning('%s\n',['No metabolite abbreviation ' C1{m,1} ' in model'])
        else
            model.met(ind).concMin=C2(m,1);
            model.met(ind).concMax=C3(m,1);
        end
    end
    fclose(fid);
end

if ~isempty(rxnBoundsFile)
    fid=fopen(rxnBoundsFile,'r');
    if fid==-1
        error(['Cannot open ' rxnBoundsFile]);
    else
        fprintf('%s\n',['Reading reaction flux bounds from: ' rxnBoundsFile]);
    end
    C = textscan(fid,'%s %.20f %.20f'); % Changed format from %f to %.20f - Hulda
    C1=C{1};
    C2=C{2};
    C3=C{3};
    for n=1:length(C1)
        %then specify particular reactions
        ind=strcmp(C1{n,1},model.rxns);
        if nnz(ind)==0
            error('%s\n',['No reaction abbreviation ' C1{n,1} ' in model'])
        else
            model.lb(ind)=C2(n,1);
            model.ub(ind)=C3(n,1);
        end
    end
    fclose(fid);
end

%the necessary fields might not be present when this script is used to
%initialise a thermodynamic model, but if it is, then update the readable
%tables of information on metabolites and reactions
if isfield(model.met(1),'mu0Min')
    %make cobra model readable
    model=readableCobraModel(model);
end

%double check that all bounds are finite
for m=1:nMet
    if ~isfinite(model.met(m).concMin)
        error([model.mets{m} ' :Minimum concentration bound is not finite'])
    end
    if ~isfinite(model.met(m).concMax)
        error([model.mets{m} ' :Minimum concentration bound is not finite'])
    end
end
for n=1:nRxn
    if ~isfinite(model.lb(n))
        error([model.rxns{n} ' :Minimum flux bound is not finite'])
    end
    if ~isfinite(model.ub(n))
        error([model.rxns{n} ' :Maximum flux bound is not finite'])
    end
end


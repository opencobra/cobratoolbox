modelFiles = dir('../data/bio/*.mat');
numSamples = 1e4;
numSkip = 1e4;
for i=3:3
    modelStruct = load(strcat('../data/bio/',modelFiles(i).name));
    P = modelStruct.Problem;
    P.c = 0*P.c;
    
    model.S = P.A;
    model.b = P.b;
    model.lb = P.lb;
    model.ub = P.ub;
    model.c = P.c;
    model.rxns = cell(length(P.lb),1);
    for j=1:length(P.lb)
        model.rxns{j} = strcat('a',num2str(j));
    end
    cobra_opts = [];
    cobra_opts.nPointsReturned = numSamples;
    cobra_opts.nStepsPerPoint = numSkip;
    model.c = 0*model.c;
    [cobraModel, xCobra] = sampleCbModel(model,[],[],cobra_opts);
    save(strcat('cobra',num2str(i)),'xCobra','numSkip');
    %do the HMC sampler
    
%     [samples_yt] = yintat_sampler(P,numSamples);
    
%     [mo] = compareSamples(x,samples_yt, options);
    
    
end
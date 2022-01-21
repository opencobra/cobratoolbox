modelList = {'ecoli_core_model.mat'};%,'modelNormal.mat'};
% modelList = {'modelNormal.mat'};

for i=1:length(modelList)
    
    theModel = load(modelList{i});
    fieldNames = fieldnames(theModel);
    modelName = fieldNames{1};
    model = getfield(theModel,modelName);
    
    
    cobra_opts = [];
    cobra_opts.nPointsReturned = 1e4;
    model.c = 0*model.c;
%     [cobraModel, xCobra] = sampleCbModel(model,[],[],cobra_opts);
    numSamples = cobra_opts.nPointsReturned;
    
%     bioTest
    
    %now do HMC
    P = [];
    P.Aeq = model.S;
    P.beq = model.b;
    P.lb = model.lb;
    P.ub = model.ub;
    P.c = 0*P.lb;%+1e-1;
    
    
    options = [];
    options.addPadding = 0;
    options.numSamples = 1e4;
%     options.JL_dim = 1;
%     options.methodHMC = @TaylorStep;
    options.walkType = 'HMC';
    [xHMC] = sample(P,options);
%     options.numSamples = 1e2;
%     options.walkType = 'CHAR';
%     [xCHAR] = sample(P,options);
    
    
    
%     c_options = [];
%     c_options.toPlot = 1;
%     [mo] = compareSamples(xCobra,xHMC,c_options);
%     for j=1:5
%        figure;
%        hold on;
%        ksdensity(xCobra(j,:));
%        ksdensity(xHMC(j,:));
%     end
%     load('char_samp.mat');
    
    mean_diff = mean(samples,2)-mean(xCobra,2);
    figure;
    plot(mean_diff);
    title('HMC lbub vs. cobra');
    norm(mean_diff)
    mean_diff2 = mean(xCobra,2)-mean(xHMC,2);
    figure;
    plot(mean_diff2);
    title('HMC lbub vs. HMC ge 0');
    norm(mean_diff2)
end
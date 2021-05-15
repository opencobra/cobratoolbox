function testSammi(testnum)
% Visualize the given model, set of reactions, and/or data using SAMMI.
% Documentation at: https://sammim.readthedocs.io/en/latest/index.html
% 
% Citation: Schultz, A., & Akbani, R. (2019). SAMMI: A Semi-Automated 
%     Tool for the Visualization of Metabolic Networks. Bioinformatics.
% 
% USAGE:
% testSammi(test)
% 
% INPUT:
%   test: test number to be loaded. Integer between 0 and 11. Please
%   refer to the examples section of the documentation to see how each
%   example is generated.
% 
% OUTPUT:
%   No MATLAB output, opens the visualization in a new browser tab.

if nargin < 1
    testnum = 1;
end

%Get COBRA directory
global CBTDIR;
%Get SAMMIM folder
sammipath = strrep(which('sammi'),'/sammi.m','')

%Set seed for consistency
rng(734)

switch testnum
    case 0
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Plot
        sammi(model)
    case 1
        %Load model
        load([CBTDIR '/test/models/mat/Recon2.v04.mat'])
        %Plot a subgraph for each subsystem
        sammi(modelR204,'subSystems')
    case 2
        %Load model
        load([CBTDIR '/test/models/mat/iJO1366.mat'])
        %Make compartment field
        x = regexp(iJO1366.mets,'_(.)$','tokens');
        x = [x{:}]; x = [x{:}];
        iJO1366.compartment = x';
        %Plot a subgraph for each compartment
        sammi(iJO1366,'compartment')
    case 3
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Initialize options
        options.load = false;
        %Plot whole model in default file
        sammi(model,[],[],[],options)
        %Modify options to render map in different file
        options.htmlName = 'index_load2.html';
        %Plot model parsed by subsystem
        sammi(model,'subSystems',[],[],options)
        %Open both visualizations
        openSammi('index_load.html')
        openSammi('index_load2.html')
    case 4
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Get reactions to plot
        tca = {'ACONTa','ACONTb','AKGDH','CS','FUM','ICDHyr','MDH','SUCOAS'};
        gly = {'ENO','FBA','FBP','GAPD','PDH','PFK','PGI','PGK','PGM','PPS','PYK','TPI'};
        ppp = {'G6PDH2r','GND','PGL','RPE','RPI','TALA','TKT1','TKT2'};
        dat = cat(2,tca,gly,ppp);
        %Plot only desired reactions
        sammi(model,dat);
    case 5
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Get reactions to plot
        tca = {'ACONTa','ACONTb','AKGDH','CS','FUM','ICDHyr','MDH','SUCOAS'};
        gly = {'ENO','FBA','FBP','GAPD','PDH','PFK','PGI','PGK','PGM','PPS','PYK','TPI'};
        ppp = {'G6PDH2r','GND','PGL','RPE','RPI','TALA','TKT1','TKT2'};
        dat = cat(2,tca,gly,ppp);
        %Define secondaries
        secondaries = {'^h\[.\]$','^h2o\[.\]$','^o2\[.\]$','^co2\[.\]$',...
            '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
            '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
        %Plot only desired reactions
        sammi(model,dat,[],secondaries);
    case 6
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Get reactions to plot
        dat(1).name = 'TCA Cycle';
        dat(1).rxns = {'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'};
        dat(2).name = 'Glycolysis';
        dat(2).rxns = {'ENO';'FBA';'FBP';'GAPD';'PDH';'PFK';'PGI';'PGK';'PGM';'PPS';'PYK';'TPI'};
        dat(3).name = 'Pentose Phosphate Pathway';
        dat(3).rxns = {'G6PDH2r';'GND';'PGL';'RPE';'RPI';'TALA';'TKT1';'TKT2'};
        %Plot only desired reactions
        sammi(model,dat);
    case 7
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Get reactions to plot
        dat(1).name = 'TCA Cycle';
        dat(1).rxns = {'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'};
        dat(2).name = 'Glycolysis';
        dat(2).rxns = {'ENO';'FBA';'FBP';'GAPD';'PDH';'PFK';'PGI';'PGK';'PGM';'PPS';'PYK';'TPI'};
        dat(3).name = 'Pentose Phosphate Pathway';
        dat(3).rxns = {'G6PDH2r';'GND';'PGL';'RPE';'RPI';'TALA';'TKT1';'TKT2'};
        %Add random flux
        for i = 1:3; dat(i).flux = randn(length(dat(i).rxns),1); end
        %Plot only desired reactions
        sammi(model,dat);
    case 8
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Define number of conditions
        n = 5;
        %Make reaction table with random data
        rxntbl = randn(length(model.rxns),n);
        rxntbl(randsample(length(model.rxns)*n,floor(n*length(model.rxns)/10))) = NaN;
        rxntbl = array2table(rxntbl,'VariableNames',sprintfc('condition_%d',1:n),...
            'RowNames',model.rxns);
        %Make metabolites table with random data
        mettbl = randn(length(model.mets),n);
        mettbl(randsample(length(model.mets)*n,floor(0.5*length(model.mets)))) = NaN;
        mettbl = array2table(mettbl,'VariableNames',sprintfc('condition_%d',1:n),...
            'RowNames',model.mets);
        %Make struct
        dat(1).type = {'rxns' 'color'};
        dat(1).data = rxntbl;
        dat(2).type = {'rxns' 'size'};
        dat(2).data = rxntbl;
        dat(3).type = {'mets' 'color'};
        dat(3).data = mettbl;
        dat(4).type = {'mets' 'size'};
        dat(4).data = mettbl;
        dat(5).type = {'links' 'size'};
        dat(5).data = rxntbl;
        %Define secondaries
        secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$','^co2\[.\]$',...
            '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
            '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
        %Plot dividing up by subsystems
        sammi(model,'subSystems',dat,secondaries)
    case 9
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Define number of conditions
        n = 5;
        %Make reaction table with random data
        rxntbl = randn(length(model.rxns),n);
        rxntbl(randsample(length(model.rxns)*n,floor(n*length(model.rxns)/10))) = NaN;
        rxntbl = array2table(rxntbl,'VariableNames',sprintfc('condition_%d',1:n),...
            'RowNames',model.rxns);
        %Make struct
        dat(1).type = {'rxns' 'color'};
        dat(1).data = rxntbl;
        %Define secondaries
        secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$','^co2\[.\]$',...
            '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
            '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
        %Define Javascript code
        jscode = ['x = document.getElementById("onloadf1");' ...
            'x.value = "Citric Acid Cycle";' ...
            'onLoadSwitch(x);' ...
            'document.getElementById("fluxmin").valueAsNumber = -0.1;' ...
            'document.getElementById("fluxmax").valueAsNumber = 0.1;' ...
            'fluxmin = -0.1; fluxmax = 0.1;' ...
            'document.getElementById("edgemin").value = "#ff0000";' ...
            'document.getElementById("edgemax").value = "#0000ff";' ...
            'document.getElementById("addrxnbreak").click();' ...
            'document.getElementsByClassName("rxnbreakval")[0].value = 0;' ...
            'document.getElementsByClassName("rxnbreakcol")[0].value = "#c0c0c0";' ...
            'defineFluxColorVectors();'];
        %Define options
        options.jscode = jscode;
        %Plot dividing up by subsystems
        sammi(model,'subSystems',dat,secondaries,options)
    case 10
        %Load model
        load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
        %Define zooming option
        options.jscode = 'zoom.transform(gMain, d3.zoomIdentity.translate(-1149,-863).scale(2.64));';
        %Load existing model
        sammi(model,[sammipath '/demo.json'],[],[],options)
    case 11
        %Load and tailor model
        load([CBTDIR '/test/models/mat/iJO1366.mat'])
        model = iJO1366;
        model = changeRxnBounds(model,model.rxns(findExcRxns(model)),0,'b');
        model = changeRxnBounds(model,'ATPM',0,'l');
        model.csense = repmat('E',length(model.mets),1);
        model.c = model.c*0;

        %Do FVA
        [fluxmin,fluxmax] = fastFVA(model,0);
        %Clear numerical error
        fluxmax(fluxmax < 1e-7) = 0;
        fluxmin(fluxmin < -1e-7) = 0;
        
        %Parse
        count = 0;
        %For each positive flux
        for id = find(fluxmax)'
            %Set as objective
            model = changeObjective(model,model.rxns{id},1);
            %Calculate fluxes
            flux = optimizeCbModel(model,'max','one');
            %Clear numerical error
            flux.x(abs(flux.x) < 1e-7) = 0;
            %Save results for plot
            count = count+1;
            ind = find(flux.x);
            dat(count).name = num2str(count);
            dat(count).rxns = model.rxns(ind);
            dat(count).flux = flux.x(ind);
        end
        %For each negative flux
        for id = find(fluxmin)'
            %Set as objective
            model = changeObjective(model,model.rxns{id},1);
            %Calculate fluxes
            flux = optimizeCbModel(model,'min','one');
            %Clear numerical error
            flux.x(abs(flux.x) < 1e-7) = 0;
            %Save results for plot
            count = count+1;
            ind = find(flux.x);
            dat(count).name = num2str(count);
            dat(count).rxns = model.rxns(ind);
            dat(count).flux = flux.x(ind);
        end
        %Plot
        sammi(model,dat)
    end
end






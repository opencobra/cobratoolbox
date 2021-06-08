function curationReport = printRefinementReport(testResultsFolder,reconVersion)
% This function prints a report of the results of the DEMETER test suite
% ran on the reconstructs refined in the present project.
%
% USAGE:
%
%    curationReport = printRefinementReport(testResultsFolder,reconVersion)
%
% INPUTS
% testResultsFolder         Folder where the test results are saved
% reconVersion              Name of the refined reconstruction project
%
% OUTPUT
% curationReport            Summary of results of QC/QA tests
%
% .. Author:
%       - Almut Heinken, 06/2020

tol=0.000001;

fprintf('Finished refinement and testing of the project %s.\n',reconVersion)
curationReport={'Feature','Number','Agreement with experimental data'};

%%
data = readtable([testResultsFolder filesep reconVersion '_refined' filesep 'growthOnKnownCarbonSources_' reconVersion '.txt'], 'Delimiter', '\t');
data=table2cell(data);

fprintf('%s draft reconstructions have been refined.\n',num2str(size(data,1)))

curationReport(size(curationReport,1)+1,:)={'Refined reconstructions',num2str(size(data,1)),'N/A'};
%%
data = readtable([testResultsFolder filesep reconVersion '_refined' filesep 'ATP_from_O2_' reconVersion '.txt'], 'Delimiter', '\t');
data=table2cell(data);

infeasATP=sum(cell2mat(data(:,2))>tol);
if infeasATP>0
    fprintf('%s reconstructions produce infeasible ATP without a substrate.\n',num2str(infeasATP))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions producing ATP without a substrate',num2str(infeasATP),'N/A'};
end
%%
if isfile(([testResultsFolder filesep 'tooHighATP.mat']))
    load([testResultsFolder filesep 'tooHighATP.mat'])
    if size(tooHighATP,1) > 0
        fprintf('%s reconstructions produce too much ATP.\n',num2str(size(tooHighATP,1)))
        curationReport(size(curationReport,1)+1,:)={'Reconstructions producing too much ATP',num2str(size(tooHighATP,1)),'N/A'};
    end
end
%%
if isfile(([testResultsFolder filesep 'notGrowing.mat']))
    load([testResultsFolder filesep 'notGrowing.mat'])
    if size(notGrowing,1) > 0
    fprintf('%s reconstructions cannot produce biomass.\n',num2str(size(notGrowing,1)))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass',num2str(size(notGrowing,1)),'N/A'};
    end
end
%%
data = readtable([testResultsFolder filesep reconVersion '_refined' filesep reconVersion '_PercentagesAgreement.xls']);
data=table2cell(data);
if data{1,2}>0
    fprintf('Carbon source pathways were refined for %s reconstructions.\n',num2str(data{1,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with carbon source experimental data',num2str(data{1,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all carbon source experimental data.\n',data{1,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{1,3});
end
if data{2,2}>0
    fprintf('Fermentation pathways were refined for %s reconstructions.\n',num2str(data{2,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with fermentation experimental data',num2str(data{2,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all fermentation experimental data.\n',data{2,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{2,3});
end
if data{3,2}>0
    fprintf('Putrefaction pathways were refined for %s reconstructions.\n',num2str(data{3,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with putrefaction pathway data',num2str(data{3,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all putrefaction pathway data.\n',data{3,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{3,3});
end
if data{4,2}>0
    fprintf('Secretion product pathways were refined for %s reconstructions.\n',num2str(data{4,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with secretion product experimental data',num2str(data{4,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all secretion product experimental data.\n',data{4,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{4,3});
end
if data{5,2}>0
    fprintf('Metabolite uptake pathways were refined for %s reconstructions.\n',num2str(data{5,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with metabolite uptake experimental data',num2str(data{5,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all metabolite uptake experimental data.\n',data{5,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{5,3});
end
if data{6,2}>0
    fprintf('Bile acid pathways were refined for %s reconstructions.\n',num2str(data{6,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with bile acids comparative genomic data',num2str(data{6,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all bile acids comparative genomic data.\n',data{6,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{6,3});
end
if data{7,2}>0
    fprintf('Drug pathways were refined for %s reconstructions.\n',num2str(data{7,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with drug comparative genomic data',num2str(data{7,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all drug comparative genomic data.\n',data{7,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{7,3});
end
if data{8,2}>0
    fprintf('Growth requirements were refined for %s reconstructions.\n',num2str(data{8,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with data on growth requirements',num2str(data{8,2}),''};
    fprintf('%0.2f %% of reconstructions can grow on defined medium for the organism.\n',data{8,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{8,3});
end
curationReport=cell2table(curationReport);
% writetable(curationReport,[testResultsFolder filesep 'Curation_report_' reconVersion],'FileType','spreadsheet');
writetable(curationReport,['Refinement_report_' reconVersion],'FileType','spreadsheet','WriteVariableNames',false);

end
function printRefinementReport(testResultsFolder,reconVersion)
% This function runs the semi-automatic refinement pipeline consisting of
% three steps: 1) refining all draft reconstructions, 2) testing the
% refined reconstructions against the input data, 3) preparing a report
% detailing any additional debugging that needs to be performed.
%
% USAGE:
%
%    printRefinementReport(testResultsFolder,version)
%
% .. Authors:
%       - Almut Heinken, 06/2020

tol=0.000001;

fprintf('Finished refinement and testing of the project %s.\n',reconVersion)
curationReport={'Feature','Number','Agreement with experimental data'};

%%
data = readtable([testResultsFolder filesep 'Number_reactions.txt'], 'Delimiter', '\t');
data=table2cell(data);

fprintf('%s draft reconstructions have been refined.\n',num2str(size(data,1)))

curationReport(size(curationReport,1)+1,:)={'Refined reconstructions',num2str(size(data,1)),'N/A'};
%%
data = readtable([testResultsFolder filesep 'ATP_from_O2.txt'], 'Delimiter', '\t');
data=table2cell(data);

infeasATP=sum(cell2mat(data(:,2))>tol);
if infeasATP>0
    fprintf('%s reconstructions produce infeasible ATP without a substrate.\n',num2str(infeasATP))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions producing ATP without a substrate',num2str(infeasATP),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'ATP_flux_aerobic.txt'], 'Delimiter', '\t');
data=table2cell(data);

toohigh=sum(cell2mat(data(:,2))>150);
if toohigh>0
    fprintf('%s reconstructions produce too much ATP under aerobic conditions.\n',num2str(toohigh))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions producing too much ATP aerobically',num2str(toohigh),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'ATP_flux_anaerobic.txt'], 'Delimiter', '\t');
data=table2cell(data);

toohigh=sum(cell2mat(data(:,2))>100);
if toohigh>0
    fprintf('%s reconstructions produce too much ATP under anaerobic conditions.\n',num2str(toohigh))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions producing too much ATP anaerobically',num2str(toohigh),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'Biomass_aerobic_Unlimited_medium.txt'], 'Delimiter', '\t');
data=table2cell(data);

nogrowth=sum(cell2mat(data(:,2))<tol);
if nogrowth>0
    fprintf('%s reconstructions cannot produce biomass.\n',num2str(nogrowth))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass',num2str(nogrowth),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'Biomass_anaerobic_Unlimited_medium.txt'], 'Delimiter', '\t');
data=table2cell(data);

nogrowth=sum(cell2mat(data(:,2))<tol);
if nogrowth>0
    fprintf('%s reconstructions cannot produce biomass anaerobically.\n',num2str(nogrowth))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass anaerobically',num2str(nogrowth),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'Biomass_aerobic_Western_diet.txt'], 'Delimiter', '\t');
data=table2cell(data);

nogrowth=sum(cell2mat(data(:,2))<tol);
if nogrowth>0
    fprintf('%s reconstructions cannot produce biomass on Western diet.\n',num2str(nogrowth))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass on Western diet',num2str(nogrowth),'N/A'};
end
%%
data = readtable([testResultsFolder filesep 'Biomass_anaerobic_Western_diet.txt'], 'Delimiter', '\t');
data=table2cell(data);

nogrowth=sum(cell2mat(data(:,2))<tol);
if nogrowth>0
    fprintf('%s reconstructions cannot produce biomass on Western diet anaerobically.\n',num2str(nogrowth))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass on Western diet anaerobically',num2str(nogrowth),'N/A'};
end
% %%
% data = readtable([testResultsFolder filesep 'Blocked_reactions.txt'],'Delimiter', '\t','ReadVariableNames', true);
% data=table2cell(data);
% 
% nogrowth=sum(cell2mat(data(:,2))<tol);
% if nogrowth>0
%     fprintf('%s reconstructions cannot produce biomass on Western diet anaerobically.\n',num2str(nogrowth))
%     curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass on Western diet anaerobically',num2str(nogrowth)};
% end
% %%
% data = readtable([testResultsFolder filesep 'Incorrect_Gene_Rules.txt'],'Delimiter', '\t','ReadVariableNames', true);
% data=table2cell(data);
% 
% if size(data,2)>1
%     fprintf('%s reconstructions cannot produce biomass on Western diet anaerobically.\n',num2str(nogrowth))
%     curationReport(size(curationReport,1)+1,:)={'Reconstructions not producing biomass on Western diet anaerobically',num2str(nogrowth)};
% end
%%
data = readtable([testResultsFolder filesep 'PercentagesAgreement.csv']);
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
    fprintf('Biomass precursor biosynthesis pathways were refined for %s reconstructions.\n',num2str(data{3,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with comparative genomics',num2str(data{3,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all comparative genomics findings.\n',data{3,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{3,3});
end
if data{4,2}>0
    fprintf('Putrefaction pathways were refined for %s reconstructions.\n',num2str(data{4,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with putrefaction pathway data',num2str(data{4,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all putrefaction pathway data.\n',data{4,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{4,3});
end
if data{5,2}>0
    fprintf('Secretion product pathways were refined for %s reconstructions.\n',num2str(data{5,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with secretion product experimental data',num2str(data{5,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all secretion product experimental data.\n',data{5,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{5,3});
end
if data{6,2}>0
    fprintf('Metabolite uptake pathways were refined for %s reconstructions.\n',num2str(data{6,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with metabolite uptake experimental data',num2str(data{6,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all metabolite uptake experimental data.\n',data{6,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{6,3});
end
if data{7,2}>0
    fprintf('Bile acid pathways were refined for %s reconstructions.\n',num2str(data{7,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with bile acids comparative genomic data',num2str(data{7,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all bile acids comparative genomic data.\n',data{7,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{7,3});
end
if data{8,2}>0
    fprintf('Drug pathways were refined for %s reconstructions.\n',num2str(data{8,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with drug comparative genomic data',num2str(data{8,2}),''};
    fprintf('%0.2f %% of reconstructions agree with all drug comparative genomic data.\n',data{8,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{8,3});
end
if data{9,2}>0
    fprintf('Growth requirements were refined for %s reconstructions.\n',num2str(data{9,2}))
    curationReport(size(curationReport,1)+1,:)={'Reconstructions with data on growth requirements',num2str(data{9,2}),''};
    fprintf('%0.2f %% of reconstructions can grow on defined medium for the organism.\n',data{9,3}*100)
    curationReport{size(curationReport,1),3}=num2str(data{9,3});
end
curationReport=cell2table(curationReport);
% writetable(curationReport,[testResultsFolder filesep 'Curation_report_' reconVersion],'FileType','spreadsheet');
writetable(curationReport,['Refinement_report_' reconVersion],'FileType','spreadsheet','WriteVariableNames',false);

end
function [Fsp,Y]= mgSimResCollect(resPath,ID,rdiet,pdiet,patnumb,FVAct,figform)
% This function is called from the MgPipe pipeline. Its purpose is to compute 
% NMPCs from simulations with different diet on multiple microbiota models. 
% Results are outputted as .csv and a PCoA on NMPCs to group microbiota 
% models of individuals for similar metabolic profile is also 
% computed and outputted. 
%
% INPUTS
%    resPath            char with path of directory where results are saved
%    ID                 cell arry with list of all unique Exchanges to diet/
%                       fecal compartment
%    rdiet              number (double) indicating if to simulate a rich diet
%    pdiet              number (double) indicating if a personalized diet
%                       is available and should be simulated
%    patnumb            number (double) of individuals in the study
%    FVAct              cell array containing FVA values for maximal uptake 
%    figform            char indicating the format of figures
%
% OUTPUTS
%   Fsp                cell array with computed NMPCs
%   Y                  classical multidimensional scaling
% ..Author: Federico Baldini, 2017-2018

 fid = fopen('ID.csv','wt'); %Exporting set of simulated reactions 
 if fid>0
     for k=1:size(ID,1)
         fprintf(fid,'%s,%f\n',ID{k,:});
     end
     fclose(fid);
 end

%Extract results from fluxes matrix and analyze: NMPCs will be computed for
%rich (if enabled) and standard diet. NMPCs are computed under the assumption 
%that the community maximizes its uptakes and secretions. NMPCs are computed
%and saved in .csv format and a PCoA which aims to group individuals for 
%similarity in their metabolic profile is also computed.

%In this section NMPCs are automatically computed for all types of diets. 
%Number of different diets are automatically computed from the dimensions of 
%the simulation object.

if rdiet ==0
    init=2
else
    init=1
end

if pdiet==0
    fl=2
else
    fl=3
end

names={'rich','standard','personalized'}
for j=init:fl

for k=2:patnumb+1
if isempty(FVAct{fl,(k-1)})==1 
    disp('Jumping not feasible model')
    warning('NAN rows in fluxes matrix, no PCoA will be plotted')
    sp=NaN(length(ID),1);
    Fsp(:,k-1)=sp;
    noPcoa=1
else
    sp=NaN(length(ID),1);%consider to remove preallocation
    for i = 1:length(ID)
        x=FVAct{j,(k-1)}{i,3};
        e=isempty(x);
        if e == 0;
            sp(i,1)=abs(FVAct{j,(k-1)}{i,3}+FVAct{j,(k-1)}{i,2});
        end
    end
    Fsp(:,k-1)=sp;
end
end

csvwrite(strcat(resPath,names{1,j},'.csv'),Fsp) 
if noPcoa==1
    disp('Jump plotting')
else
    JD = pdist(Fsp','euclidean');
    [Y,eigvals] = cmdscale(JD);
    P = [eigvals eigvals/max(abs(eigvals))]
    plot(Y(:,1),Y(:,2),'bx') 
    print(strcat(resPath,'PCoA_individuals_fluxes_',names{1,j}),figform)
end
end
end

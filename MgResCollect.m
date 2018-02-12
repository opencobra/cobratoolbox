%%Analysisng results from simulations
if cobrajl==1
for k=2:patnumb+1
pp=cell2mat(sampname((k-1),1))
load(strcat(resPath,dietT,'\','microbiota_model_richD_',pp,'.mat'))
load(strcat(resPath,dietT,'\','results\','summary_microbiota_model_richD_',pp,'.mat'))
%loop for all the entries 
%strmatch(DietID(i),microbiota_model.rxns)
%for f =1:patnumb 
FVAct{1,(k-1)}=ID
for i=1:length(ID)
find=strmatch(microbiota_model.rxns(i),ID(i))
if find ==1
    FVAct{1,(k-1)}{i,2}=sumResults(i,2)
    FVAct{1,(k-1)}{i,3}=sumResults(i,3)
    %temp_mn(i)=sumResults(i,2)
    %temp_mx(i)=sumResults(i,3)
end
end
end   
end

%Exporting set of simulated reactions 

 fid = fopen('ID.csv','wt');
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

%In this section NMPCs are automatically computed for all tipes of diets. 
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

names={'rich','standard','personalised'}
for j=init:fl

for k=2:patnumb+1
if isempty(FVAct{fl,(k-1)})==1 
    disp('Jumping not feasable model')
    warning('NAN rows in flux span matrix, no PCoA will be plotted')
    sp=NaN(length(ID),1);
    Fsp(:,k-1)=sp;
    noPcoa=1
else
    sp=NaN(length(ID),1);%consider to remove preallocation
    for i = 1:length(ID)
        x=FVAct{j,(k-1)}{i,3};
        e=isempty(x);
        if e == 0;
            sp(i,1)=abs(FVAct{j,(k-1)}{i,3}+FVAct{j,(k-1)}{i,2}); %for setup 1/2
        end
    end
    Fsp(:,k-1)=sp;
end
end

csvwrite(strcat(resPath,names{1,j},'.csv'),Fsp) 
if noPcoa==1
    disp('Jumping plotting')
else
    JD = pdist(Fsp','euclidean');
    [Y,eigvals] = cmdscale(JD);
    P = [eigvals eigvals/max(abs(eigvals))]
    plot(Y(:,1),Y(:,2),'bx') 
    print(strcat(resPath,'PCoA patients fluxes_',names{1,j}),figform)
end
end


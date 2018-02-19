function [createdModels]=createPersonalizedModel(infoPath,resPath,model,sampname,orglist,patnumb)
createdModels={}
parfor k = 2:(patnumb+1)    
    mgmodel=model
    filename=strcat(infoPath,{'normCoverage.csv'});
    filename=cell2mat(filename);
    [abundance]=readtable(filename);
    abundance = table2array(abundance(:,k+1));
    %retrieving current model ID
    id=sampname((k-1),1);
    mId=strcat('microbiota_model_samp_',id,'.mat');
    
    %Autoload for already created models 
    resPathc=resPath(1:(length(resPath)-1));
    cd(resPathc);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
        vals{K} = fnames(K).name;
    end
    vals=vals';

    mapP = strmatch(mId, vals, 'exact');
    if isempty(mapP)
       %end of trigger
       idInfo=cell2mat(sampname((k-1),1))
       %parsave(sprintf(strcat(idInfo,'%d.mat')),id)
       %code lines to find which  bacteria has abundance of 0
       noab={};
       abcel=num2cell(abundance);
       abtab=[orglist,abcel];
       cnt=1;
       for i = 1:length(orglist)
            celabtab=cell2mat(abtab(i,2));
            if celabtab == 0
               noab(cnt)=abtab(i,1);
               cnt=cnt+1;
            end
       end
       noab=noab';
       %Setting to 0 the Exchange reactions of a bacteria whose abundance is 0 in
       %the individual and in the biomass
       for i = 1:length(noab)
           IndRxns=strmatch(noab(i,1),mgmodel.rxns);%finding indixes of specific reactions
           RmRxns=mgmodel.rxns(IndRxns);
           mgmodel=removeRxns(mgmodel,RmRxns); 
       end
      %Preparing vectors with abundances and bacteria in a way to eliminate the
      %ones not present (abundance =0)
      presBac=setdiff(orglist,noab,'stable');
      abval={};
      index=1;
      for i = 1:length(abundance)
          if ~abundance(i)== 0
            abval(index) = num2cell(abundance(i));
            index=index+1;
          end
      end
     abval=abval';
     abval=cell2mat(abval);
     mgmodel=addMicrobeCommunityBiomass(mgmodel,presBac,abval);
  
    %Coupling constraints for bacteria 
    for i = 1:length(presBac)
        IndRxns=strmatch(presBac(i,1),mgmodel.rxns);%finding indixes of specific reactions 
        mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),strcat(presBac(i,1),{'_biomass0'}),400,0.01); %couple the specific reactions 
    end
    %finam.name=sampname((k-1),1); 
    %allmod(k,1)={finam};
    microbiota_model=mgmodel;
    microbiota_model.name=sampname((k-1),1);
    idInfo=cell2mat(sampname((k-1),1));
    lw=length(resPath);
    sresPath=resPath(1:(length(resPath)-1));
    cd(sresPath) 
    parsave(sprintf(strcat('microbiota_model_samp_',idInfo,'%d.mat')),microbiota_model)
    else
   s= 'microbiota model file found: skipping model creation for this sample';
   disp(s)
   
end
end

%Example of a script that can be used to set up different thermodynamic models depending on the pH temp etc

% [modelT,directions]=setupThermoModel(model,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,temp,cpHa,ppHa,epHa,isCyto,isExt,biomassRxnAbbr,Ecoli_symphID_rxnAbbr,Legendre,useKeqData,nStdDevGroupCont,figures)

mkdir one
cd one
metBoundsFile=[];
rxnBoundsFile=[];
Legendre=1;
useKeqData=1;
nStdDevGroupCont=0;
cumNormProbCutoff=0.2;
figures=0;
printToFile=1;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,310.15,7.7,7.7,7.7,0.25,0.25,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

cd ../
mkdir two
cd two
Legendre=1;
useKeqData=1;
nStdDevGroupCont=1;
figures=1;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,310.15,7.7,7.7,7.7,0.25,0.25,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

cd ../
mkdir three
cd three
Legendre=1;
useKeqData=1;
nStdDevGroupCont=0;
figures=0;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,298.15,7,7,7,0,0,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);


cd ../
mkdir four
cd four
Legendre=1;
useKeqData=0;
nStdDevGroupCont=0;
figures=0;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,310.15,7.7,7.7,7.7,0.25,0.25,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

cd ../
mkdir five
cd five
Legendre=1;
useKeqData=0;
nStdDevGroupCont=1;
figures=0;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,310.15,7.7,7.7,7.7,0.25,0.25,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

cd ../
mkdir six
cd six
Legendre=1;
useKeqData=0;
nStdDevGroupCont=0;
figures=0;
[modelT,directions]=setupThermoModel(iAF1,metAbbrAlbertyAbbr,metGroupCont,Alberty2006,298.15,7,7,7,0,0,'Ec_biomass_iAF1260_core_59p81M',Ecoli_symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

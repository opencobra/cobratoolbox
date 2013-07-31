function [scanParam,METDATA]=scanThermoParam(model,resolution,metAbbrAlbertyAbbr,iAF1260,Alberty2006,biomassRxnAbbr,Ecoli_symphID_rxnAbbr)
%parameter scan of the thermodynamic parameters for each metabolite

%INPUT
% model
% resoluton

%OUTPUT
% scanParam     cell array of parameters for each modelT
% METDATA       data on each metabolite

scanParam=cell(resolution,resolution,resolution);

METDATA=cell(resolution,resolution,resolution);

tempMin=273.15;
tempMax=313.15;
tempIncrement=(tempMax-tempMin)/resolution;

isMin=0;
isMax=0.35;
isIncrement=(isMax-isMin)/resolution;

pHaMin=5;
pHaMax=9;
pHaIncrement=(pHaMax-pHaMin)/resolution;

temp=tempMin;
for x=1:resolution
    is=isMin;
    for y=1:resolution
        pHa=pHaMin;
        for z=1:resolution
            fprintf('%s\t%d\n','temp',temp);
            fprintf('%s\t%d\n','is',is);
            fprintf('%s\t%d\n','pHa',pHa);
            scanParam{x,y,z}.temp=temp;
            scanParam{x,y,z}.is=is;
            scanParam{x,y,z}.pHa=pHa;
            %ensure that pH is not out of applicable range
            pHc=realpH(pHa,temp,is);
            if pHc<5 || pHc>9
                METDATA{x,y,z}=[];
                scanParam{x,y,z}.data=false;
            else
                modelT=setupThermoModel(model,metAbbrAlbertyAbbr,...
                    iAF1260,Alberty2006,temp,pHc,pHc,pHc,is,is,biomassRxnAbbr,Ecoli_symphID_rxnAbbr);
                METDATA{x,y,z}=modelT.met;
                scanParam{x,y,z}.data=true;
            end
            pHa=pHa+pHaIncrement;
        end
        is=is+isIncrement;
    end
    temp=temp+tempIncrement;
end
            
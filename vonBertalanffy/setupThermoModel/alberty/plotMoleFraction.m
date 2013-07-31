function plotMoleFraction(metAbbr,Alberty2006,metAbbrAlbertyAbbr,PHmin,PHmax,ISmin,ISmax,CHImin,CHImax,TEMPmin,TEMPmax,N)
%Plot the mole fractions of metabolite species of a reactant as a function of pH, ionic strength, charge and temperature.
%
% INPUT
% metAbbr               reconstruction reactant abbreviation
% Alberty2006           Basic data on the metabolite species that make
%                       up a reactant, compiled by Robert A. Alberty,
%                       Massachusetts Institute of Technology.
%                       In Print: Robert A. Alberty, Biochemical Thermodynamics: 
%                       Applications of Mathematica. John Wiley & Sons, 2006. p391-395
%                       Online: BasicBioChemData3.nb
%                       http://library.wolfram.com/infocenter/MathSource/5704/ 
% metAbbrAlbertyAbbr    mapping from model metabolite primary key to
%                       primary key of reactants in Alberty2006
%
% PHmin     Minimum glass electrode pH
% PHmax     Maximum glass electrode pH
% ISmin     Ionic strength minimum
% ISmax     Ionic strength maximum
% CHImin    Electrical potential minimum
% CHImax    Electrical potential maximum
% TEMPmin   temperature minimum
% TEMPmax   temperature maximum
%
% Ronan M. T. Fleming

%find the alberty abbreviation for this metabolite Abbreviation
albertyAbbr=metAbbrAlbertyAbbr(strcmp(metAbbr,metAbbrAlbertyAbbr(:,2)),3);

%make a list of alberty abbreviations
klt=size(Alberty2006,2);
allAlbertyAbbr=cell(klt,1);
for k=1:klt
    allAlbertyAbbr{k}=Alberty2006(k).abbreviation;
end
%find the number of species within pseudoisomer group
nSpecies=nnz(~isnan(Alberty2006(strcmp(albertyAbbr,allAlbertyAbbr)).basicData(:,1)));

if 1
    Ni=N;
    Nj=1;
    Nk=1;
    Np=1;
else
    if 1
        Ni=N;
        Nj=2;
        Nk=1;
        Np=1;
    else
        Ni=N;
        Nj=N;
        Nk=N;
        Np=N;
    end
end

%create vectors of changing pH, ionic strength and electrical potential
pHVec  = linspace(PHmin,PHmax,Ni);
isVec  = linspace(ISmin,ISmax,Nj);
chiVec = linspace(CHImin,CHImax,Nk);
tempVec = linspace(TEMPmin,TEMPmax,Np);
    
MF=zeros(nSpecies,Ni,Nj,Nk,Np);

%initialise temp and is
temp=tempVec(1);
is=isVec(1);

for i=1:Ni
    pHa=pHVec(i);
    if 0
        %convert to real pH
        [pHr,pHAdjustment]=realpH(pHa,temp,is);
    else
        pHr=pHa;
    end
    
    for j=1:Nj
        is=isVec(j);
        for k=1:Nk
            chi=chiVec(k);
            for p=1:Np
                temp=tempVec(p);
                
                MF(:,i,j,j,p)=moleFraction(metAbbr,Alberty2006,metAbbrAlbertyAbbr,temp,pHa,is,chi);
            end
        end
    end
end

for n=1:nSpecies
    legendCellArray{n}=[metAbbr int2str(Alberty2006(strcmp(albertyAbbr,allAlbertyAbbr)).basicData(n,3))];
end

if 1
    figure;
    hold on
    plot(pHVec,MF(:,:,1,1,1));
    legend(legendCellArray)
    xlabel('pH')
    ylabel('mole fraction')
end
        
                
            
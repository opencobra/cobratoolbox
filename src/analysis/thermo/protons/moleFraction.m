function mf=moleFraction(metAbbr,Alberty2006,metAbbrAlbertyAbbr,temp,pHa,is,chi)
%mole fraction of different metabolite species that make up a reactant
%
%INPUT
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
% OPTIONAL INPUT
% temp
% pHa
% is
% temp
% chi
%
%OUTPUT
% mf          mole fraction at equilibrium
%
%Ronan M. T. Fleming

if ~exist('temp','var')
    temp=298.15;
end
if ~exist('pHa','var')
    pHa=0;
end
if ~exist('pHa','var')
    pHa=0;
end
if ~exist('is','var')
    is=0;
end
if ~exist('chi','var')
    chi=0;
end

%find the alberty abbreviation for this metabolite Abbreviation
albertyAbbr=metAbbrAlbertyAbbr(strcmp(metAbbr,metAbbrAlbertyAbbr(:,2)),3);

%make a list of alberty abbreviations
klt=size(Alberty2006,2);
allAlbertyAbbr=cell(klt,1);
for k=1:klt
    allAlbertyAbbr{k}=Alberty2006(k).abbreviation;
end
%index for matching data for the alberty abbreviation
n=find(strcmp(albertyAbbr,allAlbertyAbbr));

if 0
    %convert to real pH
    [pHr,pHAdjustment]=realpH(pHa,temp,is);
else
    pHr=pHa;
end

%find the number of species within pseudoisomer group
p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
            
%Legendre transformation for pH and electrical potential
Legendre     = 1;
LegendreCHI  = 1;

[dGf0,dHf0,mf,aveHbound,aveZi,lambda,gpfnsp]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,temp,chi,Legendre,LegendreCHI);

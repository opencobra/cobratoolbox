function [Ka,pKa]=acidDissociationConstant(metAbbr,Alberty2006,metAbbrAlbertyAbbr,temp,is,chi)
%acid dissociation constant for the different metabolite species that make up a reactant
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
% temp                  temperature (default 298.15 K)
% is                    ionic strength (default 0 M)
% chi                   electrical potential (default 0)
%
%OUTPUT
% Ka          apparent equilibrium constants
% pKa         -log10(Ka)

if ~exist('temp','var')
    temp=298.15;
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


%find the number of species within pseudoisomer group
p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
            
%no Legendre transformation for pH or electrical potential
Legendre     = 0;
LegendreCHI  = 0;
pHr = 7; %dummy, has no effect

[dGf0,dHf0,mf,aveHbound,aveZi,lambda,gpfnsp]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,temp,chi,Legendre,LegendreCHI);

Ka=zeros(p-1);
pKa=zeros(p-1);

gasConstant = 8.314472/1000; % kJ K-1 mol-1

%RTalpha p 49 Alberty 2003
%where alpha is the Debye-Huckel Constant
gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;

% A <--> A- + H+
% Take into account the ionic strength effect on the Gibbs energy of a
% hydrogen ion
zi=1;
hydrogenIonistermG = -(gibbscoeff*(zi.^2)*is^0.5)/(1 + 1.6*is^0.5);

for x=1:p-1
    
    Ka(x)  =  exp((gpfnsp(x+1,1)-gpfnsp(x,1)-hydrogenIonistermG)/(gasConstant*temp));
    if 1
        pKa(x) =  -(gpfnsp(x+1,1)-gpfnsp(x,1)-hydrogenIonistermG)/(gasConstant*temp*log(10));
    else
        %p244 Alberty 2003 uses a slightly less accurate gas constant so slight
        %difference
        gpfnsp=Alberty2006(n).basicData(1:p,1);
        pKa(x) =  -(gpfnsp(x+1,1)-gpfnsp(x,1))/(log(10)* 8.31451 * .29815);
    end
end
function [atomicWeights]=parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements
% Parses NIST data on atomic weights
%
% The atomic weight    J. S. Coursey, D. J. Schwab, and R. A. Dragoset 
% NIST, Physics Laboratory, Office of Electronic Commerce in Scientific and 
% Engineering Data 
% The atomic weights are available for elements 1 through 112, 114, & 116 and
% isotopic compositions or abundances are given when appropriate. The atomic 
% weights data were published by T.B. Coplen1 in Atomic Weights of the Elements
% 1999, (and include changes reported from the 2001 review in Chem. Int., 23, 179 (2001))
% and the isotopic compositions data were published by K.J.R. Rosman2 and P.D.P. Taylor3 
% in Isotopic Compositions of the Elements 1997. The relative atomic masses of the
% isotopes data were published by G. Audi4 and A. H. Wapstra5 in The 1995 Update To
% The Atomic Mass Evaluation.
% http://physics.nist.gov/PhysRefData/Compositions/
%
% Ronan Fleming 9 March 09

fid=fopen('Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.txt','r');

nElements=2816/8;
p=1;
ele=1;
fieldNames={'AtomicNumber';
'AtomicSymbol';
'MassNumber';
'RelativeAtomicMass';
'IsotopicComposition';
'StandardAtomicWeight';
'Notes'};

for x=1:2816
    line= fgetl(fid);
    if ~isempty(line)
        if p==2 || p==7
            tmp=textscan(line,'%s%s\n',2815,'Delimiter','=(','TreatAsEmpty',' ');
            if ~isempty(tmp{2})
                atomicWeights.data(ele).(fieldNames{p})=tmp{2};
            end
            if p==2
                tmp2=tmp{2};
                if ~isempty(tmp2)
                    atomicWeights.AtomicSymbol{ele}=tmp2{1};
                end
            end
        else
            tmp=textscan(line,'%s%f\n',2815,'Delimiter','=(','TreatAsEmpty',' ');
            atomicWeights.data(ele).(fieldNames{p})=tmp{2};
        end
        p=p+1;
    else
        ele=ele+1;
        p=1;
    end
end

fclose(fid);


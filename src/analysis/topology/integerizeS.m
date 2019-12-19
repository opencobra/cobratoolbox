function [SInteger,G]=integerizeS(S,SIntRxnBool)
%convert an S matrix with some non integer coefficients into an S matrix 
%with all integer coefficients
%assumes that there are a maximum of six significant digits in the biomass
%reaction
%
%INPUT
% S         stoichiometric matrix
%
%OPTIONAL INPUT
% SIntRxnBool         Boolean of internal (mass balanced) reactions.
%                     If provided, only these reactions are integerised
%
%OUTPUT
% SInteger  stoichiometric matrix of integers
% G         scaling matrix, SInteger=S*G;
%

if ~exist('SIntRxnBool')
   SIntRxnBool=true(size(S,2),1);       
end

Sabs=abs(S);
Srem=Sabs-floor(Sabs);

[nMet,nRxn]=size(S);
G=speye(nRxn);
for n=1:nRxn
    if SIntRxnBool(n)
        if max(Srem(:,n))~=0
            fprintf('%s\t','Reaction ');
            fprintf('%s\t',int2str(n));
            if length(find(Srem(:,n)~=0))>6
                fprintf('%s\n',' a biomass reaction multiplied by 1e6');
                G(n,n)=1e6;
            else
                sigDigit=1;
                while sigDigit>0
                    Srem2=Srem(:,n)*10*sigDigit;
                    Srem2=Srem2-floor(Srem2);
                    if max(Srem2)~=0
                        sigDigit=sigDigit+1;
                    else
                        G(n,n)=10*sigDigit;
                        fprintf('%s\n',['multiplied by ' int2str(10*sigDigit)]);
                        break;
                    end
                end
            end
        end
    end
end
SInteger=fix(S*G);
            
        
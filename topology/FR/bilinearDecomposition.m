function [A,B,C]=bilinearDecomposition(S)
% Convert a stoichiometric matrix into a bilinear form.
% An example "bilinearisation" of the reaction
% A + B + C <-> D + E
% is
% A + B <-> P
% P + C <-> Q
% Q <-> D + E
% where P and Q are faux molecular species.
%
% INPUT
% S         m x n stoichiometric matrix
% 
% OUTPUT
% A         m       x (m + k) matrix selecting rows such that S=A*B*C
% B         (m + k) x (n + k) bilinear stoichiometric matrix
% C         (n + k) x      n  matrix adding columns to form net reaction
%                             stoichiometry such that S=A*B*C

[nMet,nRxn]=size(S);

Sbool=S~=0;

%boolean of forward and reverse half stoichiometric matrices 
F       =  Sbool;
F(S>0)  =      0;
R       =  Sbool;
R(S<0)  =      0;

nReactants=sum(Sbool,1);
nSubstrates=sum(F,1);
nProducts=sum(R,1);

%number of reactants above 3
nExtraReactants=nReactants-3;
nExtraReactants(nExtraReactants<=0)=0;

%indices of reactions with more than 3 reactants of all the same sign
sameSignBool = (nReactants==nSubstrates | nReactants==nProducts) & nReactants>3;
nExtraReactants(sameSignBool)=nExtraReactants(sameSignBool)+1;

cumSumExtraReactants=cumsum(nExtraReactants);
nExtra=cumSumExtraReactants(length(cumSumExtraReactants));

A = [eye(nMet), sparse(nMet,nExtra)];
    
B = sparse(nMet+nExtra,nRxn+nExtra);

C =  [eye(nRxn);sparse(nExtra,nRxn)];

if 0
    %use full matrices if debugging
    A=full(A);
    B=full(B);
    C=full(C);
end

x=1;
for n=1:nRxn
%     if n==745%83%7384
%         %pause(eps);
%     end
    substrateInd=find(F(:,n)~=0);
    productInd  =find(R(:,n)~=0);
    if nExtraReactants(n)>0
        if nnz(B(:,n))>0
            disp(sparse(B(:,n)))
            error('Already entries in B(:,n)')
        end
        switch length(substrateInd)
            case 0
                switch length(productInd)
                    case 1
                        %product in current reaction
                        B(productInd,n)=S(productInd,n);
                    case 2
                        %product in current reaction
                        B(productInd,n)=S(productInd,n);
                    otherwise
                        %real product in real reaction
                        B(productInd(1),n)=S(productInd(1),n);
                        %fake product in real reaction
                        B(nMet+x+1,n)=1;
                        for j=2:length(productInd)-1
                            if j<length(productInd)-1
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real product in fake reaction
                                B(productInd(j),nRxn+x)=S(productInd(j),n);
                                %fake product in fake reaction
                                B(nMet+x+1,nRxn+x)=1;
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            else
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real products in fake reaction
                                B(productInd(j:j+1),nRxn+x)=S(productInd(j:j+1),n);
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            end
                        end
                end
            case 1
                %substrate in current reaction
                B(substrateInd,n)=S(substrateInd,n);
                switch length(productInd)
                    case 0
                    case 1
                        %product in current reaction
                        B(productInd,n)=S(productInd,n);
                    case 2
                        %product in current reaction
                        B(productInd,n)=S(productInd,n);
                    otherwise
                        %real product in real reaction
                        B(productInd(1),n)=S(productInd(1),n);
                        %fake product in real reaction
                        B(nMet+x+1,n)=1;
                        for j=2:length(productInd)-1
                            if j<length(productInd)-1
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real product in fake reaction
                                B(productInd(j),nRxn+x)=S(productInd(j),n);
                                %fake product in fake reaction
                                B(nMet+x+1,nRxn+x)=1;
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            else
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real products in fake reaction
                                B(productInd(j:j+1),nRxn+x)=S(productInd(j:j+1),n);
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            end
                        end
                end
            case 2
                %two substrates in current reaction
                B(substrateInd,n)=S(substrateInd,n);
                switch length(productInd)
                    case 0
                    case 1
                        %one product in current reaction
                        B(productInd,n)=S(productInd,n);
                    otherwise
                        %fake product in current reaction
                        B(nMet+x,n)=1;
                        for i=1:length(productInd)-1
                            if i<length(productInd)-1
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real product in fake reaction
                                B(productInd(i),nRxn+x)=S(productInd(i),n);
                                %fake product in fake reaction
                                B(nMet+x+1,nRxn+x)=1;
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            else
                                %fake substrate in fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real products in fake reaction
                                B(productInd(end-1:end),nRxn+x)=S(productInd(end-1:end),n);
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            end
                        end
                end
            otherwise
                %more than two substrates
                
                %first two substrates in current reaction
                B(substrateInd(1:2),n)=S(substrateInd(1:2),n);
                %fake product in current reaction
                B(nMet+x,n)=1;
                
                %third substrate and onward
                i=3;
                while i<=length(substrateInd)
                    if i<length(substrateInd)
                        %fake substrate in fake reaction
                        B(nMet+x,nRxn+x)=-1;
                        %real substrate in fake reaction
                        B(substrateInd(i),nRxn+x)=S(substrateInd(i),n);
                        %fake product in fake reaction
                        B(nMet+x+1,nRxn+x)=1;
                        %record index of fake reaction
                        C(nRxn+x,n)=1;
                        %move to next fake reaction
                        x=x+1;
                    else
                        %this is the last substrate index
                        switch length(productInd)
                            case 0
                                %last substrate, no product
                                %fake substrate in current fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real substrate in fake reaction
                                B(substrateInd(i),nRxn+x)=S(substrateInd(i),n);
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            case 1
                                %last substrate, only one product
                                %fake substrate in current fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real substrate in fake reaction
                                B(substrateInd(i),nRxn+x)=S(substrateInd(i),n);
                                %real product in current fake reaction
                                B(productInd,nRxn+x)=S(productInd,n);
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                            otherwise
                                %last substrate, more than one product
                                %fake substrate in current fake reaction
                                B(nMet+x,nRxn+x)=-1;
                                %real substrate in fake reaction
                                B(substrateInd(i),nRxn+x)=S(substrateInd(i),n);
                                %fake product in fake reaction
                                B(nMet+x+1,nRxn+x)=1;
                                %record index of fake reaction
                                C(nRxn+x,n)=1;
                                %move to next fake reaction
                                x=x+1;
                                %products
                                j=1;
                                while j<=length(productInd)-1
                                    if j<length(productInd)-1
                                        %fake substrate in fake reaction
                                        B(nMet+x,nRxn+x)=-1;
                                        %real product in fake reaction
                                        B(productInd(j),nRxn+x)=S(productInd(j),n);
                                        %fake product in fake reaction
                                        B(nMet+x+1,nRxn+x)=1;
                                        %record index of fake reaction
                                        C(nRxn+x,n)=1;
                                        %move to next fake reaction
                                        x=x+1;
                                    else
                                        %fake substrate in fake reaction
                                        B(nMet+x,nRxn+x)=-1;
                                        %real products in fake reaction
                                        B(productInd(j:j+1),nRxn+x)=S(productInd(j:j+1),n);
                                        %record index of fake reaction
                                        C(nRxn+x,n)=1;
                                        %move to next fake reaction
                                        x=x+1;
                                    end
                                    %move to next product (or terminate while loop)
                                    j=j+1;
                                end
                        end
                    end
                    %move to next substrate (or may terminate while loop)
                    i=i+1;
                end
        end
    else
        B(1:nMet,n)=S(:,n);
    end
    
    if nnz(B(:,n))>3
        error('too many entries in B(:,n)')
    end
    if 0
        disp(n)
        disp(size(S))
        disp(size(A))
        disp(size(B))
        disp(size(C))
    end
    
    %check decomposition of this reaction
    decompositionCheck=sum(abs(S(:,n)-sparse(A*B*C(:,n))),1);
    if any(decompositionCheck)
        disp(n)
        disp(sparse(B(:,n)))
        disp(sparse(S(:,n)))
        disp(sparse(A*B*C(:,n)))
        error(['Decomposition incorrect for reaction ' int2str(n)])
    end
    
    %check that we are in the right part to the matrix
    if cumSumExtraReactants(n)~=x-1
        disp(n)
        disp(cumSumExtraReactants(n))
        disp(x-1)
        error('Inconsistent number of fake metabolites/reactions')
    end
end             

if nExtra~=(x-1)
    disp(nExtra)
    disp(x-1)
    error('Inconsistent number of fake metabolites/reactions')
end

%final check
decompsitionCheck=nnz(S-A*B*C);
if decompsitionCheck
    disp(decompsitionCheck)
    error('Decomposition incorrect');
end

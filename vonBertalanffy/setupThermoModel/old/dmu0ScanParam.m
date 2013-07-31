function [dmu0,T,PH,IS]=dmu0ScanParam(scanParam,METDATA,modelT,rxnAbbr)
% plot the standard transformed reaction Gibbs energy  as a function
% of temperture, ionic strength, and pH

[mlt,nlt,olt]=size(scanParam);

Sj=modelT.S(:,strcmp(modelT.rxns,rxnAbbr));

[nMet,nRxn]=size(modelT.S);

dmu0=zeros(mlt,nlt,olt);
T=zeros(1,mlt);
IS=zeros(1,nlt);
PH=zeros(1,olt);
for m=1:mlt
    for n=1:nlt
        for o=1:olt
            T(1,m)=scanParam{m,n,o}.temp;
            IS(1,n)=scanParam{m,n,o}.is;
            PH(1,o)=scanParam{m,n,o}.pHa;
            mu0=zeros(1,nMet);
            met=METDATA{m,n,o};
            if ~isempty(met)
                for x=1:nMet
                    mu0(1,x)=(met(x).mu0Min+met(x).mu0Max)/2;
                end
                dmu0(m,n,o)=mu0*Sj;
            else
                dmu0(m,n,o)=NaN;
            end
        end
    end
end

% D=reshape(dmu0(20,:,:),20,20);
% %temp 311.15
% for n=1:nlt
%     for o=1:olt
%         D(n,o)=exp(dmu0(20,n,o)/(modelT.gasConstant*311.15));
%     end
% end
% figure
% surf(PH,IS,D,'EdgeColor','none');
% xlabel('pH','FontSize',12)
% ylabel('ionic strength (mol L^{-1})','FontSize',12)
% zlabel('\Delta_{r}G^{\primeo} (kJ mol^{-1})','FontSize',12)
% title('Standard transformed Gibbs energy of formation $\n$ as a function of pH and ionic strength','FontSize',12)
% shading interp
% 
% %pH 7.6
% D=reshape(dmu0(20,:,:),20,20);
% for m=1:mlt
%     for o=1:olt
%         D(m,o)=exp(dmu0(m,14,o)/(modelT.gasConstant*T(m)));
%     end
% end
% figure;
% surf(T,IS,D,'EdgeColor','none');
% xlabel('temp (K)','FontSize',12)
% ylabel('ionic strength (mol L^{-1})','FontSize',12)
% zlabel('\Delta_{r}G^{\primeo} (kJ mol^{-1})','FontSize',12)
% title('Standard transformed Gibbs energy of formation $\n$ as a function of temperature and ionic strength','FontSize',12)
% shading interp

rxn=modelT.rxnNames{strcmp(rxnAbbr,modelT.rxns)};
%equilibrium constants
% D=reshape(dmu0(20,:,:),20,20);
%temp 311.15
D=zeros(nlt,olt);
for n=1:nlt
    for o=1:olt
        D(n,o)=exp(dmu0(20,n,o)/(modelT.gasConstant*T(20)));
    end
end
% surf(X,Y,Z)  creates a shaded surface using Z for the color data as well
% as surface height.
% If X and Y are vectors, length(X) = n and length(Y) = m, where [m,n] = size(Z). 
% In this case, the vertices of the surface faces are (X(j), Y(i), Z(i,j)) triples.
figure
surf(PH,IS,D,'EdgeColor','none');%(X(j), Y(i), Z(i,j)) triples
xlabel('pH','FontSize',12)
xlim([min(PH) max(PH)])
ylabel('ionic strength (mol L^{-1})','FontSize',12)
ylim([min(IS) max(IS)])
zlabel('K\prime','FontSize',12)
title({rxn,'Apparent Equilibrium constant as a function of','pH and ionic strength. (311.15 K)'},'FontSize',12)
shading interp

%pH 7.6
% D=reshape(dmu0(20,:,:),20,20);
D2=zeros(mlt,olt);
for m=1:mlt
    for o=1:olt
        D2(m,o)=exp(dmu0(m,o,14)/(modelT.gasConstant*T(m)));
    end
end
figure;
surf(IS,T,D2,'EdgeColor','none');%(X(j), Y(i), Z(i,j)) triples
xlabel('ionic strength (mol L^{-1})','FontSize',12)
xlim([min(IS) max(IS)])
ylabel('temp (K)','FontSize',12)
ylim([min(T) max(T)])
zlabel('K\prime','FontSize',12)
title({rxn,'Apparent Equilibrium constant as a function of',' temperature and ionic strength. (pH 7.6)'},'FontSize',12)
shading interp

%all three



function [n,edges,lambda]=plotActivityCoefficients(modelT)
%Plots statistics on activity coefficients.
%
%plot a histogram of the distribution of activity coefficients
%also a curve of  activity coefficients for different charges at a range of
%ionic strengths 
%
%INPUT
% model.met(i).lambda   activity coefficient
% model.temp            temperature
% 
% Ronan M. T. Fleming

[nMet,nRxn]=size(modelT.S);
p=1;
for x=1:nMet
    if ~isempty(modelT.met(x).lambda)
        for q=1:length(modelT.met(x).lambda)
            lambda(p)=modelT.met(x).lambda(q);
            if lambda(p)<0.01
                fprintf('%d\t%s\t%s\t%d\t%d\n',x,modelT.mets{x},modelT.metNames{x},modelT.met(x).aveZi,lambda(p));
            end
            p=p+1;
        end
    end
%     chargeMag(x)=abs(modelT.met(x).aveZi);
end

edges=[0:0.01:1];
n = histc(lambda,edges);
bar(edges-0.005,n)
% xlim([0 1])
set(gca,'FontSize',14)
xlabel('Activity Coefficient','FontSize',16)
ylabel('# Metabolite Species','FontSize',16)

% figure
% hist(chargeMag)

temp=modelT.temp; 
gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;
gasConstant=modelT.gasConstant;
isAll=zeros(1000,1);
for x=1:1000
    is=isAll(x);
    for zi=1:4 
        lambda(zi,x)=exp(-(gibbscoeff/(gasConstant*temp))*(((zi.^2)*is^0.5)/(1 + 1.6*is^0.5)));
    end
    isAll(x+1)=isAll(x)+(0.25/1000);
end
figure;
plot(isAll(1:1000),lambda','LineWidth',2)
ylabel('Activity Coefficient, \gamma','FontSize',16)
xlabel('Ionic strength (mol/L)','FontSize',16)
set(gca,'FontSize',14)
function [D,DGC]=plotConcVSdGft0GroupContUncertainty(modelT)
% compare the difference between minimum & maximum concentration, on a
% logarithmic scale, and the group contribution uncertainty for each
% metabolite
%
%INPUT
% modelT.met(m).concMax
% modelT.met(m).concMin
% modelT.met(m).dGft0GroupContUncertainty
%

[nMet,nRxn]=size(modelT.mets);

RT=modelT.temp*modelT.gasConstant;

D=zeros(nMet,1);
DGC=zeros(nMet,1);
q=0;
q2=0;
r=0;
for m=1:nMet
    d=(RT*log(modelT.met(m).concMax/modelT.met(m).concMin))/2;
    dgc=modelT.met(m).dGft0GroupContUncertainty;
    if isempty(d) || isnan(dgc)
        D(m)=NaN;
        DGC(m)=NaN;
    else
        D(m)=d;
        DGC(m)=dgc;
        if dgc>(d/2)
            q=q+1;
        end
        if dgc>(d)
            q2=q2+1;
        end
        r=r+1;
    end
end

fraction=q/r;
fraction2q=q2/r

q2=0;
r2=0;
for m=1:nMet
    d=(RT*log(modelT.met(m).concMax/modelT.met(m).concMin))/2;
    dgc=modelT.met(m).dGft0GroupContUncertainty;
    if strcmp(modelT.met(m).dGft0Source,'Keq')
        dgc=NaN;
    end
    if ~(isempty(d) || isnan(dgc))
        if dgc>(d/2)
            q2=q2+1;
        end
        r2=r2+1;
    end
end

fraction2r=q2/r2



fprintf('%s\n',['Fraction of metabolites where GC uncertainty is more significant: ' num2str(fraction)]);

d=(RT*log(20/0.2))/2;

% figure
% plot(D,DGC,'.')
% plot(DGC,'.')

figure1=figure;
axes1 = axes('Parent',figure1,'FontSize',14,'CLim',[1 2],'Layer','top');
hist(DGC,100)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
line([d d],[0 300],'Color','b','LineWidth',4,'LineStyle','--')

text('Position',[d,175],'String','$$\longleftarrow\;5.9=\frac{1}{2}RT\ln\left(\frac{20}{0.2}\right)$$','Interpreter','latex','FontSize',18,'Color','b');

xlim([0, 100])
set(gca,'XTick',0:10:100,'TickDir','out')
ylabel('# Reactants','FontSize',14)
xlabel('Standard Error in {\Delta_{f}G_{est}^{0}} (kJ/mol)','FontSize',14)
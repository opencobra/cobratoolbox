function [priorityKeq,numNonKeqMet]=priorityKeqMeasurement(modelT)
%optimal order of Keq measurement
%
%find the optimal order of Keq measurement to completely define all 
%standard Gibbs energies of formation for all metabolites. If the end of
%the loop is all reactions with two metabolites each then the loop is
%terminated
%
%INPUT
% modelT.S
% modelT.met(m).dGft0Source
%
%OUTPUT
% priorityKeq           structure indicating which reactions to measure Keq
% priorityKeq{p,1}      rxn abbr
% priorityKeq{p,2}      rxn name
% priorityKeq{p,3}      met abbr
% priorityKeq{p,4}      rxn name
% priorityKeq{p,5}      met name
% priorityKeq{p,5}      number of reactions the same metabolite appears in
%                       this give options for which reaction to measure
% numNonKeqMet        number of metabolites without data at each iteration
%
%Ronan M.T. Fleming

[nMet,nRxn]=size(modelT.S);
KeqMetBool=false(nMet,1);
for m=1:nMet
    if strcmp(modelT.met(m).dGft0Source,'Keq')
        KeqMetBool(m)=1;
    end
    %ignore protons
    abbr=modelT.mets{m};
    abbr=abbr(1:end-3);
    if strcmp(abbr,'h')
        KeqMetBool(m)=1;
    end
end

if nnz(KeqMetBool)==0
    error('No metabolite data measured with Keq')
end

intRxnBool=modelT.SIntRxnBool;

KeqMet=find(KeqMetBool==1);
nonKeqMet=find(KeqMetBool==0);

measuredMet=[];
p=1;
nNon=1;
%find the metabolites that have not been measured
nonKeqMet=setdiff(nonKeqMet,measuredMet);
numNonKeqMet(nNon)=length(nonKeqMet);
%keep measuring until no metabolite data is unknown
while ~isempty(nonKeqMet)
    measuredMet=[];
    q=1;
    q2=1;
    qpriorityKeq=[];
    %find reactions with only one metabolite data missing
    for n=1:nRxn
        %only internal reactions
        if intRxnBool(n)
            nonZeroMet=find(modelT.S(:,n)~=0);
            %find the metabolites in this reaction that have no Keq
            missingMet=intersect(nonZeroMet,nonKeqMet);
            if length(missingMet)==1
                %store the metabolites to be measured in this round
                measuredMet(q)=missingMet;
                %abbreviation of measured metabolite
                abbr=modelT.mets{missingMet};
                abbr=abbr(1:end-3);
                officialName=modelT.met(missingMet).officialName;
                if isempty(qpriorityKeq)
                    bool=0;
                else
                    bool=strcmp(abbr,qpriorityKeq(:,3));
                end
                %store the reaction Keq to be measured
                if strcmp(modelT.rxns{n},'RMI')
                    pause(0.1);
                end
                if ~any(bool)
                    qpriorityKeq{q,1}=modelT.rxns{n};
                    qpriorityKeq{q,2}=modelT.rxn(n).officialName;
                    qpriorityKeq{q,3}=abbr;
                    qpriorityKeq{q,4}=modelT.rxn(n).equation;
                    qpriorityKeq{q,5}=officialName;
                    qpriorityKeq{q,6}=1;
                else
                    qpriorityKeq{q,1}=modelT.rxns{n};
                    qpriorityKeq{q,2}=modelT.rxn(n).officialName;
                    qpriorityKeq{q,3}=abbr;
                    qpriorityKeq{q,4}=modelT.rxn(n).equation;
                    qpriorityKeq{q,5}=officialName;
                    ind=find(bool==1);
                    qpriorityKeq{q,6}=length(ind)+1;
                    for s=1:length(ind)
                        %increment the other reactions to be measured to
                        %indicate that measuring this reaction also provides
                        %knowledge on other reactions since the same metabolite
                        %is involved
                        qpriorityKeq{ind(s),6}=length(ind)+1;
                    end
                end
                q=q+1;
%             else
%                 if length(missingMet)==2
%                     %store the important metabolites to be measured in this round
%                     measuredMet(q2)=missingMet(1);
%                     q2=q2+1;
%                     measuredMet(q2)=missingMet(2);
%                     q2=q2+1;
%                 end
            end
                    
        end
    end
    nNon=nNon+1;
    nRxn1=length(nonKeqMet);
    %find the metabolites that have not been measured
    nonKeqMet=setdiff(nonKeqMet,measuredMet);
    nRxn2=length(nonKeqMet);
    numNonKeqMet(nNon)=length(nonKeqMet);
    measuredMetRxnRatio(nNon)=length(measuredMet)/(nRxn1-nRxn2);
    %if the same number of reactions still remain after another
    %iteration then there are metabolites which cannot be measured
    %using Keq.
    if numNonKeqMet(nNon)==numNonKeqMet(nNon-1)
        break;
    else
        fprintf('%s\n',['# metabolites without standard Gibbs energies of formation: ' int2str(numNonKeqMet(nNon))]);

        qpriorityKeqNum=zeros(size(qpriorityKeq,1),1);
        for x=1:size(qpriorityKeq,1)
            qpriorityKeqNum(x)=qpriorityKeq{x,6};
        end
        [x, xi] = sort(qpriorityKeqNum,'descend');
        %sorted version by important reactions
%         firstMetAbbr=qpriorityKeq{xi(x),3};
        for x=1:size(qpriorityKeq,1)
%             %only measure the reaction that gives the 
%             if isempty(qpriorityKeq{xi(x),3},firstMetAbbr)
%                 break;
%             else
                priorityKeq{p,1}=qpriorityKeq{xi(x),1};
                priorityKeq{p,2}=qpriorityKeq{xi(x),2};
                priorityKeq{p,3}=qpriorityKeq{xi(x),3};
                priorityKeq{p,4}=qpriorityKeq{xi(x),4};
                priorityKeq{p,5}=qpriorityKeq{xi(x),5};
                priorityKeq{p,6}=qpriorityKeq{xi(x),6};
                p=p+1;
%             end
        end
    end
end

figure;
hold on;
xx=1:length(numNonKeqMet);
[AX,H1,H2] = plotyy(xx,numNonKeqMet,xx,measuredMetRxnRatio);
set(H1,'LineStyle','.')
set(H2,'LineStyle','*')
set(get(AX(1),'Ylabel'),'String','# metabolites without Standard Gibbs energies of formation') 
set(get(AX(2),'Ylabel'),'String','Reaction:Metabolite ratio') 
title('Standard Gibbs energies of formation from experimental Equilibrium constants')
xlabel('# iterations')

% function createfigure(X1, Y1, Y2)
% %CREATEFIGURE(X1,Y1,Y2)
% %  X1:  vector of x data
% %  Y1:  vector of y data
% %  Y2:  vector of y data
% 
% %  Auto-generated by MATLAB on 07-Jan-2009 18:42:35
% 
% % Create figure
% figure1 = figure;
% 
% % Create axes
% axes1 = axes('Parent',figure1,...
%     'YTick',[0 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000],...
%     'YColor',[0 0 1],...
%     'FontSize',16);
% % Uncomment the following line to preserve the X-limits of the axes
% % xlim([0 26]);
% % Uncomment the following line to preserve the Y-limits of the axes
% % ylim([400 1400]);
% hold('all');
% 
% % Create plot
% plot(X1,Y1,'Parent',axes1,'MarkerSize',15,'Marker','.','LineStyle','none');
% 
% % Create ylabel
% ylabel('# metabolites without Standard Gibbs energies of formation',...
%     'FontSize',16,...
%     'Color',[0 0 1]);
% 
% % Create title
% title('Standard Gibbs energies of formation from experimental Equilibrium constants',...
%     'FontSize',14);
% 
% % Create xlabel
% xlabel('# iterations','FontSize',16);
% 
% % Create axes
% axes2 = axes('Parent',figure1,'YTick',[0 0.25 0.5 0.75 1 1.25 1.5 1.75 2],...
%     'YAxisLocation','right',...
%     'YColor',[0 0.5 0],...
%     'FontSize',16,...
%     'ColorOrder',[0 0.5 0;1 0 0;0 0.75 0.75;0.75 0 0.75;0.75 0.75 0;0.25 0.25 0.25;0 0 1],...
%     'Color','none');
% % Uncomment the following line to preserve the X-limits of the axes
% % xlim([0 26]);
% % Uncomment the following line to preserve the Y-limits of the axes
% % ylim([0.75 1.75]);
% hold('all');
% 
% % Create plot
% plot(X1,Y2,'Parent',axes2,'MarkerSize',10,'Marker','*','LineStyle','none');
% 
% % Create ylabel
% ylabel('Reaction:Metabolite ratio','VerticalAlignment','cap','FontSize',14,...
%     'Color',[0 0.5 0]);


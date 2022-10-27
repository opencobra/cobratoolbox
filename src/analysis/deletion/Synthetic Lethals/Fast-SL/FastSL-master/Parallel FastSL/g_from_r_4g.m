function [sgd,dgd,tgd,qgd]=gene_form_rxn(model,Jsl,Jdl,Jtl,Jql)
%%
%
%OUTPUT
%sgd        Indices of lethal single gene deletins identified;
%dgd        Indices of lethal double gene deletins identified;
%tgd        Indices of lethal triple gene deletins identified;
%qgd        Indices of lethal triple gene deletins identified;

% Aditya Pratapa       3/9/15. 
%%
sgd=[];
dgd=[];
tgd=[];
qgd=[];

if ~exist('Jsl', 'var')
    Jsl = [];
end

if ~exist('Jdl', 'var')
    Jdl = [];
end

if ~exist('Jtl', 'var')
    Jtl = [];
end


if ~exist('Jql', 'var')
    Jql = [];
end

x = true(size(model.genes));

for i=1:length(Jsl)
    ids=unique(find(model.rxnGeneMat(Jsl(i),:)));
    
    
    if (length(ids)>0 && ~isempty(model.rules{Jsl(i)}))
        
        %Single Gene Deletion
        dummy1=nchoosek(1:length(ids),1);
        for j=1:length(dummy1)
            x(ids(dummy1(j))) = false;
            if (eval(model.rules{Jsl(i)})==false)
                sgd=[sgd;ids(dummy1(j))];
            end
            x(ids(dummy1(j)))=true;
        end
        
        %Double Gene Deletion
        if (length(ids)>1)
            dummy2= nchoosek(1:length(ids),2);
            for j=1:(numel(dummy2)/2)
                x(ids(dummy2(j,:))) = false;
                if (eval(model.rules{Jsl(i)})==false)
                    dgd=[dgd;ids(dummy2(j,:))];
                end
                x(ids(dummy2(j,:))) = true;
            end
            
        end
        
       %Triple Gene Deletion
         if (length(ids)>2)
            dummy3= nchoosek(1:length(ids),3);
            for j=1:(numel(dummy3)/3)
                x(ids(dummy3(j,:))) = false;
                if (eval(model.rules{Jsl(i)})==false)
                    tgd=[tgd;ids(dummy3(j,:))];
                end
                x(ids(dummy3(j,:))) = true;
            end
            
         end
          if (length(ids)>3)
            dummy4= nchoosek(1:length(ids),4);
            for j=1:(numel(dummy4)/4)
                x(ids(dummy4(j,:))) = false;
                if (eval(model.rules{Jsl(i)})==false)
                    qgd=[qgd;ids(dummy4(j,:))];
                end
                x(ids(dummy4(j,:))) = true;
            end
            
        end
        
    end
end

clear ids;
for i=1:numel(Jdl)/2
    ids=unique([find(model.rxnGeneMat(Jdl(i,1),:)) find(model.rxnGeneMat(Jdl(i,2),:))]);
    if (length(ids)>0 && ~isempty(model.rules{Jdl(i,1)}) && ~isempty(model.rules{Jdl(i,2)}))
        
        %Single Gene Deletion
        dummy1=nchoosek(1:length(ids),1);
        for j=1:length(dummy1)
            x(ids(dummy1(j))) = false;
            if (eval(model.rules{Jdl(i,1)})==false)&&(eval(model.rules{Jdl(i,2)})==false)
                sgd=[sgd;ids(dummy1(j))];
            end
            x(ids(dummy1(j)))=true;
        end
        
        %Double Gene Deletion
        if (length(ids)>1)
            dummy2= nchoosek(1:length(ids),2);
            for j=1:(numel(dummy2)/2)
                x(ids(dummy2(j,:))) = false;
                if (eval(model.rules{Jdl(i,1)})==false)&&(eval(model.rules{Jdl(i,2)})==false)
                    dgd=[dgd;ids(dummy2(j,:))];
                end
                x(ids(dummy2(j,:))) = true;
            end
            
        end
        
        
       %Triple Gene Deletion
        if (length(ids)>2)
            dummy3= nchoosek(1:length(ids),3);
            for j=1:(numel(dummy3)/3)
                x(ids(dummy3(j,:))) = false;
                if (eval(model.rules{Jdl(i,1)})==false)&&(eval(model.rules{Jdl(i,2)})==false)
                    tgd=[tgd;ids(dummy3(j,:))];
                end
                x(ids(dummy3(j,:))) = true;
            end
            
        end
        %Quad Gene Deletions
          if (length(ids)>3)
            dummy4= nchoosek(1:length(ids),4);
            for j=1:(numel(dummy4)/4)
                x(ids(dummy4(j,:))) = false;
                if (eval(model.rules{Jdl(i,1)})==false)&&(eval(model.rules{Jdl(i,2)})==false)
                    qgd=[qgd;ids(dummy4(j,:))];
                end
                x(ids(dummy4(j,:))) = true;
            end
            
        end
        
        
    end
end

 
clear ids;
for i=1:numel(Jtl)/3
    ids=unique([find(model.rxnGeneMat(Jtl(i,1),:)) find(model.rxnGeneMat(Jtl(i,2),:)) find(model.rxnGeneMat(Jtl(i,3),:))]);
   
    if (length(ids)>0 && ~isempty(model.rules{Jtl(i,1)}) && ~isempty(model.rules{Jtl(i,2)}) &&  ~isempty(model.rules{Jtl(i,3)}))
        
        %Single Gene Deletion
        dummy1=nchoosek(1:length(ids),1);
        for j=1:length(dummy1)
            x(ids(dummy1(j))) = false;
            if (eval(model.rules{Jtl(i,1)})==false) && (eval(model.rules{Jtl(i,2)})==false) && (eval(model.rules{Jtl(i,3)})==false)
                sgd=[sgd;ids(dummy1(j))];
            end
            x(ids(dummy1(j)))=true;
        end
        
        %Double Gene Deletion
        if (length(ids)>1)
            dummy2= nchoosek(1:length(ids),2);
            for j=1:(numel(dummy2)/2)
                x(ids(dummy2(j,:))) = false;
                if (eval(model.rules{Jtl(i,1)})==false) && (eval(model.rules{Jtl(i,2)})==false) && (eval(model.rules{Jtl(i,3)})==false)
                    dgd=[dgd;ids(dummy2(j,:))];
                end
                x(ids(dummy2(j,:))) = true;
            end
            
        end
        
        
       %Triple Gene Deletion
       
        if (length(ids)>2)
            dummy3= nchoosek(1:length(ids),3);
            for j=1:(numel(dummy3)/3)
                x(ids(dummy3(j,:))) = false;
                if (eval(model.rules{Jtl(i,1)})==false) && (eval(model.rules{Jtl(i,2)})==false) && (eval(model.rules{Jtl(i,3)})==false)
                    tgd=[tgd;ids(dummy3(j,:))];
                end
                x(ids(dummy3(j,:))) = true;
            end
            
        end
        
        if (length(ids)>3)
            dummy4= nchoosek(1:length(ids),4);
            for j=1:(numel(dummy4)/4)
                x(ids(dummy4(j,:))) = false;
                if (eval(model.rules{Jtl(i,1)})==false) && (eval(model.rules{Jtl(i,2)})==false) && (eval(model.rules{Jtl(i,3)})==false)
                    qgd=[qgd;ids(dummy4(j,:))];
                end
                x(ids(dummy4(j,:))) = true;
            end
            
        end
        
    end
end
%%
for i=1:numel(Jql)/4
    
    ids=unique([find(model.rxnGeneMat(Jql(i,1),:)) find(model.rxnGeneMat(Jql(i,2),:)) find(model.rxnGeneMat(Jql(i,3),:)) find(model.rxnGeneMat(Jql(i,4),:))]);
   
    if (length(ids)>0 && ~isempty(model.rules{Jql(i,1)}) && ~isempty(model.rules{Jql(i,2)}) &&  ~isempty(model.rules{Jql(i,3)}) && ~isempty(model.rules{Jql(i,4)}))
        
        %Single Gene Deletion
        dummy1=nchoosek(1:length(ids),1);
        for j=1:length(dummy1)
            x(ids(dummy1(j))) = false;
            if (eval(model.rules{Jql(i,1)})==false) && (eval(model.rules{Jql(i,2)})==false) && (eval(model.rules{Jql(i,3)})==false) && (eval(model.rules{Jql(i,4)})==false)
                sgd=[sgd;ids(dummy1(j))];
            end
            x(ids(dummy1(j)))=true;
        end
        
        %Double Gene Deletion
        if (length(ids)>1)
            dummy2= nchoosek(1:length(ids),2);
            for j=1:(numel(dummy2)/2)
                x(ids(dummy2(j,:))) = false;
                if (eval(model.rules{Jql(i,1)})==false) && (eval(model.rules{Jql(i,2)})==false) && (eval(model.rules{Jql(i,3)})==false) && (eval(model.rules{Jql(i,4)})==false)
                    dgd=[dgd;ids(dummy2(j,:))];
                end
                x(ids(dummy2(j,:))) = true;
            end
            
        end
        
        
       %Triple Gene Deletion
       
        if (length(ids)>2)
            dummy3= nchoosek(1:length(ids),3);
            for j=1:(numel(dummy3)/3)
                x(ids(dummy3(j,:))) = false;
                if (eval(model.rules{Jql(i,1)})==false) && (eval(model.rules{Jql(i,2)})==false) && (eval(model.rules{Jql(i,3)})==false) && (eval(model.rules{Jql(i,4)})==false)
                    tgd=[tgd;ids(dummy3(j,:))];
                end
                x(ids(dummy3(j,:))) = true;
            end
            
        end
        
       %Quadruple Gene Deletion
        if (length(ids)>3)
            dummy4= nchoosek(1:length(ids),4);
            for j=1:(numel(dummy4)/4)
                x(ids(dummy4(j,:))) = false;
                if (eval(model.rules{Jql(i,1)})==false) && (eval(model.rules{Jql(i,2)})==false) && (eval(model.rules{Jql(i,3)})==false) && (eval(model.rules{Jql(i,4)})==false)
                    qgd=[qgd;ids(dummy4(j,:))];
                end
                x(ids(dummy4(j,:))) = true;
            end
            
        end
        
    end
end
%% Eliminate duplicates

sgd=unique(sgd);
dgd=unique(sort(dgd,2),'rows');
tgd=unique(sort(tgd,2),'rows');
qgd=unique(sort(qgd,2),'rows');

%% Eliminate duplicates in dgd
temp=[];
g=zeros(1,length(sgd));


for i=1:size(dgd,1)
    for j=1:length(sgd)
        g(j)=sum(ismember(dgd(i,:),sgd(j)));
        if g(j)>=1
            break;
        end
    end
    if max(g)<1
        temp=[temp;dgd(i,:)];
    end
end

dgd=temp;


%% Eliminate duplicates in tgd
temp=[];
g=zeros(1,length(sgd));

for i=1:length(tgd)
    for j=1:length(sgd)
        g(j)=sum(ismember(tgd(i,:),sgd(j)));
        if g(j)>=1
            break;
        end
    end
    if max(g)<1
        temp=[temp;tgd(i,:)];
    end
end


tgd=[];
tgd=temp;

temp=[];
g=zeros(1,size(dgd,1));

for i=1:length(tgd)
    for j=1:length(dgd)
        g(j)=sum(ismember(tgd(i,:),dgd(j,:)));
        
        if g(j)>=2
            break;
        end
    end
    if max(g)<2
        temp=[temp;tgd(i,:)];
    end
end

tgd=[];
tgd=temp;


%% Eliminate duplicates in QGD

temp=[];
g=zeros(1,length(sgd));

for i=1:length(qgd)
    for j=1:length(sgd)
        g(j)=sum(ismember(qgd(i,:),sgd(j)));
        if g(j)>=1
            break;
        end
    end
    if max(g)<1
        temp=[temp;qgd(i,:)];
    end
end


qgd=[];
qgd=temp;

temp=[];
g=zeros(1,length(dgd));

for i=1:length(qgd)
    for j=1:length(dgd)
        g(j)=sum(ismember(qgd(i,:),dgd(j,:)));
        
        if g(j)>=2
            break;
        end
    end
    if max(g)<2
        temp=[temp;qgd(i,:)];
    end
end

qgd=[];
qgd=temp;



temp=[];
g=zeros(1,length(tgd));
[m,n]=size(qgd);
for i=1:m
    for j=1:length(tgd)
        g(j)=sum(ismember(qgd(i,:),tgd(j,:)));
        
        if g(j)>=3
            break;
        end
    end
    if max(g)<3
        temp=[temp;qgd(i,:)];
    end
end

qgd=[];
qgd=temp;

end

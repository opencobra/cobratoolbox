function [sgd,dgd,tgd]=g_from_r(model,Jsl,Jdl,Jtl)
%%
%
%OUTPUT
%sgd        Indices of lethal single gene deletins identified;
%dgd        Indices of lethal double gene deletins identified;
%tgd        Indices of lethal triple gene deletins identified;
%
% Aditya Pratapa       9/28/14. 
%%
sgd=[];
dgd=[];
tgd=[];

if ~exist('Jsl', 'var')
    Jsl = [];
end

if ~exist('Jdl', 'var')
    Jdl = [];
end

if ~exist('Jtl', 'var')
    Jtl = [];
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
        
    end
end


%% Eliminate duplicates

sgd=unique(sgd);
dgd=unique(sort(dgd,2),'rows');
tgd=unique(sort(tgd,2),'rows');

%% Eliminate duplicates in dgd
temp=[];
g=zeros(1,length(sgd));
for i=1:length(dgd)
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
g=zeros(1,length(dgd));

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

end

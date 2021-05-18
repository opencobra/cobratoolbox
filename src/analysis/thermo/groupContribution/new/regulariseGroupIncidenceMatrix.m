function [groupM,inchiM] = regulariseGroupIncidenceMatrix(combinedModel,printLevel)
% within the combinedModel analyse the similar metabolites (having the same group decomposition vector) and the duplicates (also the same InChI)
%
% INPUT
% combinedModel
% printLevel
%
% OUTPUT
% groupM   nMet xnTrainingMet x nTrainingMet logical matrix, true if metabolite is a duplicate
% inchiM   nTrainingMet x nModelMet logical matrix, true if metabolite is a duplicate

if~exist('printLevel','var')
    printLevel=0;
end

[nMets,nGroups]=size(combinedModel.G);

%omit duplicate test metabolites defined as having the same group decomposition
[groupM,groupDuplicateBool,~,groupIA,groupIC] = duplicates(combinedModel.G);

%add unique numbers instead of empty inchi
inchiApprox=combinedModel.inchi.nonstandard;
inchiApprox(~combinedModel.inchiBool)=cellfun(@int2str,num2cell((1:nnz(~combinedModel.inchiBool))'),'UniformOutput',0);
[inchiM,inchiDuplicateBool,~,inchiIA,inchiIC] = duplicates(inchiApprox);

% combinedModel.trainingMetBool  k x 1 boolean indicating training metabolites in G
nTrainingModelMets = nnz(combinedModel.trainingMetBool);
% combinedModel.testMetBool  k x 1 boolean indicating test metabolites in G
nModelMets = nnz(combinedModel.testMetBool);

printParent=1;
for i=1:nMets
    if ~(groupDuplicateBool(i) || inchiDuplicateBool(i))
        duplicateInd=find(groupM(i,:) | inchiM(i,:));
        for k=1:length(duplicateInd)
            j=duplicateInd(k);
            %duplicates within the training set
            if combinedModel.trainingMetBool(i) && combinedModel.trainingMetBool(j)
                if strcmp(inchiApprox{i},inchiApprox{j})
                else
                    % D-Fructose 6-phosphate
                    % t*C00085       InChI=1/C6H13O9P/c7-2-6(10)5(9)4(8)3(15-6)1-14-16(11,12)13/h3-5,7-10H,1-2H2,(H2,11,12,13)/p-2/t3-,4-,5+,6?/m1/s1/fC6H11O9P/q-2
                    % D-Fructose 1-phosphate
                    % t C01094       InChI=1/C6H13O9P/c7-1-3-4(8)5(9)6(10,15-3)2-14-16(11,12)13/h3-5,7-10H,1-2H2,(H2,11,12,13)/p-2/t3-,4-,5+,6?/m1/s1/fC6H11O9P/q-2
                    if printLevel>0 && printParent
                        fprintf('%-20s%s\n',['train*' combinedModel.mets{i}],inchiApprox{i})
                        printParent=0;
                    end
                    if printLevel>0
                        fprintf('%-20s%s\n',['train ' combinedModel.mets{j}],inchiApprox{j})
                    end
                end
            end
            %duplicates between the training and test set
            if combinedModel.trainingMetBool(i) && combinedModel.testMetBool(j)
                if strcmp(inchiApprox{i},inchiApprox{j})
%                     if printLevel>0 && printParent
%                         fprintf('%-20s%s\n',['train*' combinedModel.mets{i}],inchiApprox{i})
%                         printParent=0;
%                     end
%                     if printLevel>0
%                         fprintf('%-20s%s\n',['test  ' combinedModel.mets{j}],inchiApprox{j})
%                     end
                else
                    if printLevel>0 && printParent
                        fprintf('%-20s%s\n',['train*' combinedModel.mets{i}],inchiApprox{i})
                        printParent=0;
                    end
                    if printLevel>0
                        fprintf('%-20s%s\n',['test  ' combinedModel.mets{j}],inchiApprox{j})
                    end
                end
            end
            %duplicates within the test set
            if combinedModel.testMetBool(i) && combinedModel.testMetBool(j)
                if strcmp(inchiApprox{i},inchiApprox{j})
                else
                    if printLevel>0 && printParent
                        fprintf('%-20s%s\n',['test*' combinedModel.mets{i}],inchiApprox{i})
                        printParent=0;
                    end
                    if printLevel>0
                        fprintf('%-20s%s\n',['test  ' combinedModel.mets{j}],inchiApprox{j})
                    end
                end
            end
            
        end
        if printParent==0
            printParent=1;
        end
    end
end



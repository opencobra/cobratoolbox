global CBTDIR
d=[CBTDIR '/testing/testModels/sbml'];
matFiles=dir(d);

for k=3:length(matFiles)
    %disp(k)
    disp(matFiles(k).name)
    fileName=matFiles(k).name;
    filePathName=[d '/' fileName];
    defaultBound=1000;
    fileType='SBML';
    model = readCbModel(filePathName,defaultBound,fileType);
    s=[CBTDIR '/testing/testModels/mat/' fileName(1:end-4) '.mat'];
    disp(s)
    save(s,'model');
end
% % test file for visualization of epistatic interactions
load('testInputEpistasisVisualization.mat', 'Coli')
load('testInputEpistasisVisualization.mat', 'epiColi')
load('testInputEpistasisVisualization.mat', 'genesColi')
[rxns,subsys,subsysGenes,usys] = findSubsystemOfGenes(Coli,genesColi);
[Nall.neg,~,~,Nall.pos] = convertGene2PathwayInteractions(epiColi.sE,subsys,usys);
[np,pos,neg] = visualizePathwayInEpistasis(Nall,15,usys);
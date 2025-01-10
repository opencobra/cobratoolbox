# Install 'piano' if not present
if (!require('piano')) install.packages('piano'); library('piano')

# Set the directory where this R script is present as the working directory
# setwd(dirname(parent.frame(2)$ofile))

# Declare input and output file names
gscFile = "GSC-human.txt"
gssFile = "GSS-human.txt"
resultFile = "EFMEnrichmentResults.xls"

# Read the Gene Set Collection file
genes2geneSets = read.table(file = gscFile, header = F, sep = ' ')
gsc = loadGSC(genes2geneSets)

# Read the Gene Set Statistics file
gss = read.table(file = gssFile, header = T, sep = ' ')

# Assign pvalues and fold changes to separate variables and set the corresponding reaction ID as names to both vectors
pval = gss[,3]
pval=as.numeric(pval)
names(pval) = gss[,1]
fc = gss[,2]
names(fc) = gss[,1]

# Run runGSA
gsaRes = runGSA(pval, gsc = gsc, directions = fc, geneSetStat="stouffer")

# Save the results of enrichment into excel file
GSAsummaryTable(gsaRes, save=TRUE, file=resultFile)

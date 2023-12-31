install.packages('bootstrap')

# Should have 1 file available: 
# <library>.counts.txt
# the sgrna, gene, and controls data are all in that one txt file.
# All files should have three columns, name of guide in first column, name of gene in second and value in second.
# All controls should be at bottom of table.

windows(w=12,h=12)
par(mfrow=c(3,3))

# This section creates graphs from the sgrna count and the gene count which both come from the extended counts table from Latch.
# Replace the C:...txt with the file path to the extended counts table generated by Latch. You can check the file path by finding the file on your
# Computer and then right clicking and clicking copy as path. Then paste it into the file path, but change each '\' to '/' like it is in this example.
# Also change the "Brie Library" name of the graphs to the name of the Library that you are using. You can use the Find and Replace function to make changes.
# Once the code is run, it will open 2 new windows with the graphs on them. From there, go to file then save as. Save both of the sets of graphs
# as PDFs, then you can import them into the report later on.

counts = read.table("C:/Users/.../Documents/PythonScripts/brie_counts/BrieQ20.extended-counts.txt", header = TRUE, sep="\t", nrows = 78635, stringsAsFactors = FALSE)
hist(log2(counts[,4]),breaks=100,main="Brie Library, sgRNAs",xlab="Log2 counts per sgRNA",ylab="Number of sgRNAs")
boxplot(counts[,4],main="Read Distribution, sgRNAs",ylab="Counts per sgRNA")
sgrna_cdf = ecdf(counts[,4])
plot(sgrna_cdf,xlim=c(0,5000),xlab="sgRNAs ranked by abundance",ylab="Fraction total represented",main="Cumulative Distribution, sgRNAs")
is.list(list(counts[,2]))

genes = aggregate(counts[,4]/4,list(counts[,2]),sum)
hist(log2(genes[,2]+1),breaks=100,main="Brie Library, Genes",xlab="Log2 counts per gene",ylab="Number of Genes")
boxplot(genes[,2],main="Read Distribution, Genes",ylab="Counts per gene")
genes_cdf = ecdf(genes[,2])
plot(genes_cdf,xlim=c(0,5000),xlab="Genes ranked by abundance",ylab="Fraction total represented",main="Cumulative Distribution, Genes")

# This section creates graphs from the pre-amplification data sent by Addgene. If you do have such data for the new library,
# then change the C:...txt section to the file path to that data. If you don't then you can put "#" before each line.

addgene = read.table("C:/Users/.../Documents/PythonScripts/brie_counts/addgene-read_counts.txt", sep=",")
hist(log2(addgene[,2]+1),breaks=50,main="Brie Library, Addgene",xlab="Log2 counts per sgRNA",ylab="Number of sgRNAs")
boxplot(addgene[,2],main="Read Distribution, Addgene",ylab="Counts per gene Addgene data")
addgene_cdf = ecdf(addgene[,2])
plot(addgene_cdf,xlim=c(0,500),xlab="Add sgRNAs ranked by abundance",ylab="Fraction total represented",main="Cumulative Distribution, Addgene")

#windows(w=12,h=4)
#par(mfrow=c(1,3))

#controls = read.table("C:/Users/.../Documents/PythonScripts/BrieQ20.extended-counts.txt", header = FALSE, sep="\t", skip = 76442, nrows = 77442)
#hist(log2(controls[,3]+1),breaks=50,main="Brie Library, Controls",xlab="Log2 counts per control",ylab="Number of Controls")
#boxplot(controls[,3],main="Read Distribution, Controls",ylab="Counts per control")
#controls_cdf = ecdf(controls[,3])
#plot(controls_cdf,xlim=c(0,7000),xlab="Controls ranked by abundance",ylab="Fraction total represented",main="Cumulative Distribution, Controls")

#This section creates Violin plots for the 3 sets of data and then makes one with all 3 stacked on top of each other.

windows(w=12,h=4)
par(mfrow=c(1,4))
library(vioplot)
vioplot(addgene[,2],ylim=c(0,500),col="green")
vioplot(counts[,4],ylim=c(0,10000),col="tomato",add=TRUE)
vioplot(genes[,2],ylim=c(0,10000),col="orange",add=TRUE)

vioplot(counts[,4],ylim=c(0,10000),col="tomato")
vioplot(genes[,2],ylim=c(0,10000),col="orange")
vioplot(addgene[,2],ylim=c(0,500),col="green")

# This section from here to the end of the code creates the statistics table which can be read in the console underneath

#use unname on quantile to get just a list of the values

statcounts = unname(quantile(counts[,4],probs=c(0,.1,.25,.5,.75,0.90,1)))
statgenes = unname(quantile(genes[,2],probs=c(0,.1,.25,.5,.75,0.90,1)))
stataddgene = unname(quantile(addgene[,2],probs=c(0,.1,.25,.5,.75,0.90,1)))
statcounts
#num of values, min, max, median, 25th quartile, 75th quartile, std dev, diff in rep
tabcounts = list(nrow(counts),statcounts[1],statcounts[7],statcounts[4], statcounts[3], statcounts[7]-statcounts[5],sd(counts[,4]),statcounts[6]/statcounts[2])
tabgenes = c(nrow(genes),statgenes[1],statgenes[7],statgenes[4], statgenes[3], statgenes[7]-statgenes[5], sd(genes[,2]),statgenes[6]/statgenes[2])
tabadd = c(nrow(addgene),stataddgene[1],stataddgene[7],stataddgene[4], stataddgene[3], stataddgene[7]-stataddgene[5], sd(addgene[,2]),stataddgene[6]/stataddgene[2])

tab = matrix(c(tabcounts,tabgenes,tabadd), ncol = 3, byrow = FALSE)
colnames(tab)<-c("Sgrnas", "Genes", "Addgene")
rownames(tab)<-c("# values", "min", "max", "median", "25th quartile", "75th quartile", "std dev", "90th/10th quartile")
tab

#Section not finished yet
hypotest1 = t.test(counts[,4], addgene[,2])

print(hypotest1)

nullmod =   jackknife(counts[,4], var)
hypotest2 = willcox.test(counts[,4],nullmod)
print(hypotest2)





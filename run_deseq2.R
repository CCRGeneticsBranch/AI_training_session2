# Perform differential gene expression analysis using DESeq2 on raw count matrix
# Based on: https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html

# Load required libraries
library(DESeq2)

# User input
count_matrix_file <- "GSE243183_TC-32_RawCountFile_RSEM_genes.txt" # Path to count matrix (genes as rows, samples as columns)
sample_sheet_file <- "samples.txt"     # Path to sample sheet (columns: Sample, Group)
output_file <- "DESeq2_results.tsv"    # DESeq2 results output file

# Load data
counts <- read.table(count_matrix_file,sep='\t',header=TRUE,check.names = FALSE)
rownames(counts) <- counts$symbol
counts <- counts[,-1]
counts <- as.matrix(counts)

samples <- read.table(sample_sheet_file,sep='\t',header=TRUE)
samples$Group = factor(samples$Group, levels = c("siNeg","siFli1"))

# Ensure sample order matches counts matrix
samples <- samples[match(colnames(counts), samples$Sample), ]

# DESeq2 setup
dds <- DESeqDataSetFromMatrix(
  countData = round(counts),
  colData = samples,
  design = ~ Group
)

# Filter lowly expressed genes
dds <- dds[rowSums(counts(dds) >= 10) >= 2,]

# Run DESeq2
dds <- DESeq(dds)

# Get results
res <- results(dds)
res_df <- as.data.frame(res)

# Split gene name into Ensembl_ID and Gene
res_df$id = rownames(res_df)
res_df$Ensembl_ID <- sapply(strsplit(res_df$id, "\\|"), `[`, 1)
res_df$Gene <- sapply(strsplit(res_df$id, "\\|"), `[`, 2)
  
# Rearrange columns
res_df = res_df[,c("Ensembl_ID","Gene","baseMean","log2FoldChange","lfcSE","stat","pvalue","padj")]
  
# Sort by adjusted p-value and absolute fold change
res_df = res_df[order(res_df$padj,-abs(res_df$log2FoldChange)),]

write.table(res_df, file = output_file, sep = "\t", quote = FALSE, row.names = FALSE)

print("Finished DESeq2 analysis")
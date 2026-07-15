# Perform differential expression analysis using DESeq2
# Based on: https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html

# Load required libraries
library(DESeq2)
library(openxlsx)
library(ggplot2)

# User input
gene_table <- "/data/khanlab3/gb_omics/resources/ensembl/release-102/mart_export.txt" # Gene info from Biomart, GENCODE 36 == ENSEMBL 102
count_matrix_file <- "renee/DEG_ALL/RSEM.genes.expected_counts.all_samples.reformatted.tsv"      # Path to count matrix (samples as columns, genes as rows)
fpkm_matrix_file <- "renee/DEG_ALL/RSEM.genes.FPKM.all_samples.txt"
sample_sheet_file <- "samples.txt"     # Path to sample sheet (columns: File, Sample, Group)
contrasts_file <- "contrasts.txt"      # Path to contrasts file (columns: Group1, Group2)
output_excel <- "DESeq2_results.xlsx"  # Output Excel file

# Load data
counts <- read.table(count_matrix_file,sep='\t',header=TRUE,check.names = FALSE)
rownames(counts) <- counts$symbol
counts <- counts[,-1]
counts <- as.matrix(counts)

fpkm <- read.table(fpkm_matrix_file,sep='\t',header=TRUE,check.names = FALSE)

samples <- read.table(sample_sheet_file,sep='\t')
colnames(samples) <- c("File", "Sample", "Group")
rownames(samples) <- samples$Sample

contrasts <- read.table(contrasts_file,sep='\t',header=TRUE)

# Ensure sample order matches counts matrix
samples <- samples[match(colnames(counts), samples$Sample), ]

# Load gene information
gene_info = read.table(gene_table,sep='\t',header=TRUE,check.names=FALSE)
colnames(gene_info) = c("Gene stable ID version","Biotype","Chromosome")

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

# Plot PCA
vsd <- vst(dds, blind=FALSE)

pcaData <- plotPCA(vsd, intgroup="Group", returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))

p <- ggplot(pcaData, aes(PC1, PC2, color=Group)) +
  geom_point(size=3) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) + 
  coord_fixed() + theme(aspect.ratio=1)

ggsave("PCA.png", plot = p, width = 6, height = 5, dpi = 300)

# Get results for each contrast
wb <- createWorkbook()

for (i in seq_len(nrow(contrasts))) {
  group1 <- contrasts$Group1[i]
  group2 <- contrasts$Group2[i]
  contrast_name <- paste(group1, group2, sep = "-")
  print(contrast_name)
  
  res <- results(dds, contrast = c("Group", group1, group2))
  res_df <- as.data.frame(res)

  # Split gene name into Ensembl_ID and Gene
  res_df$id = rownames(res_df)
  res_df$Ensembl_ID <- sapply(strsplit(res_df$id, "\\|"), `[`, 1)
  res_df$Gene <- sapply(strsplit(res_df$id, "\\|"), `[`, 2)
  
  # Add gene information
  res_df = merge(res_df,gene_info,by.x="Ensembl_ID",by.y="Gene stable ID version",all.x=TRUE)

  # Add fold change
  res_df$FoldChange <- 2^res_df$log2FoldChange
  
  # Add FPKM per sample
  samples_subset = samples[which(samples$Group %in% group1 | samples$Group %in% group2),]$Sample
  fpkm_subset <- as.data.frame(fpkm[match(res_df$Ensembl_ID,fpkm$gene_id), samples_subset, drop=FALSE])
  res_df <- cbind(res_df, fpkm_subset)
  
  # Rearrange columns
  res_df = res_df[,c("Ensembl_ID","Gene","Chromosome","Biotype",
                     "baseMean","log2FoldChange","FoldChange","lfcSE","stat","pvalue","padj",
                     colnames(fpkm_subset))]
  
  # Sort by adjusted p-value
  res_df = res_df[order(res_df$padj),]
  
  addWorksheet(wb, contrast_name)
  writeData(wb, contrast_name, res_df)
}

saveWorkbook(wb, output_excel, overwrite = TRUE)

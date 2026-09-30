#!/bin/bash

# ==============================================================================
# Script Name: analyze_annotation.sh
# Description: practice exercise to analyze actual genome and genomic data
# ==============================================================================


# --- global variable ---
gtf=Mus_musculus.GRCm38.75_chr1.gtf


# ==============================================================================
# Question 1 - What is actually annotated on this chromsome?
# ==============================================================================

# a. How many genes are annotated
# from the grep -v "^#" Mus_musculus.GRCm38.75_chr1.gtf | cut -f3 | sort | uniq -c
# have checked what features are annotated on this chromosome
# need to select the annotated features of interest, which is going to be in 3rd column of the GTF file
# the file is currently spaced with tabs, so need to use cut with tab delimiter to extract the 3rd column

echo "Number of genes annotated on this chromosome:"
grep -v "^#" $gtf | awk -F"\t" '$3=="gene"' | wc -l

# -------- end of question 1a --------

# b. Break the genes down by biotype, most common first
# remove the header with grep
# extract the annotated genes with awk by assigning the tab delimiter
# replace the line with sed
# \([^"]*\)]) : capture the gene biotype enclosed in quotes
# ".* : match the rest of the line after the gene biotype
# \1 : replace the entire line with just the captured gene biotype

# grep -v "^#" $gtf \     # remove headers
# | awk -F"\t" '$3=="gene"' \    # select only gene features
# | sed 's/.*gene_biotype "\([^"]*\)".*/\1/' \    # caputre the gene biotype and replace it with just the biotype
# | sort | uniq -c | sort -rn    # count the occurrences of each biotype and sort by frequency

echo "----------------------------------------"
echo "Gene biotypes and their counts:"
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="gene"' \
 | sed 's/.*gene_biotype "\([^"]*\)".*/\1/' \
 | sort | uniq -c | sort -nr

# -------- end of question 1b --------  

# c. What fraction is protein coding?
# from the previous question, we have the total number of genes and the number of protein coding genes
# we can calculate the fraction by dividing the number of protein coding genes by the total number of genes
# which is: 1240 / 2027 = 0.6117

echo "Fraction of protein coding genes:"
echo "1240 of 2027 = 61%"

# -------- end of question 1c --------


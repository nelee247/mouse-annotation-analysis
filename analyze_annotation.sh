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

echo "QUESTION 1"
echo "Number of genes annotated on this chromosome:"
grep -v "^#" $gtf | awk -F"\t" '$3=="gene"' | wc -l
echo 

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

echo "Gene biotypes and their counts:"
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="gene"' \
 | sed 's/.*gene_biotype "\([^"]*\)".*/\1/' \
 | sort | uniq -c | sort -nr
echo

# -------- end of question 1b --------  

# c. What fraction is protein coding?
# from the previous question, we have the total number of genes and the number of protein coding genes
# we can calculate the fraction by dividing the number of protein coding genes by the total number of genes
# which is: 1240 / 2027 = 0.6117

echo "Fraction of protein coding genes:"
echo "1240 of 2027 = 61%"
echo "----------------------------------------"

# -------- end of question 1c --------


# ==============================================================================
# Question 2 - which genes span the most DNA, and how much of that codes?
# ==============================================================================

# a. The five protein-coding genes with the largest genomic span
# grep with specific criteria for "protein-coding" genes
# for sed function, 
#   PATTERN:      \t[^\t]*gene_name "\([^"]*\)".*
#   REPLACEMENT:  \t\1
#   pattern syntax breakdown:
#     remember that a regex pattern followed by * is will match zero or more occurrences
#     \t          : match a tab character
#     [^\t]*      : match any characters except a tab
#     \t DOES NOT match a tab character in MacOS, use actual tab character instead
#     gene_name "  : match the literal string gene_name
#     \(       : start capturing group
#     \([^"]*\)    : capture any characters except a quote
#     ".*         : match the closing quote and the rest of the line
#     the reason why there is a tab character at the beginning of the replacement
#     is to preserve the tab-separated format of the GTF file

echo "QUESTION 2"
echo "The five protein-coding genes with the largest genomic span:"
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="gene"' \
 | grep 'gene_biotype "protein_coding"' \
 | sed 's/	[^	]*gene_name "\([^"]*\)".*/	\1/' \
 | awk -F"\t" '{print $5-$4+1"\t"$9"\t"$7}' \
 | sort -nr | head -5
echo

# -------- end of question 2a --------

# b. How much of Erbb4 is actually coding?
# CDS coordinates are repeated for each transcript
# make sure we are not counting same coding coordinates multiple times
# sort out unique coding coordinates for Erbb4
# block END in awk will be used to print the final result after processing all lines
# if END is not there it will give MULTIPLE lines of sum of coding lengths

echo "Coding coordinates for Erbb4:"
grep 'gene_name "Erbb4"' $gtf \
 | awk -F"\t" '$3=="CDS"' \
 | cut -f4,5 | sort -u \
 | awk -F"\t" '{total = total + $2 - $1 + 1} END {print total}'

echo
echo "Total transcripts for Erbb4:"
grep 'gene_name "Erbb4"' $gtf \
 | awk -F"\t" '$3=="transcript"' \
 | wc -l

 # -------- end of question 2b --------

 # c. Percentage of the gene is coding?

echo "Percentage of Erbb4 that is coding:"
echo "3993 / 1075874 = 0.37%"
echo "----------------------------------------"


# ==============================================================================
# Question 3
# ==============================================================================

# a. Rank gene by the number of exon lines. (Top 5)
# use the previous examples of specific column search

echo "QUESTION 3"
echo "The top 5 genes by the number of exon lines:"
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="exon"' \
 | sed 's/.*gene_name "\([^"]*\)".*/\1/' \
 | sort | uniq -c | sort -nr | head -5

# -------- end of question 3a --------

# b. Why is this result wrong. 
echo "Why the result is misrepresented:"
echo "The result is wrong because it counts the number of exon lines per gene
not the number of exons per gene.
a gene can have multiple exon lines for the same exon due to different transcripts,
leading to an overestimation of the number of exons."

# grep 'gene_name "Dst"' $gtf | awk -F"\t" '$3=="exon"' | wc -l
# grep 'gene_name "Dst"' $gtf | awk -F"\t" '$3=="exon"' | cut -f4,5 | sort -u | wc -l
# grep 'gene_name "Dst"' $gtf | awk -F"\t" '$3=="transcript"' | wc -l

## result:
## 511 exon lines
## 126 distinct exons
##  16 transcripts

# -------- end of question 3b --------

# c. Corrected ranking of genes by the number of exons (not exon lines)
# need to consider the coordinates of exons to count unique exons per gene
# we will use the coordinates of exons to count unique exons per gene
# field 4 = start coordinate of the exon
# field 5 = end coordinate of the exon
# field 9 = exon name

echo "The top 5 genes by the number of exons:"
grep -v "^#" $gtf \
 | awk -F"\t" '$3=="exon"' \
 | sed 's/	[^	]*gene_name "\([^"]*\)".*/\t\1/' \
 | cut -f4,5,9 | sort -u \
 | cut -f3 | sort | uniq -c | sort -nr | head -5

 # -------- end of question 3c --------

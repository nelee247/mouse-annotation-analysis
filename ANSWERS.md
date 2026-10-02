# Answer for different AI answers

## Attributing the column

``` bash
grep -v "^#" Mus_musculus.GRCm38.75_chr1.gtf | awk '{print $9}' | sort | uniq -c | head
grep -v "^#" Mus_musculus.GRCm38.75_chr1.gtf | cut -f9 | head -1
```

**Question:** 
Both run without error. 
Do they show the same thing? What exactly did the first one print, and why?

**Answer:**

- The result for the codes were pasted below. The result was not the same.
```
81226 gene_id
gene_id "ENSMUSG00000090025"; gene_name "Gm16088"; gene_source "havana"; gene_biotype "pseudogene";
```

- The reason why the two results were different is because the first code does not realize that the field is separated with *tabs* for 'gtf' file. Awk code recognizes the fields as whitespace (tab and space) in default; therefore, the field $9 will be the ninth word that follows in the line instead of tab. 


## Counting Gene

``` bash
grep -c "gene" Mus_musculus.GRCm38.75_chr1.gtf
grep -v "^#" Mus_musculus.GRCm38.75_chr1.gtf | awk -F"\t" '$3=="gene"' | wc -l
```

**Question:** 
Both are valid commands. 
Only one answers the question that was asked. 
By what factor is the wrong one wrong, and where do the extra matches come from?


**Answer:**

- The answers for each code are pasted below. The first answer is counting all the lines that contains the word "gene" because the grep will go through the full lines (and words). 

```
81227
2027
```

- Therefore, the file contains 81231 lines, and the result will give 81227, since after removing the header (5 lines) most of the files contains the word gene.
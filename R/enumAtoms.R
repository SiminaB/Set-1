enumAtoms <-
function(S, rows.sets = FALSE){
    ##if S is a matrix, then transform it into a list
    if(is.matrix(S))
    {
        ##store list (will transfer name to S after we fill it up)
        S.tmp <- list()
        ##if S has no rownames and/or column names, add them
        if(length(rownames(S)) == 0)
        {
            rownames(S) <- 1:nrow(S)
        }
        if(length(colnames(S)) == 0)
        {
            colnames(S) <- 1:ncol(S)
        }
        ##if the rows represent sets, then transpose matrix
        if(rows.sets)
        {
            S <- t(S)
        }
        ##remove all columns which have only 0s
        S <- S[ , colSums(S) != 0]
        ##get all the names of the gene-sets (i.e. all column names of S)
        gene.sets <- colnames(S)

        ##create list
        for(set in gene.sets)
        {
            ##get all genes which are present in the gene-set "set"
            S.tmp[[set]] <- which(S[ ,set] == 1)
        }

        ##change name of list back to S
        S <- S.tmp
    }

    ##if sets don't have names, give them names
    if(length(names(S)) == 0)
    {
        names(S) <- 1:length(S)
    }

    set.names <- names(S)

    ##get all the genes present in the sets
    ind <- genes <- unique(unlist(S, use.names = FALSE))

    ##get number of genes
    ngenes <- length(genes)
    ##get number of sets
    nsets <- length(S)

    ##list of atoms
    atoms <- list()

    ##get complements of all sets
    compl.sets <-
        sapply(S,
               function(sets, all.genes) {
                   setdiff(all.genes, sets) },
               genes)

    ##annotate sets to genes
    annot.genes <- reverseSplit(S)

    ##get all the sets which don't have gene i
    sets.without.a.gene <-
        sapply(annot.genes,
               function(curr.sets, all.sets) {
                   setdiff(all.sets, curr.sets) },
               set.names)

    ##print("start while loop")

    j <- 1

    while(length(ind) > 0){

        i <- ind[1]

        if(j %% 500 == 0)
        {
          ##print(length(ind))
        }

        ##get all sets in which have gene i
        sets.with.gene.i <-
            annot.genes[[i]]

        ##get all sets in which don't have gene i
        sets.without.gene.i <-
            sets.without.a.gene[[i]]

        ##get the intersection of all sets with gene.i
        ##(use De Moivre):
        ##get the complements of all sets with gene i
        compl.sets.with.gene.i <-
            compl.sets[sets.with.gene.i]

        current.atom <-
            setdiff(genes,
                    unlist(compl.sets.with.gene.i,
                           use.names = FALSE))
        ##current.atom now holds the intersection
        ##of all sets with gene i

        ##get the union of all sets without gene i
        union.sets.without.gene.i <-
            unlist(S[sets.without.gene.i],
                   use.names = FALSE)

        current.atom <-
            setdiff(current.atom, union.sets.without.gene.i)

        ##put the atom in the list
        atoms[[paste(sets.with.gene.i,collapse=",")]] <-
            current.atom

        ##throw away those genes for future calculations
        ind <- ind[!(ind %in% current.atom)]

        j <- j + 1
    }

    ##print(length(ind))

    return(atoms)
}


bayesEst <-
function(EFD.EMD,
         w, type = "count",
         pen.for.feats = 0,
         pen.for.atoms = 0,
         atom.sizes = EFD.EMD[,"EFD"]/EFD.EMD[,"EFDR"],
         ilim = 10,
         verbose = TRUE)
{
    ##if input is a vector, change it into a matrix and assume the entries are the EFDRs
    if(is.vector(EFD.EMD))
    {
        EFD.EMD <- as.matrix(EFD.EMD, ncol = 1)
        colnames(EFD.EMD) <- "EFDR"
    }

    if(is.null(rownames(EFD.EMD)))
    {
        rownames(EFD.EMD) <- 1:length(EFD.EMD)
    }

    if(type == "count")
    {
        Bayes.est <- which(EFD.EMD[,"EFDR"]+
                           pen.for.feats + pen.for.atoms/atom.sizes <= w)

        return(names(Bayes.est))
    }
    else
    {
        k <- w
        n <- atom.sizes
        q <- n-EFD.EMD[,"EFDR"]*n

        ## init
        rho <- min(n)
        i <- 0
        while (i <= ilim) {
            ## solve for rho
            t1 <- knap(rho, k, n, q)
            obj1 <- get.obj(t1, k, n, q)

            message("It: ", i, " rho: ", rho, " obj: ", obj1)

            t2 <- knap(sum(n)-rho, k, n, q)
            obj2 <- get.obj(t2, k, n, q)

            message("It: ", i, " rho: ", sum(n)-rho, " obj: ", obj2)

            if (obj1 < obj2) {
                t <- t1
            } else {
                t <- t2
            }

            ## gradient
            g <- getgrad(t, rho, k, n, q)

            ## select
            t1 <- project.grad(t, g, k, n, q)
            new.rho <- as.integer(round(t1 %*% n))

            if (new.rho==rho)
                break
            rho <- new.rho
            i <- i+1
        }

        ##t is a vector of 0s and 1s
        ##return just the atoms which are in
        if(is.null(names(t)))
        {
            names(t) <- rownames(EFD.EMD)
        }
        return(names(which(t==1)))
    }
}


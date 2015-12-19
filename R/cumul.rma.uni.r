cumul.rma.uni <- function(x, order, digits, transf, targs, ...) {

   if (!is.element("rma.uni", class(x)))
      stop("Argument 'x' must be an object of class \"rma.uni\".")

   na.act <- getOption("na.action")

   if (!is.element(na.act, c("na.omit", "na.exclude", "na.fail", "na.pass")))
      stop("Unknown 'na.action' specified under options().")

   if (!x$int.only)
      stop("Method only applicable for models without moderators.")

   if (missing(order))
      order <- NULL

   if (missing(digits))
      digits <- x$digits

   if (missing(transf))
      transf <- FALSE

   if (missing(targs))
      targs <- NULL

   #########################################################################

   if (is.null(order))
      order <- seq_len(x$k.f)

   yi.f      <- x$yi.f[order]
   vi.f      <- x$vi.f[order]
   X.f       <- cbind(x$X.f[order,])
   weights.f <- x$weights.f[order]
   not.na    <- x$not.na[order]
   slab      <- x$slab[order]

   b     <- rep(NA_real_, x$k.f)
   se    <- rep(NA_real_, x$k.f)
   zval  <- rep(NA_real_, x$k.f)
   pval  <- rep(NA_real_, x$k.f)
   ci.lb <- rep(NA_real_, x$k.f)
   ci.ub <- rep(NA_real_, x$k.f)
   QE    <- rep(NA_real_, x$k.f)
   QEp   <- rep(NA_real_, x$k.f)
   tau2  <- rep(NA_real_, x$k.f)
   I2    <- rep(NA_real_, x$k.f)
   H2    <- rep(NA_real_, x$k.f)

   ### note: skipping NA cases
   ### also: it is possible that model fitting fails, so that generates more NAs (these NAs will always be shown in output)

   for (i in seq_len(x$k.f)[not.na]) {

      res <- try(suppressWarnings(rma(yi.f[seq_len(i)], vi.f[seq_len(i)], weights=weights.f[seq_len(i)], method=x$method, weighted=x$weighted, intercept=TRUE, knha=x$knha, control=x$control)), silent=TRUE)

      if (inherits(res, "try-error"))
         next

      b[i]     <- res$b
      se[i]    <- res$se
      zval[i]  <- res$zval
      pval[i]  <- res$pval
      ci.lb[i] <- res$ci.lb
      ci.ub[i] <- res$ci.ub
      QE[i]    <- res$QE
      QEp[i]   <- res$QEp
      tau2[i]  <- res$tau2
      I2[i]    <- res$I2
      H2[i]    <- res$H2

   }

   ### for first 'not.na' element, I2 and H2 would be NA (since k=1), but set to 0 and 1, respectively

   I2[which(not.na)[1]] <- 0
   H2[which(not.na)[1]] <- 1

   #########################################################################

   ### if requested, apply transformation function

   if (is.function(transf)) {
      if (is.null(targs)) {
         b     <- sapply(b, transf)
         se    <- rep(NA,x$k.f)
         ci.lb <- sapply(ci.lb, transf)
         ci.ub <- sapply(ci.ub, transf)
      } else {
         b     <- sapply(b, transf, targs)
         se    <- rep(NA,x$k.f)
         ci.lb <- sapply(ci.lb, transf, targs)
         ci.ub <- sapply(ci.ub, transf, targs)
      }
      transf <- TRUE
   }

   ### make sure order of intervals is always increasing

   tmp <- .psort(ci.lb, ci.ub)
   ci.lb <- tmp[,1]
   ci.ub <- tmp[,2]

   #########################################################################

   if (na.act == "na.omit") {
      out <- list(estimate=b[not.na], se=se[not.na], zval=zval[not.na], pvals=pval[not.na], ci.lb=ci.lb[not.na], ci.ub=ci.ub[not.na], QE=QE[not.na], QEp=QEp[not.na], tau2=tau2[not.na], I2=I2[not.na], H2=H2[not.na])
      out$slab <- slab[not.na]
   }

   if (na.act == "na.exclude" || na.act == "na.pass") {
      out <- list(estimate=b, se=se, zval=zval, pvals=pval, ci.lb=ci.lb, ci.ub=ci.ub, QE=QE, QEp=QEp, tau2=tau2, I2=I2, H2=H2)
      out$slab <- slab
   }

   if (na.act == "na.fail" && any(!x$not.na))
      stop("Missing values in results.")

   if ((is.logical(x$knha) && x$knha) || is.character(x$knha))
      names(out)[3] <- "tval"

   ### remove tau2, I2, and H2 columns for FE models

   if (x$method == "FE")
      out <- out[-c(9,10,11)]

   out$digits    <- digits
   out$transf    <- transf
   out$slab.null <- x$slab.null
   out$level     <- x$level
   out$measure   <- x$measure
   out$knha      <- x$knha

   attr(out$estimate, "measure") <- x$measure

   class(out) <- c("list.rma", "cumul.rma")
   return(out)

}
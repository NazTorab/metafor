print.rma.mh <- function(x, digits, showfit=FALSE, ...) {

   mstyle <- .get.mstyle("crayon" %in% .packages())

   if (!inherits(x, "rma.mh"))
      stop(mstyle$stop("Argument 'x' must be an object of class \"rma.mh\"."))

   if (missing(digits)) {
      digits <- .get.digits(xdigits=x$digits, dmiss=TRUE)
   } else {
      digits <- .get.digits(digits=digits, xdigits=x$digits, dmiss=FALSE)
   }

   if (!exists(".rmspace"))
      cat("\n")

   cat(mstyle$section("Fixed-Effects Model"))
   cat(mstyle$section(paste0(" (k = ", x$k, ")")))

   if (showfit) {
      cat("\n")
      if (anyNA(x$fit.stats$ML)) {
         fs <- x$fit.stats$ML
      } else {
         fs <- .fcf(x$fit.stats$ML, digits[["fit"]])
      }
      names(fs) <- c("logLik", "deviance", "AIC", "BIC", "AICc")
      cat("\n")
      tmp <- capture.output(print(fs, quote=FALSE, print.gap=2))
      .print.table(tmp, mstyle)
      cat("\n")
   } else {
      cat("\n\n")
   }

   if (!is.na(x$QE)) {
      cat(mstyle$section("Test for Heterogeneity:"), "\n")
      cat(mstyle$result(paste0("Q(df = ", ifelse(x$k.yi-1 >= 0, x$k.yi-1, 0), ") = ", .fcf(x$QE, digits[["test"]]), ", p-val ", .pval(x$QEp, digits=digits[["pval"]], showeq=TRUE, sep=" "))))
   }

   if (is.element(x$measure, c("OR","RR","IRR"))) {

      res.table <- c(estimate=.fcf(unname(x$beta), digits[["est"]]), se=.fcf(x$se, digits[["se"]]), zval=.fcf(x$zval, digits[["test"]]), pval=.pval(x$pval, digits[["pval"]]), ci.lb=.fcf(x$ci.lb, digits[["ci"]]), ci.ub=.fcf(x$ci.ub, digits[["ci"]]))
      res.table.exp <- c(estimate=.fcf(exp(unname(x$beta)), digits[["est"]]), ci.lb=.fcf(exp(x$ci.lb), digits[["ci"]]), ci.ub=.fcf(exp(x$ci.ub), digits[["ci"]]))

      cat("\n\n")
      cat(mstyle$section("Model Results (log scale):"))
      cat("\n\n")
      tmp <- capture.output(.print.vector(res.table))
      .print.table(tmp, mstyle)

      cat("\n")
      cat(mstyle$section(paste0("Model Results (", x$measure, " scale):")))
      cat("\n\n")
      tmp <- capture.output(.print.vector(res.table.exp))
      .print.table(tmp, mstyle)

      if (x$measure == "OR") {
         cat("\n")
         MH <- ifelse(is.na(x$MH), NA, .fcf(x$MH, digits[["test"]]))
         TA <- ifelse(is.na(x$TA), NA, .fcf(x$TA, digits[["test"]]))
         if (is.na(MH) && is.na(TA)) {
            width <- 1
         } else {
            width <- max(nchar(MH), nchar(TA), na.rm=TRUE)
         }
         cat(mstyle$text("Cochran-Mantel-Haenszel Test:    "))
         if (is.na(MH)) {
            cat(mstyle$result("test value not computable for these data"))
            cat("\n")
         } else {
            cat(mstyle$result(paste0("CMH = ", formatC(MH, width=width), ", df = 1,", paste(rep(" ", nchar(x$k.pos)-1, collapse="")), " p-val ", .pval(x$MHp, digits=digits[["pval"]], showeq=TRUE, sep=" ", add0=TRUE))))
            cat("\n")
         }
         cat(mstyle$text("Tarone's Test for Heterogeneity: "))
         if (is.na(TA)) {
            cat(mstyle$result("test value not computable for these data"))
         } else {
            cat(mstyle$result(paste0("X^2 = ", formatC(TA, width=width), ", df = ", x$k.pos-1, ", p-val ", .pval(x$TAp, digits=digits[["pval"]], showeq=TRUE, sep=" ", add0=TRUE))))
         }
         cat("\n")
      }

      if (x$measure == "IRR") {
         cat("\n")
         cat(mstyle$text("Mantel-Haenszel Test: "))
         if (is.na(x$MH)) {
            cat(mstyle$result("test value not computable for these data"))
         } else {
            cat(mstyle$result(paste0("MH = ", .fcf(x$MH, digits[["test"]]), ", df = 1, p-val ", .pval(x$MHp, digits=digits[["pval"]], showeq=TRUE, sep=" "))))
         }
         cat("\n")
      }

   } else {

      res.table <- c(estimate=.fcf(unname(x$beta), digits[["est"]]), se=.fcf(x$se, digits[["se"]]), zval=.fcf(x$zval, digits[["test"]]), pval=.pval(x$pval, digits[["pval"]]), ci.lb=.fcf(x$ci.lb, digits[["ci"]]), ci.ub=.fcf(x$ci.ub, digits[["ci"]]))

      cat("\n\n")
      cat(mstyle$section("Model Results:"))
      cat("\n\n")
      tmp <- capture.output(.print.vector(res.table))
      .print.table(tmp, mstyle)

   }

   if (!exists(".rmspace"))
      cat("\n")

   invisible()

}

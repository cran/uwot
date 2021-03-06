stime <- function() {
  format(Sys.time(), "%T")
}

# message with a time stamp
# appears only if called from an environment where a logical verbose = TRUE
# OR force = TRUE
tsmessage <- function(..., domain = NULL, appendLF = TRUE, force = FALSE,
                      time_stamp = TRUE) {
  verbose <- get0("verbose", envir = sys.parent())

  if (force || (!is.null(verbose) && verbose)) {
    msg <- ""
    if (time_stamp) {
      msg <- paste0(stime(), " ")
    }
    message(msg, ..., domain = domain, appendLF = appendLF)
    utils::flush.console()
  }
}

# log vector information
summarize <- function(X, msg = "") {
  summary_X <- summary(X, digits = max(3, getOption("digits") - 3))
  tsmessage(msg, ": ", paste(names(summary_X), ":", summary_X, "|",
    collapse = ""
  ),
  force = get0("verbose", envir = sys.parent())
  )
}

# pluralize("thread", 1) => "1 thread"
# pluralize("thread", 2) => "2 threads"
pluralize <- function(str, n, prefix = NULL, inc_num = TRUE) {
  if (n == 0) {
    return("")
  }
  ret <- paste0(str, ifelse(n != 1, "s", ""))
  if (inc_num) {
    ret <- paste0(n, " ", ret)
  }
  if (!is.null(prefix)) {
    ret <- paste0(prefix, " ", ret)
  }
  ret
}

# convert data frame to matrix using numeric columns
x2m <- function(X) {
  if (!methods::is(X, "matrix")) {
    m <- as.matrix(X[, which(vapply(X, is.numeric, logical(1)))])
  }
  else {
    m <- X
  }
  m
}

# given a metric argument, returns a list containing:
# metrics - the input list with any members called "categorical" removed
# categoricals - a vector of the categorical ids
find_categoricals <- function(metrics) {
  res <- list(
    metrics = metrics
  )
  if (is.list(metrics)) {
    cat_pos <- grep("categorical", names(metrics))
    if (length(cat_pos) > 0) {
      cat_ids <- unlist(metrics[cat_pos])
      names(cat_ids) <- NULL
      res <- list(
        metrics = metrics[-cat_pos],
        categoricals = cat_ids
      )
    }
  }
  res
}

# Splits a list into its named and unnamed components:
# > lsplit_unnamed(list(1:10, pca_center = FALSE))
# $named
# $named$pca_center
# [1] FALSE
#
#
# $unnamed
# $unnamed[[1]]
#  [1]  1  2  3  4  5  6  7  8  9 10
lsplit_unnamed <- function(l) {
  lnames <- names(l)
  if (is.null(lnames)) {
    return(list(unnamed = l))
  }
  is_named <- lnames != ""
  nids <- which(is_named)
  uids <- which(!is_named)
  if (length(uids) == 0) {
    return(list(named = l[nids]))
  }

  list(
    named = l[nids],
    unnamed = l[uids]
  )
}

# Do work and update a progress bar
progress_for <- function(n, nchunks, fun) {
  message("0%   10   20   30   40   50   60   70   80   90   100%")
  message("[----|----|----|----|----|----|----|----|----|----|")
  remaining <- n
  chunk_end <- 0
  for (i in 1:nchunks) {
    chunk_start <- chunk_end + 1
    chunk_end <- chunk_start + round(remaining / (nchunks - i + 1)) - 1
    remaining <- remaining - (chunk_end - chunk_start + 1)
    
    fun(chunk_start, chunk_end)
    
    message("*", appendLF = FALSE)
    utils::flush.console()
  }
  message("|")
}

checkna <- function(X) {
  if (!is.null(X) && any(is.na(X))) {
    stop("Missing values found in 'X'")
  }
}

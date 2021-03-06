% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transform.R
\name{umap_transform}
\alias{umap_transform}
\title{Add New Points to an Existing Embedding}
\usage{
umap_transform(
  X = NULL,
  model = NULL,
  nn_method = NULL,
  init_weighted = TRUE,
  search_k = NULL,
  tmpdir = tempdir(),
  n_epochs = NULL,
  n_threads = NULL,
  n_sgd_threads = 0,
  grain_size = 1,
  verbose = FALSE,
  init = "weighted"
)
}
\arguments{
\item{X}{The new data to be transformed, either a matrix of data frame. Must
have the same columns in the same order as the input data used to generate
the \code{model}.}

\item{model}{Data associated with an existing embedding.}

\item{nn_method}{Optional pre-calculated nearest neighbor data. It must be a 
list consisting of two elements:
  \itemize{
    \item \code{"idx"}. A \code{n_vertices x n_neighbors} matrix
    containing the integer indexes of the nearest neighbors in \code{X}. Each
    vertex is considered to be its own nearest neighbor, i.e.
    \code{idx[, 1] == 1:n_vertices}.
    \item \code{"dist"}. A \code{n_vertices x n_neighbors} matrix
    containing the distances of the nearest neighbors.
  }
  Multiple nearest neighbor data (e.g. from two different pre-calculated
  metrics) can be passed by passing a list containing the nearest neighbor
  data lists as items.
  The \code{X} parameter is ignored when using pre-calculated nearest 
  neighbor data.}

\item{init_weighted}{If \code{TRUE}, then initialize the embedded coordinates
of \code{X} using a weighted average of the coordinates of the nearest
neighbors from the original embedding in \code{model}, where the weights
used are the edge weights from the UMAP smoothed knn distances. Otherwise,
use an un-weighted average.
This parameter will be deprecated and removed at version 1.0 of this
package. Use the \code{init} parameter as a replacement, replacing
\code{init_weighted = TRUE} with \code{init = "weighted"} and
\code{init_weighted = FALSE} with \code{init = "average"}.}

\item{search_k}{Number of nodes to search during the neighbor retrieval. The
larger k, the more the accurate results, but the longer the search takes.
Default is the value used in building the \code{model} is used.}

\item{tmpdir}{Temporary directory to store nearest neighbor indexes during
nearest neighbor search. Default is \code{\link{tempdir}}. The index is
only written to disk if \code{n_threads > 1}; otherwise, this parameter is
ignored.}

\item{n_epochs}{Number of epochs to use during the optimization of the
embedded coordinates. A value between \code{30 - 100} is a reasonable trade
off between speed and thoroughness. By default, this value is set to one
third the number of epochs used to build the \code{model}.}

\item{n_threads}{Number of threads to use, (except during stochastic gradient
descent). Default is half the number of concurrent threads supported by the
system.}

\item{n_sgd_threads}{Number of threads to use during stochastic gradient
descent. If set to > 1, then results will not be reproducible, even if
`set.seed` is called with a fixed seed before running.}

\item{grain_size}{Minimum batch size for multithreading. If the number of
items to process in a thread falls below this number, then no threads will
be used. Used in conjunction with \code{n_threads} and
\code{n_sgd_threads}.}

\item{verbose}{If \code{TRUE}, log details to the console.}

\item{init}{how to initialize the transformed coordinates. One of:
  \itemize{
    \item \code{"weighted"} (The default). Use a weighted average of the
    coordinates of the nearest neighbors from the original embedding in
    \code{model}, where the weights used are the edge weights from the UMAP
    smoothed knn distances. Equivalent to \code{init_weighted = TRUE}.
    \item \code{"average"}. Use the mean average of the coordinates of 
    the nearest neighbors from the original embedding in \code{model}.
    Equivalent to \code{init_weighted = FALSE}.
    \item A matrix of user-specified input coordinates, which must have
    dimensions the same as \code{(nrow(X), ncol(model$embedding))}.
  }
This parameter should be used in preference to \code{init_weighted}.}
}
\value{
A matrix of coordinates for \code{X} transformed into the space
  of the \code{model}.
}
\description{
Carry out an embedding of new data using an existing embedding. Requires
using the result of calling \code{\link{umap}} or \code{\link{tumap}} with
\code{ret_model = TRUE}.
}
\details{
Note that some settings are incompatible with the production of a UMAP model
via \code{\link{umap}}: external neighbor data (passed via a list to the
argument of the \code{nn_method} parameter), and factor columns that were
included in the UMAP calculation via the \code{metric} parameter. In the
latter case, the model produced is based only on the numeric data.
A transformation is possible, but factor columns in the new data are ignored.
}
\examples{

iris_train <- iris[1:100, ]
iris_test <- iris[101:150, ]

# You must set ret_model = TRUE to return extra data needed
iris_train_umap <- umap(iris_train, ret_model = TRUE)
iris_test_umap <- umap_transform(iris_test, iris_train_umap)
}

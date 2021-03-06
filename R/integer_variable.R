#' @title Integer Variable Class
#' @description Represents a integer valued variable for an individual.
#' This class is similar to \code{\link[individual]{CategoricalVariable}},
#' but can be used for variables with unbounded ranges, or other situations where part
#' of an individual's state is better represented by an integer, such as
#' household or age bin.
#' @importFrom R6 R6Class
#' @export
IntegerVariable <- R6Class(
  'IntegerVariable',
  public = list(

    .variable = NULL,

    #' @description Create a new IntegerVariable
    #' @param initial_values a vector of the initial values for each individual
    initialize = function(initial_values) {
      self$.variable <- create_integer_variable(as.integer(initial_values))
    },

    #' @description Get the variable values
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      if (is.null(index)) {
        return(integer_variable_get_values(self$.variable))
      }
      if (is.numeric(index)) {
        return(integer_variable_get_values_at_index_vector(self$.variable, index))
      }
      integer_variable_get_values_at_index(self$.variable, index$.bitset)
    },


    #' @description Return a \code{\link[individual]{Bitset}} for individuals with some subset of values
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values 
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(set = NULL, a = NULL, b = NULL) {
        if(!is.null(set)) {
            if (length(set) > 1) {
              return(Bitset$new(from = integer_variable_get_index_of_set_vector(self$.variable, set)))
            } else {
              return(Bitset$new(from = integer_variable_get_index_of_set_scalar(self$.variable, set)))
            }
        }
        if(!is.null(a) & !is.null(b)) {
            stopifnot(a < b)
            return(Bitset$new(from = integer_variable_get_index_of_range(self$.variable, a, b)))            
        }
        stop("please provide a set of values to check, or both bounds of range [a,b]")        
    },

    #' @description Return the number of individuals with some subset of values
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values 
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(set = NULL, a = NULL, b = NULL) {        
        if (!is.null(set)) {
            if (length(set) > 1) {
              return(integer_variable_get_size_of_set_vector(self$.variable, set))  
            } else {
              return(integer_variable_get_size_of_set_scalar(self$.variable, set))
            }
        }
        if (!is.null(a) & !is.null(b)) {
            stopifnot(a < b)
            return(integer_variable_get_size_of_range(self$.variable, a, b))           
        }
        stop("please provide a set of values to check, or both bounds of range [a,b]")        
    },

    #' @description Queue an update for a variable. There are 4 types of variable update:
    #'
    #' \enumerate{
    #'  \item{Subset update: }{The argument \code{index} represents a subset of the variable to
    #' update. The argument \code{values} should be a vector whose length matches the size of \code{index},
    #' which represents the new values for that subset.}
    #'  \item{Subset fill: }{The argument \code{index} represents a subset of the variable to
    #' update. The argument \code{values} should be a single number, which fills the specified subset.}
    #'  \item{Variable reset: }{The index vector is set to \code{NULL} and the argument \code{values}
    #' replaces all of the current values in the simulation. \code{values} should be a vector
    #' whose length should match the size of the population, which fills all the variable values in
    #' the population}
    #'  \item{Variable fill: }{The index vector is set to \code{NULL} and the argument \code{values}
    #' should be a single number, which fills all of the variable values in 
    #' the population.}
    #' }
    #' @param values a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use \code{NULL} for the
    #' fill options. If using indices, this may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    queue_update = function(values, index = NULL) {
      stopifnot(is.numeric(values))
      if(is.null(index)){
        if(length(values) == 1){
          integer_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          integer_variable_queue_update(
            self$.variable,
            values,
            numeric(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          index <- index$to_vector()
        }
        if (length(index) != 0) {
          integer_variable_queue_update(
            self$.variable,
            values,
            index
          )
        }
      }
    },

    .update = function() integer_variable_update(self$.variable)
  )
)

#' Drop a node attribute column
#' @description Within a graph's internal ndf, remove
#' an existing node attribute.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param node_attr the name of the node attribute
#' column to drop.
#' @return a graph object of class
#' \code{dgr_graph}.
#' @examples
#' graph <-
#'   create_graph() %>%
#'   add_gnm_graph(
#'     n = 5,
#'     m = 10,
#'     set_seed = 23) %>%
#'  set_node_attrs(
#'     node_attr = value,
#'     values = rnorm(
#'       n = count_nodes(.),
#'       mean = 5,
#'       sd = 1) %>% round(1))
#'
#' # Get the graph's internal
#' # ndf to show which node
#' # attributes are available
#' graph %>%
#'   get_node_df()
#'
#' # Drop the `value` node
#' # attribute
#' graph <-
#'   graph %>%
#'   drop_node_attrs(
#'     node_attr = value)
#'
#' # Get the graph's internal
#' # ndf to show that the node
#' # attribute `value` had been
#' # removed
#' graph %>%
#'   get_node_df()
#' @importFrom rlang enquo get_expr
#' @export drop_node_attrs

drop_node_attrs <- function(graph,
                            node_attr) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  # Get the requested `node_attr`
  node_attr <-
    rlang::enquo(node_attr) %>% rlang::get_expr() %>% as.character()

  # Stop function if length of `node_attr` is
  # greater than one
  if (length(node_attr) > 1) {

    stop(
      "You can only provide a single column.",
      call. = FALSE)
  }

  # Stop function if `node_attr` is any of
  # `nodes`, `node`, `type`, or `label`
  if (any(c("nodes", "node", "type", "label") %in%
          node_attr)) {

    stop(
      "You cannot drop this column.",
      call. = FALSE)
  }

  # Extract the graph's ndf
  nodes <- get_node_df(graph)

  # Get column names from the graph's ndf
  column_names_graph <- colnames(nodes)

  # Stop function if `node_attr` is not one
  # of the graph's column
  if (!any(column_names_graph %in% node_attr)) {

    stop(
      "The node attribute to drop is not in the ndf.",
      call. = FALSE)
  }

  # Get the column number for the node attr to drop
  col_num_drop <-
    which(colnames(nodes) %in% node_attr)

  # Remove the column
  nodes <- nodes[, -col_num_drop]

  # Create a new graph object
  graph$nodes_df <- nodes

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = "drop_node_attrs",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df))

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  graph
}

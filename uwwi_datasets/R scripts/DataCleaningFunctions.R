# Function to strip start/end characters from a string
stripEnclosingChars <- function(s) {
  str_sub(s, 2, -2)
}

# Function to parse unique values from the list
getUniqueVals <- function(data, field) {
  # Unique list
  data %>%
    select({{field}}) %>%
    unique() %>%
    # Strip [ ]
    mutate(
      {{field}} := stripEnclosingChars({{field}})
    ) %>%
    # Split , into new rows
    separate_rows({{field}}, sep = ", ") %>%
    # Dedupe again
    unique() %>%
    # Strip ' '
    mutate(
      {{field}} := stripEnclosingChars({{field}})
    ) %>%
    return()
}

replaceEmptyWithNA <- function(s) {
  case_when(
    s == "" ~ "NA"
    , TRUE ~ s
  ) %>%
    return()
}

# Function to convert multi-row format to multi-column
spreadRowsToCols <- function(data, field, .unit = 1) {
  data %>%
    pivot_wider(
      names_from = {{field}}
      , values_from = .unit
      , values_fn = max
      , names_prefix = paste0(ensym(field), '_')
    ) %>%
    return()
}

# Function to split field into multiple rows
splitListToCols <- function(data, field, delimiter = ', ', cols = TRUE, .unit = 1) {
  df <- data %>%
    # Strip [ ]
    mutate(
      {{field}} := stripEnclosingChars({{field}})
    ) %>%
    # Split , into new rows
    separate_rows({{field}}, sep = ', ') %>%
    # Strip ''
    mutate(
      {{field}} := stripEnclosingChars({{field}}) %>% replaceEmptyWithNA()
      , .unit = .unit
    )
  
  if (cols) {
    df %>%
      spreadRowsToCols({{field}}, .unit) %>%
      return()
  } else {
    return(df)
  }
}
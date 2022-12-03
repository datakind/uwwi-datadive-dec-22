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

# Parse field of interest from time string
# Uses regular expressions to pull from the tags and create a valid data frame
parseTimeString <- function(s) {
  # Generate data frame of time parts
  tlist <- list(
    dayOfWeek = str_extract_all(s, "(?<='dayOfWeek': ')[A-z][A-z][A-z]")
    , start_hour = str_extract_all(s, "(?<='start_hour': )(\\[([0-9]+(\\]|,))|(None))")
    , start_min = str_extract_all(s, "(?<='start_min': )(\\[([0-9]+(\\]|,))|(None))")
    , end_hour = str_extract_all(s, "(?<='end_hour': )(\\[([0-9]+(\\]|,))|(None))")
    , end_min = str_extract_all(s, "(?<='end_min': )(\\[([0-9]+(\\]|,))|(None))")
  )
  tdf <-  as.data.frame(tlist)
  names(tdf) <- names(tlist)
  # Convert hour/minute to numeric
  tdf %>%
    mutate(
      across(
        .cols = start_hour:end_min
        , .fns = function(x) {suppressWarnings(stripEnclosingChars(x) %>% as.numeric())}
      )
    ) %>%
    return()
}

# Function to create SunStart, SunEnd, MonStart, MonEnd, etc. strings from output of parseTimeString
createTimeStrings <- function(tdf) {
  # Helper function to format h:mm
  time_pad <- function(h, m) {
    paste0(h, ":", str_pad(m, width = 2, side = "left", pad = "0"))
  }
  # Create new columns
  tdf %>%
    mutate(
      Start = time_pad(start_hour, start_min)
      , End = time_pad(end_hour, end_min)
      , across(
        .cols = Start:End
        , .fns = function(x) {ifelse(x == "NA:NA", NA, x)}
      )
    ) %>%
    select(-ends_with("hour"), -ends_with("min")) %>%
    pivot_wider(names_from = dayOfWeek, values_from = Start:End) %>%
    data.frame() %>%
    return()
}

# Function to get distinct interactions from the full string
# All entries are enclosed in [ ] and individual interactions in { }
# "(?<!\\[\\{)\\{([^\\}])*\\}"
# "(\\[)?\\{([^\\}])*\\}(\\])?"
# "(?<=\\{)([^}])*(?=\\})"
parseDistinctInteraction <- function(s) {
  s %>%
  str_extract_all("(\\[)?\\{([^\\}])*\\}(\\])?") %>%
    unlist() %>%
    return()
}

# Function to extract Label: Value pairs
# Labels are format 'Label':
# Values are format ': Value,
parseInteractionLabelValue <- function(s) {
  # Strip additional [LIST] entries from s
  s <- str_replace_all(s, ": \\[\\{.*\\}\\]", ": <NESTED LIST>,")
  # Parse remaining fields
  labels <- str_extract_all(s, "(?<=')[^':]*(?=':)") %>%
    unlist()
  values <- str_extract_all(s, "(?<=': )[^,]*(?=[,}])") %>%
    unlist()
  list(labels = labels, values = values) %>%
    return()
}

# Interactions cleaning loop
cleanInteractionsData <- function(dataset) {
  dframe <- foreach(
    i = 1:nrow(dataset)
    , .combine = rbind
  ) %do% {
    output <- dataset[i, "InteractionReferral_ReferralsModule"] %>%
      parseDistinctInteraction() %>%
      parseInteractionLabelValue()
    dframe <- output$values %>%
      unlist() %>%
      rbind() %>%
      matrix(ncol = 26)
    return(dframe)
  } %>%
    data.frame()
  # Name columns
  names(dframe) <- testdata$labels
  return(dframe)
}
qmd_files <- list.files(
  path = ".",
  pattern = "\\.qmd$",
  recursive = TRUE,
  full.names = FALSE
)

# ignore rendered files and files that start with an underscore
qmd_files <- qmd_files[
  !grepl("^docs/", qmd_files) &
  !grepl("^_", basename(qmd_files)) &
  qmd_files != "index.qmd"
]

dirs <- sort(unique(dirname(qmd_files)))

normalize_github_url <- function(url) {
  if (length(url) == 0 || is.na(url) || !nzchar(url)) {
    return(NA_character_)
  }

  url <- sub("\\.git$", "", url)

  if (grepl("^git@github\\.com:", url)) {
    url <- sub("^git@github\\.com:", "https://github.com/", url)
  }

  url
}

get_repo_base_url <- function() {
  repo_slug <- Sys.getenv("GITHUB_REPOSITORY", unset = "")
  server_url <- Sys.getenv("GITHUB_SERVER_URL", unset = "https://github.com")

  if (nzchar(repo_slug)) {
    return(sprintf("%s/%s", server_url, repo_slug))
  }

  normalize_github_url(
    suppressWarnings(
      system2("git", c("config", "--get", "remote.origin.url"), stdout = TRUE, stderr = FALSE)[1]
    )
  )
}

repo_base_url <- get_repo_base_url()

# create static yml contents
cat(
'project:
  type: website
  output-dir: docs

website:
  title: "The Pacific Northwest Tribal Coding Group"
  search: true
  navbar:
    left:
      - href: index.qmd
        text: Home
  sidebar:
    style: docked
    search: true
    contents:
', file = "_quarto.yml"
)

# append the sections and their contents to the yml file
for (d in dirs) {
  section_name <- gsub("/", " / ", d)
  cat(sprintf('      - section: "%s"\n', section_name), file = "_quarto.yml", append = TRUE)
  cat('        contents:\n', file = "_quarto.yml", append = TRUE)

  these <- qmd_files[dirname(qmd_files) == d]
  for (f in these) {
    cat(sprintf('          - %s\n', f), file = "_quarto.yml", append = TRUE)
  }
}

# append more static contents
cat(
  sprintf(
    '\n  repo-url: "%s"\n  repo-actions: [edit, issue]\n\nformat:\n  html:\n    theme: cosmo\n',
    if (!is.na(repo_base_url) && nzchar(repo_base_url)) repo_base_url else ""
  ),
  file = "_quarto.yml",
  append = TRUE
)

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
'
format:
  html:
    theme: cosmo
',
  file = "_quarto.yml",
  append = TRUE
)

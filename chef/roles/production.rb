name "production"

run_list(
  "recipe[core]",
  "recipe[couchdb]",
  "recipe[ruby]",
  "recipe[passenger]",
  "recipe[rapidftr]"
)

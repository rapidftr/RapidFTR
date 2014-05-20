name "production"

run_list(
  "recipe[core]",
  "recipe[couchdb]",
  "recipe[rvm]",
  "recipe[passenger]"
)

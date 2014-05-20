name "development"

run_list(
  "recipe[core]",
  "recipe[couchdb]",
  "recipe[xvfb]",
  "recipe[firefox]",
  "recipe[rvm]",
  "recipe[seed]"
)

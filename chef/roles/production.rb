name "production"

run_list(
  "recipe[core]",
  "recipe[couchdb]",
  "recipe[ruby]",
  "recipe[passenger]",
  "recipe[rapidftr]"
)

override_attributes(
  "rapidftr" => {
    "repository" => "https://github.com/rdsubhas/RapidFTR.git",
    "revision" => "release-2.0.0"
  }
)

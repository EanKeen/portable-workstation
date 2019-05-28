function prevalidate_aliases($config) {
  foreach($alias in $config.aliases) {
    if($alias | obj_not_has_prop "name") {
      print_error "prevalidate_aliases" "Alias must have property `"name`""
      exit_program
    }

    if($alias | obj_not_has_prop "value") {
      print_error "prevalidate_aliases" "Alias must have property `"value`""
      exit_program
    }
  }
}

function prevalidate_applications($config) {
  # All props exist
  foreach($app in $config.applications) {
    if($app | obj_not_has_prop "path") {
      print_error "fill_applications" "An application specified does not have the `"path`" property. Add this required property to `"$app`"."
      exit_program
    }
  }
}

function prevalidate_binaries($config) {
  # All props exist
  foreach($bin in $config.binaries) {
    if($bin | obj_not_has_prop "path") {
      print_error "fill_binaries" "A binary specified does not have the `"path`" property. Add this required property to `"$app`"."
      exit_program
    }
  }
}

function prevalidate_refs($config) {

}

# // TODO: Verify json is legit and valid before validating
function prevalidate_config() {
  $config = Get-Content -Path "./portable.config.json" -Raw | ConvertFrom-Json

  prevalidate_applications $config
  prevalidate_binaries $config
  prevalidate_aliases $config
  prevalidate_refs $config
}

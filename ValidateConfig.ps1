# Check to be sure all paths user is entering is correct

function check_path_exists($pathName, $pathValue) {
  if($pathValue -eq "OMMIT") {
    return
  }
  elseif (Test-Path -Path $pathValue) {
    print_info "check_path_exists" "path `"$pathName`" at `"$pathValue`" reference exists"
    return
  }
  else {
    print_error "check_path_exists" "path `"$pathName`" at `"$pathValue`" reference does NOT exist. Create the path or edit your config object"
    exit_program
  }
}

function validate_refs($config) {
  foreach ($relativePath in $config.refs.PsObject.Properties) {
    check_path_exists $relativePath.Name $relativePath.Value
  }

  if(($config.refs.scoopAppsDir -eq "OMMIT" -and $config.refs.scoopDir -ne "OMMIT") -or ($config.refs.scoopAppsDir -ne "OMMIT" -and $config.refs.scoopDir -eq "OMMIT")) {
    print_error "validate_refs" "If you choose to ommit either `"scoopAppsDir`" or `"scoopDir`", you must ommit either both or none"
  }
}

function validate_binaries($config) {
  foreach($binary in $config.binaries) {
    $normalizedBin = normalize_path $config.refs.binDir $binary.path
    check_path_exists $binary.name $normalizedBin
  }
}

function validate_config($config) {
  # validate_aliases
  # validate_aliasesobj
  # validate_applications
  validate_binaries $config
  validate_refs $config
}


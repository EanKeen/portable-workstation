## Prints with different formatting
function print_title($highlightedText) {
  Write-Host "`r`n$highlightedText" -BackgroundColor White -ForegroundColor Black
}

function print_info($highlightedText, $plainText) {
  Write-Host $highlightedText -NoNewLine -BackgroundColor DarkGreen -ForegroundColor White
  Write-Host " $plainText"
}

function print_warning($highlightedText, $plainText) {
  Write-Host $highlightedText -NoNewLine -BackgroundColor DarkYellow -ForegroundColor White
  Write-Host " $plainText"
}

function print_error($highlightedText, $plainText) {
  Write-Host $highlightedText -NoNewLine -BackgroundColor DarkMagenta -ForegroundColor White
  Write-Host " $plainText"
}

## Other helper functions
# Combines relative path relative to absolute path
function normalize_path($absPath, $relPath) {
  [IO.Path]::GetFullPath((Join-Path $absPath $relPath))
  return
}

function command_exists($commandName) {
  if(Get-Command $commandName -errorAction SilentlyContinue) {
    $true
  }
  else {
    $false
  }
}

function exit_program() {
  print_title "Exiting program. Press any key to exit"
  $key = $Host.UI.RawUI.ReadKey()
  exit
}

## Writes to a particular Cmder config
function write_to_config($var, $configFile, $content) {
  if($configFile -eq $var.allConfig) {
    write_to_config $var $var.bashConfig $content
    write_to_config $var $var.psConfig $content
    write_to_config $var $var.cmdConfig $content
    return
  }
  # Add-Content -Path $configFile -Value $content -Encoding "ASCII"
  "$content" | Out-File -Encoding "ASCII" -Append -FilePath $configFile  
}

## Writes to a particular Cmder config, but more suited to a specific case (comment, variable, path, alias)
function write_comment_to_config($var, $configFile, $comment) {
  if($configFile -eq $var.allConfig) {
    write_comment_to_config $var $var.bashConfig $comment
    write_comment_to_config $var $var.psConfig $comment
    write_comment_to_config $var $var.cmdConfig $comment
    return
  }
  elseif($configFile -eq $var.bashConfig) {
    write_to_config $var $var.bashConfig "# $comment"
  }
  elseif($configFile -eq $var.psConfig) {
    write_to_config $var $var.psConfig "# $comment"
  }
  elseif($configFile -eq $var.cmdConfig) {
    write_to_config $var $var.cmdConfig ":: $comment"
  }
  print_info "comment" "Adding `"$($comment.Substring(0, 15))...`" to `"$(Split-Path $configFile -Leaf)`""
}

function write_variable_to_config($var, $configFile, $variableName, $variableValue) {
  if($configFile -eq $var.allConfig) {
    write_variable_to_config $var $var.bashConfig $variableName $variableValue
    write_variable_to_config $var $var.psConfig $variableName $variableValue
    write_variable_to_config $var $var.cmdConfig $variableName $variableValue
    return
  }
  elseif($configFile -eq $var.bashConfig) {
    write_to_config $var $configFile "$variableName=`"$variableValue`""
  }
  elseif($configFile -eq $var.psConfig) {
    write_to_config $var $configFile "`$$variableName=`"$variableValue`""
  }
  elseif($configFile -eq $var.cmdConfig) {
    write_to_config $var $configFile "set $variableName=$variableValue"
  }
  print_info "variable" "Setting `"$variableName`" to `"$variableValue`" for `"$(Split-path $configFile -Leaf)`""
}

function write_path_to_config($var, $configFile, $binName, $filePath) {
  if($configFile -eq $var.allConfig) {
    write_path_to_config $var $var.bashConfig $binName $filePath
    write_path_to_config $var $var.psConfig $binName $filePath
    write_path_to_config $var $var.cmdConfig $binName $filePath
    return
  }
  elseif($configFile -eq $var.bashConfig) {
    write_to_config $vars $var.bashConfig "export PATH=\$((Convert-Path $filePath)):`$PATH".Replace(":\", "\").Replace("\", "/")
  }
  elseif($configFile -eq $var.psConfig) {
    write_to_config $vars $var.psConfig "`$env:Path = `"${filePath};`" + `$env:Path"
  }
  elseif($configFile -eq $var.cmdConfig) {
    write_to_config $var $var.cmdConfig "set PATH=${filePath};%PATH%"
  }
  print_info "path" "Adding `"$binName`" to PATH for `"$(Split-Path $configFile -Leaf)`""
}

function write_alias_to_config($var, $configFile, $aliasName, $aliasValue) {
  if($configFile -eq $var.allConfig) {
    write_alias_to_config $var $var.bashConfig $aliasName $aliasValue
    write_alias_to_config $var $var.psConfig $aliasName $aliasValue
    write_alias_to_config $var $var.cmdConfig $aliasName $aliasValue
    return
  }
  elseif($configFile -eq $var.bashConfig) {
    write_to_config $var $configFile "alias $aliasName=`"$aliasValue`""
  }
  elseif($configFile -eq $var.psConfig) {
    write_to_config $var $configFile "function fn-$aliasName { $aliasValue }"
    write_to_config $var $configFile "Set-Alias -Name `"$aliasName`" -Value `"fn-$aliasName`""
  }
  elseif($configFile -eq $var.cmdConfig) {
    # For now, aliases are not included for batch
    # Append to pre-created user_aliases.cmd
    # Write-Line-To-File "alias $alias=$aliasValue" $configFile
    # Write-Line-To-File "doskey $alias=$aliasValue" $configFile
  }
  print_info "alias" "Setting `"$aliasName`" to `"$aliasValue`" for `"$(Split-Path -Path $configFile)`""
}

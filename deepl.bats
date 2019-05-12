#!/usr/bin/env bats

teardown() {
	sleep 1
}

@test "No parameters" {
  run ./deepl.sh
  [[ "$status" -eq 1 ]]
}

@test "Missing dot" {
  run ./deepl.sh "Vogel"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"End query with a dot"* ]]
}

@test "Single Word" {
  run ./deepl.sh -l EN "Vogel."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"bird"* ]]
}

@test "Sentence" {
  run ./deepl.sh -l DE "Translate from any language."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"aus jeder Sprache"* ]]
}

@test "Umlaut source" {
  run ./deepl.sh -l EN "Erdöl."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"oil"* ]]
}

@test "Umlaut destination" {
  run ./deepl.sh -l DE "Oil."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"öl"* ]]
}

@test "Quote source" {
  run ./deepl.sh -l DE "I'll."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Ich werde"* ]]
}

@test "Quote destination" {
  run ./deepl.sh -l EN "Ich werde."
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"I'll be"* ]]
}

@test "Double quote source" {
  run ./deepl.sh -l EN '"Apfel".'
  [[ "$status" -eq 0 ]]
  [[ "$output" == *'\"Apple\"'* ]]
}

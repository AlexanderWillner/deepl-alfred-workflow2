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

#todo: fixme
#@test "Long sentences" {
#  run ./deepl.sh -l DE "He felt that his whole life was some kind of dream and he sometimes wondered whose it was and whether they were enjoying it."
#  [[ "$status" -eq 0 ]]
#  [[ "$output" == *'\"Leben\"'* ]]
#}

#todo: fixme
#@test "Multi sentences" {
#  run ./deepl.sh -l DE "This planet has - or rather had - a problem, which was this: most of the people living on it were unhappy for pretty much of the time. Many solutions were suggested for this problem, but most of these were largely concerned with the movement of small green pieces of paper, which was odd because on the whole it wasn't the small green pieces of paper that were unhappy."
#  [[ "$status" -eq 0 ]]
#  [[ "$output" == *'\"unglücklich\"'* ]]
#}


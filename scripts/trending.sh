#!/bin/bash

allLanguages=("elixir" "python" "java" "javascript" "rust" "go" "ruby" "c" "c++" "c#" "haskell" "php" "scala" "swift" "objective-c" "kotlin" "shell" "typescript")

for l in ${allLanguages[@]}; do
  echo $l
  mix run -e "LowendinsightGet.GithubTrending.analyze(\"$l\")"
done
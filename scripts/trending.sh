#!/bin/bash

# allLanguages=("elixir" "python" "java" "javascript" "rust" "go" "ruby" "c" "c++" "c#" "haskell" "php" "scala" "swift" "objective-c" "kotlin" "shell" "typescript")

mix run --no-halt -e "LowendinsightGet.GithubTrending.process_languages()"
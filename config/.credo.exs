# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/**", "test/**"],
        excluded: []
      },
      checks: [
        {Credo.Check.Readability.MaxLineLength, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.AliasOrder, false}
      ]
    }
  ]
}

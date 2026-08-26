"""Strip version specifiers from [build-system].requires in a pyproject.toml.

Nix builds wheels with ``pyproject-build --no-isolation`` against the packages
nixpkgs ships, and pypa/build still verifies the build requirements in that
mode. Upstream pins such as ``grpcio-tools~=1.80.0`` or
``scikit-build-core ~= 0.12.2`` would therefore fail the build even though the
nixpkgs versions work. Runtime requirements are relaxed separately by the
pythonRelaxDeps hook, which edits the wheel METADATA.
"""

from __future__ import annotations

import re
import sys
import tomllib

path = sys.argv[1]
with open(path, "rb") as f:
    data = tomllib.load(f)
text = open(path, encoding="utf-8").read()
for spec in data.get("build-system", {}).get("requires", []):
    name = re.match(r"\s*([A-Za-z0-9][A-Za-z0-9._-]*)", spec).group(1)
    if name == spec:
        continue
    for quote in ('"', "'"):
        text = text.replace(f"{quote}{spec}{quote}", f"{quote}{name}{quote}")
open(path, "w", encoding="utf-8").write(text)

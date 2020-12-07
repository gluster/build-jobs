#!/usr/bin/env python3

import subprocess
import os

branch=os.environ.get('ghprbTargetBranch', 'devel')

changed_files = subprocess.check_output(
    ["git", "diff", "--name-only",  "origin/{}..HEAD".format(branch)]
).decode('UTF-8').split("\n")
list_of_files = []
for file in changed_files:
    if file.startswith("contrib/"):
        continue
    if file.endswith(".c") or file.endswith(".h"):
        subprocess.call(['clang-format', '-i', file])

# Look for any changes applied by clang-format
changed = subprocess.check_output(['git', 'diff'])

if changed:
    print(changed)
    print("The above patch needs to be applied to pass clang-format")
    exit(1)

# No changes, pass
print("clang-format did not modify any files")

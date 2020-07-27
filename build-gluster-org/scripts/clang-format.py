#!/usr/bin/env python3

import subprocess


changed_files = subprocess.check_output(
    ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD"]
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

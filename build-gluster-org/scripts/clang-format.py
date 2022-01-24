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

#comment when there is any diff generated after running clang-format
if changed:
    with open('comment.txt', 'w') as file:
    	file.write("CLANG-FORMAT FAILURE:\nBefore merging the patch, this diff needs to be considered for passing clang-format\n\n```" + changed.decode('utf-8') + "```")
    print(changed)
    print("The above patch needs to be applied to pass clang-format")

else:
    # No changes, pass
    print("clang-format did not modify any files")
    # workaround the ghprb plugin issue `!!! Couldn't read commit file !!!` comment when comment.txt does not exist 
    open('comment.txt', 'a').close()
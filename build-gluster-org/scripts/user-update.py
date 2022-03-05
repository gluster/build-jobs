import requests
import re
import os
import subprocess
import json

#Collects the gluster-maintainers names
def create_user_data(repo_path, username, password):
    os.chdir(repo_path)
    user_data = requests.get('https://api.github.com/orgs/gluster/teams/gluster-maintainers/members', auth=(username,password)).json()
    return user_data

#Function which creates the dev path
def create_new_dev_branch(branch_name):
    os.system("git checkout master")
    os.system("git pull origin master")
    os.system("git checkout -b {}".format(branch_name))

#Function to find out the names which are missing in the jenkins conf file
def search_pat(repo_path, filename, string_to_search,user_data):
    os.chdir(repo_path)
    INDENTATION_VALUE = ""
    NOT_FOUND = []
    for i, line in enumerate(open(filename)):
        if string_to_search in line:
            INDENTATION_VALUE=re.match(r"\s*", line).group()
    for username in user_data:
        with open(filename) as f:
            if re.search(username['login'], f.read()):
                continue
            else:
                NOT_FOUND.append("{}  ".format(INDENTATION_VALUE)+"- "+username['login'])
    f.close()
    return NOT_FOUND

#Function to find the files which has matching pattern
def find_files(repo_path, pattern):
    MATCHED_FILES = []
    output = subprocess.Popen(['ls',repo_path], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = output.communicate()
    filenames = stdout.decode('UTF-8').rstrip('\n').split('\n')

    for file in filenames:
        with open(file, "r+") as output_file:
             buffer = output_file.read()
             search_pattern = re.compile(r'\s*%s'%pattern)
             if search_pattern.search(buffer):
                  MATCHED_FILES.append(file)

        output_file.close()
    return MATCHED_FILES

#Function which appends the names which are not present in the jenkins conf file
def edit_file(repo_path,filename,pattern,NOT_FOUND):
    os.chdir(repo_path)
    with open(filename, "r") as input_file:
        buffer = input_file.readlines()

    with open(filename, "w") as output_file:
        search_pattern = re.compile(r'\s*%s'%pattern) 
        for line in buffer:
            if search_pattern.search(line):  
                for names in NOT_FOUND:
                    line = line + str(names) + "\n"
            output_file.write(line)

    input_file.close()
    output_file.close()

#Checks the files which are modified
def check_untracked_files(repo_path,pat,branch_name):
    os.chdir(repo_path)
    FILES = []
    os.system('git status')
    out = subprocess.Popen(['git', 'status'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = out.communicate()
    output_decoded = stdout.decode('UTF-8').split('\n')
    for line in output_decoded:
         if pat in line:
             val = line.split(':')
             FILES.append(val[1].strip())
    print (FILES)
    if len(FILES) == 0:
        print ("No changes")
    else:
        commit_and_push(FILES,branch_name)

#Commit the files and push it to the repo
def commit_and_push(FILENAMES,branch_name):
    file_names=' '.join(FILENAMES)
    print ("Changed files : {}".format(file_names))
    os.system('git add {}'.format(file_names))
    os.system('git commit -m "Updating the admin-list as per gluster-maintainers list"')
    os.system('git push origin {}'.format(branch_name))

#Creates pull request against the master branch
def create_pull_request(username, password, repo_name, title, description, head_branch, base_branch):
    git_pulls_api = "https://api.github.com/repos/gluster/{}/pulls".format(repo_name)
    payload = { "title": title, "body": description, "head": head_branch, "base": base_branch }
    r = requests.post( git_pulls_api, auth=(username,password), data=json.dumps(payload))
    if r.ok:
        print("Pull request successfully created!")
        pull_requests = requests.get("https://api.github.com/repos/gluster/{}/pulls".format(repo_name), auth=(username, password)).json()
        for pull in pull_requests:
             if pull['title'] == title:
                 print (pull['html_url'])
    else:
        print("Pull request Failed: {}".format(r.text))

def main():
    username = os.environ['GITHUB_USERNAME']
    password = os.environ['GITHUB_PASSWORD']
    url = f"https://api.github.com/orgs/gluster/teams/gluster-maintainers/members"
    pattern = "admin-list:"
    pattern2 = "modified:"
    dev_branch_name = "user-update-branch"
    repo_name = "build-jobs"
    repo_path=os.environ['WORKSPACE']+"/{}/build-gluster-org/jobs".format(repo_name)
    user_data = create_user_data(repo_path, username, password)
    create_new_dev_branch(dev_branch_name)
    filenames = find_files(repo_path, pattern)
    for filename in filenames:
        users_not_found=search_pat(repo_path, filename, pattern, user_data)
        edit_file(repo_path,filename,pattern,users_not_found)
    check_untracked_files(repo_path,pattern2,dev_branch_name)
    create_pull_request(username, password, repo_name, "Updating the admin-list","This pull request updates the specified jenkins jobs by checking the gluster-maintainers list", dev_branch_name, "master")
    
if __name__ == '__main__':
    main()

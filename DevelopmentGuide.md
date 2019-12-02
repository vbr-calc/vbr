# Developing the VBR calculator

You are welcome to extend the VBR calculator in any way you see fit. This guide is for those who want to do so following the existing framework or for those who want to contribute to the github repository.

## git & github workflow

The github repository follows a stable - master - feature branch framework. The master branch is considered the development branch. Modifications to master branch are made through feature branches. The following workflow outlines the steps for creating and developing a feature branch that eventually merges with master. Only feature branches that are nominally working should be merged into the master branch.

#### scope of feature branches

In general, you should make a new branch for all code modifications. If the feature you're developing has many components then it may be better to divide your feature into successive stages that can be merged back to master as each stage is completed. The shorter time you spend within each branch, the easier the merge back to master will be.

If you have merged a branch back into master and then decide that additional development is needed, create a new branch from master after the merge and continue development in the new branch.

#### developing a feature branch

This sections outlines the git commands for creating and using a feature branch. The following assumes that you have already cloned the VBR repository and have a terminal open in the VBR repository's directory `vbr/`

1. **Initial State**: make sure you are on master branch and up to date:
  ```
  git checkout master
  git pull
  ```
2. **New Branch**: create the new feature branch (or branch for fixing a bug):  
  ```
  $git checkout -b new_branch
  ```
where `new_branch` is the name of your branch. Keep branch names as short and as descriptive as possible.

3. **Push to remote (optional)**: If your branch will take a while to develop, if you want others to be able to view or contribute to your branch, or if you want to use multiple computers to develop your branch, push your branch to the remote repository with `--set-upstream` :
  ```
  git push --set-upstream origin new_branch
  ```
This command sets the remote branch that your local `new_branch` will track. Any `git push` or `pull` will now automatically sync with the remote `new_branch` on github. After this step, you will be able to see your branch on the github page of the VBR repository.

4. **Develop your branch**: develop as normal on the new branch, adding commits as you see fit.

5. **Test your branch**: If your feature branch adds new functionality to the `vbr` directory, you should add new test functions for your new features in `vbr/testing` (see the README there, `vbr/testing/README.md`) and occasionally run the existing test functions during development. If your new feature branch is a self contained project in `Projects`, new test functions are not required (as running your project is its own test). In either case, before merging back to master, please run the full test.

6. **merge**: Your branch is complete and runs the tests successfully, merge your branch back into master (see section on merging).

7. **delete branch**: After merging with master, delete the feature branchw ith `git branch -d new_branch`. If you need to modify your new developments or add new features, create new branches for those modifications.

#### merging your new feature branch back into master

Once your branch is ready to merge back to master, submit a pull request (PR) on github. See here (link) for general instructions. If you have developer privileges for the VBR repository and are confident of your changes, feel free to complete the PR and merge to master. Note that if you make changes to your new branch and push those changes, your pull request automatically updates. If there are non-trival conflicts, please cancel the PR and deal with conflicts within your branch by merging master into your feature branch (see below), correcting conflicts, and submitting a new PR.

#### merging latest master branch into your feature branch

If your feature branch needs to use updates from other feature branches that have been merged into the master branch, or you anticipate a complex merge with many conflicts, please merge master into your feature branch before submitting a pull request. To do this, on command line:

1. **make sure master and your branch are up to date**:
  ```
  git checkout master && git pull
  git checkout new_branch && git pull
  git branch
  ```
  (make sure the output from `git branch` shows you on `new_branch`)

2. **merge master into `new_branch`**:  
  ```
  git merge master
  ```
  If all goes well, that's it. If there are conflicts, resolve them and the commit/push the resolution to your new branch. At this point, the latest changes from master will be in your branch and you can continue development or merge your branch back to master if you're done.

### style guide & helpful git tips:

In case you're new to git or developing VBR, here are some helpful tips!

**frequent fetches**: To keep your local version of the repository up to date, get in the habit of frequently running a `git fetch` to update your local repository (start of your coding day, before switching branches, end of the day, etc.). If you then switch branches, you will know if you need to run `git pull` to update that branch.

**commits**: When committing code, please keep the first line as a brief description. When a longer description is useful, add the longer description on the third line (to do this, it's easier to use `git commit` and edit the commit in your text editor rather than a single line commit, `git commit -m "commit message"`).

**stashing**: If you need to switch branches but aren't ready to commit changes to your code, you can stash your uncommitted changes. `git stash` will store uncommitted changes on current branch, `git stash apply` will restore those uncommitted changes on your current branch.

**hot fixes**: for very quick bug fixes (typos, etc.), editing on the master branch is OK. If you're not sure whether you need a new branch, you probably need a new branch.

**conflict resolution**: there are a number of tools to aid in conflict resolution. `git mergetool` will pull up a 3-way diff of your local file, the remote file and the most recent common ancestor base file and most editors will let you step through successive conflicts and choose which version to use for the conflict. If resolving conflicts for which there is a Pull Request, you can use github's online conflict resolution editor. If you use the atom editor with github integration, you can use the built in mergetool. Whatever tool you use, if you are unsure of how to resolve the conflict, you can check the commit history to find who made the changes causing you trouble and contact them (in general you shouldn't delete others changes without talking to them).

**commit history**: `git log` will print a list of all the commits on your branch, `git log --pretty=format:"%h %s" --graph` will print the commit history in a pretty way. You can then pull up the details of a single commit with `git show commit_id` where `commit_id` is the ID of the commit. If you want less detail, you can also check a single `commit_id` with `git log --name-status --diff-filter="ACDMRT" -1 -U commit_id`.

## Adding a new VBR core method
To add a new method to the VBR core:

1. Open the corresponding parameter file in `vbr/vbrCore/params` and then:
  * add the new method name to the `params.possible_methods` cell array
  * add an `elseif` catch for the new method name
  * within the `elseif`, set `param.func_name` to the name of the matlab function that you will write for the new method, e.g.,
  ```
  param.func_name='new_vbr_method'
  ```
  * set any other values/parameters that the new method needs.

2. Create a new file in `vbr/vbrCore/functions` for your new function **with the name from `param.func_name`**. Using the above example, that would be `new_vbr_method.m`.

3. Write your new method function. The function must have the `VBR` struct as input and output:
```
function [VBR] = new_vbr_method(VBR)
```
The remainder of the function is where you write whatever calculations are appropriate. The VBR structure will come in with all the state variables and parameter values. State variables are accessed with, e.g., `VBR.in.SV.T` or `VBR.in.SV.phi`. The parameter values are accessed with `VBR.in.method_type.method_name` where `method_type` is the same as the parameter file that you modified (`anelastic`,`elastic` or `viscous`) and `method_name` is the name you added to `params.possible_methods`.

4. To return the results of your function, modify the `VBR.out` structure appropriately, e.g., ```VBR.out.method_type.method_name.result = result;```
where `method_type` is the same as the parameter file that you modified (`anelastic`,`elastic` or `viscous`) and `method_name` is the name you added to `params.possible_methods`

5. If your new method relies on other methods (e.g., you're putting in a new anelastic method that requires an elastic method to exist), you can add your method to `vbr/vbrCore/functions/checkInput.m` following the other methods already there.

To use your new method, simply add the new method name to the `methods_list`, before you call `VBRspine`, e.g.:
```
VBR.in.method_type.methods_list={'method_name'}
```
where `method_type` is `anelastic`,`elastic` or `viscous` and `method_name` is your new method.

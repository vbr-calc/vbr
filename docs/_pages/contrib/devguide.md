---
permalink: /contrib/devguide/
title: "Developing the VBR calculator"
---

You are welcome to extend the VBR calculator in any way you see fit. This guide is for those who want to do so following the existing framework or for those who want to contribute to the github repository.

# git & github workflow

The VBRc is open to community contributions! New methods, new examples, documentation fixes, bug fixes!

We follow a typical open source workflow. To submit changes:

* create your fork of the VBRc repo
* checkout a new branch
* do work on your new branch
* push those changes to your fork on github
* submit a pull request back to the main VBRc repo

If you're adding a new method, be sure to add a new test (see [testing](#testing) below) and add a note to the active release notes (`release_notes.md`) with a short summary of your work.

If you're new to git, github or contributing to open source projects, the following article has a nice overview with sample git commands: [GitHub Standard Fork & Pull Request Workflow](https://gist.github.com/Chaser324/ce0505fbed06b947d962), but we outline the steps below:

## developing a feature branch

This sections outlines the git commands for creating and using a feature branch. The following assumes that you have already forked and cloned the VBR repository and have a terminal open in the VBR repository's directory `vbr/`

1. **Initial State**: make sure you are on main branch and that your main branch is up to date:
  ```
  git checkout main
  git pull
  ```
2. **New Branch**: create the new feature branch (or branch for fixing a bug):  
  ```
  git checkout -b new_branch
  ```
where `new_branch` is the name of your branch. Keep branch names as short but as descriptive as possible.

3. **Push to remote (optional)**: If your branch will take a while to develop, if you want others to be able to view or contribute to your branch, or if you want to use multiple computers to develop your branch, push your branch to the remote repository with `--set-upstream` :
  ```
  git push --set-upstream origin new_branch
  ```
This command sets the remote branch that your local `new_branch` will track. Any `git push` or `pull` will now automatically sync with the remote `new_branch` on github. After this step, you will be able to see your branch on your fork of the VBR on github (but it has not been submitted to the main VBR repository).

4. **Develop your branch**: develop as normal on the new branch, adding commits as you see fit.

5. **Test your branch**: If your feature branch adds new functionality to the `vbr` directory, you should add new test functions for your new features in `vbr/testing` (see the README there, `vbr/testing/README.md`) and occasionally run the existing test functions during development. If your new feature is a self contained project in `Projects`, new test functions are not required (as running your project is its own test). In either case, before submitting a pull request back to main, please run the full test suite (see [testing](#testing) below).

6. **Final push and pull request**: Your branch is ready! The tests run successfully and you want to submit your great new feature back into the main VBR repository so that other people can use your great work! So push up any remaining commits to github and then visit your github page for your vbr fork. There should be a notice up top saying something to the effect of "YOUR_NEW_BRANCH had recent pushes 11 minutes ago (Compare & pull request)". Click the button to "Compare & pull request". If it's not visible, you can select your branch from the dropdown menu and then the button should appear. To submit the pull request: hit the button and then enter a sensible title and a description of what you've done, and click "Create pull request".

7. **Pull request review**: so you've created a pull request! What happens now? Well the core VBRc developers will get a notice of your pull request and they will look it over (hopefully in a timely fashion). They may request code changes or more information or may merge it into the VBRc repository directly! If your branch cannot be automatically merged due to conflicts and you need help rebasing or merging, we'll help!

## testing

When you submit a pull request, a suite of tests will run via github actions. These actions test functionality in both MATLAB and Octave. You can run the full test suite locally by running the `run_all_tests.m` script in the top level of the repository. See `vbr/testing/README.md` for details on adding new tests and running subsets of tests.

## MATLAB and Octave compatibility (and pre-commit)

Ensuring that code runs on both MATLAB and Octave can be tricky. Please avoid using MATLAB Toolboxes or 3rd party Octave packages. If you would like to add functionality that requires either of these, please open a discussion via the Issues page or reach out on Slack and we can figure out ways to minimize impact and properly test new functionality.

If you use Python for other projects, you can use some pre-commit checks here to
help catch some errors. From a fresh environment, run
`pip install -r dev_requirements.txt` to install some extra dependencies and then run

```
pre-commit install
```

After which, any time you run `git commit`, pre-commit will run some simple checks
for you. As of now, the only check ensures that `.m` files do not contain the
pound/hashtag symbol, which is a valid comment symbol in octave but not matlab
and is a common mistake when your other projects are in Python...

## style guide & helpful git tips:

In case you're new to git or developing the VBRc, here are some helpful tips!

**frequent fetches**: To keep your local version of the repository up to date, get in the habit of frequently running a `git fetch` to update your local repository (start of your coding day, before switching branches, end of the day, etc.). If you then switch branches, you will know if you need to run `git pull` to update that branch.

**commits**: When committing code, please keep the first line as a brief description. When a longer description is useful, add the longer description on the third line (to do this, it's easier to use `git commit` and edit the commit in your text editor rather than a single line commit, `git commit -m "commit message"`).

**stashing**: If you need to switch branches but aren't ready to commit changes to your code, you can stash your uncommitted changes. `git stash` will store uncommitted changes on current branch, `git stash apply` will restore those uncommitted changes on your current branch.

**conflict resolution**: there are a number of tools to aid in conflict resolution. `git mergetool` will pull up a 3-way diff of your local file, the remote file and the most recent common ancestor base file and most editors will let you step through successive conflicts and choose which version to use for the conflict. If resolving conflicts for which there is a Pull Request, you can use github's online conflict resolution editor. If you use the atom editor with github integration, you can use the built in mergetool. Whatever tool you use, if you are unsure of how to resolve the conflict, get in touch and we'll try to help!

**commit history**: `git log` will print a list of all the commits on your branch, `git log --pretty=format:"%h %s" --graph` will print the commit history in a pretty way. You can then pull up the details of a single commit with `git show commit_id` where `commit_id` is the ID of the commit. If you want less detail, you can also check a single `commit_id` with `git log --name-status --diff-filter="ACDMRT" -1 -U commit_id`.

# building the documentation locally

The website lives in the `docs/` directory and is built with [Jekyll](https://jekyllrb.com/). Pull requests that touch `docs/` are built automatically by a github action, and merges to `main` deploy the site (see [versioned documentation](#versioned-documentation) below). To preview changes before opening a pull request, you can build the site locally. You will need Ruby (3.1 or newer), the `bundler` gem (included with Ruby) and a C compiler (some gems build native extensions). The Ruby that ships with macOS is too old.

## option 1: conda

If you use conda, the easiest route is a dedicated environment with Ruby and compilers from conda-forge:

```
conda create -n vbr-docs -c conda-forge ruby c-compiler cxx-compiler pkg-config make
conda activate vbr-docs
cd docs
bundle install
```

The compilers are needed because conda's Ruby expects conda's own compiler when building native extensions. Gems are installed into the conda environment, so removing the environment removes everything.

## option 2: system packages

On macOS, install Ruby with homebrew (the Xcode command line tools provide the compiler):

```
brew install ruby
export PATH="$(brew --prefix ruby)/bin:$PATH"
```

On Debian or Ubuntu:

```
sudo apt install ruby-full build-essential libssl-dev zlib1g-dev
```

Other Linux distributions are similar: install Ruby, the Ruby development headers, the OpenSSL development headers and a compiler. Then install the gems into a directory within `docs/` so nothing is written to system directories:

```
cd docs
bundle config set --local path vendor/bundle
bundle install
```

## building and serving

From within `docs/`:

```
bundle exec jekyll serve
```

and open [http://127.0.0.1:4000/vbr/](http://127.0.0.1:4000/vbr/) in a browser. The site is configured with a base path of `/vbr` to match its location on github pages, so the trailing `/vbr/` is required. The server rebuilds pages when you edit them (changes to `_config.yml` require a restart). To only build, `bundle exec jekyll build` writes the site to `docs/_site/` (opening the html files directly will not work because of the base path, so use `jekyll serve` or another local web server).

The first build downloads the site theme from github, so requires a network connection.

## linking between pages

Because the same source is published at several paths (see below), links to other pages or to images must not hardcode the `/vbr/` site root. Use the `relative_url` filter instead, which prepends whatever base path the current build uses:

{% raw %}
```
[quick start]({{ '/gettingstarted/' | relative_url }})
![figure]({{ '/assets/images/VBRsimpleFlowchart.png' | relative_url }})
```
{% endraw %}

## generated pages

Some pages are generated from the MATLAB source by the python scripts in `vbr/support/buildingdocs/` (standard library only, see the README there): the example pages under `docs/_pages/examples/` and their figures, the release notes page `docs/_pages/history.md` and the supporting functions page. Edit the source (or the script) rather than the generated markdown, then re-run the script and commit the result.

# versioned documentation

The github action in `.github/workflows/docs.yaml` publishes several versions of the site:

* `https://vbr-calc.github.io/vbr/`: the latest release (the `stable` tag in `docs/_data/versions.yml`)
* `https://vbr-calc.github.io/vbr/dev/`: the `main` branch
* `https://vbr-calc.github.io/vbr/vX.Y.Z/`: every tag listed under `tags` in `docs/_data/versions.yml`

A drop-down in the site header switches between them. Every version is rebuilt from its git tag on every deploy (a github pages deployment replaces the whole site), using the current `docs/_includes/` and `docs/_data/versions.yml` so that old versions get the version switcher too. Merges to `main` only update the `dev` docs; the docs for a release are published as part of the [release cleanup](#release-cleanup) below.

To drop an old version from the site, remove it from `tags`. Tags listed under `legacy` predate the `relative_url` convention above, so the workflow rewrites their hardcoded `/vbr/` links in the built html; new tags do not need to be listed there.

## previewing a version locally

A plain `bundle exec jekyll serve` builds the site as `dev` at `/vbr/`. To mimic what the deploy workflow does for a given version, write a `docs/_config_version.yml` (ignored by git) such as

```
baseurl: "/vbr/dev"
docs_root: "/vbr"
docs_version: "dev"
```

and pass it as a second config file: `bundle exec jekyll serve --config _config.yml,_config_version.yml`. The switcher links point at the deployed site, so they will not resolve locally.

# how to create a release

This section contains notes for the VBRc maintainers on creating releases. VBRc
releases are simply snapshots of the code, managed by git tags and saved as source
code copies in github releases (and automatically backed up to zenodo).

## release prep

To create a release, there are a few changes you first have to make:

1. Make sure your local `main` branch matches the remote upstream `main` branch:

```shell
$ git checkout main
$ git fetch --all
$ git rebase upstream/main
```

2. Go into `vbr/support/vbr_version.m` and set `Version.is_development = 0;` and adjust the `major`, `minor` or `patch` entries in the `Version` structure to whatever version you are releasing.
3. Make sure the `release_notes.md` header contains the versions string you are releasing and adjust the entries in the release notes as needed.
4. Update the release notes for the website at `docs/_pages/history.md`: you can manually copy in the latest `release_notes.md` into that file, or if you have a Python environment availabe, you can run:
```shell
$ cd vbr/support/buildingdocs/
$ python sync_release_notes.py
$ cd ../../..
```
and it will automatically update `docs/_pages/history.md`.
5. commit those changes to a new branch, e.g.:

```shell
$ git checkout -b release_prep_v1pt2pt0
$ git add .
$ git commit -m "release prep v1.2.0"
```
6. push up the new branch and create a pull request as usual

You're now ready to release!

## actually releasing

To release, create a new version tag locally:

```
$ git tag v0.99.5
```

and push it up to gitub

```
$ git push upstream v0.99.5
```

this will trigger a github action that drafts a release based on the current
version of `release_notes.md`. Go to github, edit the release and then hit publish
when ready.

## release cleanup

Make sure your local `main` matches the upstream VBRc `main` branch and then
create a new branch, e.g., `cleanup_from_v1pt2pt0` and make the following
changes:

- Copy/paste `release_notes.md` into `release_history.md`, reset `release_notes.md` for active development.
- Go to `vbr/support/vbr_version.m` and set `Version.is_development = 1;` and update the major/minor/patch numbers as you see fit (usually just bump the patch number).
- In `docs/_data/versions.yml`, set `stable` to the new tag and add the tag to the `tags` list. Merging this publishes the release's documentation at the site root (the tag must already be on github, otherwise the docs build fails trying to check it out).

Commit the changes, push up the branch and create a new pull request as usual.

Finally, go check out the github [milestones](https://github.com/vbr-calc/vbr/milestones) and
if there is a corresponding version for this release, close it out (if there are open issues
or pull requests remaining that did not make it to release, remove them from the milestone and
add them to a new one).

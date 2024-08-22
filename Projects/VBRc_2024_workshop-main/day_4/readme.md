# How to contribute to the VBRc (and other open source projects!)

## Requirements:

You need:
* a free github account (https://github.com/)
* git installed locally 
* **git linked to github account authorization!!!** 

Follow the github documentation:

https://docs.github.com/en/get-started/getting-started-with-git/set-up-git

Also recommend that you configure an editor to use. From https://git-scm.com/book/ms/v2/Customizing-Git-Git-Configuration


> `core.editor`
> 
> By default, Git uses whatever you’ve set as your default text editor via one of the shell environment variables VISUAL or EDITOR, or else falls back to the vi editor to create and edit your commit and tag messages. To change that default to something else, you can use the core.editor setting:
>
> ```
> $ git config --global core.editor emacs
> ``` 
> 
> Now, no matter what is set as your default shell editor, Git will fire up Emacs to edit messages.


## The Open Source Workflow

Not specific to VBRc!

### git & github 101

git: "track changes" for code 

Github: online git repositories 

#### the main VBRc repository 

VBRc repository: https://github.com/vbr-calc/vbr

Make a copy of the VBRc that you never want to modify yourself:

```
$ git clone https://github.com/vbr-calc/vbr
$ cd vbr 
```

```
$ git status
```

``` 
$ git branch 
```

how to use a specific version

``` 
$ git fetch --all 
```

VBRc is versioned with git "tags" (bookmarks to a particular state of the code)

``` 
$ git checkout v*
```

To get (back) to the current development version, 

``` 
$ git checkout main
```

#### Creating your own development copy 

On github:

From https://github.com/vbr-calc/vbr, create a "fork"

> fork = separate copy of someone else's repository 
> clone = exact copy of your own repository

Now clone your own fork:

(first cleanup old)

``` 
$ cd ..
$ mv vbr vbr_clone
```

(adjust for ssh or https -- click button to get link)
``` 
$ git clone git@github.com:chrishavlin/vbr.git
```

``` 
$ cd vbr 
$ git remote -v 
```

add a link to the "upstream" package (just use https since you do not have write access)

``` 
$ git remote add upstream https://github.com/vbr-calc/vbr 
```

``` 
$ git remote -v
```

#### Overview of making changes 

To avoid git headaches: **NEVER MODIFY MAIN BRANCH** with your own changes

Branches and "pull requests"


#### Keeping your main branch synced 

``` 
$ git fetch --all 
$ git rebase upstream/main 
$ git push origin
```


### Continuous Integration Testing

Github actions
local tests 




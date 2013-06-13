
##  Guide to submitting code

<u><b> Create a new branch for each story: </b></u>

As some of us may have noticed that after implementing a new story, it might be a while before your code is merged into master branch. Hence, creating a separate branch for each story/pull request is a good practice since it allows you raising multiple pull requests at the same time. It is a good way to keep productivity independent form the rate at which the pull requests are looked at.

<u><b>Recommendation:</b></u> use the story number in the branch name to easily identify the branches you have.

<u><b> Example of creating a separate branch for your story: </b></u>

- In the project directory do:
* Create a new branch with an appropriate name (<b>the story number and a short description might work</b>) and switch to it
`git checkout -b <your_branch_name>`
1833_add_follow_up_forms could be an example of the branch name.

- Work on this branch as normal (<b>regularly pulling to keep up to date and avoid conflicts. Also run tests before and after rebase with master</b>). After committing your code, push as normal to your new branch
`git push`

- On github, navigate to your branch and raise a pull request.

- After that you can checkout to master or create a new branch for the next piece of work you pick up.

- Also take a look at the excellent OpenMRS guide to using git: https://wiki.openmrs.org/display/docs/Using+Git
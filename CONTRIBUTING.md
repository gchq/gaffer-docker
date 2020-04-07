# How to contribute

We love your input! And we want to make it as easy as possible for you to contribute, whether it's by:
* Highlighting a bug
* Discussing an idea
* Proposing a new feature
* Creating a pull request

## Getting started
* Make sure you have a [GitHub account](https://github.com/).
* Maybe create a [GitHub issue](https://github.com/gchq/gaffer-docker/issues): Does an issue already exist? If you have an issue then describe it in as much detail as you can, e.g. step-by-step to reproduce.
* Fork the repository on GitHub.
* Clone the repo: `git clone https://github.com/gchq/gaffer-docker.git`
* Create a branch for your change, probably from the develop branch. Please don't work on develop. Try this: `git checkout -b gh-<issue-number>-my_contribution develop`

## Making changes
* Make sure you can reproduce any bugs you find.
* Make your changes and test. Make sure you include new or updated tests if you need to.
* Run the tests locally by following this guide on [Deploying using Kind](kubernetes/gaffer/README.md).

## Submitting changes
* Sign the [GCHQ Contributor Licence Agreement](https://github.com/gchq/Gaffer/wiki/GCHQ-OSS-Contributor-License-Agreement-V1.0).
* Push your changes to your fork.
* Submit a [pull request](https://github.com/gchq/gaffer-docker/pulls).
* We'll look at it pretty soon after it's submitted, and we aim to respond within one week.

## Getting it accepted
Here are some things you can do to make this all smoother:
* If you think it might be controversial then discuss it with us beforehand, via a GitHub issue.
* Add tests.
* Avoid hardcoded values in templates or Docker Compose files. Try and extract them to the Values.yaml or .env files if you can

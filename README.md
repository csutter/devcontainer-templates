# lightweight-devcontainer-templates

My personal, lightweight alternatives to the [default devcontainer templates][vsc_defaults].

## Motivation

[Development containers][devcontainers] ("devcontainers") are a core part of my development
workflow. Microsoft curates an ecosystem of images, templates, and plug-in features that allow users
to get started quickly and provide deep integration into VS Code.

Personally, I've experienced a fair bit of friction with the generated configuration from the
default templates, and the preconfigured images that the templates use:
* The images are quite bloated by default and include tooling that may not be required by many or
  most applications, or in some cases even causes [issues with common setups][ruby_issue]
* The images include tools and customisations that should be left up to the individual developer
  (e.g. garish shell prompt customisations)
* The images add a level of abstraction and dependencies that makes them harder to reason about than
  a manually maintained `Dockerfile`
* The images are overoptimised for integration with Microsoft tooling
* The generated configuration contains lots of scaffolding that is often left in by developers but
  gets outdated as the spec evolves

Some of these issues can be worked around by overriding the default configuration, but still add
cruft. I was looking for a more "bring your own batteries" approach.

That said, I'm sure the default templates and images are a great help to less experienced developers
who just want to get started quickly, and those who aren't as familiar with the Docker ecosystem,
so they do have their place.

## Goals

Ultimately, the primary goal of these templates is to meet my need of simple templates to use when
I start a new project - both production-grade projects and throwaway experiments - and avoid the
need to have to copy and adapt configuration from a previous project.

The templates should have:
* Trivial configuration that is easy to understand, extend, customise, and maintain
* Default upstream Docker images for the target language/ecosystem
* No tooling and customisation by default, beyond scaffolding required to:
  * run a basic application in the target language/ecosystem, and
  * be able to install additional development tools on a non-root user level (as the upstream
    images are geared towards production deployments)

## Suggested usage

Use the templates to generate a basic devcontainer setup, then customise as follows:

* Add OS-level setup and system-level dependencies (e.g. OS package manager packages) to the
  `Dockerfile`
* Run add project-specific setup and development ecosystem dependency installation using a
  `postCreateCommand` in `devcontainer.json`. If it consists of more than one or two commands,
  consider adding a shell script in the `.devcontainer` folder and running that
* Add the minimum necessary set of VS Code extensions and configuration to `devcontainer.json`
  (leaving space for other contributors/team members to not be overloaded with default setup)
* Any personal preferences of individual developers (e.g. environment customisation or tool
  installation) should be dealt with using VS Code's ability to auto-inject user dotfiles and run
  an installation script in the process (see the Debian section in [my personal dotfiles][punkt]
  install script for an example of how to achieve this).

[devcontainers]: https://containers.dev
[punkt]: https://github.com/csutter/punkt/blob/main/install.sh
[ruby_issue]: https://github.com/microsoft/vscode-dev-containers/issues/704
[vsc_defaults]: https://github.com/devcontainers/templates

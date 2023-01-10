# devcontainer-templates

A set of devcontainer templates following the nascent [devcontainer template spec][spec_proposal].

This repository contains both "barebones" templates aiming to be more lightweight and "batteries
excluded" than the [default templates][vsc_defaults], and some more complex "opinionated" templates
that reflect my personal perspective on a good starting point for new projects in ecosystems/stacks
I frequently use.

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
* The generated configuration contains lots of superfluous scaffolding that is often left in by
  developers or left commented but gets outdated as the spec evolves
* The generated configuration for some stacks/ecosystems could be more useful in terms of including
  best practices to take full advantage of devcontainers

I was looking for a more barebones, explicit, and customisable approach on the one hand, and some
more specific and opinionated templates on the other. A set of templates that I could use to set up
a new project in minimal time, without having to refer back to previous projects for inspiration,
and that I could evolve as time goes on.

Consider these templates to complement the default "official" ones - especially for inexperienced
developers and those who don't want to have to customise their environment, the official templates
are probably a better choice.

## Goals
Ultimately, the primary goal of these templates is to meet my need for professional-grade templates
to use when I set up a new project, without having to refer back to previous projects for
inspiration, and that I could evolve as time goes on and the spec and my needs change.

The templates should:
- set a "gold standard" for how I would set up a new (or existing) project for a given stack to use
  devcontainers
- have simple configuration that is easy to understand, extend, customise, and maintain
- use default upstream Docker images for the target language/ecosystem
- keep the footprint of tooling and customisation small (or to the bare minimum in case of
  "barebones" templates)
- use a non-root user, but allow for `sudo` (many upstream images are geared towards production
  deployments and run as `root`)

## Suggested usage
Use the templates to generate a basic devcontainer setup, then customise as follows:

* Add OS-level setup and system-level dependencies (e.g. OS package manager packages) to the
  `Dockerfile`
* Run add project-specific setup and development ecosystem dependency installation using a
  `postCreateCommand` in `devcontainer.json`. If it consists of more than one or two commands,
  consider adding a shell script in the `.devcontainer` folder and running that (the opinionated
  templates may already have one)
* Add the minimum necessary set of VS Code extensions and configuration to `devcontainer.json`
  (leaving space for other contributors/team members to not be overloaded with default setup)
* Any personal preferences of individual developers (e.g. environment customisation or tool
  installation) should be dealt with using VS Code's ability to auto-inject user dotfiles and run
  an installation script in the process (see the Debian section in [my personal dotfiles][punkt]
  install script for an example of how to achieve this).

## Contributions
I've not yet figured out if I want to accept contributions to this repository. If you have an idea
for a bug fix, improvement, or new template that would fit within the scope and philosophy of this
project, please open an issue before you put in substantial work!

[devcontainers]: https://containers.dev
[punkt]: https://github.com/csutter/punkt/blob/main/install.sh
[ruby_issue]: https://github.com/microsoft/vscode-dev-containers/issues/704
[spec_proposal]: https://github.com/devcontainers/spec/blob/main/proposals/devcontainer-templates.md
[vsc_defaults]: https://github.com/devcontainers/templates

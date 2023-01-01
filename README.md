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
* The generated configuration contains lots of scaffolding that is often left in by developers but
  gets outdated as the spec evolves
* They are overoptimised for integration with Microsoft tooling

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
* No tooling and customisation by default, beyond that required to run a basic application in the
  target language/ecosystem

Tooling and customisation required by the application hosted in the container should be manually
configured in the end project's `Dockerfile`. The same goes for team preferences for extensions and
configuration in the `devcontainer.json`. Any personal preferences of individual developers
(e.g. environment customisation or tool installation) should be dealt with using VS Code's ability
to auto-inject user dotfiles and run an installation script in the process.

[devcontainers]: https://containers.dev
[ruby_issue]: https://github.com/microsoft/vscode-dev-containers/issues/704
[vsc_defaults]: https://github.com/devcontainers/templates

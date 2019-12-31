# Lab Builder

## Introduction

Several projects are available today to build different labs for testing pupose. One of the best example that was an inspiration for this project is [Detection Lab](https://github.com/clong/DetectionLab/).

The goal of this project is to provide:

* An easy lab builder environment allowing you to create several labs using the same code bases
* Some sample labs (using Vagrant) ready to build for testing purposes (Windows domain lab, malware test lab,...)

## Limitations

At the moment of writing, the provided labs use Vagrant and rely on another [Build Boxes](https://github.com/df3l0p/build-boxes) for the Virtual Machine templates.

Feel free to use other boxes or change the boxes name to your needs for your lab environment.

This project has only be tested on Ubuntu linux host but should work on other OS.

## Requirements

* pipenv (python 3)
* For sample labs
  * Windows boxes (from [Build Boxes](https://github.com/df3l0p/build-boxes))
  * Vagrant - https://www.vagrantup.com/

## Installation

```bash
git clone git@github.com:df3l0p/lab-builder.git
python3 -m pipenv install
```

To switch in the pipenv environment:

```bash
pipenv shell
```

At this point, you are able to build labs.

## Build

Vagrant is always runed against build projects (`build` directory), never from the `src` directory.
Further information about the build and on the creation of context files can be found in the [build](doc/build.md) documentation.

When a context file is created, the following command can be use to create the lab files:

```bash
invoke build.vagrant-context <my_context_file>
invoke build.vagrant-context context/win_domain_lab.ctx
```

## Samples

The project provides several already configured labs. Each lab has its own `readme.md` documentation describing the lab itself and the provided features.

## License

GNU General Public License v3.0 or later

See [COPYING](COPYING) to see the full text.

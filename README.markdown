#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet_pipeline](#setup)
    * [What puppet_pipeline affects](#what-puppet_pipeline-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_pipeline](#beginning-with-puppet_pipeline)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A demo of the Automating Continuous Delivery with Puppet and Jenkins talk give for the JPUG

## Module Description

Automates the testing of modules, via Jenkins, to demonstrate the creation of CI pipelines

## Setup

### Setup Requirements

Requires a Vagrant installation, using VirtualBox or Fusion

### Beginning with puppet_pipeline

Clone repo, then `vagrant up`, once vagrant host provisioned, `vagrant ssh host`, and then: `cd /vagrant && vagrant up jenkins --provider=docker`

## Reference

Uses rtyler/jenkins and puppet/jenkins_job_builder moduless to automate a CI Pipeline

## Limitations

Currently tested to be working on Centos7

## Development

To run tests, first bundle install:

```shell
$ bundle install
```

Then, for overall spec tests, including syntax, lint, and rspec, run:

```shell
$ bundle exec rake test
```

To run acceptance tests locally, we use vagrant; first set a few environment variables for the target system:

```shell
$ export BEAKER_set=vagrant-centos6
$ export BEAKER_destroy=no
```
Note: Setting `BEAKER_destroy=no` will allow you to login to the vagrant box that get's provisioned.

Then execute the acceptance tests:

```shell
$ bundle exec rake acceptance
```

In order to access the vagrant box that's been provisioner, there are two options:
Obtain the unique ID of the box using `vagrant global-status`, and then use `vagrant ssh [unique_id]`

Alternately, change to the directory of the Beaker generated Vagrantfile:
```
$ cd .vagrant/beaker_vagrant_files/$BEAKER_SET
```
and run `vagrant ssh` - if there are multiple boxes, you may need to use `vagrant ssh [box_name]`

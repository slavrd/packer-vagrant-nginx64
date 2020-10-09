# Packer nginx64 vagrant box

A packer project that creates a vagrant box for virtualbox provider with installed nginx. The box is based off another vagrant box.

## Prerequisites

* [Install](https://www.packer.io/intro/getting-started/install.html) Packer
* [Install](https://www.virtualbox.org/wiki/Downloads) VirtualBox
* [Install](https://www.vagrantup.com/downloads.html) Vagrant

For running the inspec test:

* Ruby version 2.5.6 - it is recommended to use a Ruby versions manager like `rbenv`. To set up `rbenv` on MAC:
  * Install rbenv - run `brew install rbenv`
  * Initialize rbenv - add to `~/.bash_profile` line `eval "$(rbenv init -)"`
  * Run `source ~/.bash_profile`
  * Install ruby 2.5.1 with rbenv - run `rbenv install 2.5.6` , check `rbenv versions`
  * Set local ruby version for the project to 2.5.1 - run `rbenv local 2.5.6` , check `rbenv local`
* Installed Ruby bundler - `gem install bundler`. If using `rbenv` run also `rbenv rehash`.
* Install the required gems - `bundle install`

## Setup

The packer template relies on several environment variables:

* `VC_BOX_NAME` - The source box from which to build the resulting one. Can be a Vagrant cloud box (myUser/myBox) or a path to a locally stored box.
* `VC_BOX_VER` - The version of the box (applicable when a Vagrant cloud box is used).
* `PKR_NGINX_VER` - the apt version string of Nginx to install. Set to `auto` for installing the latest version available in the apt repositories.
* `DST_VC_BOX` - the tag of the destination Vagrant Cloud box to upload the generated artifact.
* `DST_VC_BOX_VER` - the version of the Vagrant Cloud box to which to upload.
* `VAGRANT_CLOUD_TOKEN` -  the user token for Vagrant Cloud.

The project includes a bash script - `run.sh` - which can be used to set the variables and run packer. The script will currently execute `packer` using the `template.v1.6.json` template. The `VAGRANT_CLOUD_TOKEN` still needs to be set manually.

Script usage:

`./run.sh <nginx_version> <source_box> <source_box_version> [<dst_vc_box> <dsc_vc_box_ver>]`

* `nginx_version` - apt version string of nginx to install or 'auto'
* `source_box_name` - vagrant cloud box 'my-vc-user/my-box'
* `source_box_version` - version of the VC box or 'current'
* `dst_vc_box` - (optional) the vagrant cloud destination box
* `dsc_vc_box_ver` - (required if dst_vc_box set) the vagrant cloud destination box version

## Running the project

Project can be run in the following ways

1. Use the `run.sh` script described in the previous section. It will set the environment variables and run packer according to the provided arguments. At the minimum packer will provision the new vagrant box and test it with the `inspec`provisioner. If the destination Vagrant cloud box arguments are provided packer will upload the output box to Vagrant cloud.
2. Set the environment variables and run `packer build template.json`. You can exclude the `inspec` provisioner and/or the `vagrant-cloud` post-processor by using the `-except` switch. For example `packer build -except inspec,vagrant-cloud template.json` - will create the vagrant box but will not test it with inspec and will not upload it to Vagrant cloud

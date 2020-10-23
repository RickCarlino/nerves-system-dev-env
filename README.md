# In A Hurry?

I built this so I could reproducibly create custom nerves systems and prevent local workstation dependencies from slowing me down.

This section is essentially a "note to self".

If you wipe your laptop, you can find a replacement image on the "releases" page of this repo.

```bash
# === `cd` into the custom nerves_system you want to build.
#     farmbot_system_rpi3, farmbot_system_rpi, etc..
cd WHEREVER_CUSTOM_NERVES_SYSTEM_REPO_IS

# === Open a docker shell to work in. This will link a
#     volume to the current repo. Inside docker, the repo
#     lives in `/project`.
# FISH SHELL (not Bash):
sudo docker run --rm -i -t -v (pwd):/project nerves_system_builder:may27 bash

# CD into working directory (you're in a container now)
cd /project

# Install whatever Elixir / Erlang version you need:
asdf install elixir 1.10.4-otp-23 # <- Version changes over time
asdf install erlang 23.1.1 # <- Version changes over time

# Do the usual updates
mix deps.get --all
mix local.nerves

# === Change the `VERSION` file (otherwise the build won't run)
nano VERSION

# === Open Nerves System Shell
mix nerves.system.shell

# === Do whatever it is you need to do in buildroot menuconfig
make menuconfig

# === Build the system (time consuming)
make

# === Several hours pass. You may now build the artifacts...
mix deps.get
mix local.nerves
mix nerves.artifact

# You will now see a file that looks something like this:
farmbot_system_rpi3-portable-1.2.3-farmbot.4-567890A.tar.gz
```
# Creating A Nerves System Development Environment

Below are instructions on how to get a dev setup for building custom Nerves systems on your machine or a VM. The instructions assume a clean installation of Ubuntu 18.04.

If you are just trying to get started with the Nerves Framework, please see the [official doucmentation](https://hexdocs.pm/nerves/getting-started.html).


# Follow Along in an Empty Docker Container

You can follow along in an empty  Docker container. We will only cover Ubuntu 18.

Create an empty container via:

```
sudo docker run --rm -i -t ubuntu:18.04 bash
```

Since there are no volumes attached, **your progress will not be saved**. An explanation on how to attach a volume to a container can be found in the Docker documentation.

# Install Nerves OS-Level Dependencies

First, ensure everything is up-to-date:

```
apt-get update --yes
```

Then install missing dependencies:

```
apt install autoconf automake bc build-essential cmake curl file git libncurses5-dev libssl-dev libwxgtk3.0-dev m4 pkg-config squashfs-tools ssh-askpass unzip --yes
```

# Install ASDF

[ASDF](https://github.com/asdf-vm/asdf) is a popular version manager in the Elixir community and is the recommended version manager for Nerves development on Linux. **Bash is the assumed system shell.** The ASDF documentation explains how to install ASDF on different shells.

```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

# Install Erlang, Elixir
ASDF follows the pattern of:

1. Install plugins to manage the versions of a package.
2. Install a specific version of a package.
3. Set the version as the system default.

**Erlang installation:**

```
asdf plugin-add erlang
asdf install erlang 22.3.2
asdf global erlang 22.3.2
```

**Elixir installation:**

```
asdf plugin-add elixir
asdf install elixir 1.10.3-otp-22
asdf global elixir 1.10.3-otp-22
```

# Install FWUP

You will need FWUP to build firmware and flash SD cards.

```
curl -sLO https://github.com/fhunleth/fwup/releases/download/v1.7.0/fwup_1.7.0_amd64.deb
dpkg -i fwup_1.7.0_amd64.deb
```

# Install Nerves

Perform some housekeeping and install "nerves_bootstrap":
```
mix local.hex
mix local.rebar
mix archive.install hex nerves_bootstrap
```

# Add SSH Keys

This is required to create firmware during the installation verification step (next).

Your system might already have SSH keys in `~/.ssh/id_rsa`. If it doesn't you can generate them via:

```
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
```

# Verify Installation with a Practice Build

Ensure Nerves installed correctly by creating firmware for an empty project:

```
mix nerves.new deleteme --target rpi
cd deleteme
MIX_TARGET=rpi mix deps.get
MIX_TARGET=rpi mix firmware
```

If there were no errors, you can exit the directory and destroy the remaining project files. The purpose of building the project was to ensure all required dependencies had installed properly.

```
cd ..
rm -rf deleteme
```

# Install `nerves_system_rpi` Deps Before Proceeding

Now that we know Nerves is installed, we can begin work on a custom build. The build will fail if we do not install the following requirements:
```
apt install file cpio wget rsync gawk python3 --yes
```

# Fork `nerves_system_rpi`

The last step is to attempt a build using everything we have installed up to this point. In this example, we will build a custom version of [nerves_system_rpi](https://github.com/nerves-project/nerves_system_rpi).

```
git clone https://github.com/nerves-project/nerves_system_rpi.git -b v1.11.1
cd nerves_system_rpi/
mix deps.get
```

At this point you are ready to make changes to the system. See the [Nerves documentation for more information](https://hexdocs.pm/nerves/0.4.0/systems.html).

Once you are done making change run

```
mix nerves.system.shell
```

From within `nerves.system.shell` run:

```
make
```

This takes a long time on most machines.

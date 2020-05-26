# Creating A Nerves System Development Environment

Below are instructions on how to get a dev setup for building custom Nerves systems on your machine or a VM. The instructions assume a clean installation of Ubuntu 18.04.

If you are just trying to get started with the Nerves Framework, please see the [official doucmentation](https://hexdocs.pm/nerves/getting-started.html).


# Follow Along in an Empty Docker Container

You can follow along in an Docker empty container. We will only cover Ubuntu 18 setup.

Create an empty container via:

```
sudo docker run --rm -i -t ubuntu:18.04 bash
```

Since there are no volumes attached, **your progress will not be saved**. The Docker documentation explains this well.

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

[ASDF](https://github.com/asdf-vm/asdf) is a popular version manager in the Elixir community and is the recommended version manager for Nerves development on Linux. **Bash is the assumed system shell. See the ASDF documentation for other shells (Fish, ZSH, etc..)** The ASDF documentation explains how to install ASDF on different shells.

```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

# Install Erlang, Elixir
ASDF follows that pattern of:

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
asdf install elixir 1.10.2-otp-22
asdf global elixir 1.10.2-otp-22
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

If there were no errors, you can exit the directory and destroy the remaining project files.

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
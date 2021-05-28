# Understanding This Repo

Updating Nerves system is not always easy. To make matters worse, updates only happen a few times a year. That means that once you learn how to do it, you will immediately forget.

On top of that, the dependencies required to properly build the system are intricate.

This repo contains a docker image in `*.tar` format that can be used to build Nerves system upgrades.

The instructions below show you how to:

 * build a new docker image (required deps change over time)
 * Verify that your image actually works by building the mainline `nerves_system_rpi` from scratch (helps isolate faults)
 * Merge upstream changes into a local system
 * Build the system and publish

# Build the Container

```
docker pull ubuntu:20.04
sudo docker run --rm -i -t ubuntu:20.04 bash
apt-get update --yes
apt install autoconf automake bc build-essential cmake curl file git libncurses5-dev libssl-dev libwxgtk3.0-gtk3-dev m4 pkg-config squashfs-tools ssh-askpass unzip file cpio wget rsync gawk python3 --yes
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
asdf plugin add erlang
asdf plugin add elixir
asdf install elixir 1.11.4-otp-23
asdf install erlang 23.3.4
asdf global elixir 1.11.4-otp-23
asdf global erlang 23.3.4
curl -sLO https://github.com/fwup-home/fwup/releases/download/v1.8.4/fwup_1.8.4_amd64.deb
dpkg -i fwup_1.8.4_amd64.deb
mix local.hex
mix local.rebar
mix archive.install hex nerves_bootstrap
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
```

Lastly, add these lines to the end of `~/.bashrc` (so you can access `asdf` on next login):

```
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

# Verify Installation

Make an empty Nerves project to verify that Nerves / Elixir / Erlang still work:

```
mix nerves.new deleteme --target rpi
cd deleteme
MIX_TARGET=rpi mix deps.get
MIX_TARGET=rpi mix firmware
cd ..
rm -rf deleteme
```

# Verify Ability to Build Mainline Nerves System

Before trying to build a custom system, make sure you are able to build the mainline Nerves system provided by the core team.

```
git clone https://github.com/nerves-project/nerves_system_rpi.git -b v1.15.1
cd nerves_system_rpi/
mix deps.get
mix nerves.system.shell
make
```

This took 45 minutes on my decently powered Core i7 Laptop (SSD drive).

# Save the Container Before Continuing

Your container works. Lets save it for use next time.

Figure out the container's name:

```
sudo docker ps

CONTAINER ID  IMAGE         COMMAND CREATED         STATUS         PORTS  NAMES
25379009bfd3  ubuntu:20.04  "bash"  43 minutes ago  Up 43 minutes         naughty_chaplygin
```

```
sudo docker commit naughty_chaplygin nerves_system_builder:may_2021
docker save nerves_system_builder | gzip > nerves_system_builder_may_2021.tar.gz
```

# Perform the Upgrade on Host Machine (Not Docker)

Never pull from `main`. The Nerves team does not keep `main` stable.

Instead, pull the latest tag:

```
git pull upstream 1.15.1
```

It will certainly have merge conflict. Fix the conflicts and commit the changes.

**Pro Tip:tm:** Make sure `.tool-versions` matches upstream!

# Build the System

Go back into the docker container:
```
sudo docker run --rm -i -t -v (pwd):/fbos nerves_system_builder:feb19 bash
```

```
cd /fbos
mix local.hex
mix local.rebar
mix archive.install hex nerves_bootstrap
mix deps.get
mix nerves.shell
make
```

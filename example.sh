# === INSTALLING NERVES FROM A CLEAN SLATE (Ubuntu 18.04 LTS)
sudo docker run --rm -i -t ubuntu:18.04 bash

# === RUN UPDATES
apt-get update --yes

# === Install Nerves deps
apt install autoconf automake bc build-essential cmake curl file git libncurses5-dev libssl-dev libwxgtk3.0-dev m4 pkg-config squashfs-tools ssh-askpass unzip --yes

# === Install ASDF
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# === Install Erlang
asdf plugin-add erlang
asdf install erlang 22.3.2
asdf global erlang 22.3.2

# === Install Elixir
asdf plugin-add elixir
asdf install elixir 1.10.2-otp-22
asdf global elixir 1.10.2-otp-22

# === Install FWUP
curl -sLO https://github.com/fhunleth/fwup/releases/download/v1.7.0/fwup_1.7.0_amd64.deb
dpkg -i fwup_1.7.0_amd64.deb

# === Install Nerves
mix local.hex
mix local.rebar
mix archive.install hex nerves_bootstrap

# === Add SSH keys (needed for verification of `mix firmware`)
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""

# === Verify Nerves install by building a throwaway project
mix nerves.new deleteme --target rpi # Don't install deps
cd deleteme
MIX_TARGET=rpi mix deps.get
MIX_TARGET=rpi mix firmware
cd ..
rm -rf deleteme

# === Install `nerves_system_rpi` deps (required for `make` builds)
apt install file cpio wget rsync gawk python3 --yes

# == Clone / build `nerves_system_rpi`
git clone https://github.com/nerves-project/nerves_system_rpi.git -b v1.11.1
cd nerves_system_rpi/
mix deps.get
mix nerves.system.shell # Run `make` in here.

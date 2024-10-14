[private]
default:
  @just --list --unsorted

# setup our nixos and darwin builder
[private]
[group('rebuild')]
builder goal *args:
  nh os {{goal}} -- {{args}}

# we have this setup incase i ever want to go back and use the old stuff
[private]
[linux]
[group('rebuild')]
classic goal *args:
  sudo nixos-rebuild {{goal}} --flake . {{args}} |& nom

# rebuild the boot
[group('rebuild')]
boot *args: (builder "boot" args)

# test what happens when you switch
[group('rebuild')]
test *args: (builder "test" args)

# switch the new system configuration
[group('rebuild')]
switch *args: (builder "switch" args)

[group('rebuild')]
[macos]
provision host:
  nix run github:LnL7/nix-darwin -- switch --flake .#{{host}}
  sudo -i nix-env --uninstall lix # we need to remove the none declarative install of lix


# build the package, you must specify the package you want to build
[group('package')]
build pkg:
  nix build .#{{pkg}} --log-format internal-json -v |& nom --json

# build the iso image, you must specify the image you want to build
[group('package')]
iso image: (build "nixosConfigurations." + image + ".config.system.build.isoImage")

# build the tarball, you must specify the host you want to build
[group('package')]
tar host:
  sudo nix run .#nixosConfigurations.{{host}}.config.system.build.tarballBuilder


[private]
verify *args:
  nix-store --verify {{args}}

# repairs the nix store from any breakages it may have
[group('dev')]
repair: (verify "--check-contents --repair")

# clean the nix store and optimise it
[group('dev')]
clean:
  nix-collect-garbage --delete-older-than 3d
  nix store optimise

# check the flake for errors
[group('dev')]
check:
  nix flake check

# update the lock file, if inputs are provided, only update those, otherwise update all
[group('dev')]
update *input:
  nix flake update {{input}} --refresh
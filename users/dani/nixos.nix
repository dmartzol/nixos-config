{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.dani = {
    isNormalUser = true;
    home = "/home/dani";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$FG0EwUb7y3/gBv5w$vlhU57boVxxJOp3BDRiAE.sKltXUf.Nb9kNvmVVXW05KtSo/gF5O8VJpLQZTbd.gyKOvW2k5LGlVzn7PGrNNK0";
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAA+pYRDWSifVVfBDddo+DttySFHzCRR8FC5N7pP9BMc3Fuk8EGqm718pzv6OVZwp3cbyqC3dutFNsckVvgTx4pZMgiTDc8AytHwRt1i8xZ6XAiaVrCGtefDByrSk3DuoySrlz4RE8hLS8A502IsothKKg3WFtYYfvfpZBc/LoUsVSr/6kLcUFmDtcy/z0/7dANN1vF8FIHBDNc/N124xEqZ/0Kk+7pX6LKeTNEOSjSXzAwUfdY03O4TVY0MFm923IwrYCtQkR3Ym4j4uh3cgQ0XbsVtXbGQzJvsQfW0yhk5jpDh++Sav4esR/P3pgIDbwPxSZdaLmrL6wy2x7fUu9 dani@Daniels-MacBook-Pro.local"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}

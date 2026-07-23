{
  description = "Zoho Cliq flake package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true; # Разрешаем установку unfree пакетов
    };
  in {
    packages.x86_64-linux.zoho-cliq = pkgs.callPackage ./default.nix { };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.zoho-cliq;
  };
}

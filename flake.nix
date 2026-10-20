{
  description = "Jeff's themes and the platform customizations that install them";

  outputs =
    { self }:
    {
      homeManagerModules.conductor = ./modules/conductor-home.nix;
      darwinModules.conductor = ./modules/conductor-darwin.nix;
    };
}

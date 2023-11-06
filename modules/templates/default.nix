{
  flake.templates = {
    rust = {
      path = ./rust;
      description = "Rust Template using fenix, devenv, and flake-parts";
    };
    empty = {
      path = ./empty;
      description = "Empty Template using devenv and flake-parts";
    };
    callPackage = {
      path = ./callPackage;
      description = "Simply create a package via callPackage";
    };
  };
}

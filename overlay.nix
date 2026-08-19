# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

self: super:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

  # Single source of truth for the pinned tarball; default.nix owns the fetch
  # and passes it to both derivations.
  jsbsim-src = nurAttrs.jsbsim.src;

in
builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
    (builtins.filter (n: !isReserved n)
      (builtins.attrNames nurAttrs)))
// {
  # Inject the python module into every Python package set so that
  # `python3.withPackages (p: [ p.jsbsim ])` works. The package is also
  # exposed at the top level as `jsbsim-python` above.
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      jsbsim = pyfinal.callPackage ./pkgs/jsbsim-python {
        src = jsbsim-src;
      };
    })
  ];
}

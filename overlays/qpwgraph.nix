self: super: {
  qpwgraph = super.qpwgraph.overrideAttrs (o: rec {
    version = "0.2.1";
    src = self.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "rncbc";
      repo = "qpwgraph";
      rev = "v${version}";
      hash = "sha256-MDfB1mztkHZ59v+My53jKL4I3ICGzRGdY3OFkVspMfM=";
    };
  });
}

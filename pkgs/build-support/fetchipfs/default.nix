/**
  Fetch files from IPFS (InterPlanetary File System) using a local or remote gateway.

  This fetcher downloads content from IPFS using curl, expecting an IPFS gateway to be available.
  By default, it fetches from a gateway running on localhost:8080, but this can be configured using the `port` or `url` arguments.
  The fetched content is verified using the provided hash.

  This fetcher uses `lib.fetchers.withNormalizedHash`, so you can specify the hash as `sha256`, `sha512`, or with `outputHash`/`outputHashAlgo`, similar to other Nixpkgs fetchers.

  # Parameters
  - ipfs: The IPFS content identifier (CID) to fetch. (required)
  - url: Optional. If set, overrides the default IPFS URL. If not set, constructed from `ipfs` and `port`.
  - curlOpts: Additional options passed to curl. (optional)
  - sha256/sha512/outputHash/outputHashAlgo: Hash of the expected output (required).
  - meta: Metadata for the derivation. (optional)
  - port: Port of the local IPFS gateway (default: "8080").
  - postFetch: Shell commands to run after fetching. (optional)
  - preferLocalBuild: Whether to prefer local builds (default: true).

  # Example
  ```nix
  fetchipfs {
    ipfs = "Qm...";
    sha256 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  }
  ```
  See also: https://nixos.org/manual/nixpkgs/stable/#fetchers */

{
  lib,
  stdenv,
  curl,
}:
lib.fetchers.withNormalizedHash
  {
    hashTypes = [
      "sha1"
      "sha256"
      "sha512"
    ];
  }
  (
    {
      ipfs, # TODO: use `cid` instead of `ipfs`?
      url ? "",
      curlOpts ? "",
      outputHash,
      outputHashAlgo,
      meta ? { },
      port ? "8080",
      postFetch ? "",
      preferLocalBuild ? true,
    }:
    stdenv.mkDerivation {
      name = ipfs;
      builder = ./builder.sh;
      nativeBuildInputs = [ curl ];

      # New-style output content requirements.
      inherit outputHash outputHashAlgo;
      outputHashMode = "recursive";

      inherit
        curlOpts
        postFetch
        ipfs
        url
        port
        meta
        ;

      # Doing the download on a remote machine just duplicates network
      # traffic, so don't do that.
      inherit preferLocalBuild;
    }
  )

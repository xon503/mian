{
  pkgs,
  config,
  ...
}:
{
  home.stateVersion =
    if pkgs.stdenv.hostPlatform.isDarwin then "23.11" else config.system.stateVersion;
}

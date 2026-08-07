{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.exporter;
  yamlFormat = pkgs.formats.yaml { };
  inherit (lib)
    mkOption
    types
    concatStringsSep
    ;
in
{
  port = 9999;

  extraOpts = {
    configFile = mkOption {
      type = types.path;
      default = yamlFormat.generate "expexp.yml" cfg.settings;
      defaultText = lib.literalExpression ''yamlFormat.generate "expexp.yml" cfg.settings'';
      description = ''
        Path to an YAML configuration file.
        By default, this is generated from `settings`.
        If specified manually, then `settings` is ignored.

        See [upstream documentation](https://github.com/tcolgate/exporter_exporter#configuration).
      '';
    };

    settings = mkOption {
      description = "Settings to render into the configuration file. Ignored if configFile is set";
      type = types.submodule {
        freeformType = yamlFormat.type;
      };
    };
  };

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${lib.getExe pkgs.prometheus-exporter-exporter} \
          --config.file ${cfg.configFile} \
          --web.listen-address=${cfg.listenAddress}:${toString cfg.port}
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}

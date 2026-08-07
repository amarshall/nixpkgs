{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "prometheus-exporter-exporter";
  version = "0.6.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tcolgate";
    repo = "exporter_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0AXZFKwIkl6idpkwqND/Pdv7vk6hzOchtoOrsdLUWd4=";
  };

  vendorHash = "sha256-nuF4f54amPdbRxYQXIhpvvxP+b/Y2d+Q0pS5YPIuGT0=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
    "-X=main.Revision=${finalAttrs.src.rev}"
    "-X=main.BuildDate=1970-01-01T00:00:00Z"
    "-X=main.Branch=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A reverse proxy designed for Prometheus exporters";
    homepage = "https://github.com/tcolgate/exporter_exporter";
    changelog = "https://github.com/tcolgate/exporter_exporter/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ amarshall ];
    mainProgram = "exporter_exporter";
  };
})

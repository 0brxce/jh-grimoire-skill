{
  description = "Grimoire: security research toolkit plugin for Claude Code and omp";

  outputs = { self }: {
    homeManagerModules.default = { config, lib, ... }:
      let
        cfg = config.programs.grimoire;
        # Just the plugin, not the specs and tooling around it
        plugin = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [ ./.claude-plugin ./skills ./agents ./hooks ];
        };
        skills = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));
        agents = lib.filter (lib.hasSuffix ".md") (lib.attrNames (builtins.readDir ./agents));
        ompLink = path: lib.nameValuePair ".omp/agent/${path}" { source = "${plugin}/${path}"; };
      in
      {
        options.programs.grimoire = {
          enable = lib.mkEnableOption "Grimoire";
          targets = lib.mkOption {
            type = lib.types.listOf (lib.types.enum [ "claude-code" "omp" ]);
            default = [ "claude-code" ];
            example = [ "claude-code" "omp" ];
            description = "Coding agents to install Grimoire for.";
          };
        };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          # Registers the `grimoire` marketplace and enables grimoire@grimoire
          (lib.mkIf (lib.elem "claude-code" cfg.targets) {
            assertions = [{
              assertion = config.programs.claude-code.enable;
              message = "programs.grimoire: the claude-code target needs programs.claude-code.enable = true";
            }];
            programs.claude-code = {
              marketplaces.grimoire = plugin;
              settings.enabledPlugins."grimoire@grimoire" = true;
            };
          })
          # ponytail: omp gets skills and agents only; hooks need omp-hooks-plus, MCP needs manual config
          (lib.mkIf (lib.elem "omp" cfg.targets) {
            home.file = lib.listToAttrs (map (s: ompLink "skills/${s}") skills ++ map (a: ompLink "agents/${a}") agents);
          })
        ]);
      };
  };
}

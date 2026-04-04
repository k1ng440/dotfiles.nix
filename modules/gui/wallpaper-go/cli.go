package main

import (
	"os"

	"github.com/spf13/cobra"
)

type WallpaperFilterArgs struct {
	NoFaces       bool
	SingleFace    bool
	MultipleFaces bool
	Faces         uint32
}

func addFilterFlags(cmd *cobra.Command, args *WallpaperFilterArgs) {
	cmd.Flags().BoolVar(&args.NoFaces, "no-faces", false, "Filter wallpapers with no faces")
	cmd.Flags().BoolVar(&args.SingleFace, "single-face", false, "Filter wallpapers with a single face")
	cmd.Flags().BoolVar(&args.MultipleFaces, "multiple-faces", false, "Filter wallpapers with multiple faces")
	cmd.Flags().Uint32Var(&args.Faces, "faces", 0, "Filter wallpapers with number of faces")
}

func newRootCmd() *cobra.Command {
	var reload bool
	var skipHistory bool
	var skipWallpaper bool
	filterArgs := &WallpaperFilterArgs{}

	rootCmd := &cobra.Command{
		Use:   "wallpaper [PATH]",
		Short: "Changes the wallpaper and updates the colorscheme",
		Args:  cobra.MaximumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return runRoot(cmd, args, reload, skipHistory, skipWallpaper, filterArgs)
		},
	}

	rootCmd.Flags().BoolVar(&reload, "reload", false, "Reload current wallpaper")
	rootCmd.Flags().BoolVar(&skipHistory, "skip-history", false, "Do not save history")
	rootCmd.Flags().BoolVar(&skipWallpaper, "skip-wallpaper", false, "Do not resize or set wallpaper")
	addFilterFlags(rootCmd, filterArgs)

	// Subcommands
	rootCmd.AddCommand(newCurrentCmd())
	rootCmd.AddCommand(newRmCmd())
	rootCmd.AddCommand(newReloadCmd())
	rootCmd.AddCommand(newHistoryCmd())
	rootCmd.AddCommand(newSelectCmd())
	rootCmd.AddCommand(newDedupeCmd())
	rootCmd.AddCommand(newEditCmd())
	rootCmd.AddCommand(newAddCmd())
	rootCmd.AddCommand(newSearchCmd())
	rootCmd.AddCommand(newBackupCmd())
	rootCmd.AddCommand(newRemoteCmd())
	rootCmd.AddCommand(newCropCmd())
	rootCmd.AddCommand(newThumbnailsCmd())
	rootCmd.AddCommand(newMetadataCmd())
	rootCmd.AddCommand(newGenerateCmd())
	rootCmd.AddCommand(newWallhavenCmd())

	return rootCmd
}

func newGenerateCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "generate [bash|zsh|fish]",
		Short: "Generate shell completions",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			shell := args[0]
			root := cmd.Root()
			switch shell {
			case "bash":
				return root.GenBashCompletion(os.Stdout)
			case "zsh":
				return root.GenZshCompletion(os.Stdout)
			case "fish":
				return root.GenFishCompletion(os.Stdout, true)
			default:
				return cmd.Usage()
			}
		},
	}
}

func newCurrentCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "current",
		Short: "Prints the path of the current wallpaper",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runCurrent(cmd, args)
		},
	}
}

func newRmCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "rm [PATH]",
		Short:   "Deletes the current wallpaper",
		Aliases: []string{"remove", "delete", "yeet"},
		RunE: func(cmd *cobra.Command, args []string) error {
			return runRm(cmd, args)
		},
	}
}

func newReloadCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "reload",
		Short:   "Reloads the current wallpaper",
		Aliases: []string{"refresh"},
		RunE: func(cmd *cobra.Command, args []string) error {
			return runReload(cmd, args)
		},
	}
}

func newHistoryCmd() *cobra.Command {
	args := &WallpaperFilterArgs{}
	cmd := &cobra.Command{
		Use:   "history",
		Short: "Show wallpaper history selector with pqiv",
		RunE: func(cmd *cobra.Command, args_ []string) error {
			return runHistory(cmd, args_, args)
		},
	}
	addFilterFlags(cmd, args)
	return cmd
}

func newSelectCmd() *cobra.Command {
	args := &WallpaperFilterArgs{}
	cmd := &cobra.Command{
		Use:     "select",
		Aliases: []string{"selector", "pqiv"},
		Short:   "Show wallpaper selector with pqiv",
		RunE: func(cmd *cobra.Command, args_ []string) error {
			return runSelect(cmd, args_, args)
		},
	}
	addFilterFlags(cmd, args)
	return cmd
}

func newDedupeCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "dedupe",
		Aliases: []string{"unique", "uniq"},
		Short:   "Runs czkawka to show duplicate wallpapers",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runDedupe(cmd, args)
		},
	}
}

func newEditCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "edit [IMAGE]",
		Aliases: []string{"recrop"},
		Short:   "Edit and reload the current wallpaper with the wallpaper tool",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runEdit(cmd, args)
		},
	}
}

func newAddCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "add [IMAGES]",
		Short: "Processes wallpapers with upscaling and vertical crop",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runAdd(cmd, args)
		},
	}
}

func newSearchCmd() *cobra.Command {
	var top uint32
	cmd := &cobra.Command{
		Use:     "search [QUERY]",
		Aliases: []string{"rg", "grep", "find", "rclip"},
		Short:   "Search for wallpapers using rclip",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runSearch(cmd, args, top)
		},
	}
	cmd.Flags().Uint32Var(&top, "top", 100, "Number of top results to display")
	return cmd
}

func newBackupCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "backup [PATH]",
		Short: "Backup wallpapers to secondary location",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runBackup(cmd, args)
		},
	}
}

func newRemoteCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "remote [REMOTE]",
		Aliases: []string{"sync", "rsync"},
		Short:   "Sync wallpapers to another machine",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runRemote(cmd, args)
		},
	}
}

func newCropCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "crop [SIZE] [INPUT] [OUTPUT]",
		Aliases: []string{"resize"},
		Short:   "Crop a wallpaper to a specific size",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runCrop(cmd, args)
		},
	}
}

func newThumbnailsCmd() *cobra.Command {
	var force bool
	cmd := &cobra.Command{
		Use:   "thumbnails",
		Short: "Generate thumbnails for the wallpapers",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runThumbnails(cmd, args, force)
		},
	}
	cmd.Flags().BoolVar(&force, "force", false, "Force generation even if thumbnail already exists")
	return cmd
}

func newMetadataCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "metadata [IMAGE]",
		Short: "Prints metadata for the current wallpaper / image",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runMetadata(cmd, args)
		},
	}
}

func newWallhavenCmd() *cobra.Command {
	var query string
	var colors string
	var atleast string
	var ratios string
	filterArgs := &WallpaperFilterArgs{}

	cmd := &cobra.Command{
		Use:     "wallhaven",
		Aliases: []string{"wh"},
		Short:   "Download a random wallpaper from Wallhaven and set it",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runWallhaven(cmd, args, query, colors, atleast, ratios, filterArgs)
		},
	}
	cmd.Flags().StringVarP(&query, "query", "q", "", "Search query for Wallhaven (the 'q' parameter)")
	cmd.Flags().StringVar(&colors, "colors", "", "Search for specific colors (e.g. 000000,999999)")
	cmd.Flags().StringVar(&atleast, "atleast", "3440x1440", "Minimum resolution (e.g. 1920x1080)")
	cmd.Flags().StringVar(&ratios, "ratios", "21x9", "Aspect ratios (e.g. 16x9,16x10)")
	addFilterFlags(cmd, filterArgs)
	return cmd
}

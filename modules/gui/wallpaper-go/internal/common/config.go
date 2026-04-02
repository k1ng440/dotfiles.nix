package common

import (
	"os"
	"path/filepath"
)

type Config struct {
	WallpaperDir   string
	NixJsonPath    string
	HistoryCsvPath string
	RuntimeDir     string
	CacheDir       string
}

func NewConfig() *Config {
	home, _ := os.UserHomeDir()
	runtimeDir := os.Getenv("XDG_RUNTIME_DIR")
	cacheDir := filepath.Join(home, ".cache")
	if c := os.Getenv("XDG_CACHE_HOME"); c != "" {
		cacheDir = c
	}

	return &Config{
		WallpaperDir:   filepath.Join(home, "Pictures/Wallpapers"),
		NixJsonPath:    filepath.Join(home, ".local/state/nix.json"),
		HistoryCsvPath: filepath.Join(home, "Pictures/wallpapers_history.csv"),
		RuntimeDir:     runtimeDir,
		CacheDir:       cacheDir,
	}
}

var DefaultConfig = NewConfig()

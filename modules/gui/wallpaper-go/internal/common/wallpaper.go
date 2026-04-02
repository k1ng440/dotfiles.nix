package common

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"math/rand/v2"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

func Dir() string {
	return DefaultConfig.WallpaperDir
}

func Current() (string, error) {
	if DefaultConfig.RuntimeDir == "" {
		return "", fmt.Errorf("XDG_RUNTIME_DIR not set")
	}
	path := filepath.Join(DefaultConfig.RuntimeDir, "current_wallpaper")
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func FilterImages(dir string) ([]string, error) {
	var images []string
	err := filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			if d != nil && d.IsDir() {
				return filepath.SkipDir
			}
			return nil
		}
		if d.IsDir() {
			return nil
		}
		ext := strings.ToLower(filepath.Ext(path))
		switch ext {
		case ".jpg", ".jpeg", ".png", ".webp":
			images = append(images, path)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return images, nil
}

type WlrMonitor struct {
	Enabled bool   `json:"enabled"`
	Name    string `json:"name"`
}

func Set(wallpaperPath string) error {
	if DefaultConfig.RuntimeDir != "" {
		_ = os.WriteFile(filepath.Join(DefaultConfig.RuntimeDir, "current_wallpaper"), []byte(wallpaperPath), 0644)
	}

	cmd := exec.Command("wlr-randr", "--json")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to run wlr-randr: %w", err)
	}

	var monitors []WlrMonitor
	if err := json.Unmarshal(output, &monitors); err != nil {
		return fmt.Errorf("failed to parse wlr-randr json: %w", err)
	}

	for _, mon := range monitors {
		if !mon.Enabled {
			continue
		}
		err := exec.Command("noctalia-ipc", "wallpaper", "set", wallpaperPath, mon.Name).Run()
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to set wallpaper for %s: %v\n", mon.Name, err)
		}
	}
	return nil
}

func Reload() {
	img, err := Current()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to get current wallpaper: %v\n", err)
		return
	}

	nj, err := LoadNixJson()
	if err == nil {
		for _, mon := range nj.Monitors {
			cachePath := mon.NoctaliaWallpaperCachePath(img)
			_ = os.Remove(cachePath)
		}
	}

	_ = exec.Command("noctalia-reload").Start()
}

func RandomFromDir(dir string) string {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		nj, _ := LoadNixJson()
		if nj != nil {
			return nj.FallbackWallpaper
		}
		return ""
	}

	wallpapers, _ := FilterImages(dir)
	if len(wallpapers) == 0 {
		nj, _ := LoadNixJson()
		if nj != nil {
			return nj.FallbackWallpaper
		}
		return ""
	}

	return wallpapers[rand.IntN(len(wallpapers))]
}

type HistoryEntry struct {
	Path string
	Time time.Time
}

func History() ([]HistoryEntry, error) {
	f, err := os.Open(DefaultConfig.HistoryCsvPath)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	wallDir := Dir()
	entries, _ := os.ReadDir(wallDir)
	wallFiles := make(map[string]bool)
	for _, entry := range entries {
		wallFiles[entry.Name()] = true
	}

	r := csv.NewReader(f)
	r.FieldsPerRecord = -1
	records, err := r.ReadAll()
	if err != nil {
		return nil, err
	}

	var history []HistoryEntry
	for _, record := range records {
		if len(record) < 2 {
			continue
		}
		fname := record[0]
		dtStr := record[1]

		if !wallFiles[fname] {
			continue
		}

		dt, err := time.Parse(time.RFC3339, dtStr)
		if err != nil {
			continue
		}

		history = append(history, HistoryEntry{
			Path: filepath.Join(wallDir, fname),
			Time: dt,
		})
	}

	sort.Slice(history, func(i, j int) bool {
		return history[i].Time.After(history[j].Time)
	})

	return history, nil
}

type Geometry struct {
	W, H, X, Y float64
}

func ParseGeometry(s string) (Geometry, error) {
	var g Geometry
	// Expected to format: wxh+x+y
	parts := strings.FieldsFunc(s, func(r rune) bool {
		return r == 'x' || r == '+'
	})
	if len(parts) != 4 {
		return g, fmt.Errorf("invalid geometry format: %s", s)
	}
	var err error
	g.W, err = strconv.ParseFloat(parts[0], 64)
	if err != nil {
		return g, err
	}
	g.H, err = strconv.ParseFloat(parts[1], 64)
	if err != nil {
		return g, err
	}
	g.X, err = strconv.ParseFloat(parts[2], 64)
	if err != nil {
		return g, err
	}
	g.Y, err = strconv.ParseFloat(parts[3], 64)
	return g, err
}

type WallInfo struct {
	Path       string
	Faces      []Geometry
	Geometries map[string]string // aspect ratio (e.g., "16x9") to geometry string
	Scale      int
}

func GetWallInfo(path string) (*WallInfo, error) {
	cmd := exec.Command("exiftool", "-json", "-Xmp:wallfacer:*", path)
	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("exiftool failed: %w", err)
	}

	var raw []map[string]any
	if err := json.Unmarshal(out, &raw); err != nil || len(raw) == 0 {
		return nil, fmt.Errorf("failed to parse exiftool output: %w", err)
	}

	info := &WallInfo{
		Path:       path,
		Geometries: make(map[string]string),
		Scale:      1,
	}

	for k, v := range raw[0] {
		val := fmt.Sprint(v)
		switch {
		case k == "XMP:Faces":
			if val != "[]" {
				faces := strings.Split(val, ",")
				for _, f := range faces {
					if geom, err := ParseGeometry(strings.TrimSpace(f)); err == nil {
						info.Faces = append(info.Faces, geom)
					}
				}
			}
		case k == "XMP:Scale":
			if s, err := strconv.Atoi(val); err == nil {
				info.Scale = s
			}
		case strings.HasPrefix(k, "XMP:Crop"):
			// e.g., XMP:Crop.16x9
			aspect := strings.TrimPrefix(k, "XMP:Crop.")
			info.Geometries[aspect] = val
		}
	}

	return info, nil
}

func Gcd(a, b uint32) uint32 {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

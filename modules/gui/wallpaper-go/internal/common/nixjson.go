package common

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strconv"
)

type NixMonitor struct {
	Name             string  `json:"name"`
	Workspaces       []int   `json:"workspaces"`
	Width            uint32  `json:"width"`
	Height           uint32  `json:"height"`
	Transform        uint8   `json:"transform"`
	Scale            float64 `json:"scale"`
	DefaultWorkspace int     `json:"defaultWorkspace"`
}

func (m *NixMonitor) FinalDimensions() (uint32, uint32) {
	var w, h uint32
	if m.Transform%2 == 1 {
		w, h = m.Height, m.Width
	} else {
		w, h = m.Width, m.Height
	}

	if math.Abs(m.Scale-1.0) < 1e-9 {
		return w, h
	}
	return uint32(float64(w) / m.Scale), uint32(float64(h) / m.Scale)
}

func (m *NixMonitor) NoctaliaWallpaperCachePath(img string) string {
	imageCacheDir := filepath.Join(DefaultConfig.CacheDir, "noctalia/images/wallpapers/large")

	mtimeStr := "unknown"
	if info, err := os.Stat(img); err == nil {
		mtimeStr = strconv.FormatInt(info.ModTime().Unix(), 10)
	}

	var dims string
	if m.Transform%2 == 1 {
		dims = fmt.Sprintf("%dx%d", m.Height, m.Width)
	} else {
		dims = fmt.Sprintf("%dx%d", m.Width, m.Height)
	}

	hashStr := fmt.Sprintf("%s@%s@%s", img, dims, mtimeStr)
	hash := sha256.Sum256([]byte(hashStr))
	return filepath.Join(imageCacheDir, fmt.Sprintf("%x.png", hash))
}

type NixJson struct {
	FallbackWallpaper string       `json:"fallbackWallpaper"`
	Host             string       `json:"host"`
	Monitors          []NixMonitor `json:"monitors"`
}

func LoadNixJson() (*NixJson, error) {
	data, err := os.ReadFile(DefaultConfig.NixJsonPath)
	if err != nil {
		return nil, err
	}
	var nj NixJson
	if err := json.Unmarshal(data, &nj); err != nil {
		return nil, err
	}
	return &nj, nil
}

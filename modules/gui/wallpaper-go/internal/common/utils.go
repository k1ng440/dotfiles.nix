package common

import (
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func FullPath(p string) string {
	if strings.HasPrefix(p, "~/") {
		home, err := os.UserHomeDir()
		if err != nil {
			log.Fatalf("could not get home directory: %v", err)
		}
		return filepath.Join(home, p[2:])
	}
	return p
}

func LocalNow() time.Time {
	return time.Now()
}

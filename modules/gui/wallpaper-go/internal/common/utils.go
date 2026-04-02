package common

import (
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
  "math/rand"
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

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
func GenerateSeed(length int) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)
}

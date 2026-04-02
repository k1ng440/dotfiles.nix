package main

import (
	"bufio"
	"crypto/sha256"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"log"
	"math/rand/v2"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/disintegration/imaging"
	"github.com/k1ng/dotfiles/wallpaper-go/internal/common"
	"github.com/spf13/cobra"
)

func main() {
	if err := newRootCmd().Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func filterByFaces(images []string, args *WallpaperFilterArgs) []string {
	if !args.NoFaces && !args.SingleFace && !args.MultipleFaces && args.Faces == 0 {
		return images
	}

	var filtered []string
	for _, img := range images {
		info, err := common.GetWallInfo(img)
		if err != nil {
			continue
		}
		numFaces := uint32(len(info.Faces))

		if args.NoFaces && numFaces != 0 {
			continue
		}
		if args.SingleFace && numFaces != 1 {
			continue
		}
		if args.MultipleFaces && numFaces < 2 {
			continue
		}
		if args.Faces > 0 && numFaces != args.Faces {
			continue
		}
		filtered = append(filtered, img)
	}
	return filtered
}

func runRoot(cmd *cobra.Command, args []string, reload, skipHistory, skipWallpaper bool, filterArgs *WallpaperFilterArgs) error {
	var wallpaper string
	if reload {
		var err error
		wallpaper, err = common.Current()
		if err != nil {
			return fmt.Errorf("no current wallpaper set: %w", err)
		}
	} else {
		var imageOrDir string
		if len(args) > 0 {
			imageOrDir = args[0]
		}
		wallpaper = getRandomWallpaper(imageOrDir, filterArgs)
	}

	if !skipWallpaper {
		if reload {
			common.Reload()
		} else {
			if err := common.Set(wallpaper); err != nil {
				return err
			}
		}

		if !reload && !skipHistory {
			writeWallpaperHistory(wallpaper)
		}
	}

	return nil
}

func getRandomWallpaper(imageOrDir string, filterArgs *WallpaperFilterArgs) string {
	if imageOrDir == "-" {
		// handle stdin
		buf, err := io.ReadAll(os.Stdin)
		if err != nil {
			log.Fatalf("unable to read stdin: %v", err)
		}

		// check if it's an image
		_, format, err := image.DecodeConfig(strings.NewReader(string(buf)))
		if err == nil {
			output := fmt.Sprintf("/tmp/__wall__%d.%s", rand.Uint32N(10000), format)
			if err := os.WriteFile(output, buf, 0644); err != nil {
				log.Fatalf("could not write stdin to file: %v", err)
			}
			return output
		}

		// assume it's a path
		path := strings.TrimSpace(string(buf))
		abs, err := filepath.Abs(path)
		if err != nil {
			log.Fatalf("unable to parse stdin path: %v", err)
		}
		return abs
	}

	if imageOrDir != "" {
		info, err := os.Stat(imageOrDir)
		if err != nil {
			log.Fatalf("%s is not a valid image / directory: %v", imageOrDir, err)
		}
		if info.IsDir() {
			wallpapers, _ := common.FilterImages(imageOrDir)
			wallpapers = filterByFaces(wallpapers, filterArgs)
			if len(wallpapers) == 0 {
				log.Fatal("no wallpapers found matching filters")
			}
			return wallpapers[rand.IntN(len(wallpapers))]
		}
		abs, _ := filepath.Abs(imageOrDir)
		return abs
	}

	wallpapers, _ := common.FilterImages(common.Dir())
	wallpapers = filterByFaces(wallpapers, filterArgs)
	if len(wallpapers) == 0 {
		nj, _ := common.LoadNixJson()
		if nj != nil {
			return nj.FallbackWallpaper
		}
		return ""
	}
	return wallpapers[rand.IntN(len(wallpapers))]
}

func writeWallpaperHistory(wallpaperPath string) {
	wallDir := common.Dir()
	if filepath.Dir(wallpaperPath) != wallDir {
		return
	}

	history, _ := common.History()
	foundRecent := false
	for i := 0; i < len(history) && i < 3; i++ {
		if history[i].Path == wallpaperPath {
			foundRecent = true
			break
		}
	}

	if !foundRecent {
		history = append([]common.HistoryEntry{{Path: wallpaperPath, Time: common.LocalNow()}}, history...)
	}

	seen := make(map[string]bool)
	var newHistory []common.HistoryEntry
	for _, h := range history {
		if !seen[h.Path] {
			seen[h.Path] = true
			newHistory = append(newHistory, h)
		}
	}

	f, err := os.Create(common.DefaultConfig.HistoryCsvPath)
	if err != nil {
		log.Printf("could not create wallpapers_history.csv: %v", err)
		return
	}
	defer f.Close()

	for _, h := range newHistory {
		fname := filepath.Base(h.Path)
		fmt.Fprintf(f, "%s,%s\n", fname, h.Time.Format(time.RFC3339))
	}
}

func runCurrent(cmd *cobra.Command, args []string) error {
	curr, err := common.Current()
	if err != nil {
		return err
	}
	fmt.Println(curr)
	return nil
}

func runRm(cmd *cobra.Command, args []string) error {
	current, err := common.Current()
	if err != nil {
		return fmt.Errorf("failed to get current wallpaper: %w", err)
	}

	var nextWall string
	if len(args) > 0 {
		nextWall = getRandomWallpaper(args[0], &WallpaperFilterArgs{})
	} else {
		nextWall = getRandomWallpaper("", &WallpaperFilterArgs{})
	}

	fmt.Printf("Delete %s? (y/N): ", current)
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	input = strings.TrimSpace(input)

	if strings.ToLower(input) == "y" {
		if err := common.Set(nextWall); err != nil {
			return err
		}
		writeWallpaperHistory(nextWall)
		return os.Remove(current)
	}
	return nil
}

func runReload(cmd *cobra.Command, args []string) error {
	common.Reload()
	return nil
}

func runHistory(cmd *cobra.Command, args_ []string, args *WallpaperFilterArgs) error {
	history, err := common.History()
	if err != nil {
		return err
	}
	var paths []string
	for _, h := range history {
		paths = append(paths, h.Path)
	}
	paths = filterByFaces(paths, args)

	if len(paths) == 0 {
		fmt.Println("No history found matching filters")
		return nil
	}

	pqivCmd := exec.Command("pqiv", paths...)
	return pqivCmd.Run()
}

func runSelect(cmd *cobra.Command, args_ []string, args *WallpaperFilterArgs) error {
	images, err := common.FilterImages(common.Dir())
	if err != nil {
		return err
	}
	images = filterByFaces(images, args)

	if len(images) == 0 {
		fmt.Println("No wallpapers found matching filters")
		return nil
	}

	pqivCmd := exec.Command("pqiv", "--shuffle")
	pqivCmd.Args = append(pqivCmd.Args, images...)
	return pqivCmd.Run()
}

func runSearch(cmd *cobra.Command, args []string, top uint32) error {
	wallDir := common.Dir()
	var allResults []string

	if len(args) == 1 {
		query := strings.ToLower(args[0])
		images, _ := common.FilterImages(wallDir)
		for _, img := range images {
			if strings.Contains(strings.ToLower(filepath.Base(img)), query) {
				allResults = append(allResults, img)
			}
		}
	}

	rclipCmd := exec.Command("rclip", "--filepath-only")
	rclipCmd.Dir = wallDir
	rclipCmd.Args = append(rclipCmd.Args, "--top", fmt.Sprint(top))
	rclipCmd.Args = append(rclipCmd.Args, args...)
	out, _ := rclipCmd.Output()
	if len(out) > 0 {
		rclipResults := strings.Split(strings.TrimSpace(string(out)), "\n")
		allResults = append(allResults, rclipResults...)
	}

	if len(allResults) == 0 {
		return nil
	}

	pqivCmd := exec.Command("pqiv", "--additional-from-stdin")
	pqivCmd.Stdin = strings.NewReader(strings.Join(allResults, "\n"))
	return pqivCmd.Run()
}

func runDedupe(cmd *cobra.Command, args []string) error {
	wallDir := common.Dir()
	wallsIn := common.FullPath("~/Pictures/wallpapers_in")

	hasWallsInDupes := false
	imagesIn, _ := common.FilterImages(wallsIn)
	for _, img := range imagesIn {
		if _, err := os.Stat(filepath.Join(wallDir, filepath.Base(img))); err == nil {
			hasWallsInDupes = true
			break
		}
	}

	czkawkaArgs := []string{"image", "--directories", wallDir}
	if !hasWallsInDupes {
		czkawkaArgs = append(czkawkaArgs, "--directories", wallsIn)
	}
	czkawkaArgs = append(czkawkaArgs, "--max-difference", "0", "--hash-size", "64")

	czCmd := exec.Command("czkawka_cli", czkawkaArgs...)
	czCmd.Stdout = os.Stdout
	czCmd.Stderr = os.Stderr
	return czCmd.Run()
}

func runBackup(cmd *cobra.Command, args []string) error {
	var target string
	if len(args) > 0 {
		target = args[0]
	} else {
		target = common.FullPath("/media/HGST10")
	}

	wallDir := common.Dir()
	rsyncCmd := exec.Command("rsync", "-aP", "--delete", "--no-links", wallDir+"/", target)
	rsyncCmd.Stdout = os.Stdout
	rsyncCmd.Stderr = os.Stderr
	if err := rsyncCmd.Run(); err != nil {
		return fmt.Errorf("failed to backup wallpapers: %w", err)
	}

	historySrc := common.DefaultConfig.HistoryCsvPath
	historyDest := filepath.Join(target, "wallpapers_history.csv")
	if err := copyFile(historySrc, historyDest); err != nil {
		return fmt.Errorf("failed to backup wallpaper history: %w", err)
	}

	rclipCmd := exec.Command("rclip", "--filepath-only", "cat")
	rclipCmd.Dir = wallDir
	_ = rclipCmd.Run()

	return nil
}

func runRemote(cmd *cobra.Command, args []string) error {
	user := os.Getenv("USER")
	if user == "" {
		uCmd := exec.Command("whoami")
		out, _ := uCmd.Output()
		user = strings.TrimSpace(string(out))
	}

	remoteHost := "framework"
	if len(args) > 0 {
		remoteHost = args[0]
	}

	if err := runBackup(cmd, nil); err != nil {
		return err
	}

	wallDir := common.Dir()
	if err := rsyncRemote(wallDir, user, remoteHost); err != nil {
		return err
	}

	thumbnailsDir := filepath.Join(common.DefaultConfig.CacheDir, "noctalia/images/wallpapers/thumbnails")
	if err := rsyncRemote(thumbnailsDir, user, remoteHost); err != nil {
		return err
	}

	rclipDb := filepath.Join(os.Getenv("HOME"), ".local/share/rclip")
	return rsyncRemote(rclipDb, user, remoteHost)
}

func rsyncRemote(path, user, remoteHost string) error {
	pathStr := path
	if !strings.HasSuffix(pathStr, "/") {
		pathStr += "/"
	}
	dest := fmt.Sprintf("%s@%s:%s", user, remoteHost, pathStr)
	cmd := exec.Command("rsync", "-aP", "--delete", "--no-links", "--mkpath", pathStr, dest)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}

func runCrop(cmd *cobra.Command, args []string) error {
	if len(args) != 3 {
		return fmt.Errorf("expected size, input, and output")
	}
	sizeStr, input, output := args[0], args[1], args[2]
	var tw, th int
	fmt.Sscanf(sizeStr, "%dx%d", &tw, &th)

	src, err := imaging.Open(input)
	if err != nil {
		return err
	}

	// Simple center crop for now, matching default behavior
	dst := imaging.Fill(src, tw, th, imaging.Center, imaging.Lanczos)
	return imaging.Save(dst, output)
}

func runThumbnails(cmd *cobra.Command, args []string, force bool) error {
	thumbDir := filepath.Join(common.DefaultConfig.CacheDir, "noctalia/images/wallpapers/thumbnails")
	_ = os.MkdirAll(thumbDir, 0755)

	images, _ := common.FilterImages(common.Dir())
	for _, img := range images {
		info, _ := os.Stat(img)
		mtime := info.ModTime().Unix()
		hashStr := fmt.Sprintf("%s@384x384@%d", img, mtime)
		hash := sha256.Sum256([]byte(hashStr))
		thumbPath := filepath.Join(thumbDir, fmt.Sprintf("%x.png", hash))

		if _, err := os.Stat(thumbPath); os.IsNotExist(err) || force {
			fmt.Printf("Generating thumbnail for %s\n", img)
			src, err := imaging.Open(img)
			if err != nil {
				continue
			}
			dst := imaging.Fill(src, 384, 384, imaging.Center, imaging.Lanczos)
			imaging.Save(dst, thumbPath)
		}
	}
	return nil
}

func runMetadata(cmd *cobra.Command, args []string) error {
	var path string
	if len(args) > 0 {
		path = args[0]
	} else {
		curr, err := common.Current()
		if err != nil {
			return err
		}
		path = curr
	}

	info, err := common.GetWallInfo(path)
	if err != nil {
		return err
	}

	fmt.Printf("File: %s\n", info.Path)
	fmt.Printf("Scale: %d\n", info.Scale)
	fmt.Printf("Faces: %d\n", len(info.Faces))
	for i, f := range info.Faces {
		fmt.Printf("  Face %d: %.0fx%.0f+%.0f+%.0f\n", i, f.W, f.H, f.X, f.Y)
	}
	fmt.Println("Crops:")
	var aspects []string
	for a := range info.Geometries {
		aspects = append(aspects, a)
	}
	sort.Strings(aspects)
	for _, a := range aspects {
		fmt.Printf("  %s: %s\n", a, info.Geometries[a])
	}

	return nil
}

func runEdit(cmd *cobra.Command, args []string) error { fmt.Println("Not implemented"); return nil }
func runAdd(cmd *cobra.Command, args []string) error  { fmt.Println("Not implemented"); return nil }

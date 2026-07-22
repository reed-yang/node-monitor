package cmd

import (
	"os"
	"regexp"
	"strings"
	"testing"

	"github.com/Reed-yang/node-monitor/internal/testfixture"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
)

const staticReadmeCaptureEnv = "NODE_MONITOR_STATIC_README_CAPTURE"

var staticReadmeTimestampPattern = regexp.MustCompile(`\d{2}:\d{2}:\d{2}`)

func TestRenderStaticReadmeCapture(t *testing.T) {
	outputPath := os.Getenv(staticReadmeCaptureEnv)
	if outputPath == "" {
		t.Skipf("set %s to render the static README capture", staticReadmeCaptureEnv)
	}

	lipgloss.SetColorProfile(termenv.TrueColor)

	var output strings.Builder
	renderStaticTo(&output, testfixture.ReadmeNodes(), 2, 120, true)
	frame := staticReadmeTimestampPattern.ReplaceAllString(output.String(), "12:00:00")
	if err := os.WriteFile(outputPath, []byte(frame), 0o644); err != nil {
		t.Fatalf("write capture: %v", err)
	}
}

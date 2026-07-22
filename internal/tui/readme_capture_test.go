package tui

import (
	"os"
	"regexp"
	"testing"

	"github.com/Reed-yang/node-monitor/internal/testfixture"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
)

const readmeCaptureEnv = "NODE_MONITOR_README_CAPTURE"

var readmeTimestampPattern = regexp.MustCompile(`\d{2}:\d{2}:\d{2}`)

func TestRenderReadmeCapture(t *testing.T) {
	outputPath := os.Getenv(readmeCaptureEnv)
	if outputPath == "" {
		t.Skipf("set %s to render the README TUI capture", readmeCaptureEnv)
	}

	lipgloss.SetColorProfile(termenv.TrueColor)

	nodes := testfixture.ReadmeNodes()
	hosts := make([]string, len(nodes))
	for i, node := range nodes {
		hosts[i] = node.Hostname
	}

	m := NewModel(hosts, nil, 2, 10, false, true, ViewPanel, nil)
	m.width = 120
	m.height = 15
	m.nodes = nodes

	frame := readmeTimestampPattern.ReplaceAllString(m.View(), "12:00:00")
	if err := os.WriteFile(outputPath, []byte(frame), 0o644); err != nil {
		t.Fatalf("write capture: %v", err)
	}
}

package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// Window represents a tmux window
type Window struct {
	SessionName  string `json:"session_name"`
	WindowIndex  int    `json:"window_index"`
	WindowName   string `json:"window_name"`
	WindowActive bool   `json:"window_active"`
	WindowFlags  string `json:"window_flags"`
	WindowLayout string `json:"window_layout"`
}

// Pane represents a tmux pane
type Pane struct {
	SessionName     string `json:"session_name"`
	WindowIndex     int    `json:"window_index"`
	WindowActive    bool   `json:"window_active"`
	WindowFlags     string `json:"window_flags"`
	PaneIndex       int    `json:"pane_index"`
	MyTitle         string `json:"mytitle"`
	MyBooter        string `json:"mybooter"`
	PaneActive      bool   `json:"pane_active"`
	PaneCurrentPath string `json:"pane_current_path"`
}

// TmuxCli represents the tmux command line interface
type TmuxCli struct{}

func (cli *TmuxCli) runCommand(command string) (string, error) {
	cmd := exec.Command("/bin/sh", "-c", command)
	output, err := cmd.CombinedOutput()
	return string(output), err
}

func (cli *TmuxCli) amiInTmux() bool {
	return os.Getenv("TMUX") != ""
}

func (cli *TmuxCli) listOptions(sessionName string) (map[string]string, error) {
	output, err := cli.runCommand(fmt.Sprintf("tmux show-options -t %s", sessionName))
	if err != nil {
		return nil, err
	}
	options := make(map[string]string)
	for _, line := range strings.Split(output, "\n") {
		if strings.HasPrefix(line, "@my_") {
			parts := strings.Fields(line)
			if len(parts) >= 2 {
				options[parts[0]] = parts[1]
			}
		}
	}
	return options, nil
}

func (cli *TmuxCli) listPane(sessionName string) ([]Pane, error) {
	// Implement the logic to list panes
	return nil, nil
}

func (cli *TmuxCli) curSession() (string, error) {
	output, err := cli.runCommand("tmux display-message -p '#S'")
	return strings.TrimSpace(output), err
}

func (cli *TmuxCli) listWindow(sessionName string) ([]Window, error) {
	// Implement the logic to list windows
	return nil, nil
}

// Layout represents a tmux layout
type Layout struct {
	SessionName string            `json:"session_name"`
	Wins        []Window          `json:"wins"`
	Panes       []Pane            `json:"panes"`
	Var         map[string]string `json:"var"`
}

// X represents the main application logic
type X struct {
	cli TmuxCli
}

func (x *X) listWindow(sessionName string) ([]Window, error) {
	_, err := x.cli.runCommand(fmt.Sprintf("tmux list-windows -t %s", sessionName))
	if err != nil {
		return nil, err
	}
	windows := []Window{}
	return windows, nil
}

func (x *X) listPane(sessionName string) ([]Pane, error) {
	out, err := x.cli.runCommand(fmt.Sprintf("tmux list-panes -t %s", sessionName))
	if err != nil {
		return nil, err
	}

	panes := []Pane{}
	return panes, nil
}

func (x *X) save() {
	sessionName, err := x.cli.curSession()
	if err != nil {
		fmt.Println("Error getting current session:", err)
		return
	}
	wins, err := x.listWindow(sessionName)
	if err != nil {
		fmt.Println("Error listing windows:", err)
		return
	}
	panes, err := x.listPane(sessionName)
	if err != nil {
		fmt.Println("Error listing panes:", err)
		return
	}
	varMap, err := x.cli.listOptions(sessionName)
	if err != nil {
		fmt.Println("Error listing options:", err)
		return
	}
	layout := Layout{
		SessionName: sessionName,
		Wins:        wins,
		Panes:       panes,
		Var:         varMap,
	}
	json.NewEncoder(os.Stdout).Encode(layout)
	os.Stdout.WriteString("\n")
}

func (x *X) genTmuxSendKeys(booter string) string {
	delimiter := strings.Split(booter, " ")[0]
	cmds := strings.Split(strings.TrimPrefix(booter, delimiter), delimiter)
	for i, cmd := range cmds {
		cmds[i] = fmt.Sprintf("'%s'", strings.TrimSpace(cmd))
	}
	cmds = append([]string{"C-c"}, cmds...)
	full := strings.Join(cmds, " 'enter' ")
	return fmt.Sprintf("%s 'enter';", full)
}

func (x *X) load(fpath string) {
	// Implement the logic to load the layout
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("No command provided")
		return
	}
	cmd := strings.Replace(os.Args[1], "-", "_", -1)
	cmd = strings.TrimPrefix(cmd, "tmux_")
	x := X{cli: TmuxCli{}}
	if os.Args[1] == "tmux-save" {
		x.save()
	} else if os.Args[1] == "tmux-load" {
		x.load(os.Args[2])
	}
}

package testfixture

import "github.com/Reed-yang/node-monitor/internal/model"

// ReadmeNodes returns deterministic, anonymized nodes for documentation captures.
func ReadmeNodes() []model.NodeStatus {
	return []model.NodeStatus{
		readmeSampleNode(
			"visko-gpu-01",
			[]int{96, 94, 92, 98, 88, 91, 95, 93},
			[]int{70200, 69800, 71100, 70500, 65400, 66100, 67200, 66900},
			[]string{"alice", "alice", "alice", "alice", "bob", "bob", "bob", "bob"},
			[]string{"train.py --config llama3.yaml", "eval.py --suite reasoning"},
		),
		readmeSampleNode(
			"visko-gpu-02",
			[]int{71, 64, 68, 75, 59, 63, 70, 66},
			[]int{48200, 47100, 47600, 49000, 42100, 43800, 45900, 44700},
			[]string{"carol", "carol", "carol", "carol", "carol", "carol", "carol", "carol"},
			[]string{"pretrain.py --model 70b"},
		),
		readmeSampleNode(
			"visko-gpu-03",
			[]int{3, 1, 0, 2, 4, 1, 0, 2},
			[]int{420, 390, 410, 405, 440, 400, 395, 415},
			nil,
			nil,
		),
		readmeOfflineNode("visko-gpu-04", "SSH connection timed out"),
	}
}

func readmeSampleNode(host string, utilization, memory []int, users, commands []string) model.NodeStatus {
	gpus := make([]model.GPUInfo, len(utilization))
	for i := range utilization {
		gpu := model.GPUInfo{
			Index:       i,
			Utilization: utilization[i],
			MemoryUsed:  memory[i],
			MemoryTotal: 81920,
			Name:        "NVIDIA H100 80GB HBM3",
		}
		if i < len(users) && users[i] != "" {
			command := ""
			if len(commands) > 0 {
				command = commands[0]
			}
			if len(commands) > 1 && users[i] == "bob" {
				command = commands[1]
			}
			gpu.Processes = []model.GPUProcess{{
				PID:       10000 + i,
				User:      users[i],
				GPUIndex:  i,
				MemoryMiB: memory[i],
				Command:   command,
			}}
		}
		gpus[i] = gpu
	}
	return model.NodeStatus{Hostname: host, GPUs: gpus}
}

func readmeOfflineNode(host, message string) model.NodeStatus {
	return model.NodeStatus{Hostname: host, Error: &message}
}

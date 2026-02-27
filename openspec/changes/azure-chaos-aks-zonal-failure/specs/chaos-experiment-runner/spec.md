## ADDED Requirements

### Requirement: Runner script accepts environment and zone parameters
The system SHALL provide a `run-experiment.sh` Bash script that accepts `--env <environment>` and `--zone <1|2|3>` arguments and starts the Chaos Studio experiment for the specified environment and zone.

#### Scenario: Valid parameters start experiment
- **WHEN** an operator runs `./run-experiment.sh --env staging --zone 1`
- **THEN** the script SHALL resolve the target node pools via Resource Graph, start the Chaos Studio experiment, and print the experiment run ID

#### Scenario: Invalid zone value is rejected
- **WHEN** the operator passes `--zone 5`
- **THEN** the script SHALL exit with a non-zero status and print a usage error before contacting Azure

---

### Requirement: Pre-flight checks before fault injection
The runner SHALL perform pre-flight checks before starting the experiment: verify Azure CLI login, confirm at least one tagged node pool exists, and confirm the AKS cluster reports all nodes as Ready.

#### Scenario: All pre-flights pass
- **WHEN** the operator is logged in, tagged node pools exist, and all nodes are Ready
- **THEN** the runner SHALL proceed to start the experiment

#### Scenario: Pre-flight fails — no tagged nodes
- **WHEN** no node pools carry the required tags
- **THEN** the runner SHALL print a descriptive error listing the expected tags and exit with code 1 without starting the experiment

#### Scenario: Pre-flight fails — nodes not Ready
- **WHEN** one or more nodes are in `NotReady` state before the experiment starts
- **THEN** the runner SHALL warn the operator and require `--force` to proceed

---

### Requirement: Experiment status polling with timeout
The runner SHALL poll the Chaos Studio experiment run status every 30 seconds and print live status until the run reaches a terminal state (`Succeeded`, `Failed`, or `Cancelled`) or a configurable timeout elapses (default: 20 minutes).

#### Scenario: Experiment completes successfully
- **WHEN** the Chaos Studio run reaches `Succeeded` status
- **THEN** the runner SHALL print a success message and proceed to the post-experiment health check

#### Scenario: Experiment exceeds timeout
- **WHEN** the run has not reached a terminal state within the timeout window
- **THEN** the runner SHALL print a timeout warning and exit with a non-zero status

---

### Requirement: Post-experiment workload health check
After the experiment completes, the runner SHALL verify that all pods in the target namespace(s) return to `Running` state within a configurable window (default: 5 minutes), confirming the workload survived the zonal failure.

#### Scenario: Workload recovers within window
- **WHEN** all pods are `Running` within 5 minutes of experiment completion
- **THEN** the runner SHALL print `PASS` and exit with code 0

#### Scenario: Workload does not recover within window
- **WHEN** one or more pods remain in a non-Running state after the recovery window
- **THEN** the runner SHALL print the offending pods, print `FAIL`, and exit with code 1

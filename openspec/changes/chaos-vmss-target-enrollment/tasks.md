## 1. New Bicep module — VMSS tag application

- [x] 1.1 Create `infra/modules/management_governance/chaos/chaos-vmss-tags.bicep` with parameters `vmssName`, `location`, `environment`; reference the VMSS as `existing` and apply `chaos-target=true` + `environment=<value>` via `union()` with current tags
- [x] 1.2 Verify the module is idempotent by reviewing that re-deploying with the same params produces no diff

## 2. Wire tag + capability modules into chaos.bicep

- [x] 2.1 Add `vmssNames` string array parameter to `chaos.bicep`
- [x] 2.2 Add a `for` loop that deploys `chaos-vmss-tags.bicep` for each VMSS name, scoped to the node resource group
- [x] 2.3 Add a `for` loop that deploys `chaos-capability.bicep` for each VMSS name, scoped to the node resource group
- [x] 2.4 Add `dependsOn` on the chaos experiment module so it waits for all tag + capability loops to complete

## 3. Update management_governance.bicep call site

- [x] 3.1 Uncomment the chaos module block and add `vmssNames` parameter (the operator supplies VMSS names at deploy time)
- [x] 3.2 Add `chaosVmssNames` param with a description pointing to the `MC_*` node resource group

## 4. Validation

- [x] 4.1 Run `az bicep build` on `chaos.bicep` and `management_governance.bicep` to confirm no compilation errors
- [x] 4.2 Manually verify (or document) the step to retrieve VMSS names: `az vmss list -g <NODE_RG> --query "[].name" -o tsv`
- [x] 4.3 Confirm the run-experiment.sh pre-flight KQL query returns targets after deploying with valid VMSS names

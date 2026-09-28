# Testing methodology and evidence scope

Tests establish engineering behavior, not profit. Three levels distinguish deterministic calculation assertions, component/state behavior and actual MT5 integration. Compilation alone is not functional validation. A missing completion result is incomplete, not a pass.

## Public selected scripts

EnvironmentTests, RiskTests and SignalTests are byte-identical project scripts with complete included dependencies. Their source can be inspected here. Technical reproduction below does not grant separate rights to copy, run or modify material; applicable law or explicit holder authorization must permit the intended use.

For an authorized evaluator: use Windows MT5 and MetaEditor (historical verified build6182). Preserve `tests/` and `include/` as siblings in a local working copy. Compile each `tests/*.mq5` with F7; require zero errors and review warnings. The equivalent MetaEditor command is `/compile:"<absolute source path>" /log`. No private source is needed for these three scripts. They contain no order submission calls.

Runtime procedures require connected demo broker data, not a live-money account. Deploy scripts under a dedicated MQL5/Scripts project retaining include layout; run the selected script and inspect its completion line. EnvironmentTests and RiskTests explicitly reference EURUSDm and XAUUSDm; brokers with different suffixes need an explicitly documented authorized adaptation, not a claim that unchanged tests passed. SignalTests uses current symbol M1 history and may wait up to75 seconds for a subsequent completed bar. It checks startup/restart replay suppression and duplicate consumption. These scripts are not the full EA.

| Public test | Requirement / inputs | Expected and recorded actual | Evidence |
|---|---|---|---|
| EnvironmentTests | Synthetic0.25 tick grid, invalid properties, FX/metal broker specs | Invalid inputs rejected; ENVIRONMENT_RESULT failures=0 | [phase2](../evidence/phase2-runtime.txt) |
| RiskTests | Fixed min/max/step, equity budgets, FX/metal BUY/SELL SL estimates | Minimum-risk violations rejected, final risk within budget;40 assertions, failures=0 | [phase3](../evidence/phase3-runtime.txt) |
| SignalTests | BUY/SELL/equality/invalid values; actual M1 10/20 EMAs | Startup suppressed, next completed bar permitted once, restart suppressed;18 assertions, failures=0 | [phase4](../evidence/phase4-runtime.txt) |

These are historical master runs of the identical selected source, not newly performed runtime tests of this export. Local broker conditions may differ. No sample run in this package proves complete-EA behavior.

## Reported private-master verification

The following harnesses and functional dependencies are deliberately withheld. Their sanitized result files are included for review, not presented as publicly rerunnable suites. See the [implementation map](IMPLEMENTATION_MAP.md).

| Evidence file in evidence/ | Tested behavior and actual outcome | Important scope |
|---|---|---|
| phase5-execution-runtime.txt | Submission/confirmed events, rejection and duplicate handling; failures=0 | Historical hedging tester run |
| phase6-netting-runtime.txt | Sessions/spread/exposure, account-wide confirmed count; failures=0 | Netting tester fixture |
| phase7-netting-runtime-final.txt | Owned improving protection and ambiguity handling; failures=0 | Retained sanitized summary, not full raw log |
| phase9-admin-runtime.txt | Explicit reset/revalidation;537 checks,0 failures | Includes122 before/after write boundaries for each action; API-injected account cases |
| phase9-storage-runtime.txt | Corruption and interrupted writes;551 checks,0 failures |82 original/122 extended I/O boundaries; no power-loss guarantee |
| phase9-recovery-hedging.txt | Recovery/history/protection;44 checks,0 failures | Tester hedging, reconstructed objects |
| phase9-recovery-netting.txt | Recovery/history/conservative ownership;44 checks,0 failures | Tester netting, reconstructed objects |
| phase9-physical-restart.txt |19 preparation and260 recovery/cleanup checks,0 failures | Real terminal restart/storage; synthetic account observations |
| phase12-account-path-red.txt | Before-fix main account branch blocked entry/protection;2 failures | Intentional RED evidence; not a current passing test |
| phase12-account-path-green.txt | After-fix one confirmed entry/one improving stop;0 failures | Main account-chart branch exercised inside isolated tester |
| phase12-metal-integration.txt | Final XAUUSDm H1 run:2 signals,2 submissions,no ERROR,normal shutdown | Sep1–5,2026 exclusive; every tick,zero delay,USD10000,1:100,spread500,BE/trailing enabled; no protection trigger in this bounded run |
| private-master-compile.txt |19 entry points,0 errors/0 warnings | Private master compile result, not19 public build targets |

Historical logs may include earlier lifecycle wording or expected fail-safe diagnostics. The explicit completion result and documented case determine pass/fail. Check counts include fixtures/cleanup and do not count independent requirements. No claimed certification, broker-wide guarantee or trading performance follows from these results. See [limitations](LIMITATIONS.md).

# Implementation and disclosure map

The complete private master remains authoritative. Omission here never implies that a component is absent from the master.

| Component | Disclosure | Responsibility |
|---|---|---|
| MarketEnvironment.mqh | Complete public source | Broker/account properties and price grid |
| RiskManager.mqh | Complete public source | Monetary risk and volume validation |
| SignalEngine.mqh | Complete public source | Completed-bar EMA and attempt identity |
| EntryFilters.mqh | Complete public source | Spread, sessions, confirmed count and exposure filters |
| Logger.mqh | Complete public source | Categories and levels |
| RiskManagementDemo.mq5 | Private | Main inputs and event orchestration |
| ProvisionFirstDeployment.mq5 | Private | Deliberate first-deployment script |
| RevalidateSafety.mq5 | Private | Deliberate administrative script |
| TradeManager.mqh | Private with selected excerpt | Request validation, submission, confirmation and ledgers; preflight excerpt only |
| PositionManager.mqh | Private with selected excerpt | Owned-position iteration and modification controller; stop calculation excerpt only |
| NettingOwnership.mqh | Private | Runtime exclusive-control provenance |
| AccountAuthority.mqh | Private | Single cooperative account safety authority |
| PersistenceKeys.mqh | Private | Account-scoped persistence identity |
| SafetyStorage.mqh | Private | Complete-state persistence and integrity |
| RecoveryHistory.mqh | Private | Account history reconciliation |
| SafetyRecovery.mqh | Private | Recovery and runtime persistent safety |
| SafetyAdministration.mqh | Private | Approved reset/revalidation workflow |
| SafetyManager.mqh | Private | Financial classification and equity state machine |

## Tests

Complete public scripts: EnvironmentTests.mq5, RiskTests.mq5, SignalTests.mq5.

Private harnesses: EntryFilterTests.mq5, ExecutionPreparationTests.mq5, ExecutionTests.mq5, MainAccountPathsTests.mq5, NettingOwnershipTests.mq5, PersistenceKeyTests.mq5, PositionManagementTests.mq5, RecoveryIntegratedTests.mq5, SafetyAdministrationTests.mq5, SafetyRecoveryTests.mq5, SafetyStorageTests.mq5, SafetyTests.mq5, TerminalRestartTests.mq5.

Private master specifications, audits, decision records, raw logs, builds and operational configuration are not distributed. No binary, submodule, archive or external source link supplies the omitted implementation.

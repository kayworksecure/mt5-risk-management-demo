# Fictional private-system input illustration

The complete EA is private. This table illustrates its configuration semantics, not a runnable settings file or public installation procedure.

These values illustrate input units only. They are not optimized, recommended
for a real account, or a promise of profitable behavior. Review the selected
broker's specifications and use isolated testing.

| Group | Input | Example |
|---|---|---|
| Strategy | FastEMAPeriod / SlowEMAPeriod | 10 / 20 |
| Strategy | SignalTimeframe | PERIOD_H1 |
| Risk | SizingMode | RISK_PERCENT |
| Risk | RiskPercent | 1.0 percent of equity |
| Risk | FixedLot | 0.01, used only in FIXED_LOT and subject to validation |
| Stops | StopLossPoints | 1000 broker points |
| Stops | RiskRewardRatio | 2.0 |
| Entry | MaximumSpreadPoints | 100 broker points |
| Entry | SessionStartMinute / SessionEndMinute | 420 / 960 (07:00–16:00 server time) |
| Entry | MaximumTradesPerDay | 3, account-wide for configured magic |
| Entry | AllowMultiplePositions | false |
| Protection | BreakevenEnabled / TrailingEnabled | false / false |
| Protection | BreakevenTriggerPoints / BreakevenOffsetPoints | 500 / 0 |
| Protection | TrailingTriggerPoints / TrailingDistancePoints | 1000 / 500 |
| Safety | MaximumDailyLossPercent / MaximumDrawdownPercent | 5.0 / 10.0 |
| System | MagicNumber | 713005, fictional strategy identifier |
| System | LoggingLevel | DEMO_LOG_INFO |

For an overnight session, 1320 / 120 represents 22:00–02:00 server time.
The end is exclusive. Equal start/end is invalid. Broker points are not
universal pips; prices must still align to tick size. Positive inputs can still
be rejected by broker constraints or other safety requirements.

Main configuration lives in the privately retained `RiskManagementDemo.mq5`. Administrative
attestations belong to separate deliberate scripts and must never be treated
as automatic startup settings. No credentials or account identifiers belong
in an example settings file.

# MT5 Risk Management Demo — Engineering Portfolio

MT5 Risk Management Demo is a portfolio engineering project demonstrating professional MQL5/MetaTrader 5 trading-system architecture, execution, risk management, account protection, persistence/recovery and testing. The EMA crossover is intentionally a deterministic demonstration signal and is not presented as a profitable trading strategy.

**Selected source code is published for technical portfolio review. The complete working implementation is privately maintained and is not distributed through this repository.** This is not an installable EA product. Users should not assume suitability for live-money trading.

## Review the engineering

| Review topic | Genuine source | Evidence |
|---|---|---|
| Broker properties and tick-grid validation | [MarketEnvironment](include/MarketEnvironment.mqh) | [Environment tests](tests/EnvironmentTests.mq5) |
| Monetary SL risk and volume normalization | [RiskManager](include/RiskManager.mqh) | [Risk tests](tests/RiskTests.mq5) |
| Closed-bar signals and duplicate suppression | [SignalEngine](include/SignalEngine.mqh) | [Signal tests](tests/SignalTests.mq5) |
| Server sessions, spread and confirmed daily count | [EntryFilters](include/EntryFilters.mqh) | [Reported private filter run](evidence/phase6-netting-runtime.txt) |
| Broker preflight and stronger-only protective stops | [Execution excerpt](excerpts/EXECUTION_PREFLIGHT.md), [protection excerpt](excerpts/PROTECTION_CALCULATION.md) | [Evidence scope](docs/TESTING.md) |

The five complete modules, three representative test scripts and two verbatim excerpts are derived from the complete private project. [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json) records hashes and excerpt boundaries. Hashes verify content identity, not independent certification of runtime results.

## System architecture and private boundary

Read the [architecture](docs/ARCHITECTURE.md), [implementation map](docs/IMPLEMENTATION_MAP.md), [risk model](docs/RISK_MODEL.md), [testing methodology](docs/TESTING.md) and [limitations](docs/LIMITATIONS.md).

The main EA, order/transaction controller, exclusive netting ownership, account safety state machine, persistence/recovery and administration are privately maintained. These omissions are deliberate, not missing implementations. Neither the selected code nor the test scripts supply a complete trading EA. No compiled EA is distributed.

## Client-work relevance

The engineering demonstrated here is relevant to custom MT5 Expert Advisors, strategy-to-EA conversion, MQL5 development/debugging, execution systems, risk-management systems, position management, backtesting/validation and trading automation. No client history, years of experience or commercial performance record is implied.

## Sample evaluation and limitations

The included scripts can technically be compiled using the documented [MT5 toolchain](docs/TESTING.md); they do not submit orders. Procedures explain technical reproducibility, not a separate permission to copy, modify or reuse material. The full-system test evidence is reported private-master evidence and cannot be independently rerun from this public subset.

[Fictional settings](examples/example-settings.md) illustrate the private EA's input units; they are not an installation kit or trading recommendation. Planned stop-loss risk is not guaranteed realized loss. Gaps, slippage, commissions, swaps and broker conditions can increase realized losses. The project is not investment advice or a guarantee of returns.

## Publication status and rights

Copyright © 2026 WORKSECURE. All rights reserved. The owner-approved [copyright notice](COPYRIGHT.md) provides no open-source license or separate reuse grant. Public availability does not technically prevent copying or GitHub forking; applicable law and platform terms still apply. This local candidate awaits separate final owner authorization before any public commit or push.

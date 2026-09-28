# Risk model and source-review scope

The sizing code is public in [RiskManager](../include/RiskManager.mqh). Account loss controls described below belong to the private implementation; no full safety controller is distributed.

## Two separate sizing modes

FIXED_LOT uses the requested volume exactly after checking broker minimum,
maximum and step. An invalid request is rejected, never silently adjusted.

RISK_PERCENT uses current account equity:

`RiskBudget = AccountEquity * RiskPercent / 100`

The EA constructs tick-aligned SL/TP first, then estimates monetary loss from
entry to SL using `OrderCalcProfit`. It uses the valid broker minimum volume
as a reference, scales to the budget, caps at the maximum and floors to volume
step. If minimum-volume loss already exceeds the budget, it rejects the trade.
It recalculates the final proposed volume's loss and requires:

`EstimatedLoss <= RiskBudget + min(1e-8, RiskBudget * 1e-10)`

The tolerance is only binary arithmetic compensation, capped at 0.00000001
account-currency units. It must not permit material planned-risk excess.
Unavailable monetary calculations, invalid data or failed margin checks block.

## Units and prices

Distance inputs are broker points: `distance = input * SYMBOL_POINT`.
Tick size is the tradable price grid; tick value is monetary information and
must not be confused with either. Digits control representation, not the grid.
BUY SL is below entry and TP above; SELL uses the reverse inequalities.
SL aligns away from entry, then TP derives from that actual aligned distance
and configured reward/risk ratio. Every proposed price still needs applicable
broker stop/freeze constraints and correct bid/ask context.

Illustration only: equity 10,000 and risk 1% give a budget of 100 currency
units. If the broker calculation estimates loss 25 at 0.10 lots, raw volume
is 0.40 lots. The final volume still requires broker-step validation and a
fresh monetary calculation. These numbers are fictional, not a pip formula.

## Account loss controls

`DailyLossPct = max(0, (DailyReferenceEquity - CurrentEquity) / DailyReferenceEquity * 100)`

`DrawdownPct = max(0, (PeakEquity - CurrentEquity) / PeakEquity * 100)`

The ordinary peak is `max(previous peak, current equity)`. Reaching a threshold
latches its lock; later equity recovery does not unlock it. Daily state rolls
at broker/server day boundaries. Drawdown lock survives day changes/restart
until deliberate reset. Both formulas observe whole-account floating equity.

Qualifying financial operations require explicit revalidation without silent
rebasing. A deliberate drawdown reset can establish a new peak while retaining
the same-day daily reference, so peak may be below that reference. This reflects
different measurement periods, not a formula change. Administrative actions
retain same-day daily lock; see [the system overview](ARCHITECTURE.md).

## Planned versus realized loss

Sizing estimates planned price loss at SL. It does not guarantee execution at
that price or include every possible cost. Gaps, slippage, commission, swap,
liquidity and broker execution can produce a larger realized loss. Account
locks stop new entries; they are not a guarantee of liquidation or a maximum
loss on existing exposure. Safe owned-position protection continues where
possible; unrelated or ownership-ambiguous positions are not modified.

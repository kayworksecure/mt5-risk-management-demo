# Limitations and claim boundaries

- The public subset is not an operational EA and cannot reproduce the complete private system by clone/compile/attach. An independent developer could implement missing components; omission is not a guarantee against copying or reimplementation.
- EMA crossover is a deterministic demonstration, not a trading edge. No profitability, production-proven performance, suitability for live funds or investment advice is claimed.
- Planned SL risk differs from realized loss. Slippage, gaps, commission, swap, liquidity and broker behavior can increase loss.
- Whole-account safety does not authorize management of unrelated positions. Netting requires exclusive control; magic/history alone is insufficient. Ambiguous restarted net exposure is not intentionally modified.
- One account safety authority is supported; multiple independent terminals are not coordinated.
- Full history scans favor correctness over speed and may be expensive. Broker history completeness cannot be proved beyond the available terminal view; unavailable/mutated state fails conservatively.
- Cold startup can fail while broker data is unavailable. EMA readiness can delay signal processing. No invented broker defaults are used.
- Real terminal restart evidence used actual process lifetime and Terminal Global Variables but synthetic identity/time/equity/reconciled-history observations. Separate tester runs exercised actual tester history and ownership. This is not a power-cut durability proof.
- Administrative non-flat/pending/unstable-account checks include injected API observations. The actual manual reset dialog/account action was not exercised. No real account reset is claimed.
- Interrupted writes, network failures, storage hardware, malicious modifications and restoration of older internally valid data are not exhaustively covered. Integrity is not tamper resistance.
- Public source/test samples are reviewable; withheld full-system tests are reported evidence, not independently reproducible public tests. Hashes provide identity, not third-party certification. The historical red run is an intentional before-fix failure, not a passing result.
- Rights are reserved with no separate reuse grant under the owner-approved [copyright notice](../COPYRIGHT.md). Public GitHub functionality may permit viewing/forking under its terms. No technical anti-copy protection is promised.

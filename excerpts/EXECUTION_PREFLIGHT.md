# Genuine source excerpt: EXECUTION_PREFLIGHT

Source: `include/TradeManager.mqh`, original lines 6–68, inclusive.
Master file SHA256: `6d5f532c12630d71798ee9b63ea40fabe09a7e5a20f69508e4b6d4c1593792f0`.

Price grid, stop construction, filling choice and margin comparison only. The order controller, ownership checks, request/transaction ledger and submission paths are private. Dependencies: public MarketEnvironment.mqh. This is an excerpt, not a standalone execution module.

The code block preserves the exact selected bytes, including line endings.

```mql5
bool DemoPriceOnGrid(const double price,const DemoSymbolInfo &s)
  {
   double aligned=0;
   return DemoAlignPrice(price,s.tick_size,(int)s.digits,0,aligned) &&
          MathAbs(price-aligned)<=s.tick_size*1e-8;
  }

// Distances are broker points. Align the SL away from entry, then derive
// the RR target from that actual price distance. Sizing uses these prices.
bool DemoBuildEntryPrices(const DemoSymbolInfo &s,const MqlTick &quote,
                         const ENUM_ORDER_TYPE direction,const double stop_points,
                         const double rr,double &entry,double &sl,double &tp,string &error)
  {
   entry=0; sl=0; tp=0; error="";
   if((direction!=ORDER_TYPE_BUY && direction!=ORDER_TYPE_SELL) ||
      !DemoPositive(stop_points) || !DemoPositive(rr) || !DemoPositive(s.point) ||
      s.stops_level<0 || !DemoPriceOnGrid(quote.bid,s) ||
      !DemoPriceOnGrid(quote.ask,s) || quote.ask<quote.bid)
     { error="Invalid entry direction, distances or quote grid."; return false; }
   bool buy=(direction==ORDER_TYPE_BUY);
   double proposed_entry=(buy ? quote.ask : quote.bid);
   double distance=stop_points*s.point;
   double proposed_sl=0,proposed_tp=0;
   if(!DemoPositive(distance) ||
      !DemoAlignPrice(proposed_entry+(buy ? -distance : distance),s.tick_size,
                      (int)s.digits,buy ? -1 : 1,proposed_sl))
     { error="Stop-loss alignment failed."; return false; }
   double risk_distance=MathAbs(proposed_entry-proposed_sl);
   if(!DemoPositive(risk_distance) ||
      !DemoAlignPrice(proposed_entry+(buy ? 1 : -1)*risk_distance*rr,
                      s.tick_size,(int)s.digits,buy ? 1 : -1,proposed_tp))
     { error="Take-profit alignment failed."; return false; }
   double minimum=s.stops_level*s.point;
   // Market-position protective stops are checked against the closing quote.
   // No tolerance intentionally relaxes the broker's minimum distance.
   if(!MathIsValidNumber(minimum) ||
      (buy && !(proposed_sl<proposed_entry && proposed_tp>proposed_entry &&
                quote.bid-proposed_sl>=minimum && proposed_tp-quote.bid>=minimum)) ||
      (!buy && !(proposed_sl>proposed_entry && proposed_tp<proposed_entry &&
                 proposed_sl-quote.ask>=minimum && quote.ask-proposed_tp>=minimum)))
     { error="Stop sides or broker minimum distances invalid."; return false; }
   entry=proposed_entry; sl=proposed_sl; tp=proposed_tp;
   return true;
  }

bool DemoChooseFilling(const DemoSymbolInfo &s,ENUM_ORDER_TYPE_FILLING &filling)
  {
   if(s.execution_mode==SYMBOL_TRADE_EXECUTION_INSTANT ||
      s.execution_mode==SYMBOL_TRADE_EXECUTION_REQUEST ||
      (s.filling_mode & SYMBOL_FILLING_FOK)!=0)
     { filling=ORDER_FILLING_FOK; return true; }
   if((s.filling_mode & SYMBOL_FILLING_IOC)!=0)
     { filling=ORDER_FILLING_IOC; return true; }
   if(s.execution_mode==SYMBOL_TRADE_EXECUTION_EXCHANGE)
     { filling=ORDER_FILLING_RETURN; return true; }
   return false;
  }

bool DemoMarginFits(const double required,const double available)
  {
   return MathIsValidNumber(required) && MathIsValidNumber(available) &&
          required>=0 && available>=0 && required<=available;
  }
```

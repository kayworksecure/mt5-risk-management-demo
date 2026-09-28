# Genuine source excerpt: PROTECTION_CALCULATION

Source: `include/PositionManager.mqh`, original lines 4–54, inclusive.
Master file SHA256: `994ea7a7decb3d3cdeafd06290e43615c851d8b1a5e99c899f1c3096a8b2f24a`.

Configuration and improving-stop calculation only. The position iteration, ownership enforcement, modification ledger and submission/confirmation loop remain private. Dependencies: public MarketEnvironment.mqh and DemoPriceOnGrid in EXECUTION_PREFLIGHT.md. This is not a complete position manager.

The code block preserves the exact selected bytes, including line endings.

```mql5
struct DemoProtectionConfig
  {
   bool breakeven,trailing;
   double be_trigger,be_offset,trail_trigger,trail_distance;
  };
bool DemoProtectionValid(const DemoProtectionConfig &c)
  {
   return (!c.breakeven || (DemoPositive(c.be_trigger) && MathIsValidNumber(c.be_offset) && c.be_offset>=0)) &&
          (!c.trailing || (DemoPositive(c.trail_trigger) && DemoPositive(c.trail_distance)));
  }
bool DemoProtectionStop(const DemoSymbolInfo &s,const long type,const double entry,
                        const double old_sl,const double tp,const double bid,const double ask,
                        const DemoProtectionConfig &c,double &sl,string &error)
  {
   sl=0; error="";
   if(!DemoProtectionValid(c) || (type!=POSITION_TYPE_BUY && type!=POSITION_TYPE_SELL) ||
      !DemoPositive(entry) || !MathIsValidNumber(old_sl) || old_sl<0 ||
      !MathIsValidNumber(tp) || tp<0 || !DemoPositive(s.point) ||
      !DemoPriceOnGrid(bid,s) || !DemoPriceOnGrid(ask,s) || ask<bid ||
      s.stops_level<0 || s.freeze_level<0)
     { error="Invalid protection inputs or broker data."; return false; }
   bool buy=type==POSITION_TYPE_BUY;
   double close_price=buy?bid:ask;
   double profit=buy?close_price-entry:entry-close_price;
   double candidate=0;
   if(c.breakeven && profit>=c.be_trigger*s.point)
     {
      // Round toward stronger protection so the configured offset is retained.
      if(!DemoAlignPrice(entry+(buy?1:-1)*c.be_offset*s.point,s.tick_size,(int)s.digits,buy?1:-1,candidate))
        { error="Breakeven alignment failed."; return false; }
     }
   if(c.trailing && profit>=c.trail_trigger*s.point)
     {
      double trail;
      // Round away from the closing quote to retain the trailing distance.
      if(!DemoAlignPrice(close_price+(buy?-1:1)*c.trail_distance*s.point,s.tick_size,(int)s.digits,buy?-1:1,trail))
        { error="Trailing alignment failed."; return false; }
      if(candidate==0 || (buy?trail>candidate:trail<candidate)) candidate=trail;
     }
   if(!DemoPositive(candidate) || (old_sl>0 && (buy?candidate<=old_sl:candidate>=old_sl))) return false;
   double distance=buy?close_price-candidate:candidate-close_price;
   double minimum=s.stops_level*s.point,freeze=s.freeze_level*s.point;
   if(distance<=0 || distance<minimum || distance<=freeze) return false;
   // Existing protection inside freeze distance may make the whole SLTP request
   // unmodifiable. Preserve TP exactly; never erase it to make an SL update pass.
   if(old_sl>0 && (buy?close_price-old_sl:old_sl-close_price)<=freeze) return false;
   if(tp>0 && ((buy?tp-close_price:close_price-tp)<minimum ||
               (buy?tp-close_price:close_price-tp)<=freeze)) return false;
   sl=candidate;
   return true;
  }
```

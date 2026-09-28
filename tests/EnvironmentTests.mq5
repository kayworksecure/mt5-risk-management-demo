#property strict
#property script_show_inputs
#include "../include/MarketEnvironment.mqh"

int failures=0;
void Check(const bool passed,const string name)
  {
   Print("[TEST] ",name,": ",passed ? "PASS" : "FAIL");
   if(!passed) failures++;
  }
void OnStart()
  {
   double aligned;
   Check(DemoAlignPrice(100.13,0.25,2,-1,aligned) && MathAbs(aligned-100.0)<1e-9,"GRID_DOWN");
   Check(DemoAlignPrice(100.13,0.25,2,1,aligned) && MathAbs(aligned-100.25)<1e-9,"GRID_UP");
   Check(DemoAlignPrice(100.13,0.25,2,0,aligned) && MathAbs(aligned-100.25)<1e-9,"GRID_NEAREST");
   Check(!DemoAlignPrice(100.13,0,2,0,aligned),"ZERO_TICK_REJECT");
   Check(!DemoAlignPrice(-1,0.25,2,0,aligned),"NEGATIVE_PRICE_REJECT");
   Check(!DemoAlignPrice(100.13,0.25,1,0,aligned),"UNREPRESENTABLE_GRID_REJECT");
   DemoSymbolInfo s;
   ZeroMemory(s);
   string error;
   Check(!DemoValidateSymbol(s,error),"MISSING_SPEC_REJECT");
   Check(!DemoReadSymbol("__NONEXISTENT_RISK_DEMO_SYMBOL__",s,error),"UNKNOWN_SYMBOL_REJECT");
   DemoAccountInfo a;
   Check(DemoReadAccount(a,error),"ACCOUNT_READ");
   Print("[TEST] ACCOUNT_MODE ",DemoIsHedging(a) ? "HEDGING" : "NETTING");
   string symbols[2]={"EURUSDm","XAUUSDm"};
   for(int i=0;i<2;i++)
     {
      bool selected=SymbolSelect(symbols[i],true);
      bool valid=selected && DemoReadSymbol(symbols[i],s,error);
      Check(valid,"BROKER_SPEC_"+symbols[i]);
      if(valid)
        {
         PrintFormat("[TEST] SPEC %s digits=%d point=%.8f tick=%.8f min=%.4f max=%.4f step=%.4f",
                     s.symbol,(int)s.digits,s.point,s.tick_size,s.volume_min,s.volume_max,s.volume_step);
         s.volume_step=0;
         Check(!DemoValidateSymbol(s,error),"INVALID_STEP_REJECT_"+symbols[i]);
        }
     }
   PrintFormat("[TEST] ENVIRONMENT_RESULT failures=%d",failures);
  }

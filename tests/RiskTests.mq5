#property strict
#property script_show_inputs
#include "../include/RiskManager.mqh"
int failures=0;
void Check(const bool ok,const string name)
  { Print("[TEST] ",name,": ",ok ? "PASS" : "FAIL"); if(!ok) failures++; }
void OnStart()
  {
   double budget;
   Check(DemoRiskBudget(5000,1,budget) && MathAbs(budget-50)<1e-10,"BUDGET_5000");
   Check(DemoRiskBudget(10000,0.5,budget) && MathAbs(budget-50)<1e-10,"BUDGET_10000");
   Check(!DemoRiskBudget(0,1,budget),"ZERO_EQUITY_REJECT");
   Check(!DemoRiskBudget(5000,-1,budget),"NEGATIVE_RISK_REJECT");
   DemoSymbolInfo s;
   ZeroMemory(s); s.volume_min=0.1; s.volume_max=2; s.volume_step=0.1;
   Check(DemoValidVolume(0.3,s),"FIXED_STEP_VALID");
   Check(!DemoValidVolume(0.35,s),"FIXED_STEP_REJECT");
   Check(!DemoValidVolume(0.01,s),"FIXED_MIN_REJECT");
   Check(!DemoValidVolume(2.1,s),"FIXED_MAX_REJECT");
   string symbols[2]={"EURUSDm","XAUUSDm"};
   for(int i=0;i<2;i++)
     {
      string error;
      if(!SymbolSelect(symbols[i],true) || !DemoReadSymbol(symbols[i],s,error))
        { Check(false,"SPEC_"+symbols[i]); continue; }
      MqlTick tick;
      if(!SymbolInfoTick(s.symbol,tick) || !DemoPositive(tick.ask) || !DemoPositive(tick.bid))
        { Check(false,"QUOTE_"+symbols[i]); continue; }
      for(int side=0;side<2;side++)
        {
         ENUM_ORDER_TYPE direction=side==0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         double entry=side==0 ? tick.ask : tick.bid;
         for(int distance=100;distance<=1000;distance*=10)
           {
            double sl=entry+(side==0 ? -1 : 1)*distance*s.tick_size;
            double volume,loss,min_loss;
            string name=s.symbol+"_"+(side==0 ? "BUY" : "SELL")+"_"+IntegerToString(distance);
            bool estimated=DemoStopLossMoney(direction,s.symbol,s.volume_min,entry,sl,min_loss);
            Check(estimated,"ESTIMATE_"+name);
            if(!estimated) continue;
            Check(!DemoRiskVolume(s,direction,entry,sl,min_loss/2,volume,loss,error),"MIN_RISK_REJECT_"+name);
            double valid_budget=MathMax(50,min_loss*10);
            bool accepted=DemoRiskVolume(s,direction,entry,sl,valid_budget,volume,loss,error);
            Check(accepted && DemoValidVolume(volume,s) && loss<=valid_budget+DemoRiskTolerance(valid_budget),"FINAL_RISK_"+name);
            double max_loss;
            if(DemoStopLossMoney(direction,s.symbol,s.volume_max,entry,sl,max_loss))
               Check(DemoRiskVolume(s,direction,entry,sl,max_loss*2,volume,loss,error) && volume<=s.volume_max &&
                     loss<=max_loss*2+DemoRiskTolerance(max_loss*2),"MAX_CAP_"+name);
            else Check(false,"MAX_ESTIMATE_"+name);
           }
        }
     }
   PrintFormat("[TEST] RISK_RESULT failures=%d",failures);
  }

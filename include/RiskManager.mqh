#ifndef RISK_DEMO_RISK_MQH
#define RISK_DEMO_RISK_MQH
#include "MarketEnvironment.mqh"

enum ENUM_DEMO_SIZING_MODE { FIXED_LOT=0, RISK_PERCENT=1 };

bool DemoValidVolume(const double volume,const DemoSymbolInfo &s)
  {
   if(!DemoPositive(volume) || !DemoPositive(s.volume_min) ||
      !DemoPositive(s.volume_max) || !DemoPositive(s.volume_step) ||
      s.volume_max<s.volume_min || volume<s.volume_min || volume>s.volume_max)
      return false;
   double steps=volume/s.volume_step;
   // At most 1e-8 of a step compensates for binary representation only.
   return MathIsValidNumber(steps) && steps<=1e12 && MathAbs(steps-MathRound(steps))<=1e-8;
  }

bool DemoRiskBudget(const double equity,const double percent,double &budget)
  {
   budget=0;
   if(!DemoPositive(equity) || !DemoPositive(percent)) return false;
   budget=equity*(percent/100.0);
   if(!DemoPositive(budget)) { budget=0; return false; }
   return true;
  }

bool DemoStopLossMoney(const ENUM_ORDER_TYPE direction,const string symbol,
                       const double volume,const double entry,const double sl,
                       double &loss)
  {
   loss=0;
   if(!DemoPositive(volume) || !DemoPositive(entry) || !DemoPositive(sl) ||
      (direction!=ORDER_TYPE_BUY && direction!=ORDER_TYPE_SELL) ||
      (direction==ORDER_TYPE_BUY && sl>=entry) ||
      (direction==ORDER_TYPE_SELL && sl<=entry)) return false;
   double profit=0;
   if(!OrderCalcProfit(direction,symbol,volume,entry,sl,profit) ||
      !MathIsValidNumber(profit) || profit>=0) return false;
   loss=-profit;
   return DemoPositive(loss);
  }

// This tolerance is capped at 0.00000001 account-currency units. It cannot
// authorize a material risk excess, even for unusually large budgets.
double DemoRiskTolerance(const double budget)
  {
   return MathMin(1e-8,budget*1e-10);
  }

bool DemoRiskVolume(const DemoSymbolInfo &s,const ENUM_ORDER_TYPE direction,
                    const double entry,const double sl,const double budget,
                    double &volume,double &estimated_loss,string &error)
  {
   volume=0; estimated_loss=0; error="";
   if(!DemoPositive(budget) || !DemoValidVolume(s.volume_min,s))
     { error="Invalid budget or minimum-volume specification."; return false; }
   double reference_loss;
   if(!DemoStopLossMoney(direction,s.symbol,s.volume_min,entry,sl,reference_loss))
     { error="Monetary stop-loss calculation failed."; return false; }
   if(reference_loss>budget+DemoRiskTolerance(budget))
     { error="Minimum tradable volume exceeds risk budget."; return false; }
   // Reference volume need not equal one lot: preserve its scaling explicitly.
   double raw=(budget/reference_loss)*s.volume_min;
   if(!DemoPositive(raw)) { error="Invalid raw risk volume."; return false; }
   double capped=MathMin(raw,s.volume_max);
   double steps=capped/s.volume_step;
   if(!MathIsValidNumber(steps) || steps>1e12)
     { error="Unrepresentable volume step count."; return false; }
   volume=MathFloor(steps)*s.volume_step;
   if(!DemoValidVolume(volume,s) ||
      !DemoStopLossMoney(direction,s.symbol,volume,entry,sl,estimated_loss))
     { volume=0; estimated_loss=0; error="Final volume or monetary loss invalid."; return false; }
   if(estimated_loss>budget+DemoRiskTolerance(budget))
     { volume=0; estimated_loss=0; error="Final estimated loss exceeds risk budget."; return false; }
   return true;
  }
#endif

#ifndef RISK_DEMO_ENVIRONMENT_MQH
#define RISK_DEMO_ENVIRONMENT_MQH

struct DemoSymbolInfo
  {
   string symbol;
   long digits,stops_level,freeze_level,trade_mode,filling_mode,execution_mode,order_mode;
   double point,tick_size,tick_value,tick_value_profit,tick_value_loss;
   double volume_min,volume_max,volume_step;
  };

struct DemoAccountInfo
  {
   // Local scoping only: never include these identifiers in public logs.
   long login,margin_mode;
   string server,currency;
   double balance,equity;
   bool terminal_connected,terminal_trade_allowed,program_trade_allowed;
   bool account_trade_allowed,account_expert_allowed;
  };

bool DemoPositive(const double value)
  {
   return MathIsValidNumber(value) && value>0.0;
  }

bool DemoValidateSymbol(const DemoSymbolInfo &s,string &error)
  {
   error="";
   if(s.symbol=="" || s.digits<0 || s.digits>8 || !DemoPositive(s.point) ||
      !DemoPositive(s.tick_size) || !DemoPositive(s.tick_value) ||
      !DemoPositive(s.tick_value_profit) || !DemoPositive(s.tick_value_loss) ||
      !DemoPositive(s.volume_min) || !DemoPositive(s.volume_max) ||
      !DemoPositive(s.volume_step) || s.volume_max<s.volume_min ||
      s.stops_level<0 || s.freeze_level<0 ||
      s.trade_mode<SYMBOL_TRADE_MODE_DISABLED || s.trade_mode>SYMBOL_TRADE_MODE_FULL ||
      s.execution_mode<SYMBOL_TRADE_EXECUTION_REQUEST || s.execution_mode>SYMBOL_TRADE_EXECUTION_EXCHANGE ||
      s.filling_mode<0 || s.order_mode<0)
     {
      error="Invalid or unavailable critical symbol specification.";
      return false;
     }
   if(MathAbs(s.point-MathPow(10.0,-(int)s.digits))>s.point*1e-8 ||
      MathAbs(NormalizeDouble(s.tick_size,(int)s.digits)-s.tick_size)>s.tick_size*1e-8)
     {
      error="Inconsistent point, digits or tick grid.";
      return false;
     }
   return true;
  }

bool DemoReadSymbol(const string symbol,DemoSymbolInfo &s,string &error)
  {
   ZeroMemory(s);
   s.symbol=symbol;
   error="";
   // Boolean overloads distinguish a valid zero property from query failure.
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,s.digits) ||
      !SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,s.stops_level) ||
      !SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL,s.freeze_level) ||
      !SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE,s.trade_mode) ||
      !SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE,s.filling_mode) ||
      !SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE,s.execution_mode) ||
      !SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE,s.order_mode) ||
      !SymbolInfoDouble(symbol,SYMBOL_POINT,s.point) ||
      !SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,s.tick_size) ||
      !SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE,s.tick_value) ||
      !SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_PROFIT,s.tick_value_profit) ||
      !SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS,s.tick_value_loss) ||
      !SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,s.volume_min) ||
      !SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,s.volume_max) ||
      !SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,s.volume_step))
     {
      error="Symbol information query failed; no fallback used.";
      return false;
     }
   return DemoValidateSymbol(s,error);
  }

bool DemoReadAccount(DemoAccountInfo &a,string &error)
  {
   ZeroMemory(a);
   ResetLastError();
   a.login=AccountInfoInteger(ACCOUNT_LOGIN);
   a.server=AccountInfoString(ACCOUNT_SERVER);
   a.currency=AccountInfoString(ACCOUNT_CURRENCY);
   a.margin_mode=AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   a.balance=AccountInfoDouble(ACCOUNT_BALANCE);
   a.equity=AccountInfoDouble(ACCOUNT_EQUITY);
   a.terminal_connected=(bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   a.terminal_trade_allowed=(bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   a.program_trade_allowed=(bool)MQLInfoInteger(MQL_TRADE_ALLOWED);
   a.account_trade_allowed=(bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   a.account_expert_allowed=(bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   error="";
   if(GetLastError()!=0 || a.login<=0 || a.server=="" || a.currency=="" ||
      !MathIsValidNumber(a.balance) || !MathIsValidNumber(a.equity) ||
      (a.margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING &&
       a.margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_NETTING &&
       a.margin_mode!=ACCOUNT_MARGIN_MODE_EXCHANGE))
     {
      error="Invalid or unavailable account information.";
      return false;
     }
   return true;
  }

bool DemoIsHedging(const DemoAccountInfo &a)
  {
   return a.margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
  }

// Phase 2 has no ownership provenance. An existing net position must be
// considered unproven; later execution logic must establish exclusive control.
bool DemoExistingNetExposureUnproven(const string symbol,const DemoAccountInfo &a)
  {
   if(DemoIsHedging(a)) return false;
   for(int i=PositionsTotal()-1;i>=0;--i)
     {
      if(PositionGetTicket(i)==0) return true;
      string position_symbol;
      if(!PositionGetString(POSITION_SYMBOL,position_symbol)) return true;
      if(position_symbol==symbol) return true;
     }
   return false;
  }

// Direction: -1 rounds down, 0 nearest, +1 up. Callers choose the direction
// for the price role, then validate side/distance and recalculate monetary risk.
bool DemoAlignPrice(const double raw,const double tick_size,const int digits,
                    const int direction,double &aligned)
  {
   aligned=0.0;
   if(!DemoPositive(raw) || !DemoPositive(tick_size) || digits<0 || digits>8 ||
      direction<-1 || direction>1) return false;
   double units=raw/tick_size;
   if(!MathIsValidNumber(units) || units>1e12) return false;
   double grid=(direction<0 ? MathFloor(units) : (direction>0 ? MathCeil(units) : MathRound(units)));
   aligned=NormalizeDouble(grid*tick_size,digits);
   // Tolerance is solely for representational error, not an extra tradable tick.
   double tolerance=tick_size*1e-8;
   if(!DemoPositive(aligned) || MathAbs(aligned/tick_size-MathRound(aligned/tick_size))>1e-8 ||
      (direction<0 && aligned>raw+tolerance) ||
      (direction>0 && aligned<raw-tolerance))
     {
      aligned=0.0;
      return false;
     }
   return true;
  }
#endif

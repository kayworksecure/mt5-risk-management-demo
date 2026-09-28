#ifndef RISK_DEMO_ENTRY_FILTERS_MQH
#define RISK_DEMO_ENTRY_FILTERS_MQH
#include "MarketEnvironment.mqh"

bool DemoSessionValid(const int start_minute,const int end_minute)
  { return start_minute>=0 && start_minute<1440 && end_minute>=0 && end_minute<1440 && start_minute!=end_minute; }

// Half-open server-time interval: start included, end excluded. Equal endpoints
// are rejected rather than silently interpreted as all day or no trading.
bool DemoInSession(const int minute,const int start_minute,const int end_minute)
  {
   if(minute<0 || minute>=1440 || !DemoSessionValid(start_minute,end_minute)) return false;
   if(start_minute<end_minute) return minute>=start_minute && minute<end_minute;
   return minute>=start_minute || minute<end_minute;
  }

bool DemoSpreadAllowed(const double bid,const double ask,const double point,const double maximum)
  {
   // Compare prices to avoid cancellation/division turning an exact decimal
   // boundary (e.g. a 20-point FX spread) into 20.00000000002 points.
   double ceiling=bid+maximum*point;
   return DemoPositive(bid) && DemoPositive(ask) && ask>=bid && DemoPositive(point) &&
          MathIsValidNumber(maximum) && maximum>=0 && MathIsValidNumber(ceiling) && ask<=ceiling;
  }

bool DemoServerDay(const datetime now,datetime &day,int &minute)
  {
   day=0; minute=0; MqlDateTime parts={};
   if(now<=0 || !TimeToStruct(now,parts)) return false;
   minute=parts.hour*60+parts.min;
   parts.hour=0; parts.min=0; parts.sec=0; day=StructToTime(parts);
   return day>0 && day<=now;
  }

bool DemoQualifyingEntry(const long type,const long entry,const long reason,const long magic,
                         const long configured_magic,const double volume)
  {
   // INOUT contains a newly opened opposite exposure after a netting reversal.
   // Each confirmed entry deal counts once, including distinct partial fills.
   // This classification does not grant authority to control a net position.
   return configured_magic>0 && magic==configured_magic && reason==DEAL_REASON_EXPERT &&
          (type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL) &&
          (entry==DEAL_ENTRY_IN || entry==DEAL_ENTRY_INOUT) && DemoPositive(volume);
  }

// One authoritative history calculation for initialization, transactions and
// entry checks. No request-time increment and no additive transaction counter.
bool DemoDailyEntryCount(const long magic,const datetime now,int &count,string &error)
  {
   count=0; error=""; datetime day; int minute;
   if(magic<=0 || !DemoServerDay(now,day,minute) || !HistorySelect(day,now+1))
     { error="Daily entry history or server day unavailable."; return false; }
   int total=HistoryDealsTotal(),candidate=0;
   for(int i=0;i<total;i++)
     {
      ulong deal=HistoryDealGetTicket(i); long time,type,entry,reason,deal_magic; double volume;
      if(deal==0 || !HistoryDealGetInteger(deal,DEAL_TIME,time) ||
         !HistoryDealGetInteger(deal,DEAL_TYPE,type) || !HistoryDealGetInteger(deal,DEAL_MAGIC,deal_magic))
        { error="Daily deal properties unavailable."; return false; }
      if(time<(long)day || time>(long)now || deal_magic!=magic ||
         (type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)) continue;
      if(!HistoryDealGetInteger(deal,DEAL_ENTRY,entry) || !HistoryDealGetInteger(deal,DEAL_REASON,reason) ||
         !HistoryDealGetDouble(deal,DEAL_VOLUME,volume) || !DemoPositive(volume))
        { error="Daily entry classification unavailable."; return false; }
      if(DemoQualifyingEntry(type,entry,reason,deal_magic,magic,volume)) candidate++;
     }
   count=candidate; return true;
  }

bool DemoAdditionalExposureAllowed(const string symbol,const long magic,const bool multiple,string &error)
  {
   error="";
   if(symbol=="" || magic<=0) { error="Invalid exposure context."; return false; }
   if(multiple) return true; // TradeManager still enforces account-mode ownership.
   DemoAccountInfo account;
   if(!DemoReadAccount(account,error)) return false;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      string position_symbol; long position_magic;
      if(PositionGetTicket(i)==0 || !PositionGetString(POSITION_SYMBOL,position_symbol) ||
         !PositionGetInteger(POSITION_MAGIC,position_magic))
        { error="Exposure inspection unavailable."; return false; }
      if(position_symbol==symbol && (!DemoIsHedging(account) || position_magic==magic))
        { error="Additional symbol exposure disabled while an applicable position exists."; return false; }
     }
   return true;
  }

bool DemoEntryFilters(const string symbol,const long magic,const double maximum_spread,
                      const int session_start,const int session_end,const int maximum_trades,
                      const bool multiple,int &count,string &error)
  {
   count=0; error=""; datetime now=TimeCurrent(),day; int minute;
   if(maximum_trades<=0 || !DemoSessionValid(session_start,session_end) ||
      !MathIsValidNumber(maximum_spread) || maximum_spread<0 || !DemoServerDay(now,day,minute))
     { error="Invalid entry controls or unavailable server time."; return false; }
   if(!DemoInSession(minute,session_start,session_end))
     { error="Outside configured server-time session."; return false; }
   DemoSymbolInfo specification; MqlTick quote;
   if(!DemoReadSymbol(symbol,specification,error)) return false;
   if(!SymbolInfoTick(symbol,quote) || quote.time_msc<=0 ||
      !DemoSpreadAllowed(quote.bid,quote.ask,specification.point,maximum_spread))
     { error="Spread exceeds maximum or quote unavailable."; return false; }
   if(!DemoDailyEntryCount(magic,now,count,error)) return false;
   if(count>=maximum_trades) { error="Confirmed account-wide daily entry limit reached."; return false; }
   return DemoAdditionalExposureAllowed(symbol,magic,multiple,error);
  }
#endif

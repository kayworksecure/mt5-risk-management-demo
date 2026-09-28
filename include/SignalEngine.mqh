#ifndef RISK_DEMO_SIGNAL_MQH
#define RISK_DEMO_SIGNAL_MQH

enum ENUM_DEMO_SIGNAL { DEMO_NO_SIGNAL=0, DEMO_BUY_SIGNAL=1, DEMO_SELL_SIGNAL=-1 };

ENUM_DEMO_SIGNAL DemoCrossover(const double fast2,const double slow2,
                                const double fast1,const double slow1)
  {
   if(!MathIsValidNumber(fast2) || !MathIsValidNumber(slow2) ||
      !MathIsValidNumber(fast1) || !MathIsValidNumber(slow1) ||
      fast2==EMPTY_VALUE || slow2==EMPTY_VALUE || fast1==EMPTY_VALUE || slow1==EMPTY_VALUE)
      return DEMO_NO_SIGNAL;
   if(fast2<=slow2 && fast1>slow1) return DEMO_BUY_SIGNAL;
   if(fast2>=slow2 && fast1<slow1) return DEMO_SELL_SIGNAL;
   return DEMO_NO_SIGNAL;
  }

class CDemoSignalEngine
  {
private:
   int m_fast,m_slow;
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   datetime m_observed,m_attempted;
public:
   CDemoSignalEngine(void) : m_fast(INVALID_HANDLE),m_slow(INVALID_HANDLE),
      m_timeframe(PERIOD_CURRENT),m_observed(0),m_attempted(0) {}

   void Release(void)
     {
      if(m_fast!=INVALID_HANDLE) IndicatorRelease(m_fast);
      if(m_slow!=INVALID_HANDLE) IndicatorRelease(m_slow);
      m_fast=INVALID_HANDLE; m_slow=INVALID_HANDLE;
     }

   bool Init(const string symbol,const ENUM_TIMEFRAMES timeframe,
             const int fast,const int slow,string &error)
     {
      Release(); m_observed=0; m_attempted=0;
      error="";
      if(fast<=0 || slow<=fast || PeriodSeconds(timeframe)<=0)
        { error="Invalid EMA periods or timeframe."; return false; }
      m_symbol=symbol; m_timeframe=timeframe;
      // Standard close-price EMAs; no optimized or proprietary signal inputs.
      m_fast=iMA(symbol,timeframe,fast,0,MODE_EMA,PRICE_CLOSE);
      m_slow=iMA(symbol,timeframe,slow,0,MODE_EMA,PRICE_CLOSE);
      if(m_fast==INVALID_HANDLE || m_slow==INVALID_HANDLE)
        { Release(); error="EMA handle creation failed."; return false; }
      // Approved startup policy: never replay the bar already completed at
      // initialization. Unavailable history fails initialization, not open.
      datetime baseline=iTime(m_symbol,m_timeframe,1);
      if(baseline<=0)
        { Release(); error="Startup completed-bar baseline unavailable."; return false; }
      m_observed=baseline;
      m_attempted=baseline;
      return true;
     }

   bool Poll(datetime &bar,ENUM_DEMO_SIGNAL &signal,string &error)
     {
      bar=0; signal=DEMO_NO_SIGNAL; error="";
      datetime completed=iTime(m_symbol,m_timeframe,1);
      if(completed<=0 || m_fast==INVALID_HANDLE || m_slow==INVALID_HANDLE ||
         BarsCalculated(m_fast)<3 || BarsCalculated(m_slow)<3)
        { error="Completed-bar EMA data unavailable."; return false; }
      // Also reject history moving backwards; only a subsequent bar qualifies.
      if(completed<=m_observed) return true;
      double fast[2],slow[2];
      // CopyBuffer writes the oldest requested item first: [0]=bar 2,
      // [1]=bar 1. Bar 0 is never requested for crossover confirmation.
      if(CopyBuffer(m_fast,0,1,2,fast)!=2 || CopyBuffer(m_slow,0,1,2,slow)!=2 ||
         iTime(m_symbol,m_timeframe,1)!=completed)
        { error="EMA copy incomplete or completed bar changed during read."; return false; }
      for(int i=0;i<2;i++)
         if(!MathIsValidNumber(fast[i]) || !MathIsValidNumber(slow[i]) ||
            fast[i]==EMPTY_VALUE || slow[i]==EMPTY_VALUE)
           { error="Invalid EMA buffer values."; return false; }
      m_observed=completed;
      bar=completed;
      if(completed!=m_attempted) signal=DemoCrossover(fast[0],slow[0],fast[1],slow[1]);
      return true;
     }

   bool ConsumeAttempt(const datetime bar)
     {
      if(bar<=0 || bar!=m_observed || bar==m_attempted) return false;
      m_attempted=bar;
      return true;
     }
  };
#endif

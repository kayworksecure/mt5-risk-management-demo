#property strict
#property script_show_inputs
#include "../include/SignalEngine.mqh"
int failures=0;
void Check(const bool ok,const string name)
  { Print("[TEST] ",name,": ",ok ? "PASS" : "FAIL"); if(!ok) failures++; }
void OnStart()
  {
   Check(DemoCrossover(1,2,3,2)==DEMO_BUY_SIGNAL,"BUY_CROSS");
   Check(DemoCrossover(3,2,1,2)==DEMO_SELL_SIGNAL,"SELL_CROSS");
   Check(DemoCrossover(2,2,3,2)==DEMO_BUY_SIGNAL,"BUY_EQUAL_BAR2");
   Check(DemoCrossover(2,2,1,2)==DEMO_SELL_SIGNAL,"SELL_EQUAL_BAR2");
   Check(DemoCrossover(1,2,2,2)==DEMO_NO_SIGNAL,"EQUAL_BAR1_NO_CROSS");
   Check(DemoCrossover(3,2,4,2)==DEMO_NO_SIGNAL,"NO_CROSS");
   Check(DemoCrossover(EMPTY_VALUE,2,3,2)==DEMO_NO_SIGNAL,"EMPTY_REJECT");
   CDemoSignalEngine engine;
   string error;
   Check(!engine.Init(_Symbol,PERIOD_M1,0,20,error),"INVALID_FAST_REJECT");
   Check(!engine.Init(_Symbol,PERIOD_M1,20,10,error),"INVALID_SLOW_REJECT");
   bool initialized=engine.Init(_Symbol,PERIOD_M1,10,20,error);
   Check(initialized,"HANDLES_INIT");
   if(initialized)
     {
      datetime bar=0;
      ENUM_DEMO_SIGNAL signal=DEMO_NO_SIGNAL;
      datetime baseline=iTime(_Symbol,PERIOD_M1,1);
      bool ready=false;
      for(int i=0;i<50 && !IsStopped();i++)
        { if(engine.Poll(bar,signal,error)) { ready=true; break; } Sleep(100); }
      Check(ready && bar==0 && signal==DEMO_NO_SIGNAL,"STARTUP_BAR_SUPPRESSED");
      Check(!engine.ConsumeAttempt(baseline),"STARTUP_BAR_NOT_ATTEMPTABLE");
      if(ready)
        {
         Check(engine.Poll(bar,signal,error) && bar==0 && signal==DEMO_NO_SIGNAL,"REPEATED_POLL_NO_OPPORTUNITY");
         bool next_bar=false;
         ulong started=GetTickCount64();
         while(!IsStopped() && GetTickCount64()-started<75000)
           {
            if(engine.Poll(bar,signal,error) && bar>baseline) { next_bar=true; break; }
            Sleep(100);
           }
         Check(next_bar,"NEW_COMPLETED_BAR");
         if(next_bar)
           {
            Check(engine.ConsumeAttempt(bar),"NEW_BAR_ATTEMPT_ALLOWED");
            Check(!engine.ConsumeAttempt(bar),"CONSUME_DUPLICATE_REJECT");
            Check(engine.Init(_Symbol,PERIOD_M1,10,20,error),"RESTART_INIT");
            bool restarted=false;
            for(int i=0;i<50 && !IsStopped();i++)
              { if(engine.Poll(bar,signal,error)) { restarted=true; break; } Sleep(100); }
            Check(restarted && bar==0 && signal==DEMO_NO_SIGNAL,"RESTART_REPLAY_SUPPRESSED");
           }
        }
     }
   engine.Release();
   PrintFormat("[TEST] SIGNAL_RESULT failures=%d",failures);
  }


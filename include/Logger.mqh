#ifndef RISK_DEMO_LOGGER_MQH
#define RISK_DEMO_LOGGER_MQH

enum ENUM_DEMO_LOG_LEVEL
  {
   DEMO_LOG_ERROR = 0,
   DEMO_LOG_INFO  = 1,
   DEMO_LOG_DEBUG = 2
  };

enum ENUM_DEMO_LOG_CATEGORY
  {
   DEMO_INIT,
   DEMO_SIGNAL,
   DEMO_FILTER,
   DEMO_RISK,
   DEMO_TRADE,
   DEMO_MANAGE,
   DEMO_SAFETY,
   DEMO_RECOVERY,
   DEMO_ERROR
  };

string DemoLogCategory(const ENUM_DEMO_LOG_CATEGORY category)
  {
   switch(category)
     {
      case DEMO_INIT:     return "[INIT]";
      case DEMO_SIGNAL:   return "[SIGNAL]";
      case DEMO_FILTER:   return "[FILTER]";
      case DEMO_RISK:     return "[RISK]";
      case DEMO_TRADE:    return "[TRADE]";
      case DEMO_MANAGE:   return "[MANAGE]";
      case DEMO_SAFETY:   return "[SAFETY]";
      case DEMO_RECOVERY: return "[RECOVERY]";
      default:            return "[ERROR]";
     }
  }

class CDemoLogger
  {
private:
   ENUM_DEMO_LOG_LEVEL m_level;

public:
   CDemoLogger(void) : m_level(DEMO_LOG_INFO) {}

   void SetLevel(const ENUM_DEMO_LOG_LEVEL level)
     {
      m_level=level;
     }

   void Write(const ENUM_DEMO_LOG_LEVEL level,
              const ENUM_DEMO_LOG_CATEGORY category,
              const string message,
              const bool always_visible=false)
     {
      // Call safety-critical failures/lock events at ERROR so no user level
      // can hide them. Lifecycle records also remain visible for diagnosis.
      if(always_visible || level==DEMO_LOG_ERROR || level<=m_level)
         Print(DemoLogCategory(category)," ",message);
     }
  };

#endif

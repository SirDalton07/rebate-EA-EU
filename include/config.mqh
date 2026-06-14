//+------------------------------------------------------------------+
//| Configuration File - Rebate EA EU                                |
//+------------------------------------------------------------------+

// ==================== TRADING PARAMETERS ====================
#define MAGIC_NUMBER 12345
#define MA_FAST 8
#define MA_SLOW 21

// ==================== RISK MANAGEMENT ====================
#define RISK_PER_TRADE 2.0          // Risk per trade in % of balance
#define SL_PIPS 50                  // Stop Loss in pips
#define TP_PIPS 20                  // Take Profit in pips
#define DAILY_LOSS_LIMIT 2.0        // Daily loss limit in % of balance
#define MAX_TRADES_PER_DAY 10       // Maximum trades per day

// ==================== REBATE PARAMETERS ====================
#define REBATE_PER_TRADE 5.0        // Rebate per trade in USD (example)
#define LOG_FILE "rebate_log.csv"   // Log file name

// ==================== TRADING HOURS ====================
#define TRADING_START_HOUR 0        // Start trading hour (0-23)
#define TRADING_END_HOUR 24         // End trading hour (0-23)

// ==================== SLIPPAGE & SPREAD ====================
#define MAX_SPREAD 3                // Maximum allowed spread in pips
#define SLIPPAGE 3                  // Acceptable slippage in pips

// ==================== POINT CONSTANT ====================
#define POINT Point                 // MQL4/MQL5 compatibility

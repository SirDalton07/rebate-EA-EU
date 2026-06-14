//+------------------------------------------------------------------+
//| Rebate EA EU - MQ4 Trading Robot                                  |
//| Pair: EURUSD, Timeframe: M15                                      |
//| Strategy: MA Crossover with Dynamic Lot by Balance               |
//+------------------------------------------------------------------+
#property copyright "SirDalton07"
#property link      "https://github.com/SirDalton07/rebate-EA-EU"
#property version   "1.00"
#property strict

#include <trades.mqh>
#include <rebate.mqh>
#include <config.mqh>

//--- Global variables
int lastTradeBar = 0;
double lastBalance = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== Rebate EA EU Started ===");
    Print("Pair: ", Symbol(), " | Timeframe: ", Period(), " minutes");
    Print("Strategy: MA Crossover | Lot Type: Dynamic by Balance");
    
    // Initialize rebate tracking
    InitRebateTracking();
    
    lastBalance = AccountBalance();
    lastTradeBar = 0;
    
    Print("Initialization complete. Ready to trade!");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== Rebate EA EU Stopped ===");
    Print("Reason: ", reason);
    SaveRebateData();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Skip if not enough bars
    if (Bars < 50)
        return;
    
    // Only trade once per candle
    if (lastTradeBar == Bars)
        return;
    
    lastTradeBar = Bars;
    
    // Check daily loss limit
    if (CheckDailyLossLimit())
    {
        Print("[ALERT] Daily loss limit reached. Stopping trades.");
        return;
    }
    
    // Update rebate tracking every tick
    UpdateRebateTracking();
    
    // Get current signal
    int signal = GetMASignal();
    
    // Check for existing orders
    int positionType = GetPositionType();
    
    // Trade logic
    if (signal == OP_BUY && positionType != OP_BUY)
    {
        // Close sell if any
        if (positionType == OP_SELL)
            CloseTrade();
        
        // Open buy
        OpenTrade(OP_BUY);
    }
    else if (signal == OP_SELL && positionType != OP_SELL)
    {
        // Close buy if any
        if (positionType == OP_BUY)
            CloseTrade();
        
        // Open sell
        OpenTrade(OP_SELL);
    }
    
    // Update balance for daily tracking
    lastBalance = AccountBalance();
}

//+------------------------------------------------------------------+
//| Get MA Crossover Signal                                           |
//+------------------------------------------------------------------+
int GetMASignal()
{
    // MA Fast (8) and MA Slow (21) on M15
    double maFast = iMA(Symbol(), PERIOD_CURRENT, MA_FAST, 0, MODE_SMA, PRICE_CLOSE, 1);
    double maSlow = iMA(Symbol(), PERIOD_CURRENT, MA_SLOW, 0, MODE_SMA, PRICE_CLOSE, 1);
    
    double maFastPrev = iMA(Symbol(), PERIOD_CURRENT, MA_FAST, 0, MODE_SMA, PRICE_CLOSE, 2);
    double maSlowPrev = iMA(Symbol(), PERIOD_CURRENT, MA_SLOW, 0, MODE_SMA, PRICE_CLOSE, 2);
    
    // Crossover Buy: Fast MA crosses above Slow MA
    if (maFastPrev <= maSlowPrev && maFast > maSlow)
        return OP_BUY;
    
    // Crossover Sell: Fast MA crosses below Slow MA
    if (maFastPrev >= maSlowPrev && maFast < maSlow)
        return OP_SELL;
    
    return -1; // No signal
}

//+------------------------------------------------------------------+
//| Get current position type                                         |
//+------------------------------------------------------------------+
int GetPositionType()
{
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
            {
                return OrderType();
            }
        }
    }
    return -1; // No position
}

//+------------------------------------------------------------------+
//| Check daily loss limit                                            |
//+------------------------------------------------------------------+
bool CheckDailyLossLimit()
{
    double dailyProfit = GetDailyProfit();
    double dailyLossLimit = -(AccountBalance() * DAILY_LOSS_LIMIT / 100);
    
    return (dailyProfit < dailyLossLimit);
}

//+------------------------------------------------------------------+
//| Get daily profit/loss                                             |
//+------------------------------------------------------------------+
double GetDailyProfit()
{
    double profit = 0;
    datetime today = TimeDayStart(TimeCurrent());
    
    for (int i = 0; i < OrdersHistoryTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if (OrderSymbol() == Symbol() && 
                OrderMagicNumber() == MAGIC_NUMBER &&
                OrderCloseTime() >= today)
            {
                profit += OrderProfit();
            }
        }
    }
    return profit;
}

//+------------------------------------------------------------------+
//| Utility: Get start of day                                         |
//+------------------------------------------------------------------+
datetime TimeDayStart(datetime time)
{
    return time - (time % 86400);
}

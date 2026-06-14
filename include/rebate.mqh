//+------------------------------------------------------------------+
//| Rebate Tracking Functions - Rebate EA EU                         |
//+------------------------------------------------------------------+

#include <config.mqh>

struct RebateData
{
    int totalTrades;
    double totalRebate;
    double totalProfit;
    datetime startTime;
};

RebateData rebateData;
int lastOrdersTotal = 0;

//+------------------------------------------------------------------+
//| Initialize Rebate Tracking                                       |
//+------------------------------------------------------------------+
void InitRebateTracking()
{
    rebateData.totalTrades = 0;
    rebateData.totalRebate = 0.0;
    rebateData.totalProfit = 0.0;
    rebateData.startTime = TimeCurrent();
    
    // Create/clear log file
    int handle = FileOpen(LOG_FILE, FILE_CSV | FILE_WRITE);
    if (handle != INVALID_HANDLE)
    {
        FileWrite(handle, "Date,Time,Type,Lots,Entry,Exit,Profit,Rebate");
        FileClose(handle);
    }
    
    Print("[REBATE] Tracking initialized at ", TimeToStr(rebateData.startTime));
}

//+------------------------------------------------------------------+
//| Update Rebate Tracking (Every Tick)                              |
//+------------------------------------------------------------------+
void UpdateRebateTracking()
{
    int currentOrdersTotal = OrdersTotal();
    
    // Check for closed orders in history
    for (int i = 0; i < OrdersHistoryTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
            {
                // Check if this is a new closed order
                if (OrderCloseTime() > rebateData.startTime)
                {
                    rebateData.totalTrades++;
                    rebateData.totalRebate += REBATE_PER_TRADE;
                    rebateData.totalProfit += OrderProfit();
                    
                    // Log trade
                    LogTrade(OrderTicket(), OrderType(), OrderOpenPrice(), OrderClosePrice(), 
                            OrderProfit(), REBATE_PER_TRADE);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Log Trade to CSV File                                            |
//+------------------------------------------------------------------+
void LogTrade(int ticket, int type, double entry, double exit, double profit, double rebate)
{
    int handle = FileOpen(LOG_FILE, FILE_CSV | FILE_READ | FILE_WRITE);
    if (handle != INVALID_HANDLE)
    {
        FileSeek(handle, 0, SEEK_END);
        
        string typeStr = (type == OP_BUY) ? "BUY" : "SELL";
        string line = TimeToStr(TimeCurrent(), TIME_DATE) + "," +
                     TimeToStr(TimeCurrent(), TIME_SECONDS) + "," +
                     typeStr + "," +
                     DoubleToStr(OrderOpenPrice(), 5) + "," +
                     DoubleToStr(entry, 5) + "," +
                     DoubleToStr(exit, 5) + "," +
                     DoubleToStr(profit, 2) + "," +
                     DoubleToStr(rebate, 2);
        
        FileWrite(handle, line);
        FileClose(handle);
    }
}

//+------------------------------------------------------------------+
//| Save Rebate Data to File                                         |
//+------------------------------------------------------------------+
void SaveRebateData()
{
    Print("\n=== REBATE SUMMARY ===");
    Print("Total Trades: ", rebateData.totalTrades);
    Print("Total Rebate: $", DoubleToStr(rebateData.totalRebate, 2));
    Print("Total Profit: $", DoubleToStr(rebateData.totalProfit, 2));
    Print("Session Duration: ", (TimeCurrent() - rebateData.startTime) / 3600, " hours");
    Print("========================\n");
}

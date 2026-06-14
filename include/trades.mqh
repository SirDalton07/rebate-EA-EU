//+------------------------------------------------------------------+
//| Trading Functions - Rebate EA EU                                 |
//+------------------------------------------------------------------+

#include <config.mqh>

//+------------------------------------------------------------------+
//| Open Trade (Buy or Sell)                                         |
//+------------------------------------------------------------------+
bool OpenTrade(int type)
{
    double bid = Bid;
    double ask = Ask;
    double price = (type == OP_BUY) ? ask : bid;
    double lotSize = CalculateLotSize();
    int slippage = SLIPPAGE;
    
    // Check spread
    double spread = ask - bid;
    if (spread > POINT * MAX_SPREAD)
    {
        Print("[WARNING] Spread too high: ", spread / Point, " pips");
        return false;
    }
    
    // Calculate SL and TP
    double sl, tp;
    
    if (type == OP_BUY)
    {
        sl = bid - (SL_PIPS * Point);
        tp = ask + (TP_PIPS * Point);
    }
    else
    {
        sl = ask + (SL_PIPS * Point);
        tp = bid - (TP_PIPS * Point);
    }
    
    // Open order
    int ticket = OrderSend(Symbol(), type, lotSize, price, slippage, sl, tp, "Rebate EA", MAGIC_NUMBER, 0, clrBlue);
    
    if (ticket < 0)
    {
        Print("[ERROR] Failed to open trade. Error: ", GetLastError());
        return false;
    }
    
    Print("[TRADE] Order opened. Ticket: ", ticket, " | Type: ", (type == OP_BUY ? "BUY" : "SELL"), " | Lot: ", lotSize);
    return true;
}

//+------------------------------------------------------------------+
//| Close Trade                                                       |
//+------------------------------------------------------------------+
bool CloseTrade()
{
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
            {
                double price = (OrderType() == OP_BUY) ? Bid : Ask;
                bool result = OrderClose(OrderTicket(), OrderOpenPrice(), price, SLIPPAGE, clrRed);
                
                if (!result)
                {
                    Print("[ERROR] Failed to close trade. Error: ", GetLastError());
                    return false;
                }
                
                Print("[TRADE] Order closed. Ticket: ", OrderTicket(), " | Profit: ", OrderProfit());
                return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size (Dynamic by Balance)                          |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double balance = AccountBalance();
    double riskAmount = (balance * RISK_PER_TRADE) / 100;
    double pipValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double lotSize = riskAmount / (SL_PIPS * pipValue);
    
    // Normalize to broker's lot step
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    
    lotSize = MathMax(minLot, MathMin(maxLot, MathRound(lotSize / lotStep) * lotStep));
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Check if Trading Hours are Valid                                 |
//+------------------------------------------------------------------+
bool IsValidTradingHour()
{
    int hour = Hour();
    
    if (TRADING_START_HOUR < TRADING_END_HOUR)
        return (hour >= TRADING_START_HOUR && hour < TRADING_END_HOUR);
    else
        return (hour >= TRADING_START_HOUR || hour < TRADING_END_HOUR);
}

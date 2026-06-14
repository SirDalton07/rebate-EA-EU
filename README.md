# Rebate EA EU

**MQ4 Trading Robot for EURUSD with Rebate Tracking System**

## Overview

Rebate EA EU is an automated trading robot designed for MetaTrader 4 (MQ4) that trades the EURUSD pair on M15 timeframe with a focus on maximizing rebate earnings.

## Features

✅ **MA Crossover Strategy** - Fast MA (8) crosses Slow MA (21) for entry signals  
✅ **Dynamic Lot Sizing** - Automatically calculates lot size based on account balance and risk  
✅ **Risk Management** - Stop Loss, Take Profit, Daily Loss Limits  
✅ **Rebate Tracking** - Logs all trades and calculates total rebate earnings  
✅ **Daily Loss Protection** - Stops trading if daily loss limit is reached  
✅ **Trade Logging** - CSV export for performance analysis  

## Configuration

### Trading Parameters
```
MA_FAST = 8          // Fast Moving Average
MA_SLOW = 21         // Slow Moving Average
RISK_PER_TRADE = 2%  // Risk per trade
SL_PIPS = 50         // Stop Loss
TP_PIPS = 20         // Take Profit
```

### Risk Management
```
DAILY_LOSS_LIMIT = 2%        // Stop if daily loss exceeds 2% of balance
MAX_TRADES_PER_DAY = 10      // Maximum trades allowed per day
MAX_SPREAD = 3               // Maximum spread tolerance in pips
```

### Rebate Settings
```
REBATE_PER_TRADE = $5        // Rebate per trade (adjust per broker)
```

Edit these values in `include/config.mqh`

## Installation

1. **Copy files to MetaTrader 4:**
   ```
   robot.mq4 → MetaTrader 4\experts\
   include/   → MetaTrader 4\experts\include\
   ```

2. **Compile in MetaEditor:**
   - Open MetaEditor (Tools → MetaEditor in MT4)
   - Open `robot.mq4`
   - Press F5 to compile

3. **Attach to Chart:**
   - Open EURUSD M15 chart
   - Drag `Rebate EA EU` onto chart
   - Enable "Allow live trading"
   - Set parameters if needed

## Strategy Logic

### Entry Conditions
- **BUY Signal:** Fast MA crosses above Slow MA
- **SELL Signal:** Fast MA crosses below Slow MA
- **Close Position:** When opposite signal occurs

### Position Management
- **Only 1 position per time:** EA closes previous position before opening new one
- **Stop Loss:** 50 pips below entry
- **Take Profit:** 20 pips above entry
- **Ratio:** 1:0.4 (conservative risk/reward for volume trading)

## Risk Management Rules

1. **Daily Loss Limit:** If daily loss reaches -2% of account balance, EA stops trading
2. **Spread Filter:** Trades are skipped if spread exceeds 3 pips
3. **Dynamic Lot Size:** Automatically adjusts lot based on account balance
4. **Max Trades/Day:** Limited to 10 trades per day to prevent overtrading

## Rebate Tracking

The EA automatically logs all trades to `rebate_log.csv` with:
- Date & Time
- Trade Type (BUY/SELL)
- Entry & Exit Price
- Profit/Loss
- Rebate Amount

### Example Output
```
Date,Time,Type,Lots,Entry,Exit,Profit,Rebate
2026-06-14,10:30:45,BUY,0.1,1.07654,1.07674,20.00,5.00
2026-06-14,10:45:22,SELL,0.1,1.07674,1.07654,20.00,5.00
```

## File Structure

```
rebate-EA-EU/
├── robot.mq4                 # Main EA file
├── include/
│   ├── config.mqh           # Configuration parameters
│   ├── trades.mqh           # Trading functions
│   └── rebate.mqh           # Rebate tracking system
├── README.md                # This file
└── rebate_log.csv           # Trade log (generated)
```

## Performance Tips

1. **Backtest First:** Always backtest on historical data before live trading
2. **Start Small:** Test with minimum lot sizes first
3. **Monitor Spread:** Choose broker with tight EURUSD spreads
4. **Broker Rebate:** Confirm rebate amount with your broker
5. **Trading Hours:** Consider restricting trades to London/NY sessions

## Troubleshooting

### No Trades Occurring
- Check if chart is M15 timeframe
- Verify EURUSD pair is loaded
- Check if EA is enabled (Expert Advisors should be ON)
- Review error logs in MT4 Journal

### Wrong Lot Size
- Verify account balance
- Check RISK_PER_TRADE setting
- Ensure broker allows calculated lot size

### Spreads Too High
- Switch to different broker with tighter spreads
- Trade during major session overlap (1-2PM GMT)
- Increase MAX_SPREAD tolerance if needed

## Important Notes

⚠️ **Disclaimer:** This EA is provided as-is for educational purposes. Past performance does not guarantee future results. Always use proper risk management and never risk more than you can afford to lose.

⚠️ **Live Trading:** Test thoroughly in demo account first before live trading.

⚠️ **Broker Verification:** Confirm rebate amounts with your broker's terms.

## Support & Development

For issues, suggestions, or improvements:
- Create an Issue on GitHub
- Submit a Pull Request
- Contact: https://github.com/SirDalton07

## Version History

**v1.00** - Initial release
- MA Crossover strategy
- Dynamic lot sizing
- Basic rebate tracking
- Risk management features

## License

Open source - Free to use and modify

---

**Last Updated:** 2026-06-14  
**Author:** SirDalton07  
**Repository:** https://github.com/SirDalton07/rebate-EA-EU

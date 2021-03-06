//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Volume_Price_Change_EURUSD_M30_Params : Stg_Volume_Price_Change_Params {
  Stg_Volume_Price_Change_EURUSD_M30_Params() {
    Volume_Price_Change_Period = 21;
    Volume_Price_Change_Applied_Price = PRICE_CLOSE;
    Volume_Price_Change_Shift = 0;
    Volume_Price_Change_SignalOpenMethod = 0;
    Volume_Price_Change_SignalOpenLevel = 0;
    Volume_Price_Change_SignalCloseMethod = 0;
    Volume_Price_Change_SignalCloseLevel = 0;
    Volume_Price_Change_PriceLimitMethod = 0;
    Volume_Price_Change_PriceLimitLevel = 0;
    Volume_Price_Change_MaxSpread = 5;
  }
} stg_vpc_arrays_m30;

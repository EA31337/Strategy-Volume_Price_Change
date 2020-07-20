//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements strategy based on the Volume Price Change oscillator.
 */

// Includes.
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __Volume_Price_Change_Parameters__ =
    "-- Volume Price Change strategy params --";                           // >>> Volume Price Change <<<
INPUT int Volume_Price_Change_Period = 0;                                  // Period
INPUT ENUM_APPLIED_PRICE Volume_Price_Change_Applied_Price = PRICE_CLOSE;  // Applied Price
INPUT int Volume_Price_Change_Shift = 0;                                   // Shift (0 for default)
int Volume_Price_Change_SignalOpenMethod = 0;                              // Signal open method (-63-63)
double Volume_Price_Change_SignalOpenLevel = 0;                            // Signal open level (-49-49)
int Volume_Price_Change_SignalOpenFilterMethod = 0;                        // Signal open filter method
int Volume_Price_Change_SignalOpenBoostMethod = 0;                         // Signal open boost method
int Volume_Price_Change_SignalCloseMethod = 0;                             // Signal close method
double Volume_Price_Change_SignalCloseLevel = 18;                          // Signal close level
int Volume_Price_Change_PriceLimitMethod = 0;                              // Price limit method
double Volume_Price_Change_PriceLimitLevel = 1;                            // Price limit level
double Volume_Price_Change_MaxSpread = 6.0;                                // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_Volume_Price_Change_Params : StgParams {
  unsigned int Volume_Price_Change_Period;
  ENUM_APPLIED_PRICE Volume_Price_Change_Applied_Price;
  int Volume_Price_Change_Shift;
  int Volume_Price_Change_SignalOpenMethod;
  double Volume_Price_Change_SignalOpenLevel;
  int Volume_Price_Change_SignalOpenFilterMethod;
  int Volume_Price_Change_SignalOpenBoostMethod;
  int Volume_Price_Change_SignalCloseMethod;
  double Volume_Price_Change_SignalCloseLevel;
  int Volume_Price_Change_PriceLimitMethod;
  double Volume_Price_Change_PriceLimitLevel;
  double Volume_Price_Change_MaxSpread;

  // Constructor: Set default param values.
  Stg_Volume_Price_Change_Params()
      : Volume_Price_Change_Period(::Volume_Price_Change_Period),
        Volume_Price_Change_Applied_Price(::Volume_Price_Change_Applied_Price),
        Volume_Price_Change_Shift(::Volume_Price_Change_Shift),
        Volume_Price_Change_SignalOpenMethod(::Volume_Price_Change_SignalOpenMethod),
        Volume_Price_Change_SignalOpenLevel(::Volume_Price_Change_SignalOpenLevel),
        Volume_Price_Change_SignalOpenFilterMethod(::Volume_Price_Change_SignalOpenFilterMethod),
        Volume_Price_Change_SignalOpenBoostMethod(::Volume_Price_Change_SignalOpenBoostMethod),
        Volume_Price_Change_SignalCloseMethod(::Volume_Price_Change_SignalCloseMethod),
        Volume_Price_Change_SignalCloseLevel(::Volume_Price_Change_SignalCloseLevel),
        Volume_Price_Change_PriceLimitMethod(::Volume_Price_Change_PriceLimitMethod),
        Volume_Price_Change_PriceLimitLevel(::Volume_Price_Change_PriceLimitLevel),
        Volume_Price_Change_MaxSpread(::Volume_Price_Change_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Volume_Price_Change : public Strategy {
 public:
  Stg_Volume_Price_Change(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Volume_Price_Change *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL,
                                       ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_Volume_Price_Change_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_Volume_Price_Change_Params>(_params, _tf, stg_cci_arrays_m1, stg_cci_arrays_m5,
                                                    stg_cci_arrays_m15, stg_cci_arrays_m30, stg_cci_arrays_h1,
                                                    stg_cci_arrays_h4, stg_cci_arrays_h4);
    }
    // Initialize strategy parameters.
    Volume_Price_Change_Params ccia_params(_params.Volume_Price_Change_Period,
                                           _params.Volume_Price_Change_Applied_Price,
                                           _params.Volume_Price_Change_Shift);
    ccia_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Volume_Price_Change(ccia_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Volume_Price_Change_SignalOpenMethod, _params.Volume_Price_Change_SignalOpenLevel,
                       _params.Volume_Price_Change_SignalOpenFilterMethod,
                       _params.Volume_Price_Change_SignalOpenBoostMethod, _params.Volume_Price_Change_SignalCloseMethod,
                       _params.Volume_Price_Change_SignalCloseLevel);
    sparams.SetPriceLimits(_params.Volume_Price_Change_PriceLimitMethod, _params.Volume_Price_Change_PriceLimitLevel);
    sparams.SetMaxSpread(_params.Volume_Price_Change_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Volume_Price_Change(sparams, "Volume Price Change");
    return _strat;
  }

  /**
   * Check if strategy is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Chart *_chart = this.Chart();
    Indi_Volume_Price_Change *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[CURR].value[VPC_DOWN] > 0;
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[CURR].value[VPC_UP] > 0;
        break;
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indi_Volume_Price_Change *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return _result;
  }
};

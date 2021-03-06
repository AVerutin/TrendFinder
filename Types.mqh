//+------------------------------------------------------------------+
//|                                            Описание типов данных |
//|                                           Copyright 2021, AlexV. |
//|                                       mailto://alexbroot@mail.ru |
//+------------------------------------------------------------------+

enum ENUM_TREND_TYPE
{
   TREND_BULLISH = 0,   // Бычий
   TREND_BEARISH,       // Медвежий
   TREND_NONE           // Флет
};

enum ENUM_INDICATOR_TYPE
{
   INDICATOR_PANE = 0,  // Панели
   INDICATOR_LABEL      // Текст
};

enum ENUM_CHART_PERIOD
{
   CHART_PERIOD_D1 = 0, // Дневной график
   CHART_PERIOD_H4,     // 4 часовой график
   CHART_PERIOD_H1,     // 1 часовой график
   CHART_PERIOD_M30,    // 30 минутный график
   CHART_PERIOD_M15,    // 15 минутный график
   CHART_PERIOD_M5,     // 5 минутный график
   CHART_PERIOD_M1      // 1 минутный график
};

enum ENUM_CHART_CORNER
{
   CHART_LEFT_UPPER = 0,   // Верхний левый угол
   CHART_RIGHT_UPPER,      // Верхний правый угол
   CHART_LEFT_LOWER,       // Нижний левый угол
   CHART_RIGHT_LOWER       // Нижний правый угол
};

enum ENUM_SCALE_TYPE
{
   SCALE_SMALL = 0,        // Мелкий масшаб (460 баров)
   SCALE_MIDDLE,           // Средний масштаб (230 баров)
   SCALE_LARGE             // Крупный масшаб (114 баров)
};

enum ENUM_LOG_TYPE
{
   LOG_DEBUG = 0,          // Отладочное сообщение
   LOG_INFORMATION,        // Информационное сообщение
   LOG_WARNING,            // Предупреждающее сообщение
   LOG_ERROR               // Сообщение об ошибке
};

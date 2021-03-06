//+------------------------------------------------------------------+
//|                                 Класс текстовой метки индикатора |
//|                                           Copyright 2021, AlexV. |
//|                                       mailto://alexbroot@mail.ru |
//+------------------------------------------------------------------+

#include "Types.mqh"

class CLabel
{
public:
   CLabel::CLabel();
   CLabel::CLabel(const string);
   CLabel::CLabel(const string, const string);
   CLabel::CLabel(const CLabel &);
   void SetName(const string);
   void MoveTo(int, int);
   void ChangeCorner(const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER);
   void SetText(const string);
   void SetColor(const color);
   void SetTrend(const ENUM_TREND_TYPE trend=TREND_NONE);
   void Delete();
   ENUM_TREND_TYPE GetTrend();
   void SetPeriod(const ENUM_CHART_PERIOD period=CHART_PERIOD_D1);
   ENUM_CHART_PERIOD GetPeriod();
   void SetUpdated(bool);
   bool IsUpdated();

   
private:
   void Draw();

   ENUM_CHART_PERIOD m_period;
   ENUM_TREND_TYPE m_trendType;
   ENUM_BASE_CORNER m_corner;
   string m_text;
   string m_name;
   color m_color;
   int m_posX;
   int m_posY;
   bool m_updated;
};

// Конструктор по-умолчанию
CLabel::CLabel()
   : m_text("N"), m_name("Label1"), m_color(clrYellow), 
   m_posX(0), m_posY(0), m_corner(CORNER_RIGHT_UPPER),
   m_trendType(TREND_NONE), m_period(CHART_PERIOD_D1), m_updated(false)
{
   Draw();
}

// Конструктор с указанием имени 
CLabel::CLabel(const string name)
   : m_text("N"), m_name(name), m_color(clrYellow), 
   m_posX(0), m_posY(0), m_corner(CORNER_RIGHT_UPPER),
   m_trendType(TREND_NONE), m_period(CHART_PERIOD_D1), m_updated(false)
{
   Draw();
}

// Конструктор с указанием имени и текста метки
CLabel::CLabel(const string name,const string text)
   : m_text(text), m_name(name), m_color(clrYellow), 
   m_posX(0), m_posY(0), m_corner(CORNER_RIGHT_UPPER),
   m_trendType(TREND_NONE), m_period(CHART_PERIOD_D1), m_updated(false)
{
   Draw();
}

// Конструктор копирования
CLabel::CLabel(const CLabel &label) 
   : m_text(label.m_text), m_name(label.m_name + "_copy"), m_color(label.m_color), 
   m_posX(label.m_posX), m_posY(label.m_posY), m_corner(label.m_corner),
   m_trendType(label.m_trendType), m_period(label.m_period), m_updated(label.m_updated)
{
   Draw();
}

// Задать имя метки
void CLabel::SetName(const string name)
{
   m_name = name;
}

// Переместить метку в указанные координаты
void CLabel::MoveTo(int xl, int yl)
{
//--- сбросим значение ошибки 
   ResetLastError(); 

//--- переместим текстовую метку 
   if(!ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, xl)) 
   { 
      Print(__FUNCTION__, 
         ": не удалось переместить X-координату метки! Код ошибки = ", GetLastError()); 
         
      return; 
   } 
     
   if(!ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, yl)) 
   { 
      Print(__FUNCTION__, 
         ": не удалось переместить Y-координату метки! Код ошибки = ", GetLastError()); 
         
      return; 
   } 

//--- успешное выполнение 
   return; 
}

// Изменить угол размещения метки
void CLabel::ChangeCorner(const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER)
{
//--- сбросим значение ошибки 
   ResetLastError(); 

//--- изменим угол привязки 
   if(!ObjectSetInteger(0, m_name, OBJPROP_CORNER, corner)) 
   { 
   Print(__FUNCTION__, 
      ": не удалось изменить угол привязки! Код ошибки = ", GetLastError()); 
      
   return; 
   } 

//--- успешное выполнение 
   return; 
}

// Задать текст метки
void CLabel::SetText(const string text)
{
//--- сбросим значение ошибки 
   ResetLastError(); 
   
//--- изменим текст объекта 
   if(!ObjectSetString(0, m_name, OBJPROP_TEXT, text)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось изменить текст! Код ошибки = ",GetLastError()); 
            
      return; 
     } 
     
//--- успешное выполнение 
   return; 
}

// Задать цвет метки
void CLabel::SetColor(const color col)
{
//--- сбросим значение ошибки 
   ResetLastError(); 
   
//--- изменим текст объекта 
   m_color = col;
   
   if(!ObjectSetInteger(0, m_name, OBJPROP_COLOR, col)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось изменить цвет! Код ошибки = ",GetLastError()); 
            
      return; 
     } 
     
//--- успешное выполнение 
   return; 
}

// Задать тип тренда
void CLabel::SetTrend(const ENUM_TREND_TYPE trend=TREND_NONE)
{
   m_trendType = trend;
   
   switch(trend)
   {
      case TREND_NONE : {
         ObjectSetInteger(0, m_name, OBJPROP_COLOR, clrYellow); // установим цвет фона
         break;
      }
      case TREND_BEARISH : {
         ObjectSetInteger(0, m_name, OBJPROP_COLOR, clrRed);    // установим цвет фона
         break;
      }
      case TREND_BULLISH : {
         ObjectSetInteger(0, m_name, OBJPROP_COLOR, clrGreen);  // установим цвет фона
         break;
      }
   }
}

// Удалить метку
void CLabel::Delete()
{
//--- сбросим значение ошибки 
   ResetLastError(); 
   
//--- удалим метку 
   if(!ObjectDelete(0, m_name)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось удалить текстовую метку! Код ошибки = ",GetLastError()); 
            
      return; 
     } 
     
//--- успешное выполнение 
   return; 
}

// Вывести метку на график
void CLabel::Draw()
{
//--- сбросим значение ошибки 
   ResetLastError(); 
   
//--- создадим текстовую метку 
   if (ObjectFind(m_name) == -1)
      if(!ObjectCreate(0, m_name, OBJ_LABEL, 0, 0, 0)) 
      { 
         Print(__FUNCTION__, 
            ": не удалось создать текстовую метку! Код ошибки = ",GetLastError()); 
         return; 
      } 
     
//--- установим координаты метки 
   ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, m_posX);           // Координаты метки
   ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, m_posY); 
   ObjectSetInteger(0, m_name, OBJPROP_CORNER, m_corner);            // Угол привязки
   ObjectSetString (0, m_name, OBJPROP_TEXT, m_text);                // Текст
   ObjectSetString (0, m_name, OBJPROP_FONT, "Consolas");            // Шрифт
   ObjectSetInteger(0, m_name, OBJPROP_FONTSIZE, 16);                // Размер шрифта
   ObjectSetDouble (0, m_name, OBJPROP_ANGLE, 0.0);                  // Угол наклона текста
   ObjectSetInteger(0, m_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);  // Способ привязки
   ObjectSetInteger(0, m_name, OBJPROP_COLOR, m_color);              // Цвет текста
   ObjectSetInteger(0, m_name, OBJPROP_BACK, false);                 // отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0, m_name, OBJPROP_SELECTABLE, false);           // включим (true) или отключим (false) режим перемещения метки мышью 
   ObjectSetInteger(0, m_name, OBJPROP_SELECTED, false); 
   ObjectSetInteger(0, m_name,OBJPROP_HIDDEN, true);                 // скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(0, m_name,OBJPROP_ZORDER, 0);                    // установим приоритет на получение события нажатия мыши на графике 
   
//--- успешное выполнение 
   return; 
}

// Получить тип тренда
ENUM_TREND_TYPE CLabel::GetTrend()
{
   return m_trendType;
}

// Установить период
void CLabel::SetPeriod(const ENUM_CHART_PERIOD period=CHART_PERIOD_D1)
{
   m_period = period;
}

// Получить период
ENUM_CHART_PERIOD CLabel::GetPeriod()
{
   return m_period;
}

// Установить признак актуальности данных
void CLabel::SetUpdated(bool update)
{
   m_updated = update;
}

// Получить признак актуальности данных
bool CLabel::IsUpdated()
{
   return m_updated;
}

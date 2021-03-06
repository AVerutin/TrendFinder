//+------------------------------------------------------------------+
//|                             Класс прямоугольной метки индикатора |
//|                                           Copyright 2021, AlexV. |
//|                                       mailto://alexbroot@mail.ru |
//+------------------------------------------------------------------+

#include "Types.mqh"

class CPane 
{
public:
   CPane::CPane();
   CPane::CPane(const string);
   CPane::CPane(const CPane &);
   void SetName(const string);
   void MoveTo(int x, int y);
   void ChangeCorner(const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER);
   void SetColor(color);
   void SetTrend(const ENUM_TREND_TYPE trend=TREND_NONE);
   ENUM_TREND_TYPE GetTrend();
   void SetPeriod(const ENUM_CHART_PERIOD period=CHART_PERIOD_D1);
   ENUM_CHART_PERIOD GetPeriod();
   void Delete();
   void SetUpdated(bool);
   bool IsUpdated();

private:
   void Draw();
   
   ENUM_CHART_PERIOD m_period;
   ENUM_TREND_TYPE m_trendType;
   ENUM_BASE_CORNER m_corner;
   string m_name;
   color m_color;
   int m_posX;
   int m_posY;
   bool m_updated;
};

// Конструктор по-умолчанию
CPane::CPane() 
   : m_posX(0), m_posY(0), m_color(clrYellow),
   m_name("Pane1"), m_corner(CORNER_RIGHT_UPPER), m_trendType(TREND_NONE), m_period(CHART_PERIOD_D1), m_updated(false)
{
   Draw();
}

// Конструктор с именем
CPane::CPane(const string name)
   : m_posX(0), m_posY(0), m_color(clrYellow),
   m_name(name), m_corner(CORNER_RIGHT_UPPER), m_trendType(TREND_NONE), m_period(CHART_PERIOD_D1), m_updated(false)
{
   Draw();
}


// Копирующий конструктор
CPane::CPane(const CPane &pane) 
   : m_posX(pane.m_posX), m_posY(pane.m_posY), m_color(pane.m_color),
   m_name(pane.m_name), m_corner(pane.m_corner), m_trendType(pane.m_trendType), m_period(pane.m_period), m_updated(pane.m_updated)
{
   Draw();
}

// Задать имя панели
void CPane::SetName(const string name)
{
   m_name = name;
}

// Переместить панель
void CPane::MoveTo(int xl, int yl)
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

// Изменить угол привязки
void CPane::ChangeCorner(const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER)
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

// Задать цвет панели
void CPane::SetColor(color col)
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

// Установить тренд
void CPane::SetTrend(const ENUM_TREND_TYPE trend=TREND_NONE)
{
   m_trendType = trend;
   
   switch(trend)
   {
      case TREND_NONE : {
         ObjectSetInteger(0, m_name, OBJPROP_BGCOLOR, clrYellow); // установим цвет фона
         break;
      }
      case TREND_BEARISH : {
         ObjectSetInteger(0, m_name, OBJPROP_BGCOLOR, clrRed);    // установим цвет фона
         break;
      }
      case TREND_BULLISH : {
         ObjectSetInteger(0, m_name, OBJPROP_BGCOLOR, clrGreen);  // установим цвет фона
         break;
      }
   }
}

// Получить текущий тренд
ENUM_TREND_TYPE CPane::GetTrend()
{
   return m_trendType;
}

// Удалить панель
void CPane::Delete()
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

// Вывести панель на график
void CPane::Draw()
{
   //--- сбросим значение ошибки
   ResetLastError();
   
   //--- создадим прямоугольную метку
   if (ObjectFind(m_name) == -1)
      ObjectCreate(0, m_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);

   ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, m_posX);           // установим координаты метки
   ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, m_posY);  
   ObjectSetInteger(0, m_name, OBJPROP_CORNER, m_corner);            // Угол привязки
   ObjectSetInteger(0, m_name, OBJPROP_XSIZE, 20);                   // установим размеры метки
   ObjectSetInteger(0, m_name, OBJPROP_YSIZE, 18);
   ObjectSetInteger(0, m_name, OBJPROP_BGCOLOR, m_color);            // установим цвет фона
   ObjectSetInteger(0, m_name, OBJPROP_BORDER_TYPE, BORDER_SUNKEN);  // установим тип границы
   ObjectSetInteger(0, m_name, OBJPROP_CORNER, m_corner);            // установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0, m_name, OBJPROP_COLOR, clrNONE);              // установим цвет плоской рамки (в режиме Flat)
   ObjectSetInteger(0, m_name, OBJPROP_STYLE, STYLE_SOLID);          // установим стиль линии плоской рамки
   ObjectSetInteger(0, m_name, OBJPROP_WIDTH, 0);                    // установим толщину плоской границы
   ObjectSetInteger(0, m_name, OBJPROP_BACK, false);                 // отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0, m_name, OBJPROP_SELECTABLE, false);           // включим (true) или отключим (false) режим перемещения метки мышью
   ObjectSetInteger(0, m_name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, m_name, OBJPROP_HIDDEN, true);                // скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(0, m_name, OBJPROP_ZORDER, 0);                   // установим приоритет на получение события нажатия мыши на графике
   
   return;

}

// Установить период
void CPane::SetPeriod(const ENUM_CHART_PERIOD period=CHART_PERIOD_D1)
{
   m_period = period;
}

// Получить период
ENUM_CHART_PERIOD CPane::GetPeriod()
{
   return m_period;
}

// Установить признак актуальности данных
void CPane::SetUpdated(bool update)
{
   m_updated = update;
}

// Получить признак актуальности данных
bool CPane::IsUpdated()
{
   return m_updated;
}

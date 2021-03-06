//+------------------------------------------------------------------+
//|                                                    FindTrend.mq4 |
//|                                           Copyright 2021, AlexV. |
//|                                       mailto://alexbroot@mail.ru |
//+------------------------------------------------------------------+
#include "Pane.mqh"
#include "Label.mqh"
#include "FileLogger.mqh"

#property strict
// Версия программы
extern string version = "0.3.0"; // Версия программы

// Параметры размещения
extern ENUM_CHART_CORNER InpCorner  =  CHART_RIGHT_UPPER;  // Угол привязки
extern ENUM_INDICATOR_TYPE InpType  =  INDICATOR_PANE;     // Тип индикатора
extern bool DrawBoxes = true; // Выводить границы массивов

// Координаты меток
extern int x_coor = 10;    // Сдвиг по оси X
extern int y_coor = 10;    // Сдвиг по оси Y
int x_size = 180;
int y_size = 30;
int x_step = 5;
int y_panl = 20;
int x_rect = 20;
int y_rect = 20;
int x_text = 30;
int y_text = 20;
int y_line = 6;

// Величина прохода
extern int far_dist = 150.0; // Величина прохода

// Масштабы
extern int              Zoom1=460;  // Этап 1 
extern int              Zoom2=230;  // Этап 2
extern int              Zoom3=114;  // Этап 3

//--- indicator buffers
double         D1Buffer[];
double         H4Buffer[];
double         H1Buffer[];
double         M30Buffer[];
double         M15Buffer[];
double         M5Buffer[];
double         M1Buffer[];

CLabel* labels[7];
CPane* panes[7];
FileLogger* logger; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- Подключение логгинга
   logger = new FileLogger("Main");
   logger.Information("Запущен индикатор");

//--- indicator buffers mapping
   SetIndexBuffer(0, D1Buffer);
   SetIndexBuffer(1, H4Buffer);
   SetIndexBuffer(2, H1Buffer);
   SetIndexBuffer(3, M30Buffer);
   SetIndexBuffer(4, M15Buffer);
   SetIndexBuffer(5, M5Buffer);
   SetIndexBuffer(6, M1Buffer);

//--- размеры окна графика 
   long x_distance; 
   long y_distance; 
   
   if (InpType == INDICATOR_LABEL)
      x_coor += 20;
   
//--- текст и периоды для меток
   string labelsText[7] = {"D1", "H4", "H1", "M30", "M15", "M5", "M1"};
   ENUM_CHART_PERIOD periods[7] = {CHART_PERIOD_D1, CHART_PERIOD_H4, CHART_PERIOD_H1, CHART_PERIOD_M30, CHART_PERIOD_M15, CHART_PERIOD_M5, CHART_PERIOD_M1};
   
//--- определим размеры окна 
   if(!ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, x_distance)) 
   { 
      Comment("Не удалось получить ширину графика! Код ошибки = ", GetLastError()); 
      return (1); 
   } 
   
   if(!ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, y_distance)) 
   { 
      Comment("Не удалось получить высоту графика! Код ошибки = ", GetLastError()); 
      return (1); 
   } 
   
//--- проверим входные параметры на корректность 
   if(x_coor < 0 || x_coor > x_distance-1 || y_coor < 0 || y_coor > y_distance-1) 
   { 
      Comment("Ошибка! Некорректные значения входных параметров!"); 
      return (1); 
   } 
   
//--- создадим выбранную метку на графике 
   switch (InpType)
   {
      case INDICATOR_PANE : {
         for (int i = 0; i < 7; i++)
         {
            ENUM_TREND_TYPE trend = FindTrend((ENUM_CHART_PERIOD)i);
            string name = "pane_" + IntegerToString(i+1);
            CPane *pane = new CPane(name);
            pane.SetPeriod(periods[i]);
            pane.SetTrend(trend);
            panes[i] = pane;
            
            MovePane(i);
         }
         
         break;
      }
      case INDICATOR_LABEL : {
         for (int i = 0; i < 7; i++)
         {
            ENUM_TREND_TYPE trend = FindTrend((ENUM_CHART_PERIOD)i);
            string name = "label_" + IntegerToString(i+1);
            CLabel *label = new CLabel(name);
            label.SetText(labelsText[i]);
            label.SetPeriod(periods[i]);
            label.SetTrend(trend);
            labels[i] = label;
            
            MoveLabel(i);
         }
      }
   }

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment(""); // Очистим окно от сообщений
   
//--- Удалим все созданные объекты
   switch (InpType)
   {
      case INDICATOR_PANE : {
         for (int i = 0; i < 7; i++)
         {
            panes[i].Delete();
            CPane *pane = panes[i];
            delete pane;
         }
         
         break;
      }
      case INDICATOR_LABEL : {
         for (int i = 0; i < 7; i++)
         {
            labels[i].Delete();
            CLabel *label = labels[i];            
            delete label;
         }
      }
   }
   
   delete logger;
   
   ObjectsDeleteAll(0, OBJ_RECTANGLE);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Вывод элементов в зависимости от выбранного типа   
   switch(InpType)
   {
      case INDICATOR_PANE : {
         for (int i = 0; i < 7; i++)
         {
            ENUM_TREND_TYPE type = GetTrend(i, time[0]);
            panes[i].SetTrend(type);
         }
         
         break;
      }
      case INDICATOR_LABEL : {
         for (int i = 0; i < 7; i++)
         {
            ENUM_TREND_TYPE type = GetTrend(i, time[0]);
            labels[i].SetTrend(type);
         }
      }
      
      break;
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| User-defined functions                                           |
//+------------------------------------------------------------------+

//+--------------------- Размещение панелей -------------------------+
void MovePane(int pos)
{
   int x_pn = 0;
   int y_pn = 0;
   
   switch (pos)
   {
      case 0 : {
         // Первый прямоугольник
         x_pn = x_coor + x_step;
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size; y_pn = y_coor + y_rect;}
         
         break;
      }
      case 1 : {
         // Второй прямоугольник
         x_pn = x_coor + x_rect + 2*x_step;
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - x_step - x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - x_step - x_rect; y_pn = y_coor + y_rect;}
         
         break;
      }
      case 2 : {
         // Третий прямоугольник
         x_pn = x_coor + 2*x_rect + 3*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 2*x_step - 2*x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 2*x_step - 2*x_rect; y_pn = y_coor + y_rect;}

         break;
      }
      case 3 : {
         // Четвертый прямоугольник
         x_pn = x_coor + 3*x_rect + 4*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 3*x_step - 3*x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 3*x_step - 3*x_rect; y_pn = y_coor + y_rect;}
         
         break;
      }
      case 4 : {
         // Пятый прямоугольник
         x_pn = x_coor + 4*x_rect + 5*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 4*x_step - 4*x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 4*x_step - 4*x_rect; y_pn = y_coor + y_rect;}

         break;
      }
      case 5 : {
         // Шестой прямоугольник
         x_pn = x_coor + 5*x_rect + 6*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 5*x_step - 5*x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 5*x_step - 5*x_rect; y_pn = y_coor + y_rect;}
         
         break;
      }
      case 6 : {
         // Седьмой прямоугольник
         x_pn = x_coor + 6*x_rect + 7*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 6*x_step - 6*x_rect;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 6*x_step - 6*x_rect; y_pn = y_coor + y_rect;}
      
         break;
      }
   }
      
   panes[pos].MoveTo(x_pn, y_pn);     
}

//+---------------------- Размещение меток --------------------------+
void MoveLabel(int pos)
{
   int x_pn = 0;
   int y_pn = 0;
   
   switch (pos)
   {
      case 0 : {
         // Первая метка
         x_pn = x_coor + x_step;
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size;
         if (InpCorner == 2)  y_pn = y_coor + y_text;
         if (InpCorner == 3) {x_pn = x_coor + x_size; y_pn = y_coor + y_text;}
         
         break;
      }
      case 1 : {
         // Вторая метка
         x_pn = x_coor + x_text + 2*x_step;
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - x_step - x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - x_step - x_text; y_pn = y_coor + y_text;}
         
         break;
      }
      case 2 : {
         // Третья метка
         x_pn = x_coor + 2*x_text + 3*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 2*x_step - 2*x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 2*x_step - 2*x_text; y_pn = y_coor + y_text;}

         break;
      }
      case 3 : {
         // Четвертая метка
         x_pn = x_coor + 3*x_text + 4*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 3*x_step - 3*x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_text;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 3*x_step - 3*x_text; y_pn = y_coor + y_text;}
         
         break;
      }
      case 4 : {
         // Пятая метка
         x_pn = x_coor + 4*x_text + 5*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 4*x_step - 4*x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_text;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 4*x_step - 4*x_text; y_pn = y_coor + y_text;}

         break;
      }
      case 5 : {
         // Шестая метка
         x_pn = x_coor + 5*x_text + 6*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 5*x_step - 5*x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 5*x_step - 5*x_text; y_pn = y_coor + y_text;}
         
         break;
      }
      case 6 : {
         // Седьмая метка
         x_pn = x_coor + 6*x_text + 7*x_step; 
         y_pn = y_coor + x_step;
         
         if (InpCorner == 1)  x_pn = x_coor + x_size - 6*x_step - 6*x_text;
         if (InpCorner == 2)  y_pn = y_coor + y_rect;
         if (InpCorner == 3) {x_pn = x_coor + x_size - 6*x_step - 6*x_text; y_pn = y_coor + y_text;}
      
         break;
      }
   }
      
   labels[pos].MoveTo(x_pn, y_pn);     
}


//+----------- Определение направления движения ---------------------+
ENUM_TREND_TYPE GetTrend(int pos, datetime tickTime)
{
   // Print("Определяем тренд у ", pos, " элемента массива");
   
   ENUM_TREND_TYPE result = TREND_NONE; 
   ENUM_TREND_TYPE trend = TREND_NONE;
   ENUM_CHART_PERIOD period;
   bool updated = false;
   datetime now = TimeCurrent();
   
   // Получим текущие значения элементов
   switch (InpType)
   {
      case INDICATOR_PANE : {
         period = panes[pos].GetPeriod();
         trend = panes[pos].GetTrend();
         updated = panes[pos].IsUpdated();
         break;
      }
      case INDICATOR_LABEL : {
         period = labels[pos].GetPeriod();
         trend = labels[pos].GetTrend();
         updated = labels[pos].IsUpdated();
         break;
      }
   }
   
   switch (period)
   {
      case CHART_PERIOD_D1 : {
         // Day
         
         datetime timeOpen = iTime(Symbol(), PERIOD_D1, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_D1);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }
         
         break;
      }
      case CHART_PERIOD_H4 : {
         // H4

         datetime timeOpen = iTime(Symbol(), PERIOD_H4, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_H4);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }
      case CHART_PERIOD_H1: {
         // H1

         datetime timeOpen = iTime(Symbol(), PERIOD_H1, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_H1);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }
      case CHART_PERIOD_M30: {
         // M30

         datetime timeOpen = iTime(Symbol(), PERIOD_M30, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_M30);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }
      case CHART_PERIOD_M15: {
         // M15

         datetime timeOpen = iTime(Symbol(), PERIOD_M15, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_M15);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }
      case CHART_PERIOD_M5: {
         // M5

         datetime timeOpen = iTime(Symbol(), PERIOD_M5, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_M5);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }
      case CHART_PERIOD_M1: {
         // M1

         datetime timeOpen = iTime(Symbol(), PERIOD_M1, 0);
         datetime t = TimeCurrent() - timeOpen; // D'1970.01.01 09:41:30'
         
         //TODO: Срабатывает несколько раз в течение указанного времени, не выплняется условие проверки
         if (t <= D'1970.01.01 00:00:10' && !updated)
         {
            result = FindTrend(CHART_PERIOD_M1);
            updated = true;
            
            if (InpType == INDICATOR_LABEL)
            {
               labels[pos].SetTrend(trend);
               labels[pos].SetUpdated(updated);
            }
            else
            {
               panes[pos].SetTrend(trend);
               panes[pos].SetUpdated(updated);
            }
         }
         else 
         {
            if (t > D'1970.01.01 00:00:10')
            {
               if (InpType == INDICATOR_PANE)
               {
                  panes[pos].SetUpdated(false);
               }
               else if (InpType == INDICATOR_LABEL)
               {
                  labels[pos].SetUpdated(false);
               }
            }
            
            result = trend;
         }

         break;
      }   
   }
   
   return result;
}

// Поиск тренда на заданном периоде графика
ENUM_TREND_TYPE FindTrend(ENUM_CHART_PERIOD period)
{
   ENUM_TREND_TYPE result = TREND_NONE;
   ENUM_TREND_TYPE scale1 = TREND_NONE;
   ENUM_TREND_TYPE scale2 = TREND_NONE;
   ENUM_TREND_TYPE scale3 = TREND_NONE;
   
   switch(period)
   {
      case CHART_PERIOD_D1 : 
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_D1, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_D1, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_D1, SCALE_LARGE);
         }
         
         break;
      }
      case CHART_PERIOD_H4 :
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_H4, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_H4, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_H4, SCALE_LARGE);
         }
         
         //TODO: Определить тренд на основании трех значений
         result = scale1;
         
         break;
      }
      case CHART_PERIOD_H1 :
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_H1, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_H1, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_H1, SCALE_LARGE);
         }
         
         //TODO: Определить тренд на основании трех значений
         result = scale1;
         
         break;
      }
      case CHART_PERIOD_M30 :
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_M30, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_M30, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_M30, SCALE_LARGE);
         }
         
         //TODO: Определить тренд на основании трех значений
         result = scale1;
         
         break;
      }
      case CHART_PERIOD_M15 : 
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_M15, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_M15, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_M15, SCALE_LARGE);
         }
         
         //TODO: Определить тренд на основании трех значений
         result = scale1;
         
         break;
      }
      case CHART_PERIOD_M5 :
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_M5, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_M5, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_M5, SCALE_LARGE);
         }

         //TODO: Определить тренд на основании трех значений
         result = scale1;
         
         break;
      }
      case CHART_PERIOD_M1 :
      {
         // Первый этап - 460 баров
         if (Bars >= 460)
         {
            scale1 = CheckScale(PERIOD_M1, SCALE_SMALL);
         }
         
         // Второй этап - 230 баров
         if (Bars >= 230)
         {
            scale2 = CheckScale(PERIOD_M1, SCALE_MIDDLE);
         }
         
         // Третий этаап - 114 баров
         if (Bars >= 114)
         {
            scale3 = CheckScale(PERIOD_M1, SCALE_LARGE);
         }
         
         //TODO: Определить тренд на основании трех значений
         result = scale1;

         break;
      }
   }
   
   return result;
}

// Определить на сколько процентов перешли ширину диапазона
double Distance(double bid, double low, double high)
{
   double result = 0;
   
   if (bid >= low && bid <= high)
   {
      // Находимся внутри диапазона, 
      // Найдем пройденный путь в процентах от нижней границы даипазона
      // high - low = ширина диапазона
      // bid  - low = текущее положение внутри диапазона
      result = (bid - low) * 100 /  (high - low);      
   }
   else if (bid < low)
   {
      // Находимся ниже канала, 
      // найдем на сколько недошли до нижней границы диапазона
      // High - Low = 100%
      // Low  - Bid = X% 
      result = (low - bid) * 100 / (high - low);
   }
   else
   {
      // Находимся выше канала, 
      // найдем на сколько перешли верхнюю границу диапазона
      // High - Low  = 100%
      // Bid  - High = X% 
      result = (bid - high) * 100 / (high - low);
   }
   
   return result;
}

void CreateRect(string name, string desc, string tooltip, datetime time1, double price1, datetime time2, double price2, color clr)
{
   if (ObjectFind(0, name) >= 0)
   {
      if (!ObjectDelete(0, name))
      {
         int errCode = GetLastError();
         Print("Не удалось удалить границы диапазона [", name, "]: ", errCode);
      }
   }
   else
   {
      Print("Границы диапазона [", name, "] не найдены!");
   }
   
   if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2))
   {
      Print("Не удалось вывести границы диапазона [", name, "]: ", GetLastError());
      ChartRedraw();
   }
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);           // установим цвет прямоугольника 
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);   // установим стиль линий прямоугольника 
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);             // установим толщину линий прямоугольника 
   ObjectSetInteger(0, name, OBJPROP_FILL, false);          // включим (true) или отключим (false) режим заливки прямоугольника 
   ObjectSetInteger(0, name, OBJPROP_BACK, false);          // отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);    // включим (true) или отключим (false) 
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);      // режим выделения прямоугольника для перемещений 
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);        // скроем (true) или отобразим (false) имя графического объекта в списке объектов    
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);            // установим приоритет на получение события нажатия мыши на графике 
   ObjectSetString (0, name, OBJPROP_TEXT, desc);           // установим описание объекта
   ObjectSetString (0, name, OBJPROP_TOOLTIP, tooltip);     // установим всплывающую подсказку
}

// Определение тренда для заданного периода и масштаба
ENUM_TREND_TYPE CheckScale(ENUM_TIMEFRAMES period, ENUM_SCALE_TYPE type)
{
   int barsCount = 0;
   int barsUsed  = 0;
   ENUM_TREND_TYPE result = TREND_NONE;
   int currentPeriod = Period();
   
   switch (type)
   {
      case SCALE_SMALL  : { barsCount = 460; barsUsed = 50; break; }
      case SCALE_MIDDLE : { barsCount = 230; barsUsed = 40; break; }
      case SCALE_LARGE  : { barsCount = 114; barsUsed = 20; break; }
   }

   MqlRates left[];
   MqlRates right[];
   ArraySetAsSeries(left, true);
   ArraySetAsSeries(right, true);
   
   int copyLeft = CopyRates(Symbol(), period, barsCount-barsUsed+1, barsUsed+1, left);
   int copyRight = CopyRates(Symbol(), period, 1, barsUsed+1, right);
   
   if (copyLeft > 0 && copyRight > 0)
   {
      // Проводим анализ первого этапа на M1
      // Находим экстремумы массива слева
      double maxLeft=0;
      double minLeft=0;
      
      for (int i = 0; i < copyLeft; i++)
      {
         if (left[i].high > maxLeft || maxLeft == 0)
            maxLeft = left[i].high;
            
         if (left[i].low < minLeft || minLeft == 0)
            minLeft = left[i].low;
      }
      
      // Находим экстремумы массива справа
      double maxRight=0;
      double minRight=0;

      for (int i = 0; i < copyRight; i++)
      {
         if (right[i].high > maxRight || maxRight == 0)
            maxRight = right[i].high;
            
         if (right[i].low < minRight || minRight == 0)
            minRight = right[i].low;
      }
      
      if (period == currentPeriod && DrawBoxes)
      {
//         color clr = clrBlack;
//   
//         switch (period)
//         {
//            case PERIOD_D1  : { clr = clrRed; break; }
//            case PERIOD_H4  : { clr = clrBlue; break; }
//            case PERIOD_H1  : { clr = clrGreen; break; }
//            case PERIOD_M30 : { clr = clrYellow; break; }
//            case PERIOD_M15 : { clr = clrMaroon; break; }
//            case PERIOD_M5  : { clr = clrCyan; break; }
//            case PERIOD_M1  : { clr = clrOrange; break; }
//         }
   
         // Вывод границ левого диапазона
         datetime timeLeft1 = left[copyLeft-1].time;
         double priceLeft1 = NormalizeDouble(maxLeft, Digits); // Цена максимума
         datetime timeLeft2 = left[0].time;
         double priceLeft2 = NormalizeDouble(minLeft, Digits); // Цена минимума
         
         string name1 = EnumToString(period) + "_" + EnumToString(type) + "_1";
         CreateRect(name1, name1, name1, timeLeft1, priceLeft1, timeLeft2, priceLeft2, clrRed);
         
         // Вывод границ правого диапазона
         datetime timeRight1 = right[copyLeft-1].time;
         double priceRight1 = NormalizeDouble(maxRight, Digits); // Цена максимума
         datetime timeRight2 = right[0].time;
         double priceRight2 = NormalizeDouble(minRight, Digits); // Цена минимума
         
         string name2 = EnumToString(period) + "_" + EnumToString(type) + "_2";
         CreateRect(name2, name2, name2, timeRight1, priceRight1, timeRight2, priceRight2, clrDodgerBlue);
      }
      
      double dist = Distance(Bid, minLeft, maxLeft);
      
      if (dist >= far_dist)
      {
         // Тренд установлен
         if (Bid > maxLeft)
         {
            Print (EnumToString(period), TimeCurrent(), " Вверх: [", minLeft, ":", maxLeft, "]");
            result = TREND_BULLISH;
         }
         else
         {
            Print(EnumToString(period), TimeCurrent(), " Вниз: [", minLeft, ":", maxLeft, "]");
            result = TREND_BEARISH;
         }
      }
      else
      {
         Print (EnumToString(period), TimeCurrent(), " Возможен флет: [", minLeft, ":", maxLeft, "]");
         result = TREND_NONE;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   datetime dt_1     = 0;
   double   price_1  = 0;
   datetime dt_2     = 0;
   double   price_2  = 0;
   int      window   = 0;
   int      x        = 0;
   int      y        = 0;

   // Нажатие на первый прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == "pane_1" || clickedChartObject == "label_1") {
//         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
//         
//         y = y_coor + y_rect + 2*x_step;
//         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
//         
//         y = y_coor + 2*y_rect + 3*x_step;
//         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);
         
         Comment("Нажали на первый индикатор");
         
         // RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_1_cl,rect_1_st,rect_1_wd,false,false,true,InpHidden_OBJ,0);
      }
   }

   // Нажатие на второй прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == "pane_2" || clickedChartObject == "label_2") {
//         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
//         
//         y = y_coor + y_rect + 2*x_step;
//         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
//         
//         y = y_coor + 2*y_rect + 3*x_step;
//         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);
         
         Comment("Нажали на второй индикатор");
         
         // RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_1_cl,rect_1_st,rect_1_wd,false,false,true,InpHidden_OBJ,0);
      }
   }

}

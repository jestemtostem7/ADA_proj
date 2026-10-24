with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Text_IO;

procedure Main is
--DEKLARACJE TYPOW
   type Nazwa_towaru is (
 Klasyczny,
 Proteinowy,
 Bialy
                        );

   type Stan_samochodu is (
                           W_drodze,
                           Czeka,
                           Koniec
                           );

   type Tablica_aktywnosci is array (1 .. 5) of Stan_samochodu;

type Dostawa is record
      Id : Integer;
      Towar : Nazwa_towaru;
      Ilosc : Integer;
   end record;

   --FUNKCJA ZMIANY AKTYWNOSCI (ABY UNIKNAC JEDNOCZESNEGO
   --NADPISYWANIA I ODCZYTYWANIA)

   protected Status_dostaw is
      procedure Ustaw_status(Id : Integer; Stan : Stan_samochodu);
      function Czy_aktywny(Id : Integer) return Stan_samochodu;
      function Czy_koniec return Boolean;
   private
      Aktywnosci : Tablica_aktywnosci := (others => W_drodze);
   end Status_dostaw;

   protected body Status_dostaw is
      procedure Ustaw_status(Id : Integer; Stan : Stan_samochodu) is
      begin
         Aktywnosci(Id) := Stan;
      end Ustaw_status;
      function Czy_aktywny(Id : Integer) return Stan_samochodu is
      begin
         return Aktywnosci(Id);
      end Czy_aktywny;
      function Czy_koniec return Boolean is
         Licznik : Integer := 0;
      begin
         for I in 1 .. 5 loop
            if Aktywnosci(I) = Koniec then
               Licznik := Licznik + 1;
               end if;
         end loop;
         if Licznik = 5 then
            return True;
         else
            return False;
            end if;
         end Czy_koniec;
      end Status_dostaw;

   --LOGIKA ROZLADUNKU

   task Rozladunek is
      entry Nowa_Dostawa(D : Dostawa);
      end Rozladunek;

   task body Rozladunek is

   begin

      loop
         select
            accept Nowa_Dostawa(D : Dostawa) do

                  if Status_dostaw.Czy_aktywny(D.Id) = Czeka then
                 Put_Line("Przyjeto samochod " & Integer'Image(D.Id));
               Put_Line("Zaczeto rozladunek");
                     delay Duration(D.Ilosc);
               Put_Line("Zakonczono rozladunek");
               Status_dostaw.Ustaw_status(D.Id,Koniec);
           end if;
            end Nowa_Dostawa;
         or
              delay 3.0;
               Put_Line("Brak nowych dostaw");
         end select;
         exit when Status_dostaw.Czy_koniec;
      end loop;


      end Rozladunek;

   --SAMOCHODY

   task type Samochod_Type(Id : Integer);

   Samochod1 : Samochod_Type(1);
   Samochod2 : Samochod_Type(2);
   Samochod3 : Samochod_Type(3);
   Samochod4 : Samochod_Type(4);
   Samochod5 : Samochod_Type(5);

   task body Samochod_type is


      --PRZYPISYWANIE DOSTAW

      D : Dostawa;

      subtype Zakres_ilosci is Integer range 1 .. 15;
      package Losowanie_ilosci is
        new Ada.Numerics.Discrete_Random(Zakres_ilosci);
      Gen_ilosci : Losowanie_ilosci.Generator;
      I : Zakres_ilosci;

      package Losowanie_towarow is
        new Ada.Numerics.Discrete_Random(Nazwa_towaru);
      Gen_towarow : Losowanie_towarow.Generator;
      T : Nazwa_towaru;

      subtype Zakres is Integer range 1 .. 10;
      package Losowanie is
        new Ada.Numerics.Discrete_Random(Zakres);
      Gen : Losowanie.Generator;
      X : Zakres;
   begin

      Losowanie_towarow.Reset(Gen_towarow);
      Losowanie_ilosci.Reset(Gen_ilosci);
      Losowanie.Reset(Gen);

      I := Losowanie_ilosci.Random(Gen_ilosci);
      T := Losowanie_towarow.Random(Gen_towarow);
      X := Losowanie.Random(Gen);

      D.Id := Id;
      Status_dostaw.Ustaw_status(Id,W_drodze);
      D.Towar := T;
      D.Ilosc := I;

       --KONIEC PRZYPISYWANIA DOSTAW

      --LOGIKA SAMOCHODOW

      delay Duration(X);
      Status_dostaw.Ustaw_status(Id,Czeka);
      Put_Line("Przyjechal samochod nr " & Integer'Image(Id) & " i jest gotowy na rozladunek");


      select
         Rozladunek.Nowa_Dostawa(D);
      or
           -- MODUL H
         delay 15.0;
         Put_Line("Samochod " & Integer'Image(Id) & " zrezygnowal z oczekiwania");
         Status_dostaw.Ustaw_status(Id,Koniec);
      end select;


   end Samochod_type;






--i w sumie w glownej procedurze nic sie nie dzieje
begin
null;
end Main;

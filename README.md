

# Kalkulator wyrażeń matematycznych (ONP) w asemblerze

* Przygotowany przez Patryka Ludwikowskiego (nr. albumu 117813), testowany przez Alberta Mazura (117816).
* Projekt zaliczeniowy z Architektury Systemów Komputerowych za semestr letni 2022 informatyka drugiego roku na Uniwersytecie Rzeszowskim.



### Założenia

+ Użytkownik podaje wyrażenie matematyczne w postaci tekstowej, w tym: 
	- liczby całkowite lub zmiennoprzecinkowe (oddzielone kropką),
	- z operatorami (`+-*/%^`), 
	- z nawiasami (`()`),
	- z znanymi stałymi matematycznymi (np. `pi`, `euler`),
	- z prostymi funkcjami (np. `abs`, `min`, `max`, `sqrt`, `cbrt`, `sin`, `cos`).
+ Wyrażenie w postaci notacji infiksowej zostanie sparsowane do [Odwrotnej Notacji Polskiej](https://pl.wikipedia.org/wiki/Odwrotna_notacja_polska). Zaletą ONP jest możliwość obliczania wyrażeń, bez informacji o ważności operatorów (priorytetów).
+ Jeśli wyrażenia ma nieznane zmienne, są one wylistowane i później w pętli wczytywane od użytkownika dla obliczania wyników dla różnego zestawu zmiennych.
	- W takim przypadku program zakończy się w przypadku nie podania żadnej wartości (pusta linia lub EOF).
+ Wyrażenie jest obliczane jednokrotnie w przypadku braku zmiennych lub wielokrotnie dla każdego zestawu zmiennych.

- Maksymalna długość wyrażenia jest odgórnie określona (np. 250 znaków).
- Maksymalna długość nazwy funkcji to 9 znaków (dla lepszej struktury w pamięci).
- Nazwy funkcji i zmiennych muszą być alfanumeryczne i mogą zawierać znak podłogi (`[a-zA-Z_][a-zA-Z0-9_]{0,8}`).
- Wielkość znaków dla funkcji i stałych nie jest rozpoznawana, ale jest rozpoznawana dla zmiennych.
- Program jest napisany w architekturze 32 bitowej i używa kilku sztuczek z tym związanych.
- Poprawność wyrażeń nie jest ściśle sprawdzana, ale dla niektórych błędów (np. niedomknięte nawiasy) program powinien zakończyć działanie w poprawny sposób (próba ignorowania błędu lub komunikat i wyjście).
- Przy wypisywaniu reprezentacji ONP, jeśli funkcje pobiera elementy, ma wskazane ile argumentów pobierają poprzez `#n`, np. `min(2, 3, 4)` to `2 3 4 min#3`.



### Przykładowa sesja

```
Podaj wyrazenie: (1/2) * x^2 + 2x + 1
Wyrazenie w ONP: 1 2 / x 2 ^ * 2 x * + 1 +

Podaj x: 4
Wynik: 15

Podaj x: ^Z (EOF)
(koniec)
```



### Struktura kodu

* Stosy

	Ujednolicony stos (tablica z indeksem) składający się z liczb zmiennoprzecinkowych o 64 bitach (`double/f64`).

	Potrzebne do:

	+ parsowania wyrażenia do ONP (stos operatorów i stos wyjściowy),
	+ wykonania ONP (wejście i stos wartości).

	Prosta implementacja stosu będzie miała tablicę (stałą wielkość, dla ułatwienia) i indeks ostatniego elementu stosu.

	Operatory i funkcje będą reprezentowane na wspólnym stosie/tablicy jako [specjalne niestandardowe wartości NaN](https://en.wikipedia.org/wiki/Double-precision_floating-point_format). Niżej w tym pliku jest to bardziej opisane (patrz pseudokody).

	_(pseudokod w C++)_
	```cpp
	struct f64_stack {
		f64 values[255];
		u8 index;
		u8 _pad[7];
	};
	static_assert(sizeof(f64_stack) == 2048);
	```

* Struktury operatorów/funkcji

	Operatory/funkcje będą opisane priorytetem, liczbą argumentów i funkcją do wykonania (adres skoku), który zmodyfikuje odpowiednio stos operacji.

	_(pseudokod w C++)_
	```cpp
	struct f64_stack;
	using stack_applicable_function = void (*)(f64_stack&, u8);

	struct op_def {
		char name[10]; // up to 9 chars + 0 (align 8 bytes)
		u8 priority; // operator priority
		u8 max_args; // max number of args
		stack_applicable_function function;

		bool is_function() const {
			return priority >= 128;
		}
	};
	static_assert(sizeof(op_def) == 16);

	struct special_f64 {
		union {
			f64 as_f64;
			u64 as_u64;
			struct {
				char name[6];
				u16 header;
			};
			struct {
				const op_def* def;
				u8 args;
				u8 flags;
				u16 _header;
			};
		};

		bool is_variable() const {
			return header == (0x7FF8 | 1);
		}
		bool is_function() const {
			return header == (0x7FF8 | 2);
		}
		bool is_bracket() const {
			return header == (0x7FF8 | 3);
		}
	};
	static_assert(sizeof(special_f64) == sizeof(f64));
	```

* Funkcja parsowania do ONP (wypełnia wskazany stos parsując wskazany ciąg znaków).

	[Algorytm z Wikipedii](https://pl.wikipedia.org/wiki/Odwrotna_notacja_polska#Algorytm_konwersji_z_notacji_infiksowej_do_ONP).

	Z drobnymi modyfikacjami, m.in.:

	+ Wartość przed nawiasem/funkcją/stałą/zmienną oznacza mnożenie np. `2(3+4)` to `2 3 4 + *` czyli `14`, lub `2x` to `2 x *`.

* Funkcja wykonywania ONP (przechodzi wskazaną tablicę wykonując kolejne operacje).

	[Algorytm z Wikipedii](https://pl.wikipedia.org/wiki/Odwrotna_notacja_polska#Algorytm_obliczenia_warto%C5%9Bci_wyra%C5%BCenia_ONP).

	+ Funkcje nie są ograniczone do działania przy użyciu zwykłego stosu - teoretycznie mogłyby odwoływać się do całego stosu (a nie tylko szczytu) lub nawet wykonywać dowolny kod.

* Funkcja głowna: wczytanie wejścia, użycie funkcji parsującej, przygotowanie zmiennych (jeśli jakieś), użycie funkcji wykonującej i zwracanie wyniku.



### Testowanie

Dołączony został skrypt w języku JavaScript (NodeJS) do automatycznego testowania. 

Do uruchomieniem wymagane jest zainstalowane środowisko Node ([pobieranie tutaj](https://nodejs.org/en/download/)) oraz następnie jednorazowo zainstalowanie używanych przez skrypt pakietów komendą `npm install` (z linii poleceń w folderze głównym, ze skryptem i plikiem `package.json`).

Po instalacji Node i wymaganych pakietów, można uruchomić test:
```
npm run test
```

Uwaga: Pierwszy w kolejności test przy pierwszym uruchomieniu może zawieść ze względu na ustawienia antywirusa, który może skanować testować działanie nieznanej aplikacji (plik EXE powstały po kompilacji).



### Uwagi

* Lista operatorów: `+-*/%`, `^` (potęga) i `!` (silnia).
* Lista stałych: `pi`, `euler`, `golden`, `inf` (nieskończoność), `unixtime` (obecny czas) i `nr_albumu` (numer albumu autora).
* Lista funkcji: 
	+ `abs(x)`, `sign(x)`, `ceil(x)`, `floor(x)`, `round(x)`,
	+ `min(...)`, `max(...)`, `sum(...)`, `product(...)`, `count(...)` (zliczanie argumentów), `avg(...)`,
	+ `sqrt(x)`, `cbrt(x)`, 
	+ `rad(x)` (konwersja stopni na radiany), `deg(x)` (konwersja radianów na stopnie),
	+ `sin(x)`, `cos(x)`, `tan(x)`, `asin(x)`, `acos(x)`, `atan(x)`, `atan2(x, y)`, 
	+ `exp(x)`, `ln(x)`, `log(x)`, `log(x, base)`, `log10(x)`,
	+ `fib` (Fibonacci, argument zaokrąglany).
- Silnia zaokrągla argument (np. `5!` = 120, ale `5.2!` też jest 120 zamiast 142.451944).



### Inne pomysły

_Różne ciekawe luźne pomysły, które można byłoby zaimplementować dla praktyki, ale są generalnie poza założeniami projektu..._

+ W przypadku wartości bliskich zeru, zaokrąglić do zera, np. `sin(pi)` niech zwraca zero zamiast `1.22461e-016`, dla wygody odczytu.
+ Obsługa liczb `0xABC` (heksadecymalnych), `0b101` (binarnych), `0765` (ósemkowych).
+ Możliwość separowania cyfr liczb, np. `1'000 * 2` da `2000` zamiast błędu przez znak `'`.
+ Operator (lub funkcja?) warunkowy i operatory logiczne, np. `2^(a > b ? 5 : 3)`.
+ Poprawne działanie w przypadku wprowadzenia postaci ONP.
+ Możliwość omijania zmiennej przy podawaniu (używa z poprzedniej pętli). Zakończenie programu przy użyciu EOF lub SIGINT).
+ Przełączniki/argumenty programu, np. `main.exe --step-by-step -e "2+3*4"`.
+ Tryb krok po kroku z komentarzami.
+ Kolory i polskie znaki.
+ Zmienne dłuższe niż 6 znaków (wymaga struktury poza obecnym stosem).
+ Większa dokładność (liczby 128-bitowe).
+ Liczby urojone.
+ Operacje na wektorach (i tablicach?).
+ Duże operatory sumowania i mnożenia, np. `sum(i, 0..4, 2i+1)` (1 + 3 + 5 + 7 + 9 = 25).
+ Możliwość wprowadzania kodów ASCII, np. `'a' + 'b'` równe 97 + 98 czyli 195.
+ Silnia ciągła (dla niecałkowitych wartości).
+ Silnia drugiego stopnia (`n!!` =/= `(n!)!`).
+ Maszyna Turinga:
	* Kilka specjalnych operatorów mogłoby chyba uczynić ewaluator wyrażeń ONP zdolnym do wykonywania dowolnego kodu.
	* Niech `$` będzie stałą wskaźnika odczytu wyrażenia (wstawia swój indeks w wyrażeniu na stos).
	* Niech `get`/`@` kopiuje (na górę stosu) wybraną wartość z stosu (indeks na stosie).
	* Niech `set`/`=` ustawia wybraną wartość na wybranej pozycji na stosie.
	* Niech `go` ustawia wskaźnik odczytu wyrażenia.
	* Przykład dla sprawdzania palindromu:

		_"Kod" w ONP (nieco sformatowane dla czytelności):_
		```log
		0 10 "devil lived"              // Ustawienie zmiennych i danych
		$                               // Pobranie pozycji do 2. skoku 
			0 get 2 + get               // Pobranie wartości wskazanej i
			1 get 2 + get               // Pobranie wartości wskazanej j
			==                          // Sprawdzenie równości
			$ 8 +                       // Przygotowanie skoku prawdy
			$ 35 +                      // Przygotowanie skoku fałszu
			? go                        // Wykonanie warunkowego skoku
				0 0 get 1 + set         // Inkrementacja i
				1 1 get 1 - set         // Dekrementacja j
				0 get 2 +               // Pobranie i
				1 get 2 +               // Pobranie j
				<                       // Sprawdzenie mniejszości
				$ 5 +                   // Przygotowanie skoku fałszu
				? go                    // Wykonanie warunkowego skoku
					1                   // Ustawienie 1 na wyjście
					$ 999 +             // Przygotowanie skoku końca
					go                  // Koniec "programu"
			0                           // Ustawienie 0 na wyjście
			$ 999 +                     // Przygotowanie skoku końca
			go                          // Koniec "programu"
		:
		```

		Oczywiście wartości przesunięć do skoków mogą być niedokładne.

		Krócej (ONP): `0 10 "devil lived" $ 0 get 2 + get 1 get 2 + get == $ 8 + $ 35 + ? go 0 0 get 1 + set 1 1 get 1 - set 0 get 2 + 1 get 2 + < $ 5 + ? go 1 $ 999 + go 0 $ 999 go`



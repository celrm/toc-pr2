LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY cerrojo IS
  PORT (
    rst: IN std_logic;
    clk: IN std_logic;
    boton: IN std_logic;
    entrada: IN std_logic_vector (7 downto 0);
    seg: out  STD_LOGIC_VECTOR (6 downto 0);
    led: out  STD_LOGIC_VECTOR (15 downto 0)
  );
END cerrojo;

ARCHITECTURE cerrojoArch of cerrojo is
component debouncer
  PORT (
    rst: IN std_logic;
    clk: IN std_logic;
    x: IN std_logic;
    xDeb: OUT std_logic;
    xDebFallingEdge: OUT std_logic;
    xDebRisingEdge: OUT std_logic
  );
END component;
component conv_7seg
    Port ( x : in STD_LOGIC_VECTOR (3 downto 0);
           display : out STD_LOGIC_VECTOR (6 downto 0));
end component;

signal clave: std_logic_vector (7 downto 0);
signal ok: std_logic;
signal intentos: STD_LOGIC_VECTOR (3 downto 0);

type estados is (inicial,tres,dos,uno,final);
SIGNAL estado, estado_sig: estados;

BEGIN
comp_deb: debouncer port map (rst, clk, boton, open, ok, open);
comp_num: conv_7seg port map (intentos,seg);

clave <= (others => '0');
ok <= '0';
led <= (others => '1');
intentos <= "0011";

p_estados:
  PROCESS (rst, clk)
  BEGIN
    IF (rst = '1') THEN
      estado <= inicial;
    ELSIF (RISING_EDGE(clk)) THEN
      estado <= estado_sig;
    END IF;
  END PROCESS p_estados;

p_transiciones:
PROCESS (estado,ok,entrada)
BEGIN
estado_sig <= estado; --en caso de que no cambie nada, el estado se mantiene

case estado is
when inicial =>
    if (ok = '1') then
        estado_sig <= tres;
   
        led <= (others => '0');
        clave <= entrada;
        intentos <= "0011";
    end if;
when tres =>
    if (ok = '1') then
        if (clave = entrada) then
            estado_sig <= inicial;
            
            led <= (others => '1');
        else estado_sig <= dos;
            intentos <= std_logic_vector(unsigned(intentos) - 1);
        end if;
    end if;
when dos =>
    if (ok = '1') then
        if (clave = entrada) then
            estado_sig <= inicial;
            
            led <= (others => '1');
        else estado_sig <= uno;      
            intentos <= std_logic_vector(unsigned(intentos) - 1);      
        end if;
    end if;
when uno =>
    if (ok = '1') then
        if (clave = entrada) then
            estado_sig <= inicial;
            
            led <= (others => '1');
        else estado_sig <= final;   
            intentos <= std_logic_vector(unsigned(intentos) - 1);
        end if;
    end if;
when final => 
end case;
END PROCESS p_transiciones;

END cerrojoArch;

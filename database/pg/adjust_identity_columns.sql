DO
$$
DECLARE  
  retorno record;
  sql text;
  valor record;
  saida record;
BEGIN
    for retorno in     
      select table_name from information_schema.columns
      where column_name = 'id' and identity_generation = 'BY DEFAULT'
    loop
        raise notice '%', retorno;
        sql := format ('select max(id) as maior from %s', retorno.table_name);
        execute sql into valor;
        if not valor.maior >= 0 then
          continue;
        end if;
        if length(valor.maior::text) = 0 then
          continue;
        end if;
        raise notice ' - %', valor;
        valor.maior := valor.maior+1;
        -- sql := format ('alter table %s alter column id restart with %s', retorno.table_name, valor.maior);
        /*sql := format ('SELECT setval(pg_get_serial_sequence(%s, %s), %s)', 
                          retorno.table_name, 'id', valor.maior);
        raise notice '|%|', sql;
        perform sql;*/
        select into saida * from setval(pg_get_serial_sequence(retorno.table_name, 'id'), valor.maior);
        raise notice '  --> %', saida;
    end loop;
END
$$
LANGUAGE 'plpgsql';


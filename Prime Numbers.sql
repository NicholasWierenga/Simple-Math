SET SERVEROUTPUT ON;

CREATE TABLE primelist (
    prime NUMBER(6)
);

DROP TABLE primelist;

DECLARE
    primenum   INTEGER(6) := 0;
    primecount INTEGER(6) := 0;
    primelist  VARCHAR2(10000) := 'The primes in this range are: ';
BEGIN
    FOR x IN 1..10000 LOOP
        FOR y IN 2..x LOOP
            IF y = x THEN
                primenum := x;
                primecount := primecount + 1;
                primelist := primelist || primenum || ', '; --adds prime to list
            END IF;

            IF x MOD y = 0 THEN
                EXIT; --to exit the inner loop after a factor of x is found
            END IF;
        END LOOP;
    END LOOP;

    dbms_output.put_line(substr(primelist, 1, length(primelist) - 2) || '.');

END; -- This results in a string with all the prime numbers in the range in it.


--This is the above block, but inserts the list into Primelist instead of a string.

DECLARE
    primenum INTEGER(6) := 0;
BEGIN
    FOR x IN 1..10000 LOOP
        FOR y IN 2..x LOOP
            IF y = x THEN
                primenum := x;
                INSERT INTO primelist VALUES ( primenum );

            END IF;

            IF x MOD y = 0 THEN
                EXIT; --to exit the inner loop after a factor of x is found
            END IF;
        END LOOP;
    END LOOP;
END;

CREATE SEQUENCE seq1 INCREMENT BY 1;

DROP SEQUENCE seq1;

CREATE TABLE primelist (
    prime   NUMBER(6),
    tabrows NUMBER(6) DEFAULT seq1.NEXTVAL
);

DROP TABLE primelist;

DECLARE -- This accomplishes what the above block does, but much slower.
    tableprime INTEGER(6); -- It takes the test number and mods it with previous primes in the table.
    maxrow     INTEGER(6); -- It also uses another collumn with a sequence, so a new table will be needed.
    currrow    INTEGER(6);
BEGIN
    INSERT INTO primelist ( prime ) VALUES ( 2 ); -- We insert the first prime to start
    SELECT seq1.CURRVAL
    INTO currrow
    FROM dual;

    SELECT COUNT(*)
    INTO maxrow
    FROM primelist;

    maxrow := maxrow + currrow;
    FOR n IN 3..10000 LOOP
        SELECT MIN(tabrows)
        INTO currrow
        FROM primelist;

        WHILE currrow < maxrow LOOP
            SELECT prime
            INTO tableprime
            FROM primelist
            WHERE tabrows = currrow;

            IF currrow = maxrow - 1 THEN
                maxrow := maxrow + 1;
                INSERT INTO primelist ( prime ) VALUES ( n );

                EXIT;
            END IF;

            IF n MOD tableprime = 0 THEN
                EXIT;
            END IF;
            currrow := currrow + 1;
        END LOOP;

    END LOOP;

END;

CREATE TABLE primelist (
    prime NUMBER(6)
);

DROP TABLE primelist;

DECLARE -- Below can test for prime using a specific number using values from the table.
    testprime NUMBER(6) := 81;
    primes    NUMBER(6);
BEGIN
    INSERT INTO primelist VALUES ( 0 );

    SELECT MAX(prime)
    INTO primes
    FROM primelist
    WHERE prime IN ( 0, testprime );

    DELETE FROM primelist
    WHERE prime = 0; -- Inserting 0 was only to avoid the null row error.

    IF primes = 0 THEN
        dbms_output.put_line(testprime || ' is not prime.');
    ELSE
        dbms_output.put_line(testprime || ' is prime.');
    END IF;

END;
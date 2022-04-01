SET SERVEROUTPUT ON;

CREATE TABLE primelist (
    prime NUMBER(6)
);

DECLARE -- This finds primes and returns them in a string.
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
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

    dbms_output.put_line(substr(primelist, 1, length(primelist) - 2) || '.');

END; 

--This is the above block, but inserts the list into primelist instead of a string.

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

SELECT prime FROM primelist;

DROP TABLE primelist PURGE;

------------------------------------------------------------------------------

CREATE SEQUENCE seq1 INCREMENT BY 1;

CREATE TABLE primelist (
    prime   NUMBER(6),
    tabrows NUMBER(6) DEFAULT seq1.NEXTVAL
);

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

SELECT prime FROM primelist;

DROP SEQUENCE seq1;

DROP TABLE primelist PURGE;

-------------------------------------------------------------------------------

-- Below is another way of generating primes, but only requires SQL.
-- The idea is the same as above, but it runs much faster.

CREATE TABLE primelist (
    prime NUMBER(6)
);

INSERT INTO primelist ( prime )
    SELECT ROWNUM
    FROM col$ -- Pick some large-rowed table or start cross joining if you need more rows for some reason.
    FETCH FIRST 10000 ROWS ONLY; -- Change to expand range.

DELETE FROM primelist a 
WHERE EXISTS ( -- We use a correlated subquery to delete non-primes.
    SELECT b.prime 
    FROM primelist b
    WHERE mod(a.prime, b.prime) = 0 AND a.prime > b.prime AND b.prime <> 1
) OR a.prime = 1;

SELECT prime FROM primelist;

-- Below can test for prime using a specific number using values from the table.

DECLARE 
    testprime NUMBER(6) := 5;
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

DROP TABLE primelist PURGE;


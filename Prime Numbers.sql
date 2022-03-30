SET SERVEROUTPUT ON;

DECLARE
    primenum     NUMBER(6) := 0;
    primecount   NUMBER(6) := 0;
    primelist    VARCHAR2(10000) := 'The primes in this range are: ';
BEGIN
    FOR x IN 1..10000 LOOP FOR y IN 2..x LOOP
        IF y = x THEN
            primenum := x;
            primecount := primecount + 1;
            primelist := primelist
                         || primenum
                         || ', '; --adds prime to list
        END IF;

        IF x MOD y = 0 THEN
            EXIT; --to exit the inner loop after a factor of x is found
        END IF;
    END LOOP;
    end LOOP;

    dbms_output.put_line(substr(primelist, 1, length(primelist) - 2)
                         || '.');

END; -- This results in a string containing all the prime numbers from the range.

CREATE GLOBAL TEMPORARY TABLE primelist (
    prime NUMBER(6)
);

--This is the above block, but inserts the list into Primelist instead of a string.

DECLARE
    primenum NUMBER(6) := 0;
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

-- Below can test for primes using values from the table.

DECLARE
    testprime   NUMBER(6) := 81;
    primes      NUMBER(6);
BEGIN
    INSERT INTO primelist VALUES ( 0 );

    SELECT
        MAX(prime)
    INTO primes
    FROM
        primelist
    WHERE
        prime IN (
            0,
            testprime
        );

    DELETE FROM primelist
    WHERE
        prime = 0; -- Inserting 0 was only to avoid the null row error.

    IF primes = 0 THEN
        dbms_output.put_line(testprime || ' is not prime.');
    ELSE
        dbms_output.put_line(testprime || ' is prime.');
    END IF;

END;

DROP TABLE primelist;

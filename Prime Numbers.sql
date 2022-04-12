/*
This is my git full of a bunch of methods related to prime numbers.
Many of these are slow, poorly coded, and unnecessarily complicated.
I coded these and maybe I'll try to better them later, but math done 
poorly can still be interesting.
*/

SET SERVEROUTPUT ON;

CREATE TABLE primelist (
    prime NUMBER(6)
);

DECLARE -- This finds primes and returns them in a string.
    primenum   INTEGER(6) := 0;
    primecount INTEGER(6) := 0;
    primelist  VARCHAR2(32767) := 'The primes in this range are: ';
BEGIN
    FOR x IN 1..40000 LOOP
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

-- This is the above block, but inserts the list into primelist instead of a string.
-- It took about a minute to sort through 70000 numbers.

DECLARE
    primenum INTEGER(9) := 0;
BEGIN
    FOR x IN 1..70000 LOOP
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

-- This took about a minute to get through the 17000 numbers.

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
    FOR n IN 3..17000 LOOP
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

-- This was one of the better ones and took about a minute to get through 110k rows. 

CREATE TABLE numlist (
    nums INTEGER
);

INSERT INTO numlist ( nums )
    SELECT ROWNUM
    FROM col$ -- Pick some large-rowed table and cross join to it to itself.
    CROSS JOIN (
        SELECT ROWNUM
        FROM col$
        FETCH FIRST 100 ROWS ONLY)
    FETCH FIRST 110000 ROWS ONLY; 

DECLARE
    prime INTEGER := 0;
BEGIN
    DELETE FROM numlist
    WHERE nums = 1;

    WHILE prime IS NOT NULL LOOP
        
        EXECUTE IMMEDIATE 'DELETE FROM numlist
        WHERE mod(nums, ' || prime || ') = 0 AND ' || prime || ' <> nums'; -- Deletes all numbers that have prime as a factor.

        SELECT MIN(nums)
        INTO prime
        FROM numlist
        WHERE nums > prime; -- We pick the next number in the table, 
                            -- which is prime due to it not being deleted by all previous primes used.

    END LOOP;

END;

SELECT nums AS "Primes"
FROM numlist;

DROP TABLE numlist PURGE;

-------------------------------------------------------------------------------

-- This took about a minute to get through 70000.

CREATE TABLE primelist (
    prime NUMBER(6)
);

INSERT INTO primelist ( prime )
    SELECT ROWNUM
    FROM col$ -- Pick some large-rowed table or start cross joining if you need more rows for some reason.
    FETCH FIRST 70000 ROWS ONLY; -- Change to expand range.

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


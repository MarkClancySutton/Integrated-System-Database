--Creating the users 

-- Create a role called alice
CREATE USER alice WITH PASSWORD 'password';

-- Create a role called bob
CREATE ROLE bob WITH PASSWORD 'password';

-- Create roles connie and dave with LOGIN privilege
CREATE ROLE connie LOGIN PASSWORD 'password';
CREATE ROLE dave LOGIN PASSWORD 'password';

--Create the schema called wonderland and make alice the owner
CREATE SCHEMA wonderland AUTHORIZATION alice;

--Create a role called wonderuser and give them the specified PRIVILEGES
CREATE ROLE wonderuser;
GRANT USAGE ON SCHEMA wonderland TO wonderuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA wonderland TO wonderuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA wonderland GRANT INSERT, UPDATE, DELETE ON TABLES TO wonderuser;

--Make wonderland the default schema for alice 
ALTER ROLE alice SET search_path TO wonderland, public;

--Grant BOB the wonderuser privilage:
GRANT wonderuser TO bob;

--Grant Connie the privilege to create views 
GRANT CREATE VIEW TO connie;

-- Grant Dave the privilages to select from any table
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dave;



-- Create ALICETAB table
CREATE TABLE ALICETAB (
    ALICEID SERIAL PRIMARY KEY
);

-- Insert 5 rows into ALICETAB
INSERT INTO ALICETAB VALUES (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT);
COMMIT;

SELECT * FROM alicetab;

--Bob turn

-- Insert 5 rows into ALICETAB
INSERT INTO ALICETAB VALUES (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT);

-- Delete the first 5 rows from the table
DELETE FROM ALICETAB WHERE ALICEID <= 5;

COMMIT;

-- Grant Connie the ability to insert data into ALICETAB
GRANT INSERT ON ALICETAB TO connie;

--Alice again 
-- Alice needs to grant Connie the permission to create a view
GRANT CREATE ON SCHEMA wonderland TO alice;

--Connie login
-- Query the data in ALICETAB
SELECT * FROM ALICETAB;

-- Create CONNIEVIEW
CREATE VIEW CONNIEVIEW AS
SELECT * FROM ALICETAB WHERE ALICEID > 5;

-- Insert 5 rows into ALICETAB with ALICEID > 5
INSERT INTO ALICETAB (ALICEID) VALUES (6), (7), (8), (9), (10);

-- Allow the user dave to select from CONNIEVIEW
GRANT SELECT ON CONNIEVIEW TO dave;

--Login as dave 
-- Query the data in CONNIEVIEW
SELECT * FROM CONNIEVIEW;

-- Query the data in ALICETAB
SELECT * FROM ALICETAB;

--login as postgress
-- Revoke the insert privilege on all tables from wonderuser
REVOKE INSERT ON ALL TABLES IN SCHEMA wonderland FROM wonderuser;

--part 2 of the lab 

CREATE TABLE PPSNS (
    USERNAME VARCHAR(255),
    PPSN VARCHAR(255)
);

INSERT INTO PPSNS (USERNAME, PPSN) VALUES
('Alice', 'Alice-ppsn'),
('Bob', 'Bob-ppsn'),
('Connie', 'Connie-ppsn'),
('Dave', 'Dave-ppsn');

CREATE ROLE PADMINS;
CREATE ROLE PUSERS;

-- Add Alice to the PADMINS role
GRANT PADMINS TO Alice;

-- Add the other 3 users to the PUSERS role
GRANT PUSERS TO Bob, Connie, Dave;

-- Grant read-only access to PUSERS
GRANT SELECT ON PPSNS TO PUSERS;

-- Grant INSERT, UPDATE, DELETE to PADMINS
GRANT INSERT, UPDATE, DELETE ON PPSNS TO PADMINS;

-- Implement row-level security policy
CREATE POLICY pusers_policy
ON PPSNS
FOR SELECT
USING (USERNAME = current_user);

CREATE POLICY padmins_policy
ON PPSNS
FOR ALL
USING (USERNAME = current_user);

-- Grant usage on the policy to PUSERS and PADMINS
GRANT USAGE ON POLICY pusers_policy, padmins_policy TO PUSERS, PADMINS;

-- Grant select privilege to PADMINS
GRANT SELECT ON PPSNS TO PADMINS;

-- Create a POLICY allowing PPSN-ADMIN to view all rows in the table
CREATE POLICY admin_view_policy
ON PPSNS
FOR SELECT
TO PADMINS
WITH CHECK (true);











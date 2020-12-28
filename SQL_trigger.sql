//SQL TRIGGER

1. CREATE LIVE table

CREATE TABLE product
(
id INT IDENTITY,
name VARCHAR(255)
)

2. CREATE audit trail table

CREATE TABLE productLogs
(
id INT IDENTITY,
docentry INT,
name VARCHAR(255),
operation CHAR(4),
CHECK(operation = 'INS' OR operation='DEL' OR operation='UP')
)


3. create trigger every function on the live table

CREATE TRIGGER trgProductLogs
ON product
AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ACTION CHAR(1)

	--INSERT INTO dbo.productLogs
 --   ( docentry, name, operation )
 --   SELECT id,name,'INS' FROM inserted AS i
 --   UNION ALL
 --   SELECT id,name,'DEL' FROM deleted AS d
 --   UNION ALL
 --   SELECT id,name,'UPD' FROM updat AS u

 SET @ACTION = (CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted)
                     THEN 'U'
                     WHEN EXISTS(SELECT 1 FROM inserted)
                     THEN 'I'
                     WHEN EXISTS(SELECT 1 FROM deleted)
                     THEN 'D'
                     ELSE NULL
 END)
    --SELECT @ACTION

    IF @ACTION = 'I'
    BEGIN
         INSERT INTO dbo.productLogs( docentry, name, operation )
         SELECT id,name,'INS' FROM inserted
    END

    IF @ACTION = 'U'
		BEGIN
				 INSERT INTO dbo.productLogs( docentry, name, operation )
				 SELECT id,name,'UP' FROM inserted
		END

    IF @ACTION = 'D'
    BEGIN
         INSERT INTO dbo.productLogs( docentry, name, operation )
         SELECT id,name,'DEL' FROM deleted
    END

END

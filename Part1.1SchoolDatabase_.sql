CREATE DATABASE School;
USE School;
DROP TABLE Academic;
DROP TABLE SSIS;
DROP TABLE MEFS;

#Creating tables
CREATE TABLE Students(
   ID INT NOT NULL PRIMARY KEY,
   `First Name` VARCHAR(30),
   `Last Name` VARCHAR(30),
    Classroom INT
   );
   
CREATE TABLE Term(
  TermID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  Termname VARCHAR(20)
);

   
CREATE TABLE Academic(
    AcademicID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID INT REFERENCES Students(ID),
    TermID INT REFERENCES Term(TermID),
    `F&P Reading Level` VARCHAR(20),
    `MAP Reading RIT` INT,
    `MAP Reading Percentile` INT,
    `MAP Reading Quintile` VARCHAR(50),
    `MAP Math RIT` INT,
    `MAP Math Percentile` INT,
    `MAP Math Quintile` VARCHAR(50)
   
);


   
CREATE TABLE SSIS(
    SSISID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID INT REFERENCES Students(ID),
    TermID INT REFERENCES Term(TermID),
    `Self-Awareness` INT,
    `Self-Management` INT,
    `Social Awareness` INT,
    `Relationship Skills` INT,
    `Responsible Decision Making` INT,
    `Motivation to Learn` INT
);

   
CREATE TABLE MEFS(
    MEFSID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID INT REFERENCES Students(ID),
    TermID INT REFERENCES Term(TermID),
    `Percentile (National)` INT,
     CHECK (`Percentile (National)`<= 100)
);

CREATE TABLE Attendance(
	AttendanceID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID INT REFERENCES Students(ID),
    `Total Days Attended` INT,
    `Days Absent Due to Illness` INT,
    `Total Days of School` INT

);

INSERT INTO Term VALUES (1, 'Fall'),
						(2, 'Winter');
            
#This view is to find the average MEFS percentile of the top 10 illness absence students
#The purpose is to see does illness absence affecting MEFS percentile.
CREATE VIEW AbsenceMEFS
AS 
SELECT s.`First Name`,s.`Last Name`, `Days Absent Due to Illness`, AVG(`Percentile (National)`) AS AvgPercentile
FROM School.MEFS m
JOIN School.Students s ON m.ID=s.ID
JOIN School.Attendence a ON s.ID=a.ID
GROUP BY s.ID
ORDER BY `Days Absent Due to Illness` DESC
LIMIT 10;

#This view is to find the MEFS percentile Difference for each student from Fall to Winter
CREATE VIEW MEFSDiff
AS
SELECT s.ID,s.`First Name`,s.`Last Name`, s.Classroom, SUM(CASE WHEN TermID=2 THEN `Percentile (National)` ELSE 0 END)-
SUM(CASE WHEN TermID=1 THEN `Percentile (National)` ELSE 0 END) as Difference
FROM School.MEFS m
JOIN School.Students s ON m.ID=s.ID 
GROUP BY s.ID
ORDER BY Difference DESC;

CREATE VIEW AVGImporvMEFS
AS
SELECT t.Classroom, AVG(t.difference) as avg
FROM MEFSDiff as t
GROUP BY t.Classroom;

#Thses two views are built to compare the fall to winter F&P Reading Level improvements

CREATE VIEW FPReading
AS SELECT `F&P Reading Level`,t.TermID, COUNT(ID) as count
      FROM School.Academic ac
      JOIN School.Term t ON ac.TermID=t.TermID
      GROUP BY t.TermID,`F&P Reading Level`;

CREATE VIEW FPReadingTerm
AS
SELECT `F&P Reading Level`,
SUM(CASE WHEN TermID =1 THEN t.count ELSE 0 END) AS Fall,
SUM(CASE WHEN TermID =2 THEN t.count ELSE 0 END) AS Winter
FROM FPReading AS t
GROUP BY `F&P Reading Level`;

CREATE VIEW AvgIncrease
AS
SELECT
(SELECT AVG(`MAP Reading RIT`)
 FROM School.Academic
 WHERE TermId=2) - (SELECT AVG(`MAP Reading RIT`)
 FROM School.Academic
 WHERE TermId=1) AS AVGIncrease;
 
CREATE VIEW AttendanceAcademic
AS
SELECT s.ID, s.`First Name`,s.`Last Name`, s.Classroom,
`Days Absent Due to Illness`, 
(`Total Days of School`-`Days Absent Due to Illness`-`Total Days Attended`) AS OtherAbsent ,
(`Total Days of School`-`Total Days Attended`) AS TotalAbsent,
ROUND((`Total Days Attended`/`Total Days of School`)*100,2) AS AttendenceRate,
(`Percentile (National)`) AS MEFSPercentile, 
`MAP Reading RIT`,(`MAP Reading Quintile`) as RQ, 
`MAP Math RIT`,(`MAP Math Quintile`) as MQ
FROM School.MEFS m
JOIN School.Students s ON m.ID=s.ID
JOIN School.Attendence a ON s.ID=a.ID
JOIN Academic ac ON ac.ID=s.ID
WhERE ac.TermID=2
GROUP BY s.ID
ORDER BY TotalAbsent DESC;


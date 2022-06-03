#The queries below are for the data exploration

#Academic Analysis
#This is to find for each Reading level, the number students changes from Fall to Winter
SELECT `F&P Reading Level`,
SUM(CASE WHEN TermID =1 THEN t.count ELSE 0 END) AS Fall,
SUM(CASE WHEN TermID =2 THEN t.count ELSE 0 END) AS Winter
FROM (SELECT `F&P Reading Level`,t.TermID, COUNT(ID) as count
      FROM School.Academic ac
      JOIN School.Term t ON ac.TermID=t.TermID
      GROUP BY t.TermID,`F&P Reading Level`) as t
GROUP BY `F&P Reading Level`;

#The average MAP Reading RIT increase from Fall to Winter
SELECT
(SELECT AVG(`MAP Reading RIT`)
 FROM School.Academic
 WHERE TermId=2) - (SELECT AVG(`MAP Reading RIT`)
 FROM School.Academic
 WHERE TermId=1) AS AVGIncrease;
#The average MAP Math RIT increase from Fall to Winter
 SELECT
(SELECT AVG(`MAP Math RIT`)
 FROM School.Academic
 WHERE TermId=2) - (SELECT AVG(`MAP Math RIT`)
 FROM School.Academic
 WHERE TermId=1) AS AVGIncrease;
 
 #Here is to find the avergae  MAP Reading RIT by Term and Classroom
 SELECT  a.TermID, s.Classroom, AVG(`MAP Reading RIT`) as avg
   FROM School.Academic a
   JOIN School.Students s ON a.ID=s.ID 
   GROUP BY a.TermID, s.Classroom;
    #Here is to find the avergae  MAP Math RIT by Term and Classroom
 SELECT  a.TermID, s.Classroom, AVG(`MAP Math RIT`) as avg
   FROM School.Academic a
   JOIN School.Students s ON a.ID=s.ID 
   GROUP BY a.TermID, s.Classroom;
 
#MEFS & Attendence Analysis
#Here is to find the average MEFS percentile of the top 10 illness absence students
#The purpose is to see does illness absence affecting MEFS percentile.

SELECT s.`First Name`,s.`Last Name`, `Days Absent Due to Illness`, AVG(`Percentile (National)`) AS AvgPercentile
FROM School.MEFS m
JOIN School.Students s ON m.ID=s.ID
JOIN School.Attendence a ON s.ID=a.ID
GROUP BY s.ID
ORDER BY `Days Absent Due to Illness` DESC
LIMIT 10;

#Here is to find the MEFS percentile Difference for each student from Fall to Winter
SELECT t.Classroom, AVG(t.difference) as avg
FROM(
   SELECT s.ID,s.`First Name`,s.`Last Name`, s.Classroom, SUM(CASE WHEN TermID=2 THEN `Percentile (National)` ELSE 0 END)-
   SUM(CASE WHEN TermID=1 THEN `Percentile (National)` ELSE 0 END) as difference
   FROM School.MEFS m
   JOIN School.Students s ON m.ID=s.ID 
   GROUP BY s.ID
   ORDER BY difference DESC) as t
GROUP BY t.Classroom;

#Here is to find the avergae MEFS percentile by Term and Classroom
 SELECT  m.TermID, s.Classroom, AVG(`Percentile (National)`) as avg
   FROM School.MEFS m
   JOIN School.Students s ON m.ID=s.ID 
   GROUP BY m.TermID, s.Classroom;
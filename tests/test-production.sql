-- 1:
-- Query for finding all the prerequisite courses 
-- We can figure out whether this is an All_of group or One_of group 
--   based on whether the rows belong to the same coursegroupid 
SELECT coursecode, coursegroupid
FROM courseGroupMember
WHERE courseGroupID IN (
    SELECT groupid
    FROM courseGroup
    WHERE groupID IN (
        SELECT prereqcoursegroupid
        FROM prerequisite
        WHERE courseCode = UPPER('cs 488')
    )
);

-- 2
-- Query to get the basic information about a course like title, description, etc
SELECT courseCode,title, courseTypes, description, subjectTitle 
FROM course 
WHERE UPPER(courseCode) = UPPER('cs 488');


-- 3
-- Shows how many times a course is in either spring, fall, or winter
SELECT  termCode, COUNT(*) as TimesOffered
FROM (
    SELECT  termCode % 10 as termCode 
    FROM (
        SELECT DISTINCT termCode FROM courseOffering 
        WHERE courseCode = 'MATH 135' AND courseType = 'LEC') As distinctCourses
) as filterTermCode
GROUP BY termCode
ORDER BY termCode DESC;


-- 4
-- Shows when a course is offered in either F,W,S
-- WITH clause is needed since otherwise we can't filter based on term as term is defined in Select
WITH courseTermData AS
(SELECT DISTINCT CASE
    WHEN termCode % 10 = 9 THEN 'F'
    WHEN termCode % 10 = 5 THEN 'S'
    WHEN termCode % 10 = 1 THEN 'W'
END AS Term, 
CASE
    WHEN termCode % 10 = 9 THEN CONCAT(termCode % 1000 / 10 + 2000,'F')
    WHEN termCode % 10 = 5 THEN CONCAT(termCode % 1000 / 10 + 2000,'S')
    WHEN termCode % 10 = 1 THEN CONCAT(termCode % 1000 / 10 + 2000,'W')
END AS Year
FROM courseOffering 
WHERE courseCode = 'CS 350' AND courseType = 'LEC')
SELECT Term, Year
FROM courseTermData WHERE Term = 'F';


-- 5
-- Given a professor shows how many times he/she teaches in Spring, Winter, Fall
SELECT  termCode,profFirstName, profLastName, COUNT(*) as NumOfTimesTaught
FROM (
    SELECT termCode % 10 as termCode, profFirstName, profLastName
    FROM (
        SELECT DISTINCT termCode as termCode, profFirstName, profLastName
        FROM courseOffering
        WHERE courseCode = 'CS 350' AND courseType = 'LEC'
        AND (profFirstName LIKE '%Lesley%'
        AND profLastName LIKE '%Istead%')
    ) as getDistinctTimesTeach
) as tablewithProfCourseTerm
GROUP BY termCode, profFirstName, profLastName
ORDER BY termCode DESC;


-- 6
-- Shows the total history in which a given prof teaches a given course
SELECT  DISTINCT termCode,courseCode, profFirstName, profLastName
FROM courseOffering 
WHERE courseCode = 'CS 350'
AND (profFirstName LIKE '%Lesley%'
AND profLastName LIKE '%Istead%')
AND courseType = 'LEC'
ORDER BY termCode DESC;


-- 7
-- Shows a List of all the profs that teach a certain course
-- and order them by the number of the number of sections they teach and also show
-- the number of terms in total they taught the course
WITH sectionsProf AS (
    SELECT profFirstName, profLastName, COUNT(*) as sectionsTaught
    FROM courseOffering 
    WHERE courseCode = 'CS 350'
    AND courseType = 'LEC'
    AND profFirstName IS NOT NULL
    AND profLastName IS NOT NULL
    GROUP BY profFirstName, profLastName
),
termsProf AS (
    SELECT profFirstName, profLastName, COUNT(*) as termsTaught
    FROM (
        SELECT DISTINCT termCode, courseCode, profFirstName,profLastName
        FROM courseOffering
        WHERE courseCode = 'CS 350'
        AND courseType = 'LEC'
        AND profFirstName IS NOT NULL
        AND profLastName IS NOT NULL
    ) as distinctprofterms
    GROUP BY profFirstName, profLastName
)
SELECT s.profFirstName, s.profLastName, s.sectionsTaught, t.termsTaught
FROM sectionsProf s LEFT OUTER JOIN termsProf t
ON s.profFirstName = t.profFirstName AND s.profLastName = t.profLastName
ORDER BY s.sectionsTaught DESC;

-- 8
-- Shows what the courses groups (& quantities) are required to satisfy
-- a degree requirement (eg. 'Computer Science').
-- Combines the quantites from coursegroup table to the matching rows
-- in the coursegrouptable which correspond to the degree requirement.
SELECT * FROM 
(SELECT coursecode, coursegroupid AS groupid 
	FROM coursegroupmember 
	WHERE coursegroupid = ANY 
		(SELECT coursegroupid 
			FROM degreerequirement 
			WHERE degreetitle = 'Computer Science')) AS coursecodetogroupid
NATURAL JOIN coursegroup;


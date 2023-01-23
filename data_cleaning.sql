--Preprocessing ball by ball data--

SELECT *
FROM [IPL_Ball-by-Ball_2008-2020]
ORDER BY id,
	inning,
	[over],
	ball;


/*
Adding total balls, runs, runs in last 5 overs 
and wickets in last 5 overs columns as:

- total balls column created using row_number() windows function
    partitioning by id and inning and ordering by over and ball.

- runs column is the cumulative sum of total_runs column ordered
    by total balls column.

- runs is last 5 overs is the sum of total_runs between current ball 
    and 29 preceding balls.

- wickets in last 5 overs is the sum of is_wicket between current ball
    and 29 preceding balls.

Inserting the new data into temp table.
*/

WITH CTE
AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY id,
			inning ORDER BY [over],
				ball
			) total_balls
	FROM [IPL_Ball-by-Ball_2008-2020]
	)
SELECT *,
	SUM(total_runs) OVER (
		PARTITION BY id,
		inning ORDER BY total_balls ROWS 29 PRECEDING
		) last5_runs,
	SUM(total_runs) OVER (
		PARTITION BY id,
		inning ORDER BY total_balls
		) runs,
	SUM(is_wicket) OVER (
		PARTITION BY id,
		inning ORDER BY total_balls ROWS 29 PRECEDING
		) last5_wickets,
	SUM(is_wicket) OVER (
		PARTITION BY id,
		inning ORDER BY total_balls
		) wickets
INTO #ball_by_ball -->temp table
FROM CTE
-- ORDER BY id,
-- 	inning,
-- 	[over],
-- 	ball

--Dropping unwanted columns from temp table--

ALTER TABLE #ball_by_ball

DROP COLUMN batsman,
	non_striker,
	bowler,
	batsman_runs,
	extra_runs,
	total_runs,
	non_boundary,
	is_wicket,
	dismissal_kind,
	player_dismissed,
	fielder,
	extras_type

/*
Adding total runs made in an innings column
and joining it to the temp table based on
id column where innings match
*/

WITH cte
AS (
	SELECT id,
		inning,
		sum(total_runs) total
	FROM [IPL_Ball-by-Ball_2008-2020]
	GROUP BY id,
		inning
	)
SELECT cte.id,
	cte.inning,
	[over],
	batting_team,
	bowling_team,
	total_balls,
	last5_runs,
	runs,
	last5_wickets,
	wickets,
	total
INTO #ball_by_ball_total
FROM #ball_by_ball a
JOIN cte
	ON cte.id = a.id
WHERE cte.inning = a.inning
-- ORDER BY id,
-- 	inning,
-- 	[total_balls]


--Adding date and venue from match data--

SELECT a.id,
	DATE,
	venue,
	a.inning,
	batting_team,
	bowling_team,
	[over],
	runs,
	wickets,
	last5_runs,
	last5_wickets,
	total
FROM #ball_by_ball_total a
JOIN [IPL_Matches_2008-2020] b
	ON a.id = b.id
ORDER BY id,
	inning,
	total_balls

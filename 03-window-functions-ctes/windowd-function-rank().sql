-- rank()
--fetch the top 3 employees in each department earning the max salary
select * from (
select *,
rank() over(partition by dept_name order by salary desc) as rnk   --whenever we use rank()  when it finds a duplicate value it will assign the same rank but for every duplicate record it's going to skip a value
from employees e ) x
where x.rnk<4;

-- dense_rank() : similar to rank() the only differnce between both is that



select *,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk    --whenever we use dense_rank() when it finds a duplicate value it will assign the same rank , and will not skip any value
from employees e 


--RANK() vs DENSE_RANK() Mastery Problems
--Problem 1 (Beginner): Student Grade Rankings
--Scenario: A teacher wants to rank students by their final exam scores. Some students have identical scores, and the teacher needs to decide how to handle ties for scholarship eligibility (top 3 positions).
--What to Show: student_id, student_name, score, and a ranking column. Think about whether gaps in ranking matter for scholarship decisions.


CREATE TABLE student_scores (
    student_id INTEGER,
    student_name VARCHAR(50),
    score INTEGER
);

INSERT INTO student_scores VALUES
(1, 'Alice', 95),
(2, 'Bob', 87),
(3, 'Charlie', 95),
(4, 'Diana', 82),
(5, 'Eve', 87),
(6, 'Frank', 90),
(7, 'Grace', 95),
(8, 'Henry', 78);


select *
,dense_rank() over(order by score desc) as ranking     --in this case ties counts, because they still better then the others the one with score 90 is the second in his class not the forth (based on score)
from student_scores


--Problem 2 (Beginner): Sales Performance Tiers
--Scenario: A company categorizes salespeople into performance tiers (Gold, Silver, Bronze) based on sales amounts. They need consecutive tier assignments without gaps, regardless of ties.
--What to Show: salesperson_id, name, sales_amount, and tier_rank (1=Gold, 2=Silver, 3=Bronze, etc.).

CREATE TABLE sales_performance (
    salesperson_id INTEGER,
    name VARCHAR(50),
    sales_amount DECIMAL(10,2)
);

INSERT INTO sales_performance VALUES
(1, 'John', 125000.00),
(2, 'Sarah', 98000.00),
(3, 'Mike', 125000.00),
(4, 'Lisa', 87000.00),
(5, 'Tom', 125000.00),
(6, 'Amy', 76000.00),
(7, 'David', 98000.00),
(8, 'Emma', 65000.00);

select * from sales_performance

select *,
dense_rank() over(order by sales_amount desc) as tier_drmethod,
case 
	when sales_amount >=125000 then '1'
	when sales_amount between 85000 and 100000 then '2'     --in this case when we want the rankig to be finite , and based on a rule we use case and we add our ranking conditions when condition then value ..... then we add an end in this case i dont know if he ment only 1 , 2 and 3 if he did this is the only approach if he didnt he can cheack the dense_rank() i tried to cover all cases and learned the case end 
	when sales_amount <85000 then '3'
end as SPT_casemethod
from sales_performance
order by sales_amount desc

-- Problem 3 (Intermediate): Tournament Bracket Seeding
-- Scenario: A gaming tournament needs to seed 16 players into brackets. Players with identical scores should get the same seed number, but subsequent seeds must account for the actual number of players ahead of them for bracket positioning.
-- What to Show: player_id, username, score, seed_position. Consider how traditional tournament seeding works.

CREATE TABLE tournament_scores (
    player_id INTEGER,
    username VARCHAR(30),
    score INTEGER
);

INSERT INTO tournament_scores VALUES
(1, 'ProGamer99', 2450),
(2, 'SkillMaster', 2380),
(3, 'ElitePlayer', 2450),
(4, 'GameKing', 2290),
(5, 'TechNinja', 2380),
(6, 'SpeedDemon', 2450),
(7, 'PixelWarrior', 2180),
(8, 'CodeBreaker', 2380),
(9, 'CyberAce', 2100),
(10, 'DataHunter', 2290),
(11, 'LogicBeast', 2050),
(12, 'ByteForce', 2290),
(13, 'NetGhost', 1980),
(14, 'CloudStrike', 2180),
(15, 'FireWall', 1920),
(16, 'SystemHack', 2100);

select * from tournament_scores

select *,
rank() over(order by score desc) as seed
from tournament_scores


--Problem 4 (Intermediate): Product Popularity Categories
--Scenario: An e-commerce platform wants to assign products to popularity categories (Trending, Popular, Standard, Niche) based on view counts. Categories should be consecutive (1,2,3,4) regardless of ties to ensure even distribution across recommendation algorithms.
--What to Show: product_id, product_name, view_count, category_level within each product_category.

CREATE TABLE product_views (
    product_id INTEGER,
    product_name VARCHAR(60),
    product_category VARCHAR(30),
    view_count INTEGER
);

INSERT INTO product_views VALUES
(1, 'Wireless Headphones Pro', 'Electronics', 15000),
(2, 'Smart Fitness Watch', 'Electronics', 12000),
(3, 'Bluetooth Speaker Max', 'Electronics', 15000),
(4, 'Gaming Mouse Elite', 'Electronics', 8000),
(5, 'USB-C Hub Deluxe', 'Electronics', 12000),
(6, 'Portable Charger Ultra', 'Electronics', 6000),
(7, 'Running Shoes Air', 'Sports', 9500),
(8, 'Yoga Mat Premium', 'Sports', 7200),
(9, 'Protein Powder Gold', 'Sports', 9500),
(10, 'Resistance Bands Set', 'Sports', 5800),
(11, 'Water Bottle Steel', 'Sports', 7200),
(12, 'Workout Gloves Pro', 'Sports', 4200);
--like problem 2 , i will do it with case (even if he didnt set limits here and in problem 2 but i will ) and dense_rank and i will also use the when ==> then ==> else  and the least  methods combining dense rank with both of them

select * from product_views

select *,
dense_rank() over(partition by product_category order by view_count desc) as ranking_using_dr,
case 
	when view_count >=12000 then 'Trending'
	when view_count between 9000 and 10000 then 'Popular'
	when view_count between 6000 and 9000 then  'Standard'
	when view_count <6000 then 'Niche'
end as ranking_using_case,
case 
	when dense_rank() over(partition by product_category order by view_count desc) >= 4 then 4
	else dense_rank() over(partition by product_category order by view_count desc)
end as ranking_using_case_and_deskrank,
least(dense_rank() over(partition by product_category order by view_count desc),4) as ranking_using_dens_rank_and_least
from product_views

--Problem 5 (Intermediate): Employee Promotion Rankings
--Scenario: HR is determining promotion order based on performance scores. Employees with identical scores should be considered equally qualified, but the company needs to know exactly how many people are ahead of each employee for budget planning.
--What to Show: employee_id, name, department, performance_score, promotion_rank within each department.

CREATE TABLE employee_performance (
    employee_id INTEGER,
    name VARCHAR(50),
    department VARCHAR(30),
    performance_score DECIMAL(3,1)
);

INSERT INTO employee_performance VALUES
(1, 'Amanda Chen', 'Engineering', 9.2),
(2, 'Marcus Johnson', 'Engineering', 8.7),
(3, 'Sofia Rodriguez', 'Engineering', 9.2),
(4, 'James Wilson', 'Engineering', 8.1),
(5, 'Priya Patel', 'Engineering', 8.7),
(6, 'Alex Thompson', 'Marketing', 8.9),
(7, 'Rachel Green', 'Marketing', 8.3),
(8, 'Daniel Kim', 'Marketing', 8.9),
(9, 'Laura Martinez', 'Marketing', 7.8),
(10, 'Kevin Brown', 'Marketing', 8.3),
(11, 'Emily Davis', 'Sales', 9.1),
(12, 'Michael Taylor', 'Sales', 8.6),
(13, 'Jessica Lee', 'Sales', 9.1),
(14, 'Christopher Clark', 'Sales', 8.2),
(15, 'Ashley White', 'Sales', 8.6);

select * from employee_performance

select *,
rank() over(partition by department order by performance_score desc) as rank_in_department,--the company need to know how many  people are ahead of each employee for budget planning so i added another column ,
rank() over(partition by department order by performance_score desc) -1 as people_ahead       --case end is more for a clear limits , not good with functions and etc , also i learned to make a new column manualy and get to know how to make it (think more and take more time)
from employee_performance


--Problem 6 (Advanced): Movie Awards Voting
--Scenario: Film critics are voting for movie awards. Movies with identical average ratings should receive the same award tier, and the ceremony organizers need consecutive award tiers (Best Picture, Outstanding, Excellent, Good) for presentation flow.
--What to Show: movie_id, title, genre, avg_rating, award_tier within each genre.

CREATE TABLE movie_ratings (
    movie_id INTEGER,
    title VARCHAR(70),
    genre VARCHAR(20),
    avg_rating DECIMAL(3,1)
);

INSERT INTO movie_ratings VALUES
(1, 'The Last Frontier', 'Sci-Fi', 9.1),
(2, 'Midnight in Paris Redux', 'Drama', 8.8),
(3, 'Quantum Paradox', 'Sci-Fi', 8.6),
(4, 'Desert Winds', 'Drama', 9.1),
(5, 'Stellar Odyssey', 'Sci-Fi', 9.1),
(6, 'Broken Mirrors', 'Drama', 8.3),
(7, 'Neon Dreams', 'Sci-Fi', 7.9),
(8, 'Silent Waters', 'Drama', 8.8),
(9, 'Code Red Mission', 'Action', 8.4),
(10, 'Thunder Strike', 'Action', 7.7),
(11, 'Shadow Protocol', 'Action', 8.4),
(12, 'Velocity Chase', 'Action', 8.1),
(13, 'Iron Fortress', 'Action', 7.7),
(14, 'Night Pursuit', 'Action', 8.7);

select * from  movie_ratings

select *,
case dense_rank() over(partition by genre order by avg_rating )
	when 1 then 'Best Picture'
	when 2 then 'Outstanding'                                                   --well well well i cracked it  , we can use the value generated by the dense_rank and use it as a case and deal with the values and return a string they want
	when 3 then 'Excellent'
	when 4 then 'Good'
end as awar_tier
from movie_ratings

--Problem 7 (Advanced): Academic Research Citations Impact
--Scenario: A university is ranking research papers by citation counts for tenure decisions. Papers with identical citations should be considered equally impactful, but the committee needs to understand the actual competitive landscape (how many papers are truly ahead).
--What to Show: paper_id, title, author, citations, impact_rank within each research_field.

CREATE TABLE research_papers (
    paper_id INTEGER,
    title VARCHAR(80),
    author VARCHAR(50),
    research_field VARCHAR(30),
    citations INTEGER
);

INSERT INTO research_papers VALUES
(1, 'Neural Networks in Quantum Computing', 'Dr. Smith', 'Computer Science', 847),
(2, 'Advanced Machine Learning Algorithms', 'Dr. Johnson', 'Computer Science', 623),
(3, 'Blockchain Security Protocols', 'Dr. Lee', 'Computer Science', 847),
(4, 'AI Ethics and Society', 'Dr. Brown', 'Computer Science', 592),
(5, 'Data Mining Techniques', 'Dr. Wilson', 'Computer Science', 623),
(6, 'Cognitive Load in Learning', 'Dr. Davis', 'Psychology', 734),
(7, 'Memory Formation Studies', 'Dr. Miller', 'Psychology', 589),
(8, 'Behavioral Pattern Analysis', 'Dr. Garcia', 'Psychology', 734),
(9, 'Social Psychology Frameworks', 'Dr. Martinez', 'Psychology', 456),
(10, 'Neuroscience Applications', 'Dr. Anderson', 'Psychology', 589),
(11, 'Climate Change Modeling', 'Dr. Taylor', 'Environmental', 912),
(12, 'Renewable Energy Systems', 'Dr. White', 'Environmental', 756),
(13, 'Ocean Acidification Effects', 'Dr. Clark', 'Environmental', 912),
(14, 'Carbon Footprint Analysis', 'Dr. Lewis', 'Environmental', 634),
(15, 'Sustainable Agriculture', 'Dr. Walker', 'Environmental', 756);

select * from research_papers


select *,
rank() over(partition by research_field order by citations desc) as impact_rank,
row_number() over(partition by research_field order by citations desc) as paper_number    --added this for more context
from research_papers



--Problem 8 (Advanced): Stock Portfolio Risk Tiers
--Scenario: A financial advisor is categorizing stocks into risk tiers (Low Risk=1, Medium Risk=2, High Risk=3, etc.) based on volatility scores. Stocks with identical volatility should get the same risk tier, and the tiers must be consecutive for portfolio allocation algorithms.
--What to Show: stock_id, symbol, company_name, volatility_score, risk_tier within each sector.

CREATE TABLE stock_volatility (
    stock_id INTEGER,
    symbol VARCHAR(10),
    company_name VARCHAR(50),
    sector VARCHAR(20),
    volatility_score DECIMAL(4,2)
);

INSERT INTO stock_volatility VALUES
(1, 'TECH1', 'TechGiant Corp', 'Technology', 23.45),
(2, 'TECH2', 'Innovation Labs', 'Technology', 31.78),
(3, 'TECH3', 'Digital Solutions', 'Technology', 23.45),
(4, 'TECH4', 'Cloud Systems Inc', 'Technology', 18.92),
(5, 'TECH5', 'AI Dynamics', 'Technology', 31.78),
(6, 'HLTH1', 'MediCorp International', 'Healthcare', 15.67),
(7, 'HLTH2', 'Pharma Innovations', 'Healthcare', 28.34),
(8, 'HLTH3', 'BioTech Solutions', 'Healthcare', 15.67),
(9, 'HLTH4', 'Medical Devices Co', 'Healthcare', 12.89),
(10, 'HLTH5', 'Health Systems Ltd', 'Healthcare', 28.34),
(11, 'FIN1', 'Global Bank Corp', 'Financial', 19.23),
(12, 'FIN2', 'Investment Group', 'Financial', 25.67),
(13, 'FIN3', 'Credit Solutions', 'Financial', 19.23),
(14, 'FIN4', 'Insurance Giant', 'Financial', 14.78),
(15, 'FIN5', 'Wealth Management', 'Financial', 25.67);

select * from stock_volatility

select  *,
case dense_rank() over(partition by sector order by volatility_score ) 
	when 1 then 'Low Risk'
	when 2 then 'Medium Risk'
	when 3 then 'High Risk'
end as risk_tier
from stock_volatility

--Problem 9 (Expert): Olympic Medal Standings
--Scenario: The Olympics committee is creating official medal standings. Countries with identical medal counts should share the same rank, but the next rank should reflect the actual number of countries that performed better (traditional Olympic ranking system).
--What to Show: country_id, country_name, gold_medals, silver_medals, bronze_medals, total_medals, overall_rank (ranked by total_medals, then gold, then silver).

CREATE TABLE olympic_medals (
    country_id INTEGER,
    country_name VARCHAR(30),
    gold_medals INTEGER,
    silver_medals INTEGER,
    bronze_medals INTEGER,
    total_medals INTEGER
);
INSERT INTO olympic_medals VALUES
(1, 'United States', 23, 19, 17, 59),
(2, 'China', 22, 18, 19, 59),
(3, 'Japan', 17, 14, 12, 43),
(4, 'Germany', 15, 13, 16, 44),
(5, 'Australia', 12, 15, 18, 45),
(6, 'France', 14, 17, 13, 44),
(7, 'Italy', 13, 16, 15, 44),
(8, 'Canada', 11, 14, 20, 45),
(9, 'Great Britain', 16, 12, 15, 43),
(10, 'South Korea', 10, 13, 14, 37),
(11, 'Netherlands', 12, 11, 14, 37),
(12, 'Brazil', 9, 12, 16, 37);

select * from olympic_medals

select *,
rank() over(order by total_medals desc, gold_medals desc, silver_medals desc)   as overall_rank
from olympic_medals

--Problem 10 (Expert): University Department Budget Allocation
--Scenario: A university allocates research funding based on department performance scores. Departments with identical scores should receive the same funding tier, and tiers must be consecutive (Tier 1, Tier 2, Tier 3) for administrative processing, regardless of how many departments tie.
--What to Show: dept_id, department_name, college, performance_score, publication_count, funding_tier within each college.
CREATE TABLE department_performance (
    dept_id INTEGER,
    department_name VARCHAR(40),
    college VARCHAR(30),
    performance_score DECIMAL(4,1),
    publication_count INTEGER
);
INSERT INTO department_performance VALUES
(1, 'Computer Science', 'Engineering', 94.5, 156),
(2, 'Electrical Engineering', 'Engineering', 91.2, 134),
(3, 'Mechanical Engineering', 'Engineering', 94.5, 142),
(4, 'Civil Engineering', 'Engineering', 88.7, 118),
(5, 'Chemical Engineering', 'Engineering', 91.2, 129),
(6, 'Biomedical Engineering', 'Engineering', 87.3, 95),
(7, 'Psychology', 'Liberal Arts', 89.8, 87),
(8, 'English Literature', 'Liberal Arts', 85.4, 62),
(9, 'History', 'Liberal Arts', 89.8, 74),
(10, 'Philosophy', 'Liberal Arts', 82.1, 45),
(11, 'Sociology', 'Liberal Arts', 85.4, 58),
(12, 'Political Science', 'Liberal Arts', 87.6, 69),
(13, 'Biology', 'Sciences', 92.7, 178),
(14, 'Chemistry', 'Sciences', 90.3, 165),
(15, 'Physics', 'Sciences', 92.7, 189),
(16, 'Mathematics', 'Sciences', 88.9, 142),
(17, 'Statistics', 'Sciences', 90.3, 156),
(18, 'Environmental Science', 'Sciences', 86.5, 98);

select * from department_performance

select *,
case dense_rank() over(partition by college order by performance_score desc) 
	 when 1 then 'tier 1'
	 when 2 then 'tier 2'
	 when 3 then 'tier 3'
	 else 'tier 4'
end as funding_tier
from department_performance

--Problem 11 (Expert): Healthcare Quality Rankings
--Scenario: A healthcare network ranks hospitals by patient satisfaction scores. Hospitals with identical scores should receive the same quality rating, but insurance networks need to know the exact competitive position for reimbursement rate negotiations.
--What to Show: hospital_id, hospital_name, region, satisfaction_score, patient_volume, quality_rank within each region.

CREATE TABLE hospital_quality (
    hospital_id INTEGER,
    hospital_name VARCHAR(50),
    region VARCHAR(20),
    satisfaction_score DECIMAL(3,1),
    patient_volume INTEGER
);
INSERT INTO hospital_quality VALUES
(1, 'Metropolitan General', 'Northeast', 4.7, 12500),
(2, 'City Medical Center', 'Northeast', 4.3, 8900),
(3, 'Regional Healthcare', 'Northeast', 4.7, 10200),
(4, 'University Hospital', 'Northeast', 4.1, 15600),
(5, 'Community Health', 'Northeast', 4.3, 6800),
(6, 'St. Mary Medical', 'Northeast', 4.9, 9400),
(7, 'Sunrise Hospital', 'Southeast', 4.5, 11200),
(8, 'Palm Beach Medical', 'Southeast', 4.2, 7800),
(9, 'Coastal Healthcare', 'Southeast', 4.5, 9600),
(10, 'Bay Area General', 'Southeast', 4.8, 13400),
(11, 'Meridian Health', 'Southeast', 4.2, 8700),
(12, 'Atlantic Medical', 'Southeast', 4.6, 10800),
(13, 'Mountain View Hospital', 'West', 4.4, 9800),
(14, 'Desert Springs Medical', 'West', 4.6, 11500),
(15, 'Pacific General', 'West', 4.4, 14200),
(16, 'Valley Healthcare', 'West', 4.1, 7600),
(17, 'Sierra Medical Center', 'West', 4.6, 10400),
(18, 'Sunset Hospital', 'West', 4.3, 8900);

select * from hospital_quality

select *,
rank() over(partition by region order by satisfaction_score desc,patient_volume desc) as quality_rank
from hospital_quality

--Problem 12 (Master): Multi-Criteria Academic Ranking
--Scenario: A graduate school ranks PhD programs using a complex scoring system based on research output, faculty quality, and student outcomes. Programs with identical composite scores should receive the same prestige tier, but the ranking committee needs to understand exactly how many programs are performing better for accreditation purposes.
--What to Show: program_id, program_name, university, research_score, faculty_score, student_score, composite_score, prestige_rank within each field_of_study. Calculate composite_score as: (research_score * 0.4) + (faculty_score * 0.35) + (student_score * 0.25).

CREATE TABLE phd_programs (
    program_id INTEGER,
    program_name VARCHAR(60),
    university VARCHAR(40),
    field_of_study VARCHAR(25),
    research_score DECIMAL(3,1),
    faculty_score DECIMAL(3,1),
    student_score DECIMAL(3,1)
);
INSERT INTO phd_programs VALUES
(1, 'Computer Science PhD', 'MIT', 'Technology', 9.5, 9.2, 8.8),
(2, 'Computer Science PhD', 'Stanford', 'Technology', 9.3, 9.4, 9.1),
(3, 'Computer Science PhD', 'Carnegie Mellon', 'Technology', 9.4, 9.0, 8.9),
(4, 'Artificial Intelligence PhD', 'UC Berkeley', 'Technology', 9.2, 9.1, 8.7),
(5, 'Data Science PhD', 'Harvard', 'Technology', 8.9, 9.3, 9.0),
(6, 'Cybersecurity PhD', 'Georgia Tech', 'Technology', 8.7, 8.8, 8.6),
(7, 'Molecular Biology PhD', 'Harvard Medical', 'Life Sciences', 9.6, 9.4, 8.9),
(8, 'Neuroscience PhD', 'Johns Hopkins', 'Life Sciences', 9.4, 9.2, 9.1),
(9, 'Genetics PhD', 'UCSF', 'Life Sciences', 9.5, 9.1, 8.8),
(10, 'Immunology PhD', 'Rockefeller', 'Life Sciences', 9.2, 9.5, 9.0),
(11, 'Biochemistry PhD', 'Caltech', 'Life Sciences', 9.1, 9.3, 8.7),
(12, 'Cell Biology PhD', 'Yale', 'Life Sciences', 8.9, 9.0, 8.9),
(13, 'Theoretical Physics PhD', 'Princeton', 'Physical Sciences', 9.7, 9.6, 8.8),
(14, 'Particle Physics PhD', 'CERN-affiliated', 'Physical Sciences', 9.5, 9.4, 8.6),
(15, 'Astrophysics PhD', 'Harvard-Smithsonian', 'Physical Sciences', 9.4, 9.2, 8.9),
(16, 'Quantum Physics PhD', 'MIT', 'Physical Sciences', 9.3, 9.5, 8.7),
(17, 'Materials Science PhD', 'Northwestern', 'Physical Sciences', 9.0, 8.9, 8.8),
(18, 'Chemistry PhD', 'Caltech', 'Physical Sciences', 9.2, 9.1, 8.9);

select * from phd_programs

select *,(research_score * 0.4) + (faculty_score * 0.35) + (student_score * 0.25) as composite_score,
rank() over (partition by field_of_study order by ((research_score * 0.4) + (faculty_score * 0.35) + (student_score * 0.25)) desc ) as prestige_rank
from phd_programs

/*
📚 Key Learning Reinforcement
When to Use RANK():

Traditional competitive scenarios (Olympics, tournaments, academic standings)
When you need to know exactly how many are ahead (budget planning, resource allocation)
Fair competition where gaps matter (promotion order, reimbursement negotiations)

When to Use DENSE_RANK():

Categorical assignments (tiers, award levels, grades)
When you need consecutive numbering (algorithms, administrative processing)
Equal recognition scenarios (scholarships, awards where ties deserve equal treatment)

💡 Professional Development Notes
Strengths to Build On:

Business thinking - You consistently considered real-world implications
Technical creativity - Multiple solution approaches show depth
Pattern recognition - You identified when similar techniques apply
Documentation - Your comments show clear reasoning

Areas for Growth:

Read requirements more carefully - Some solutions solved different problems than asked
Question assumptions - When unsure, think about the business impact of your choice

🎖️ Final Thoughts
You've shown excellent analytical instincts and are clearly thinking like a data professional. The mistakes you made are actually good mistakes - they show you're experimenting and pushing boundaries rather than just memorizing syntax.
Your breakthrough moment was Problem 6 where you combined DENSE_RANK() with CASE - that's the kind of creative problem-solving that makes senior analysts valuable.
Next steps:

Practice reading business requirements more slowly
Always ask "What would the end user do with this ranking?"
Continue experimenting with different approaches - your creativity is your strength!

Grade breakdown:

Technical execution: 85/100
Business logic: 80/100
Creativity/Problem-solving: 95/100
Code quality: 85/100    
i just need to learn more how businesses think but i got the basics i can move forward , in the end i am not a data analyst , i am a Data Engineer hihi >0<*/
/*CREATE TABLE employees (
    emp_id INTEGER,
    emp_name CHARACTER VARYING(50),
    dept_name CHARACTER VARYING(50),
    salary INTEGER
);*/

/*INSERT INTO employees (emp_id, emp_name, dept_name, salary) VALUES
(101, 'Mohan', 'Admin', 4000),
(102, 'Rajkumar', 'HR', 3000),
(103, 'Akbar', 'IT', 4000),
(104, 'Dorvin', 'Finance', 6500),
(105, 'Rohit', 'HR', 3000),
(106, 'Rajesh', 'Finance', 5000),
(107, 'Preet', 'HR', 7000);*/

/*INSERT INTO employees (emp_id, emp_name, dept_name, salary) VALUES
(108, 'Sneha', 'Admin', 4500),
(109, 'Vikram', 'IT', 4800),
(110, 'Priya', 'Finance', 6200),
(111, 'Arjun', 'HR', 3200),
(112, 'Kiran', 'IT', 4600),
(113, 'Neha', 'Admin', 4100),
(114, 'Suresh', 'Finance', 5800),
(115, 'Anita', 'HR', 3400),
(116, 'Ravi', 'IT', 5000),
(117, 'Meera', 'Admin', 4300),
(118, 'Hari', 'Finance', 5900),
(119, 'Sunil', 'HR', 3600),
(120, 'Lakshmi', 'IT', 4700),
(121, 'Deepak', 'Admin', 4200),
(122, 'Shalini', 'Finance', 6300),
(123, 'Vijay', 'HR', 3800),
(124, 'Pooja', 'IT', 4900);*/

SELECT * FROM employees;



select max(salary) as the_rich_one,dept_name from employees
group by (dept_name)


select e.*,max(salary) over(partition by dept_name) as max_salary from employees as e;
/*    Row number     */ 


select e.*, row_number()  over(partition by dept_name) as rn
from employees e;

/*
Does OVER() make the window?
Yes, exactly. The OVER() clause is the command that defines how to build that window.

Think of it like this:

ROW_NUMBER() is the what (what action to perform).

OVER(...) is the how and where (how to build the window for the action).

An empty OVER() means the window is the entire result set.

Does PARTITION BY make multiple windows?
Yes, absolutely. This is the perfect way to think about it.

The PARTITION BY clause splits the entire result set into multiple, smaller, independent windows (partitions) based on unique values in a column.

Let's use your example: OVER(PARTITION BY dept_name)

The database takes all employee rows.

It sees PARTITION BY dept_name.

It creates a separate window for each distinct department:

One window containing all 'Admin' rows

One window containing all 'IT' rows

One window containing all 'Finance' rows

One window containing all 'HR' rows

The ROW_NUMBER() function then runs separately and completely independently inside each of these windows. It starts counting from 1 inside the 'Admin' window, then when it moves to the 'IT' window, it resets the counter and starts over at 1. */

-- fetch the first 2 employees from each department to join the company 

select * from (
select e.*, row_number()  over(partition by dept_name order by emp_id) as rn  
from employees e) x   --result table will be named x 
where x.rn <3;

----------------------------------

--Problem 1 (Easy): Customer Order Tracking

--Scenario: E-commerce company tracking order sequence by date to identify first buyers.
--What to Show: Display all orders with order_id, customer_name, order_date, and a column showing their sequence based on order_date.

CREATE TABLE orders (
    order_id INTEGER,
    customer_name VARCHAR(50),
    order_date DATE
);

INSERT INTO orders (order_id, customer_name, order_date) VALUES
(1, 'Alice', '2025-01-01'),
(2, 'Bob', '2025-01-02'),
(3, 'Charlie', '2025-01-03'),
(4, 'David', '2025-01-04'),
(5, 'Eve', '2025-01-05'),
(6, 'Frank', '2025-01-06'),
(7, 'Grace', '2025-01-07'),
(8, 'Henry', '2025-01-08'),
(9, 'Ivy', '2025-01-09'),
(10, 'Jack', '2025-01-10');
select * from orders



select *,row_number() over(order by order_date desc)     --learned that i can put order by in the over() i putted it outside and was not good (6/10)
from orders


--Problem 2 (Medium-Easy): Warehouse Stock Levels

--Scenario: Retail chain checking stock levels per warehouse to prioritize restocking low items.
--What to Show: Display all items with item_id, warehouse, stock_quantity, and a column showing their order within each warehouse based on stock_quantity.

select * from warehouse_stock


select *,row_number() over(partition by warehouse order by stock_quantity desc)    --8/10 – Solid approach, just needs aliasing.
from warehouse_stock

--Problem 3 (Medium): Sports Tournament Results

--Scenario: Sports tournament ordering teams by points per match, using time for tiebreaks.
--What to Show: Display all results with match_id, team_name, points, match_time, and a column showing their order within each match based on points and match_time.


CREATE TABLE tournament_results (
    match_id INTEGER,
    team_name VARCHAR(50),
    points INTEGER,
    match_time TIME
);

INSERT INTO tournament_results (match_id, team_name, points, match_time) VALUES
(1, 'Team Alpha', 10, '14:00:00'),
(1, 'Team Beta', 10, '14:05:00'),
(1, 'Team Gamma', 8, '14:10:00'),
(2, 'Team Delta', 12, '15:00:00'),
(2, 'Team Epsilon', 9, '15:05:00'),
(2, 'Team Zeta', 9, '15:10:00'),
(3, 'Team Eta', 11, '16:00:00'),
(3, 'Team Theta', 7, '16:05:00'),
(4, 'Team Iota', 13, '17:00:00'),
(4, 'Team Kappa', 10, '17:05:00'),
(5, 'Team Lambda', 8, '18:00:00'),
(5, 'Team Mu', 14, '18:05:00'),
(6, 'Team Nu', 9, '19:00:00'),
(7, 'Team Xi', 12, '20:00:00'),
(8, 'Team Omicron', 11, '21:00:00'),
(9, 'Team Pi', 10, '22:00:00'),
(10, 'Team Rho', 13, '23:00:00');
select * from tournament_results


select *,row_number() over(partition by match_id order by points desc,match_time)
from tournament_results      --8.5/10 – Very good, just needs aliasing.
--Problem 4 (Medium-Hard):

--Scenario: Tech conference ranking speakers by duration per session, only for sessions after 2025-06-01 with duration > 45 minutes.
--What to Show: Display relevant sessions with session_id, speaker_name, duration, session_date, and a column showing their order within each session based on duration.
CREATE TABLE speaker_sessions (
    session_id INTEGER,
    speaker_name VARCHAR(50),
    duration INTEGER,
    session_date DATE
);

INSERT INTO speaker_sessions (session_id, speaker_name, duration, session_date) VALUES
(1, 'Dr. Smith', 60, '2025-05-15'),
(1, 'Prof. Johnson', 50, '2025-05-15'),
(2, 'Ms. Lee', 70, '2025-06-10'),
(2, 'Mr. Kim', 55, '2025-06-10'),
(3, 'Dr. Patel', 40, '2025-06-20'),
(3, 'Prof. Garcia', 65, '2025-06-20'),
(4, 'Ms. Wong', 80, '2025-07-01'),
(4, 'Mr. Chen', 45, '2025-07-01'),
(5, 'Dr. Martinez', 55, '2025-07-15'),
(5, 'Prof. Rodriguez', 75, '2025-07-15'),
(6, 'Ms. Hernandez', 50, '2025-08-01'),
(7, 'Mr. Lopez', 90, '2025-08-10'),
(8, 'Dr. Gonzalez', 60, '2025-09-01'),
(9, 'Prof. Wilson', 70, '2025-09-05'),
(10, 'Ms. Anderson', 40, '2025-09-10'),
(11, 'Mr. Thomas', 85, '2025-10-01'),
(12, 'Dr. Taylor', 65, '2025-10-05');

select * from speaker_sessions


select *,
row_number() over(partition by session_id) 
from speaker_sessions     						--7/10 – Good filtering, but misses the per-session ranking intent , the scenario is tricky a little bit that why i forget to add the  "partition by session_id" also the lack of data means lack of seeing cases ,and that will make the query worse
where session_date>'2025-06-01' and duration > 45
--Problem 5 (Hard)

--Scenario: HR reviewing employee scores per department, including average tenure per department.
--What to Show: All employees with order within their department and average tenure; columns: emp_id, department, score, tenure_years, order_in_dept, avg_tenure.

CREATE TABLE performance_metrics (
    emp_id INTEGER,
    department VARCHAR(50),
    score INTEGER,
    tenure_years INTEGER
);

INSERT INTO performance_metrics (emp_id, department, score, tenure_years) VALUES
(101, 'Engineering', 95, 5),
(102, 'Engineering', 88, 3),
(103, 'Marketing', 92, 4),
(104, 'Marketing', 85, 2),
(105, 'Sales', 90, 6),
(106, 'Sales', 87, 1),
(107, 'Engineering', 93, 7),
(108, 'Marketing', 89, 5),
(109, 'Sales', 91, 4),
(110, 'Engineering', 86, 2),
(111, 'Marketing', 94, 3),
(112, 'Sales', 84, 8),
(113, 'Engineering', 96, 4),
(114, 'Marketing', 83, 1),
(115, 'Sales', 89, 5),
(116, 'Engineering', 92, 6),
(117, 'Marketing', 90, 7),
(118, 'Sales', 88, 3),
(119, 'Engineering', 85, 2),
(120, 'Marketing', 91, 4);


select * from performance_metrics

select *,row_number() over(partition by department order by score desc) as order_in_dept ,avg(tenure_years) over(partition by department) as avg_tenure
from performance_metrics      --7.5/10 – Strong concept, but needs proper aliasing.

--Problem 6 (Advanced)

--Scenario: Library analyzing reservations by date per genre, selecting the first 3 per genre for restocking priority.
--What to Show: The selected reservations with order within each genre; columns: reservation_id, book_genre, reservation_date, reservation_fee, order_in_genre.

CREATE TABLE book_reservations (
    reservation_id INTEGER,
    book_genre VARCHAR(50),
    reservation_date DATE,
    reservation_fee DECIMAL(5,2)
);

INSERT INTO book_reservations (reservation_id, book_genre, reservation_date, reservation_fee) VALUES
(1, 'Fiction', '2025-01-10', 5.00),
(2, 'Fiction', '2025-01-15', 4.50),
(3, 'Non-Fiction', '2025-01-20', 6.00),
(4, 'Non-Fiction', '2025-01-25', 5.50),
(5, 'Mystery', '2025-02-01', 4.00),
(6, 'Mystery', '2025-02-05', 5.00),
(7, 'Fiction', '2025-02-10', 6.50),
(8, 'Non-Fiction', '2025-02-15', 4.75),
(9, 'Mystery', '2025-02-20', 5.25),
(10, 'Fiction', '2025-03-01', 5.75),
(11, 'Non-Fiction', '2025-03-05', 6.25),
(12, 'Mystery', '2025-03-10', 4.25),
(13, 'Fiction', '2025-03-15', 5.50),
(14, 'Non-Fiction', '2025-03-20', 6.00),
(15, 'Mystery', '2025-03-25', 4.75),
(16, 'Fiction', '2025-04-01', 5.25),
(17, 'Non-Fiction', '2025-04-05', 5.75),
(18, 'Mystery', '2025-04-10', 6.50),
(19, 'Fiction', '2025-04-15', 4.50),
(20, 'Non-Fiction', '2025-04-20', 5.00),
(21, 'Mystery', '2025-04-25', 6.00),
(22, 'Fiction', '2025-05-01', 4.75),
(23, 'Non-Fiction', '2025-05-05', 5.50),
(24, 'Mystery', '2025-05-10', 6.25),
(25, 'Fiction', '2025-05-15', 4.25);

select * from book_reservations 

select * from 
(select b.*, row_number() over (partition by book_genre order by reservation_date asc) as rn
from book_reservations b) as x     --10/10 – Excellent work!
where x.rn <4
/*
ROW_NUMBER() is mostly used to assign a unique sequential number to rows within a result set, making it ideal for scenarios requiring ordered rankings or pagination. It’s commonly applied in:Order Tracking: Sequencing transactions or events (e.g., customer orders by date).
Data Analysis: Ranking within groups (e.g., employees by score per department).
Pagination: Selecting top N rows per category (e.g., top 3 reservations per genre).
Reporting: Identifying sequence in time-based or performance data (e.g., tournament results).
*/
    -- #################    DONE  ####################### 
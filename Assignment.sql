create database SQL_assigemet;
use classicmodels;
select * from employees;

# Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

# a.Fetch the employee number, first name and last name of those employees
# who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)

select employeeNumber,
	firstName,
    lastName
    from employees
    where ( select e.emp_name as employee,
              m.emp_name as manager
              from employees e 
              left join manager m
              on e.manager_id = m.emp_id );
              
    #          b.	Show the unique productline values containing the word cars at the end from the products table.
    
    
    select distinct productLine from products
    where productLine like "%Cars";
    
    # Q2. CASE STATEMENTS for Segmentation
    
    # Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
     
					 #    "North America" for customers from USA or Canada
                     #   "Europe" for customers from UK, France, or Germany
                      #  "Other" for all remaining countries
                      
                      
                      select * from customers;
                      
                      select distinct country from customers;
                      alter table customers drop region ;
                      
                      select customer_id,
                             customerName,
                             case
                                 when country in ("USA","Canada") then "North America "
								 when country in ("France", "UK", "Germany") then "Europe"
                                 else "others"
                                 end as "customerSegment"
                                 from customers;
                                 
                                 select * from orderdetails;
                                 
# Q3. Group By with Aggregation functions and Having clause, Date and Time functions 

# a.Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity
# across all orders.

select sum(quantityOrdered) as total_Ordered,
           ProductCode 
from orderdetails
group by ProductCode
order by max(total_Ordered) desc limit 10;

select ProductCode ,
sum(quantityOrdered) as total_Ordered
from orderdetails
group by ProductCode
order by total_Ordered desc limit 10;

select * from payments;
-- b.	Company wants to analyse payment frequency by month.
--  Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20.
--  Sort the results by total number of payments in descending order.  (Refer Payments table). 

select monthname(paymentDate) as payment_month,
count(customerNumber) as num_payment
from payments
group by monthname(paymentDate)
having count(customerNumber) > 20
order by count(customerNumber) desc;

select * from customers;
select * from orders;

# Q.5 a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

select (c.country) as country,
       count(o.OrderNumber) as Order_Count
       from customers c
       inner join
       orders o 
       on c.customer_id = o.customer_id
       group by c.country
       order by count(o.OrderNumber) desc limit 5;
       
       # Q6. SELF JOIN
       
       create table projects(
       EmployeeID int primary key auto_increment,
       Fullname varchar(50) not null,
       Gender enum("Male","Female"),
       Manager_id int
       );
       describe projects;
       
       insert into projects values(1,"Pranaya","Male",3),
                                   (2,"Priyanka","Female",1),
                                   (3,"Preety","Female",Null),
                                   (4,"Anurag","Male",1),
                                   (5,"Sambit","Male",1),
                                   (6,"Rajesh","Male",3),
                                   (7,"Hina","Female",3);
                                   
             select * from projects;            
             
             select m.Fullname as Manager_name,
                    e.Fullname as Employee_name
                    from projects m
                    inner join projects e
                    on e.Manager_id  = m.employeeid   ;  
                    
        # DDL Commands: Create, Alter, Rename
        
      create table facility(
      facility_ID int,
      Name varchar(100),
      state varchar(100),
      Country varchar(100)
	);
    
       alter table facility modify facility_ID int auto_increment primary key;
      
      alter table facility add city varchar(100) not null after name;
      describe facility;
      
# Q.8 Views in SQL

select * from products;
select * from productlines;
select * from orders;
select * from orderdetails;
	

create view product_category_sales  as
select p1.productline,
       sum(od.quantityOrdered * od.priceEach) as total_sales,
       count(distinct o.ordernumber) as number_of_orders
       from productlines p1 
       inner join products p 
       on p.productline = p1.productline
       inner join orderdetails od
       on od.productcode  = p.productcode
       inner join orders o
       on o.orderNumber = od.orderNumber
       group by p1.productline;
       
       select * from product_category_sales;
       
       select * from customers;
       select * from payments;
       
# Q.9 Stored Procedures in SQL with parameters

delimiter //

create procedure Get_country_payments(in  in_year int, in in_country varchar(50))
select year(p.paymentDate) as payment_year,
c.country,
round(sum(p.amount)/1000,0) as total_amount_K
from payments p
inner join customers c on
c.customer_id = p.customerNumber
where year(p.paymentDate) = 2003
and c.country = "France"
group by year(p.paymentDate),c.country;
               end //
               
               call Get_country_payments(2003,"France");
               
  # Q.10 . Window functions - Rank, dense_rank, lead and lag

-- a) Using customers and orders tables, rank the customers based on their order frequency

select * from customers;
select * from orders;

select customer_id,
customerName,
order_count,
rank() over(order by order_count desc) as rank_orders,
dense_rank() over(order by order_count desc) as dense_rank_orders
from
(select c.customer_id,
c.customerName,
count(o.orderNumber) as order_count
from customers c
inner join orders o on
c.customer_id = o.customer_id
group by c.customer_id,c.customerName)
as t;

select * from orders;
select year(orderDate) as Year,
month(orderDate) as Month,
count(orderNumber) as total_orders,


SELECT
    order_year,
    order_month,
    order_count,
    CONCAT(
        ROUND(
            (order_count - prev_year_count) * 100.0 / NULLIF(prev_year_count, 0),
        0), '%') AS yoy_change
FROM (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        TO_CHAR(order_date, 'Mon') AS order_month,
        COUNT(order_id) AS order_count,
        LAG(COUNT(order_id)) OVER (
            PARTITION BY TO_CHAR(order_date, 'Mon')
            ORDER BY EXTRACT(YEAR FROM order_date)
        ) AS prev_year_count
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date), TO_CHAR(order_date, 'Mon')
) t
ORDER BY order_month, order_year;

select * from products;
select * from productline;

select * from products;

-- Q11.Subqueries and their applications

-- a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

select
productline,
count(*) as product_count
 from products
where buyprice > (select avg(buyprice) from products)
group by productline;








-- Q12. ERROR HANDLING in SQL
create table emp_eh (
emp_id int primary key,
EmpName varchar(50),
emailaddress varchar(50)
);

delimiter //

create procedure Insert_Emp_EH(
in p_emp_id int,
in p_EmpName varchar(100),
in p_EmailAddress varchar(100)
)
begin
    declare exit handler for sqlexception
    begin
    
    rollback;
    select 'Error occured'  as message ;
    end ;
    
    start transaction;
     insert into emp_eh (EmpID,EmpName,EmailAddress)
     values( p_EmpID, p_EmpName , p_EmailAddress );
     commit;
     end //
     delimiter ;

call Insert_emp_eh (101,'John Doe','john@example.com');
call Insert_emp_eh (101,'John Doe','Jane@example.com');

-- Q13. TRIGGERS
-- Create the table Emp_BIT. Add below fields in it.


create table emp_bit (
name varchar(50),
Occupation varchar(50),
Working_date date,
Working_hours int
);

insert into emp_bit values
               ("Robin","Scientist","2020-10-04",12),
               ("Warner","Engineer","2020-10-04",10),
               ("Peter","Actor","2020-10-04",13),
               ("Macro","Doctor","2020-10-04",14),
               ("Brydon","Teacher","2020-10-04",12),
               ("Antonio","Business","2020-10-04",11);
               
               describe emp_bit;
               select * from emp_bit;
       delimiter //     
       create trigger try_before_insert_empbit
       before insert on emp_bit
       for each row
       begin
                if NEW.Working_hours < 0 then 
                   set NEW.Working_hours = ABS(NEW.working_hours);
                 END if ;
	end //
                 
                 delimiter //
                 
                 insert into emp_bit values("Alex","Teacher","2020-10-04",-4);
                 select * from emp_bit where name = "Alex";
                 
			
         drop table if exists emp_bit ; 
         drop trigger if exist emp_bit;
 

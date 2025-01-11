USE vbay
GO
--Looking at all the tables to get familiar

--All bids
select * 
from vb_bids;

--Item types lookup table
select * 
from vb_item_types_lookup;

--All items
select * 
from vb_items;

--Rating type lookup table
select * 
from vb_rating_astypes_lookup;

--All user ratings
select *
from vb_user_ratings;

--All users
select *
from vb_users;

--All user zip_codes
select *
from vb_zip_codes;

--Filter to only show collectables
select * from vb_items
    where item_type='Collectables';


--Columns that should be projected
select item_name, item_type, item_reserve, item_soldamount
    from vb_items
    where item_type='Collectables';

--Sort output by item_name
select item_name, item_type,item_reserve, item_soldamount
    from vb_items
    where item_type='Collectables'
    order by item_name;

--QUERY 2:SELLERS OF ANTIQUES
--All items
select * from vb_items;

--All users
select * from vb_users;

--Join vb_items and vb_users tables to determine which emails belong to sellers of antiques
select s.*, i.*
    from vb_items as i 
        join vb_users as s
        on i.item_seller_user_id = s.user_id;


--Filter rows to only show antiques while joining the same tables as above
select s.*, i.*
    from vb_items as i 
        join vb_users as s 
        on i.item_seller_user_id = s.user_id
    where i.item_type='Antiques';

--Only project columns we need
select s.user_email, s.user_firstname, s.user_lastname, i.item_type, i.item_name
    from vb_items as i 
    join vb_users as s
    on i.item_seller_user_id = s.user_id
where i.item_type = 'Antiques';

--QUERY 3: SELLER'S REPORT
--All items
select * from vb_items;

--All users
select * from vb_users;

--Join vb_items and vb_users twice to identify sellers and buyers
select *
from vb_items as i 
    join vb_users as s on s.user_id = i.item_seller_user_id
    join vb_users as b on b.user_id = i.item_buyer_user_id;

--Where only sold items
select * 
    from vb_items as i 
        join vb_users as s on s.user_id = i.item_seller_user_id
        join vb_users as b on b.user_id = i.item_seller_user_id
    where i.item_sold = 1;

--Project only columns needed
select s.user_email as sellers_email,
    b.user_email as buyers_email,
    i.item_soldamount - i.item_reserve as item_margin,
    i.*
    from vb_items as i 
        join vb_users as s on s.user_id = i.item_seller_user_id
        join vb_users as b on b.user_id = i.item_seller_user_id
    where i.item_sold = 1;

--Sort with highest margin first 
select s.user_email as sellers_email,
    b.user_email as buyers_email,
    i.item_soldamount - i.item_reserve as item_margin,
    i.*
    from vb_items as i 
        join vb_users as s on s.user_id = i.item_seller_user_id
        join vb_users as b on b.user_id = i.item_buyer_user_id
    where i.item_sold = 1
    order by item_margin DESC;

    --1. Sales woud like to send mailings to users who live in a zip code that starts with '13', for example 13244, so they can be notified of their new contact in that region.
    select * 
    from vb_users 
    where user_zip_code like '13%';

    --2. Find all users from state of NY. Print their names, emails, city, state and zipcode.  Sort by city, then user's last/first name
    select u.user_email, u.user_firstname, u.user_lastname, z.zip_city, z.zip_state, z.zip_code
    from vb_users as u
        join vb_zip_codes as z on u.user_zip_code = z.zip_code
    where z.zip_state = 'NY'
    order by z.zip_city, u.user_lastname, u.user_firstname;

    --Items that have not sold with reserve higher than 250
    select item_id, item_name, item_type, item_reserve
    from vb_items
    where item_sold = 0 
        AND item_reserve >= 250
    order by item_reserve DESC;

    --Reserve item categories, do not include all other and add column 250 or more "high-priced item"; 50 or less "low-priced item"; everything else "average-priced item"
    select item_id, item_name, item_type, item_reserve,
        case when item_reserve >= 250 then 'high-priced item'
            when item_reserve <=50 then 'low-priced item'
            else 'average-priced item'
            end as item_reserve_category
    from vb_items
    where NOT item_type = 'All Other';

    --Valid user bids with status 'ok'
    select b.bid_id, b.bid_item_id, u.user_firstname, u.user_lastname, u.user_email, bid_datetime, b.bid_amount, b.bid_status
    from vb_bids as b
        join vb_users as u 
            on b.bid_user_id = u.user_id
    where b.bid_status='ok'
    order by bid_datetime DESC;

--Bad bidder list
select b.bid_datetime,u.user_firstname, u.user_lastname, u.user_email, u.user_id, i.item_name, i.item_id, b.bid_amount, b.bid_status
from vb_bids as b
    join vb_users as u 
        on b.bid_user_id = u.user_id
    join vb_items as i 
        on b.bid_item_id = i.item_id   
where NOT bid_status= 'ok'
order by u.user_lastname, u.user_firstname, b.bid_datetime;

--items with no bids
select i.item_id,i.item_name, i.item_type,i.item_reserve, b.bid_status, concat(u.user_firstname, ' ', u.user_lastname) as seller_name
from vb_items i 
    left join vb_bids b 
        on i.item_id= b.bid_item_id
    join vb_users u
        on i.item_seller_user_id=u.user_id
where b.bid_status IS null;

--seller ratings

select concat(g.user_firstname, ' ', g.user_lastname) as rating_giver, concat(t.user_firstname, ' ', t.user_lastname) as person_rated, 
r.rating_value, rating_comment, r.rating_astype
from vb_user_ratings r
    join vb_users g
        on r.rating_by_user_id = g.user_id
    join vb_users t 
        on r.rating_for_user_id = t.user_id
where r.rating_astype='Seller';

--item sold with buyer and seller info
select i.item_id, i.item_name, i.item_type, i.item_soldamount, concat(s.user_firstname, ' ', s.user_lastname) as seller_name,
concat(sz.zip_city,' ', sz.zip_state) as seller_city_state, concat(b.user_firstname, ' ', b.user_lastname) as buyer_name,
concat(bz.zip_city, ' ', bz.zip_state) as buyer_city_state
from vb_items i 
    join vb_users s 
        on i.item_seller_user_id=s.user_id
    join vb_users b 
        on i.item_buyer_user_id=b.user_id
    join vb_zip_codes sz 
        on s.user_zip_code=sz.zip_code
    join vb_zip_codes bz
        on b.user_zip_code=bz.zip_code;

--users with no activity
select u.user_firstname, u.user_lastname, u.user_email, bi.item_buyer_user_id,si.item_seller_user_id, bd.bid_user_id
from vb_users u
    left join vb_items si
        on si.item_seller_user_id=u.user_id
    left join vb_items bi
        on bi.item_buyer_user_id=u.user_id
    left join vb_bids bd
        on bd.bid_user_id=u.user_id
where bi.item_buyer_user_id is null
    and si.item_seller_user_id is null
    and bd.bid_user_id is null;

/*For all items, include the name of the item, the reserve price, the lowest bid, highest bid, and sold amount. 
Put the items with the largest reserve first.*/
--tables to be used
select *
from vb_items;
select * 
from vb_bids;
--join tables
select * 
from vb_items
    join vb_bids on item_id=bid_item_id;
--only valid bids
select * 
from vb_items
    join vb_bids on item_id=bid_item_id
where bid_status ='ok';
--group min and max bids sorted by desc
select item_name, item_reserve, min(bid_amount) as min_bid,
    max(bid_amount) as max_bid, item_soldamount
from vb_items 
    join vb_bids on item_id=bid_item_id
where bid_status = 'ok'
group by item_name, item_reserve, item_soldamount
order by item_reserve desc;

--Classify users based on valid bids
--look at both tables that will be used
select * from vb_users;
select * from vb_bids;

--left join from users to bids to see which users have no bids
select *
    from vb_users s 
        left join vb_bids b 
            on b.bid_user_id = s.user_id;

--filter to obtain only valid bids
select *
    from vb_users s 
        left join vb_bids b 
            on b.bid_user_id = s.user_id
    where b.bid_status = 'ok';

--show info with a count of bids including rows with nulls
select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts
    from vb_users s 
        left join vb_bids b 
            on b.bid_user_id=s.user_id
    where b.bid_status = 'ok'
    group by s.user_email, s.user_firstname, s.user_lastname;

--Create cases (categories) based on activity
select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts,
    case when count(*) between 0 and 1 then 'Low'
        when count(*) between 2 and 4 then 'Moderate'
        else 'High' end as user_bid_activity
    from vb_users s
        left join vb_bids b 
            on b.bid_user_id=s.user_id
    where b.bid_status = 'ok'
    group by s.user_email, s.user_firstname, s.user_lastname;

    --For Activity report, use previous query as the table  using with
    with user_bids as (
        select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts,
    case when count(*) between 0 and 1 then 'Low'
        when count(*) between 2 and 4 then 'Moderate'
        else 'High' end as user_bid_activity
    from vb_users s
        left join vb_bids b 
            on b.bid_user_id=s.user_id
    where b.bid_status = 'ok'
    group by s.user_email, s.user_firstname, s.user_lastname
    )
    select * from user_bids;

    --group by user bid activity and count rows
    with user_bids as (
        select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts,
    case when count(*) between 0 and 1 then 'Low'
        when count(*) between 2 and 4 then 'Moderate'
        else 'High' end as user_bid_activity
    from vb_users s
        left join vb_bids b 
            on b.bid_user_id=s.user_id
    where b.bid_status = 'ok'
    group by s.user_email, s.user_firstname, s.user_lastname
    )
    select user_bid_activity, count(*) as user_count
    from user_bids
    group by user_bid_activity;

    --sort by user_count
    with user_bids as (
        select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts,
    case when count(*) between 0 and 1 then 'Low'
        when count(*) between 2 and 4 then 'Moderate'
        else 'High' end as user_bid_activity
    from vb_users s
        left join vb_bids b 
            on b.bid_user_id=s.user_id
    where b.bid_status = 'ok'
    group by s.user_email, s.user_firstname, s.user_lastname
    )
    select user_bid_activity, count(*) as user_count
    from user_bids
    group by user_bid_activity
    order by user_count;

--collectables sorted by item names
select item_name, item_type, item_reserve, item_soldamount
    from vb_items
    where item_type='Collectables'
    order by item_name;

----------HOMEWORK QUESTIONS----------------  
/*how many item types are there? For each item type, provide the count of items,in that type, the min, average and max item reserve prices for that type. 
 Sort output by item type*/
select 
    item_type, 
    count(item_type) as count_item_type, 
    min(item_reserve) as min_item_reserve, 
    AVG(item_reserve) as average_item_reserve , 
    max(item_reserve) as max_item_reserve
from vb_items
group by item_type 
order by item_type;

/*Perform an analysis of each item in the “Antiques” and “Collectables” item types. For each item, display the name, item type, and item reserve. 
Include the minimum, maximum, and average item reserve over each item type so that the current item reserve can be compared to these values.*/

select item_name, item_type, item_reserve,
    min(item_reserve) over (partition by item_type) as min_item_reserve,
    max(item_reserve) over (partition by item_type) as max_item_reserve,
    avg(item_reserve) over (partition by item_type) as avg_item_reserve 
from vb_items
where item_type in ('Antiques', 'Collectables');

/*query to include the names, counts (number of ratings), and average seller ratings (as a decimal) of users. For reference, User Carrie Dababbi 
has four seller ratings and an average rating of 4.75. */

select u.user_firstname, u.user_lastname, 
    count(*) as count_seller_ratings, 
    avg(cast(rating_value as decimal(3,2))) as avg_seller_rating
from vb_user_ratings r 
    join vb_users u 
        on r.rating_for_user_id=u.user_id
where rating_astype = 'Seller'
Group by u.user_firstname, u.user_lastname;

/*Create a list of “Collectable” item types with more than one bid. Include the name of the item and the number of bids, making sure the item with the most bids appear first.*/
select i.item_name, count(*) as count_bids, i.item_type
    from vb_items i 
        join vb_bids b on 
            i.item_id=b.bid_item_id
where item_type = 'Collectables'
group by i.item_name, i.item_type
having count(*) > 1
order by count(*) desc;

/*Generate a valid bidding history for any given item of your choice. Display the item ID, item name, a number representing the order the bid was placed, 
the bid amount, and the bidder’s name.*/

select 
     i.item_id, i.item_name, row_number () over (order by b.bid_datetime) as bid_order, b.bid_amount, 
    u.user_firstname + ' ' + u.user_lastname as bidder
from vb_bids b
    join vb_items i on 
    b.bid_item_id=i.item_id
    join vb_users u on 
    b.bid_user_id = u.user_id
where bid_item_id = 36;

/*Rewrite your query in the previous question to include the names of the next and previous bidders, like this example, 
again showing the first three bids for item 11.*/
select 
     i.item_id, i.item_name, 
     row_number () over (order by b.bid_datetime) as bid_order, 
     b.bid_amount,
     lag(u.user_firstname + ' ' + u.user_lastname) over (order by b.bid_datetime) as prev_bidder,
     u.user_firstname + ' ' + u.user_lastname as bidder,
     lead(u.user_firstname + ' ' + u.user_lastname) over (order by b.bid_datetime) as next_bidder
from vb_bids b
    join vb_items i on 
    b.bid_item_id=i.item_id
    join vb_users u on 
    b.bid_user_id = u.user_id
where bid_item_id = 36;

/*Find the names and emails of the users who give out the worst ratings (lower than the overall average rating) to either buyers or sellers 
(no need to differentiate whether the user rated a buyer or seller), and include only those users who have submitted more than one rating.*/

with rating_info as (
select u.user_firstname + ' ' + u.user_lastname as rater, u.user_email, r.rating_value, count(*) as count_of_ratings,
    avg(r.rating_value) over () as avg_overall_rating
from vb_user_ratings r 
    join vb_users u 
    on r.rating_by_user_id = u.user_id
group by u.user_firstname + ' ' + u.user_lastname, u.user_email, r.rating_value
having count(*) >1
)
select *
from rating_info
where rating_value < avg_overall_rating
order by rating_value;

/*Produce a report of the KPI (key performance indicator) user bids per item. Show the user’s name and email, total number of valid bids, 
total count of items bid upon, and then the ratio of bids to items. As a check, Anne Dewey’s bids per item ratio is 1.666666.*/

select 
u.user_firstname + ' ' + u.user_lastname as bidder_name, u.user_email, b.bid_status, 
count(*) as bid_count,
count(distinct i.item_name) as count_items,
cast(count(*) as decimal(3,2))/cast(count(distinct i.item_name) as decimal (3,2)) as ratio_bid_to_item
from vb_users u
    join vb_bids b 
        on u.user_id=b.bid_user_id
    join vb_items i
        on b.bid_item_id = i.item_id
where bid_status = 'ok'
group by u.user_firstname + ' ' + u.user_lastname,u.user_email, b.bid_status;

/*Among items not sold, show highest bidder name and the highest bid for each item. Make sure to include only valid bids.*/

with bid_info as (
select i.item_id, i.item_name, u.user_firstname + ' ' + u.user_lastname as high_bidder, b.bid_amount,
row_number() over(partition by i.item_id order by b.bid_amount desc) as bid_ranking
from vb_bids b
    join vb_items i 
        on b.bid_item_id=i.item_id
    join vb_users u 
        on u.user_id=b.bid_user_id
        where i.item_sold = 0 and b.bid_status='ok'
)  
select 
    item_id, item_name, high_bidder, bid_amount
from bid_info
where bid_ranking = 1;

/*Write a query with output similar to Question 3, but also includes the overall average seller 
rating and the difference between each user’s average rating and the overall average.
 For reference, the overall average seller rating should be 3.2.*/

with avg_seller_rating as (
    select u.user_firstname + ' ' + u.user_lastname as rater, 
        avg(cast(rating_value as decimal(3,2))) over(partition by u.user_firstname, u.user_lastname) as avg_seller_rating,
        avg(cast(rating_value as decimal(3,2))) over () as overall_avg_seller_rating
    from vb_user_ratings r 
        join vb_users u 
            on r.rating_for_user_id=u.user_id
    where rating_astype = 'Seller'
)
select distinct(rater), avg_seller_rating, overall_avg_seller_rating, 
    avg_seller_rating-overall_avg_seller_rating as diff_from_overall_rate_avg
from avg_seller_rating;
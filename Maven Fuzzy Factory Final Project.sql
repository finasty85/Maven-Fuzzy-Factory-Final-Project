-- Maven Fuzzy Factory Final Project.
-- In this project we are asked to determine different factors to see the overall growth in the company since its inception. 

-- Part 1 volume growth for sessions and orders trended by quarter for the life of the business
-- We can determine that per quarter orders has increased overall since inception

Select
    quarter(website_sessions.created_at) per_quarter_time,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
from website_sessions
left join orders
	on orders.website_session_id = website_sessions.website_session_id
group by year(website_sessions.created_at),1;

-- Part 2 show quartly figures since we launched, session-to-order conversion rate, revenue per order, revenue per session

-- We need to get the per quarter time, the conversion of orders to sessions, the total revenue divided by the orders to get the revenue per order, total revenue divided by all of the sessions to get revenue per session. 
-- We will have to left join on orders to determine the sessions and the matching orders.

select
    quarter(website_sessions.created_at) per_quarter_time,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rt,
    sum(orders.price_usd)/count(distinct orders.order_id) as rev_per_order,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as rev_per_session
from website_sessions
left join orders
	on orders.website_session_id = website_sessions.website_session_id
group by year(website_sessions.created_at),1;

-- part 3 could you pull a quarterly view of orders from gsearch non prand, bsearch nonbrand, brand search, organic search and direct type in?

-- Step 1: Get specific search type data.

select distinct
	utm_source,
    utm_campaign,
    http_referer
from website_sessions;

-- Step 2: Determine inner subquery. Select the created at, website session id and use the case function to get each search type.
-- Step 3: Determine outer subquery. Select the timeframe, count each order and use the pivot method to count each search type. Left join with the orders table to determine which search type has an order. 

select
quarter(sessions_w_channel_group.created_at) as per_quarter,
count(distinct orders.order_id) as orders,
count(case when channel_group = 'gsearch_nonbrand' then orders.order_id else null end) as to_gsearch_nonbrand,
count(case when channel_group = 'bsearch_nonbrand' then orders.order_id else null end) as to_bsearch_nonbrand,
count(case when channel_group = 'brand_search_overall' then orders.order_id else null end) as to_brand_search_overall,
count(case when channel_group = 'organic_search' then orders.order_id else null end) as to_organic_search,
count(case when channel_group = 'direct_type_in' then orders.order_id else null end) as to_direct_type_in
from
(select
	created_at,
    website_session_id,
    case
		when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
        when utm_source is null and http_referer is null then 'direct_type_in'
        when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then 'gsearch_nonbrand'
        when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then 'bsearch_nonbrand'
        when utm_campaign = 'brand' then 'brand_search_overall'
	end as channel_group
from website_sessions) as sessions_w_channel_group
left join orders
	on orders.website_session_id = sessions_w_channel_group.website_session_id
group by year(sessions_w_channel_group.created_at),1;
	
-- part 4 show the overall session-to-order conversion rate trends for those same channels, by quarter. Please make note of any periods where we made improvements or optimizations.

-- Using the same data as above just adding in a conversion rate per each search type.

select
quarter(sessions_w_channel_group.created_at) as per_quarter,
count(distinct orders.order_id) as orders,
count(case when channel_group = 'gsearch_nonbrand' then orders.order_id else null end)/
	count(case when channel_group = 'gsearch_nonbrand' then sessions_w_channel_group.website_session_id else null end) as gearch_nonbrand_conv_rt,
count(case when channel_group = 'bsearch_nonbrand' then orders.order_id else null end)/
	count(case when channel_group = 'bsearch_nonbrand' then sessions_w_channel_group.website_session_id else null end) as bearch_nonbrand_conv_rt,
count(case when channel_group = 'brand_search_overall' then orders.order_id else null end)/
	count(case when channel_group = 'brand_search_overall' then sessions_w_channel_group.website_session_id else null end) as brand_search_overall_conv_rt,
count(case when channel_group = 'organic_search' then orders.order_id else null end)/
	count(case when channel_group = 'organic_search' then sessions_w_channel_group.website_session_id else null end) as organic_search_conv_rt,
count(case when channel_group = 'direct_type_in' then orders.order_id else null end)/
	count(case when channel_group = 'direct_type_in' then sessions_w_channel_group.website_session_id else null end) as direct_type_in_conv_rt
from
(select
	created_at,
    website_session_id,
    case
		when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
        when utm_source is null and http_referer is null then 'direct_type_in'
        when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then 'gsearch_nonbrand'
        when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then 'bsearch_nonbrand'
        when utm_campaign = 'brand' then 'brand_search_overall'
	end as channel_group
from website_sessions) as sessions_w_channel_group
left join orders
	on orders.website_session_id = sessions_w_channel_group.website_session_id
group by year(sessions_w_channel_group.created_at),1;

-- gsearch has stayed steady, bsearch, brand, organic and direct have gone up overall. 

-- part 5 Let's pull monthly trending for revenue and margin by product along with total sales and revenue. Note anything you see about seasonality.

-- Sum each product using the pivot method by seeing trends in their revenue and margins. Also, sum the price_usd column to determine total revenue and sum the price_usd minus the cost of goods to determine the total margin 

Select
	year(created_at) as yr,
    month(created_at) as mo,
    sum(case when product_id = 1 then price_usd else null end) as mrfuzzy_rev,
    sum(case when product_id = 1 then price_usd-cogs_usd else null end) as mrfuzzy_margin,
    sum(case when product_id = 2 then price_usd else null end) as lovebear_rev,
    sum(case when product_id = 2 then price_usd-cogs_usd else null end) as lovebear_margin,
    sum(case when product_id = 3 then price_usd else null end) as birthdaybear_rev,
    sum(case when product_id = 3 then price_usd-cogs_usd else null end) as birthdaybear_margin,
    sum(case when product_id = 4 then price_usd else null end) as minibear_rev,
    sum(case when product_id = 4 then price_usd-cogs_usd else null end) as minibear_margin,
    sum(price_usd) as total_revenue,
    sum(price_usd-cogs_usd) as total_margin
from order_items
group by 1,2
order by 1,2;


-- See overall growth in all products MoM. See greater growth durning the holidays and a decline, but still growth, after the holidays.

-- Part 6 Please pull monthly sessions to the /products page and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved.

-- Step 1: Create a temp table with just the pageviews where the pageview url is '/products'

drop table if exists product_pageviews;
Create temporary table product_pageviews
Select
	website_session_id,
    website_pageview_id,
    created_at as saw_product_page_at
from website_pageviews
where pageview_url = '/products';

/*Step 2: Determine the click through rate and the conversion to order rate. Need to left join on our temp table with the website pageviews and the orders tables. Also need to ensure the website pageview id from website pageviews 
is greater than our temp table website pageview id. This will determine our next clicked page.*/ 

select
	year(saw_product_page_at) as yr,
    month(saw_product_page_at) as mo,
    count(distinct product_pageviews.website_session_id) as sessions_to_product_page,
    count(distinct website_pageviews.website_session_id) as clicked_to_next_page,
    count(distinct website_pageviews.website_session_id)/count(distinct product_pageviews.website_session_id) as clickthrough_rt,
    count(distinct orders.order_id)/
		count(distinct product_pageviews.website_session_id) as conv_product_to_order
from product_pageviews
left join website_pageviews
	on website_pageviews.website_session_id = product_pageviews.website_session_id
    and website_pageviews.website_pageview_id> product_pageviews.website_pageview_id
left join orders
	on orders.website_session_id = product_pageviews.website_session_id
    
    group by 1,2;

-- Part 7 We made our 4th product available December 5th 2014. It was previously a cross sell item. Could you please pull sales data since then, and show how well each product cross-sells from one another

-- Step 1: Create temp table to pull relevant product data from December 5th 2014.

drop table if exists primary_products;
create temporary table primary_products
select
	order_id as ordered_products,
    primary_product_id,
    created_at as ordered_at
from orders
where created_at > '2014-12-05';

-- Step 2: Determine inner subquery. Get all data from primary products temp table along with the cross sell product ID from the order items table. Left join on order id and ordered products and also making sure the ordered item has a cross sold product.

select
	primary_products.*,
    order_items.product_id as cross_sell_product_id
from primary_products
left join order_items
	on order_items.order_id = primary_products.ordered_products
    and order_items.is_primary_item = 0;

-- Step 3: Determine the outer subquery. Use the pivot method to show all 4 products and their cross sell rate with each other.

select
	primary_product_id,
    count(distinct ordered_products) as total_orders,
	count(case when cross_sell_product_id = 1 then ordered_products else null end) as cross_sell1,
    count(case when cross_sell_product_id = 1 then ordered_products else null end)/
		count(distinct ordered_products) as cross_sell1_rt,
    count(case when cross_sell_product_id = 2 then ordered_products else null end) as cross_sell2,
    count(case when cross_sell_product_id = 2 then ordered_products else null end)/
		count(distinct ordered_products) as cross_sell2_rt,
    count(case when cross_sell_product_id = 3 then ordered_products else null end) as cross_sell3,
    count(case when cross_sell_product_id = 3 then ordered_products else null end)/
		count(distinct ordered_products) as cross_sell3_rt,
    count(case when cross_sell_product_id = 4 then ordered_products else null end) as cross_sell4,
    count(case when cross_sell_product_id = 4 then ordered_products else null end)/
		count(distinct ordered_products) as cross_sell4_rt
from(
select
	primary_products.*,
    order_items.product_id as cross_sell_product_id
from primary_products
left join order_items
	on order_items.order_id = primary_products.ordered_products
    and order_items.is_primary_item = 0) as crossed_items
    group by 1;
